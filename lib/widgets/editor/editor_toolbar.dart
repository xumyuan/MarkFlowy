/// 编辑器工具栏组件
/// 参考: marktext/src/muya/lib/ui/formatPicker/config.js — 工具栏按钮配置
/// 参考: marktext/src/muya/lib/contentState/formatCtrl.js — 格式化控制
///
/// 功能:
/// - 格式化按钮行（粗体/斜体/下划线/删除线/代码）
/// - 块类型按钮（标题H1-H6/段落/引用/列表）
/// - QuickInsert 下拉面板（22 项块插入菜单）
/// - Emoji Picker 弹窗
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/editor_provider.dart';
import '../../providers/search_provider.dart';
import 'quick_insert.dart';

/// 工具栏按钮定义
/// 对应 marktext formatPicker/config.js 中的 icons 配置
class EditorToolbarItem {
  final String type;
  final String tooltip;
  final IconData icon;
  final String? shortcut;
  final bool isActive;

  const EditorToolbarItem({
    required this.type,
    required this.tooltip,
    required this.icon,
    this.shortcut,
    this.isActive = false,
  });
}

/// 编辑器工具栏
/// 对应 marktext FormatPicker + editParagraph 菜单功能
/// 集成 QuickInsert 面板和 Emoji Picker
class EditorToolbar extends ConsumerWidget {
  /// 格式化按钮点击回调
  final void Function(String type)? onFormatAction;

  /// 块类型按钮点击回调
  final void Function(String type)? onBlockAction;

  /// 插入按钮点击回调（链接/图片/表格/分割线/emoji）
  final void Function(String type)? onInsertAction;

  /// QuickInsert 选中回调（将 label 转为块操作）
  final void Function(String label)? onQuickInsert;

  /// 当前活跃的内联格式
  final Set<String> activeFormats;

  /// 当前块类型
  final String? currentBlockType;

