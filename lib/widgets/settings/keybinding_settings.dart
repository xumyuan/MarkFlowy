/// 快捷键设置面板
/// 参考: marktext/src/renderer/src/prefComponents/keybindings/index.vue
///
/// 包含:
/// - 快捷键列表（命令名 + 当前快捷键）
/// - 点击修改快捷键
/// - 恢复默认
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 快捷键项数据
class _KeybindingItem {
  final String id;
  final String description;
  final String accelerator;

  const _KeybindingItem({
    required this.id,
    required this.description,
    required this.accelerator,
  });
}

/// 默认快捷键列表（对应 marktext 的 keybinding 配置）
const _defaultKeybindings = [
  _KeybindingItem(id: 'new-file', description: '新建文件', accelerator: 'Ctrl+N'),
  _KeybindingItem(id: 'open-file', description: '打开文件', accelerator: 'Ctrl+O'),
  _KeybindingItem(id: 'save', description: '保存', accelerator: 'Ctrl+S'),
  _KeybindingItem(id: 'save-as', description: '另存为', accelerator: 'Ctrl+Shift+S'),
  _KeybindingItem(id: 'close-tab', description: '关闭标签', accelerator: 'Ctrl+W'),
  _KeybindingItem(id: 'undo', description: '撤销', accelerator: 'Ctrl+Z'),
  _KeybindingItem(id: 'redo', description: '重做', accelerator: 'Ctrl+Shift+Z'),
  _KeybindingItem(id: 'cut', description: '剪切', accelerator: 'Ctrl+X'),
  _KeybindingItem(id: 'copy', description: '复制', accelerator: 'Ctrl+C'),
  _KeybindingItem(id: 'paste', description: '粘贴', accelerator: 'Ctrl+V'),
  _KeybindingItem(id: 'select-all', description: '全选', accelerator: 'Ctrl+A'),
  _KeybindingItem(id: 'find', description: '查找', accelerator: 'Ctrl+F'),
  _KeybindingItem(id: 'replace', description: '替换', accelerator: 'Ctrl+H'),
  _KeybindingItem(id: 'bold', description: '粗体', accelerator: 'Ctrl+B'),
  _KeybindingItem(id: 'italic', description: '斜体', accelerator: 'Ctrl+I'),
  _KeybindingItem(id: 'underline', description: '下划线', accelerator: 'Ctrl+U'),
  _KeybindingItem(id: 'strike', description: '删除线', accelerator: 'Ctrl+D'),
  _KeybindingItem(id: 'heading-1', description: '标题 1', accelerator: 'Ctrl+1'),
  _KeybindingItem(id: 'heading-2', description: '标题 2', accelerator: 'Ctrl+2'),
  _KeybindingItem(id: 'heading-3', description: '标题 3', accelerator: 'Ctrl+3'),
  _KeybindingItem(id: 'toggle-sidebar', description: '切换侧边栏', accelerator: 'Ctrl+\\'),
  _KeybindingItem(id: 'source-code', description: '源码模式', accelerator: 'Ctrl+E'),
  _KeybindingItem(id: 'settings', description: '设置', accelerator: 'Ctrl+,'),
];

/// 快捷键设置（对应 prefComponents/keybindings/index.vue）
class KeybindingSettings extends ConsumerStatefulWidget {
  const KeybindingSettings({super.key});

  @override
  ConsumerState<KeybindingSettings> createState() => _KeybindingSettingsState();
}

class _KeybindingSettingsState extends ConsumerState<KeybindingSettings> {
  late List<_KeybindingItem> _keybindings;

  @override
  void initState() {
    super.initState();
    _keybindings = List.from(_defaultKeybindings);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('快捷键', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          '点击快捷键列可以修改绑定，也可以恢复默认设置。',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
        const SizedBox(height: 16),

        // 快捷键列表表格
        DataTable(
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text('功能')),
            DataColumn(label: Text('快捷键')),
            DataColumn(label: Text('操作')),
          ],
          rows: _keybindings.map((item) {
            return DataRow(cells: [
              DataCell(Text(item.description)),
              DataCell(
                InkWell(
                  onTap: () => _showEditDialog(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.accelerator,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      tooltip: '编辑',
                      onPressed: () => _showEditDialog(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 18),
                      tooltip: '恢复默认',
                      onPressed: () => _resetKeybinding(item),
                    ),
                  ],
                ),
              ),
            ]);
          }).toList(),
        ),
        const SizedBox(height: 24),

        // 底部操作按钮
        Row(
          children: [
            ElevatedButton(
              onPressed: _restoreAllDefaults,
              child: const Text('恢复所有默认'),
            ),
          ],
        ),
      ],
    );
  }

  /// 显示快捷键编辑对话框
  void _showEditDialog(_KeybindingItem item) {
    showDialog(
      context: context,
      builder: (context) => _KeyInputDialog(
        currentAccelerator: item.accelerator,
        onCommit: (newAccelerator) {
          setState(() {
            final index = _keybindings.indexWhere((k) => k.id == item.id);
            if (index >= 0) {
              _keybindings[index] = _KeybindingItem(
                id: item.id,
                description: item.description,
                accelerator: newAccelerator,
              );
            }
          });
        },
      ),
    );
  }

  /// 恢复单个快捷键默认值
  void _resetKeybinding(_KeybindingItem item) {
    final defaultItem = _defaultKeybindings.firstWhere(
      (k) => k.id == item.id,
    );
    setState(() {
      final index = _keybindings.indexWhere((k) => k.id == item.id);
      if (index >= 0) {
        _keybindings[index] = defaultItem;
      }
    });
  }

  /// 恢复所有默认快捷键
  void _restoreAllDefaults() {
    setState(() {
      _keybindings = List.from(_defaultKeybindings);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已恢复所有默认快捷键')),
    );
  }
}

/// 快捷键输入对话框（对应 key-input-dialog.vue）
class _KeyInputDialog extends StatefulWidget {
  final String currentAccelerator;
  final ValueChanged<String> onCommit;

  const _KeyInputDialog({
    required this.currentAccelerator,
    required this.onCommit,
  });

  @override
  State<_KeyInputDialog> createState() => _KeyInputDialogState();
}

class _KeyInputDialogState extends State<_KeyInputDialog> {
  String _currentKeys = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentKeys = widget.currentAccelerator;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('录入快捷键'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('按下新的快捷键组合：'),
          const SizedBox(height: 16),
          KeyboardListener(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: _handleKeyEvent,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _currentKeys.isEmpty ? '等待输入...' : _currentKeys,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onCommit(_currentKeys);
            Navigator.of(context).pop();
          },
          child: const Text('确认'),
        ),
      ],
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final parts = <String>[];
    if (HardwareKeyboard.instance.isControlPressed) parts.add('Ctrl');
    if (HardwareKeyboard.instance.isShiftPressed) parts.add('Shift');
    if (HardwareKeyboard.instance.isAltPressed) parts.add('Alt');
    if (HardwareKeyboard.instance.isMetaPressed) parts.add('Meta');

    final keyLabel = event.logicalKey.keyLabel;
    if (keyLabel.isNotEmpty &&
        !['Control Left', 'Control Right', 'Shift Left', 'Shift Right',
          'Alt Left', 'Alt Right', 'Meta Left', 'Meta Right']
            .contains(keyLabel)) {
      parts.add(keyLabel);
    }

    if (parts.isNotEmpty) {
      setState(() {
        _currentKeys = parts.join('+');
      });
    }
  }
}
