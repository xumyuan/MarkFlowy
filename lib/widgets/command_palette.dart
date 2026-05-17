/// 命令面板 Widget
/// 参考: marktext/src/renderer/src/components/commandPalette/index.vue
///
/// 类似 VS Code 的命令面板:
/// - Ctrl/Cmd+Shift+P 打开
/// - 搜索框 + 命令列表
/// - 模糊搜索匹配
/// - 显示命令名称和对应快捷键
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/shortcut_service.dart';

/// 命令面板可见性 Notifier
class _CommandPaletteVisibleNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;
  void hide() => state = false;
  void toggle() => state = !state;
}

/// 命令面板可见性 Provider
final commandPaletteVisibleProvider =
    NotifierProvider<_CommandPaletteVisibleNotifier, bool>(
  _CommandPaletteVisibleNotifier.new,
);

/// 命令面板 Widget
class CommandPalette extends ConsumerStatefulWidget {
  const CommandPalette({super.key});

  @override
  ConsumerState<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends ConsumerState<CommandPalette> {
  final _queryController = TextEditingController();
  final _focusNode = FocusNode();
  int _selectedIndex = 0;
  List<CommandEntry> _filteredCommands = [];

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVisible = ref.watch(commandPaletteVisibleProvider);

    if (!isVisible) return const SizedBox.shrink();

    // 获取所有可用命令
    final serviceState = ref.watch(shortcutServiceProvider);
    final allCommands = serviceState.service.getAllCommandEntries();

    // 过滤命令
    _filteredCommands = _filterCommands(allCommands, _queryController.text);

    // 自动聚焦
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_focusNode.hasFocus) _focusNode.requestFocus();
    });

    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // 背景遮罩
        Positioned.fill(
          child: GestureDetector(
            onTap: _close,
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
        ),
        // 命令面板
        Positioned(
          top: screenSize.height * 0.1,
          left: (screenSize.width - 500) / 2,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(6),
            color: theme.colorScheme.surface,
            child: Container(
              width: 500,
              constraints: BoxConstraints(
                maxHeight: screenSize.height * 0.6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 搜索输入框
                  _buildSearchInput(theme),
                  // 命令列表
                  if (_filteredCommands.isNotEmpty)
                    Flexible(child: _buildCommandList(theme)),
                  if (_filteredCommands.isEmpty &&
                      _queryController.text.isNotEmpty)
                    _buildEmptyState(theme),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 搜索输入框
  Widget _buildSearchInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: TextField(
        controller: _queryController,
        focusNode: _focusNode,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: '搜索命令...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: theme.colorScheme.primary),
          ),
        ),
        onSubmitted: (_) => _executeSelected(),
        onEditingComplete: () {},
      ),
    );
  }

  /// 命令列表
  Widget _buildCommandList(ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _filteredCommands.length,
      itemBuilder: (context, index) {
        final command = _filteredCommands[index];
        final isSelected = index == _selectedIndex;

        return InkWell(
          onTap: () => _executeCommand(command),
          child: Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : null,
            child: Row(
              children: [
                // 命令描述
                Expanded(
                  child: Text(
                    command.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 快捷键标签
                if (command.shortcutLabel.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: Text(
                      command.shortcutLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 空状态提示
  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        '未找到匹配的命令',
        style: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  /// 查询变更回调
  void _onQueryChanged() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  /// 模糊过滤命令列表
  List<CommandEntry> _filterCommands(
      List<CommandEntry> commands, String query) {
    if (query.isEmpty) return commands;

    final lowerQuery = query.toLowerCase();
    return commands.where((cmd) {
      return cmd.description.toLowerCase().contains(lowerQuery) ||
          cmd.commandId.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// 执行选中的命令
  void _executeSelected() {
    if (_filteredCommands.isEmpty) return;
    if (_selectedIndex >= 0 && _selectedIndex < _filteredCommands.length) {
      _executeCommand(_filteredCommands[_selectedIndex]);
    }
  }

  /// 执行指定命令
  void _executeCommand(CommandEntry command) {
    _close();
    ref.read(shortcutServiceProvider).service.executeCommand(command.commandId);
  }

  /// 关闭面板
  void _close() {
    ref.read(commandPaletteVisibleProvider.notifier).hide();
    _queryController.clear();
    _selectedIndex = 0;
  }

  /// 处理键盘导航（ArrowUp/Down/Escape）
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focusNode.onKeyEvent = _handleKeyEvent;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        setState(() {
          if (_selectedIndex <= 0) {
            _selectedIndex = _filteredCommands.length - 1;
          } else {
            _selectedIndex--;
          }
        });
        return KeyEventResult.handled;

      case LogicalKeyboardKey.arrowDown:
        setState(() {
          if (_selectedIndex >= _filteredCommands.length - 1) {
            _selectedIndex = 0;
          } else {
            _selectedIndex++;
          }
        });
        return KeyEventResult.handled;

      case LogicalKeyboardKey.escape:
        _close();
        return KeyEventResult.handled;

      default:
        return KeyEventResult.ignored;
    }
  }
}
