/// 编辑模式切换组件
/// 参考: marktext 中的 sourceCode 模式切换（通过菜单或快捷键触发）
///
/// 功能:
/// - 三个模式按钮: WYSIWYG / 源码 / 分屏
/// - SegmentedButton 实现
/// - 切换时回调通知
library;

import 'package:flutter/material.dart';

import '../../providers/editor_provider.dart';

/// 编辑模式切换器
/// 对应 marktext 中 View 菜单的 Source Code Mode 切换功能
class ModeSwitcher extends StatelessWidget {
  /// 当前编辑模式
  final EditorMode currentMode;

  /// 模式切换回调
  final ValueChanged<EditorMode>? onModeChanged;

  const ModeSwitcher({
    super.key,
    required this.currentMode,
    this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<EditorMode>(
      segments: const [
        ButtonSegment<EditorMode>(
          value: EditorMode.wysiwyg,
          label: Text('WYSIWYG'),
          icon: Icon(Icons.edit_note, size: 16),
        ),
        ButtonSegment<EditorMode>(
          value: EditorMode.sourceCode,
          label: Text('源码'),
          icon: Icon(Icons.code, size: 16),
        ),
        ButtonSegment<EditorMode>(
          value: EditorMode.splitView,
          label: Text('分屏'),
          icon: Icon(Icons.vertical_split, size: 16),
        ),
      ],
      selected: {currentMode},
      onSelectionChanged: (selected) {
        onModeChanged?.call(selected.first);
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        textStyle: WidgetStatePropertyAll(
          const TextStyle(fontSize: 12),
        ),
        padding: WidgetStatePropertyAll(
          const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }
}