  const EditorToolbar({
    super.key,
    this.onFormatAction,
    this.onBlockAction,
    this.onInsertAction,
    this.onQuickInsert,
    this.activeFormats = const {},
    this.currentBlockType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            // QuickInsert 按钮（下拉菜单：22 项块类型）
            _buildQuickInsertButton(theme),

            _buildDivider(theme),

            // Emoji Picker 按钮
            _buildEmojiButton(theme),

            _buildDivider(theme),

            // 格式化按钮组
            ..._buildFormatButtons(theme),

            _buildDivider(theme),

            // 块类型按钮组
            ..._buildBlockButtons(theme),

            _buildDivider(theme),

            // 插入按钮组
            ..._buildInsertButtons(theme),
          ],
        ),
      ),
    );
  }

  /// QuickInsert 下拉按钮（对应 MarkText 的 @ 菜单，22 项 5 分类）
  Widget _buildQuickInsertButton(ThemeData theme) {
    return PopupMenuButton<String>(
      tooltip: '快速插入 (对应 MarkText @ 菜单)',
      offset: const Offset(0, 36),
      position: PopupMenuPosition.under,
      icon: Icon(Icons.add_circle_outline, size: 18,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
      onSelected: (label) {
        if (label.startsWith('emoji:')) {
          // Emoji 已通过单独的 emoji picker 处理
          return;
        }
        onQuickInsert?.call(label);
        // 同时尝试通过命令总线触发对应的段落命令
        final commandId = QuickInsertMenu.labelToCommandId(label);
        if (commandId.isNotEmpty) {
          onBlockAction?.call(label);
        }
      },
      itemBuilder: (context) {
        final menuItems = <PopupMenuEntry<String>>[];
        for (final category in QuickInsertMenu.categories) {
          menuItems.add(PopupMenuItem<String>(
            enabled: false,
            height: 24,
            child: Text(category.title, style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
          ));
          for (final item in category.items) {
            menuItems.add(PopupMenuItem<String>(
              value: item.label,
              height: 34,
              child: Row(
                children: [
                  Icon(item.icon, size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                  const SizedBox(width: 8),
                  Text(item.title, style: const TextStyle(fontSize: 13)),
                  const Spacer(),
                  if (item.shortcut != null)
                    Text(item.shortcut!, style: TextStyle(fontSize: 10, fontFamily: 'monospace',
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                ],
              ),
            ));
          }
          menuItems.add(const PopupMenuDivider());
        }
        return menuItems;
      },
    );
  }

  /// Emoji Picker 按钮（对应 MarkText 的 : 表情输入）
  Widget _buildEmojiButton(ThemeData theme) {
    return Builder(
      builder: (context) => InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              content: EmojiPickerPanel(
                onEmojiSelected: (alias) {
                  Navigator.of(context).pop();
                  onInsertAction?.call('emoji:$alias');
                },
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text('😀', style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  /// 构建格式化按钮
  List<Widget> _buildFormatButtons(ThemeData theme) {
    final items = [
      EditorToolbarItem(type: 'strong', tooltip: '粗体 (⌘B)', icon: Icons.format_bold, isActive: activeFormats.contains('strong')),
      EditorToolbarItem(type: 'em', tooltip: '斜体 (⌘I)', icon: Icons.format_italic, isActive: activeFormats.contains('em')),
      EditorToolbarItem(type: 'u', tooltip: '下划线 (⌘U)', icon: Icons.format_underline, isActive: activeFormats.contains('u')),
      EditorToolbarItem(type: 'del', tooltip: '删除线 (⌘D)', icon: Icons.format_strikethrough, isActive: activeFormats.contains('del')),
      EditorToolbarItem(type: 'inline_code', tooltip: '行内代码 (⌘`)', icon: Icons.code, isActive: activeFormats.contains('inline_code')),
      EditorToolbarItem(type: 'mark', tooltip: '高亮 (⇧⌘H)', icon: Icons.highlight, isActive: activeFormats.contains('mark')),
      EditorToolbarItem(type: 'clear', tooltip: '清除格式 (⇧⌘R)', icon: Icons.format_clear),
    ];
    return items.map((item) => _ToolbarButton(item: item, onTap: () => onFormatAction?.call(item.type))).toList();
  }

  /// 构建块类型按钮
  List<Widget> _buildBlockButtons(ThemeData theme) {
    final items = [
      EditorToolbarItem(type: 'heading1', tooltip: '标题 1', icon: Icons.looks_one, isActive: currentBlockType == 'heading1'),
      EditorToolbarItem(type: 'heading2', tooltip: '标题 2', icon: Icons.looks_two, isActive: currentBlockType == 'heading2'),
      EditorToolbarItem(type: 'heading3', tooltip: '标题 3', icon: Icons.looks_3, isActive: currentBlockType == 'heading3'),
      EditorToolbarItem(type: 'paragraph', tooltip: '段落', icon: Icons.notes, isActive: currentBlockType == 'paragraph'),
      EditorToolbarItem(type: 'blockquote', tooltip: '引用', icon: Icons.format_quote, isActive: currentBlockType == 'blockquote'),
      EditorToolbarItem(type: 'ul-bullet', tooltip: '无序列表', icon: Icons.format_list_bulleted, isActive: currentBlockType == 'ul-bullet'),
      EditorToolbarItem(type: 'ol-order', tooltip: '有序列表', icon: Icons.format_list_numbered, isActive: currentBlockType == 'ol-order'),
    ];
    return items.map((item) => _ToolbarButton(item: item, onTap: () => onBlockAction?.call(item.type))).toList();
  }

  /// 构建插入按钮
  List<Widget> _buildInsertButtons(ThemeData theme) {
    final items = [
      const EditorToolbarItem(type: 'link', tooltip: '链接 (⌘L)', icon: Icons.link),
      const EditorToolbarItem(type: 'image', tooltip: '图片 (⇧⌘I)', icon: Icons.image),
      const EditorToolbarItem(type: 'table', tooltip: '表格 (⇧⌘T)', icon: Icons.table_chart_outlined),
      const EditorToolbarItem(type: 'hr', tooltip: '分割线 (⌥⌘-)', icon: Icons.horizontal_rule),
    ];
    return items.map((item) => _ToolbarButton(item: item, onTap: () => onInsertAction?.call(item.type))).toList();
  }

  /// 构建分隔线
  Widget _buildDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: 1,
        height: 20,
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
      ),
    );
  }
}

/// 工具栏单个按钮
class _ToolbarButton extends StatefulWidget {
  final EditorToolbarItem item;
  final VoidCallback? onTap;

  const _ToolbarButton({
    required this.item,
    this.onTap,
  });

  @override
  State<_ToolbarButton> createState() => _ToolbarButtonState();
}

class _ToolbarButtonState extends State<_ToolbarButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = widget.item.isActive;

    return Tooltip(
      message: widget.item.tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primaryContainer
                  : (_isHovered
                      ? theme.colorScheme.surfaceContainerHighest
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              widget.item.icon,
              size: 18,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
