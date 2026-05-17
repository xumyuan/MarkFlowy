/// 预定义快捷键映射
/// 参考: marktext/src/main/keyboard/keybindingsDarwin.js
///       marktext/src/main/keyboard/keybindingsWindows.js
///       marktext/src/main/keyboard/keybindingsLinux.js
///
/// 根据运行平台自动选择对应的快捷键表。
/// macOS 使用 Cmd，Windows/Linux 使用 Ctrl。
library;

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 快捷键绑定记录
class ShortcutBinding {
  /// 命令标识符（如 'file.save', 'edit.undo'）
  final String commandId;

  /// 快捷键组合
  final SingleActivator activator;

  /// 命令的可读描述
  final String description;

  const ShortcutBinding({
    required this.commandId,
    required this.activator,
    required this.description,
  });
}

/// 平台自适应修饰键（macOS 用 Meta/Cmd，其它平台用 Control）
bool get _isMacOS => Platform.isMacOS;

/// 辅助方法：创建平台自适应快捷键
/// macOS: meta=true (Cmd), 其他: control=true (Ctrl)
SingleActivator _platformShortcut(
  LogicalKeyboardKey key, {
  bool shift = false,
  bool alt = false,
}) {
  return SingleActivator(
    key,
    meta: _isMacOS,
    control: !_isMacOS,
    shift: shift,
    alt: alt,
  );
}

/// 仅 Ctrl 修饰（用于 macOS 上不使用 Cmd 的快捷键）
SingleActivator _ctrlShortcut(
  LogicalKeyboardKey key, {
  bool shift = false,
  bool alt = false,
}) {
  return SingleActivator(
    key,
    control: true,
    shift: shift,
    alt: alt,
  );
}

// ==================== 文件操作快捷键 ====================

/// 文件菜单快捷键
final List<ShortcutBinding> fileShortcuts = [
  ShortcutBinding(
    commandId: 'file.new-tab',
    activator: _platformShortcut(LogicalKeyboardKey.keyT),
    description: '新建标签',
  ),
  ShortcutBinding(
    commandId: 'file.new-window',
    activator: _platformShortcut(LogicalKeyboardKey.keyN),
    description: '新建窗口',
  ),
  ShortcutBinding(
    commandId: 'file.open-file',
    activator: _platformShortcut(LogicalKeyboardKey.keyO),
    description: '打开文件',
  ),
  ShortcutBinding(
    commandId: 'file.open-folder',
    activator: _platformShortcut(LogicalKeyboardKey.keyO, shift: true),
    description: '打开文件夹',
  ),
  ShortcutBinding(
    commandId: 'file.save',
    activator: _platformShortcut(LogicalKeyboardKey.keyS),
    description: '保存',
  ),
  ShortcutBinding(
    commandId: 'file.save-as',
    activator: _platformShortcut(LogicalKeyboardKey.keyS, shift: true),
    description: '另存为',
  ),
  ShortcutBinding(
    commandId: 'file.close-tab',
    activator: _platformShortcut(LogicalKeyboardKey.keyW),
    description: '关闭标签',
  ),
  ShortcutBinding(
    commandId: 'file.close-window',
    activator: _platformShortcut(LogicalKeyboardKey.keyW, shift: true),
    description: '关闭窗口',
  ),
  ShortcutBinding(
    commandId: 'file.quick-open',
    activator: _platformShortcut(LogicalKeyboardKey.keyP),
    description: '快速打开',
  ),
];

// ==================== 编辑操作快捷键 ====================

/// 编辑菜单快捷键
final List<ShortcutBinding> editShortcuts = [
  ShortcutBinding(
    commandId: 'edit.undo',
    activator: _platformShortcut(LogicalKeyboardKey.keyZ),
    description: '撤销',
  ),
  ShortcutBinding(
    commandId: 'edit.redo',
    activator: _platformShortcut(LogicalKeyboardKey.keyZ, shift: true),
    description: '重做',
  ),
  ShortcutBinding(
    commandId: 'edit.cut',
    activator: _platformShortcut(LogicalKeyboardKey.keyX),
    description: '剪切',
  ),
  ShortcutBinding(
    commandId: 'edit.copy',
    activator: _platformShortcut(LogicalKeyboardKey.keyC),
    description: '复制',
  ),
  ShortcutBinding(
    commandId: 'edit.paste',
    activator: _platformShortcut(LogicalKeyboardKey.keyV),
    description: '粘贴',
  ),
  ShortcutBinding(
    commandId: 'edit.copy-as-rich',
    activator: _platformShortcut(LogicalKeyboardKey.keyC, shift: true),
    description: '复制为富文本',
  ),
  ShortcutBinding(
    commandId: 'edit.paste-as-plaintext',
    activator: _platformShortcut(LogicalKeyboardKey.keyV, shift: true),
    description: '粘贴为纯文本',
  ),
  ShortcutBinding(
    commandId: 'edit.select-all',
    activator: _platformShortcut(LogicalKeyboardKey.keyA),
    description: '全选',
  ),
  ShortcutBinding(
    commandId: 'edit.duplicate',
    activator: _platformShortcut(LogicalKeyboardKey.keyD, alt: true),
    description: '复制段落',
  ),
  ShortcutBinding(
    commandId: 'edit.find',
    activator: _platformShortcut(LogicalKeyboardKey.keyF),
    description: '查找',
  ),
  ShortcutBinding(
    commandId: 'edit.find-next',
    activator: _isMacOS
        ? _platformShortcut(LogicalKeyboardKey.keyG)
        : const SingleActivator(LogicalKeyboardKey.f3),
    description: '查找下一个',
  ),
  ShortcutBinding(
    commandId: 'edit.find-previous',
    activator: _isMacOS
        ? _platformShortcut(LogicalKeyboardKey.keyG, shift: true)
        : const SingleActivator(LogicalKeyboardKey.f3, shift: true),
    description: '查找上一个',
  ),
  ShortcutBinding(
    commandId: 'edit.replace',
    activator: _isMacOS
        ? _platformShortcut(LogicalKeyboardKey.keyF, alt: true)
        : _platformShortcut(LogicalKeyboardKey.keyR),
    description: '替换',
  ),
  ShortcutBinding(
    commandId: 'edit.find-in-folder',
    activator: _platformShortcut(LogicalKeyboardKey.keyF, shift: true),
    description: '在文件夹中查找',
  ),
];

// ==================== 段落快捷键 ====================

/// 段落菜单快捷键
final List<ShortcutBinding> paragraphShortcuts = [
  // macOS: Cmd+1~6, Windows 不绑定标题快捷键
  if (_isMacOS) ...[
    ShortcutBinding(
      commandId: 'paragraph.heading-1',
      activator: _platformShortcut(LogicalKeyboardKey.digit1),
      description: '一级标题',
    ),
    ShortcutBinding(
      commandId: 'paragraph.heading-2',
      activator: _platformShortcut(LogicalKeyboardKey.digit2),
      description: '二级标题',
    ),
    ShortcutBinding(
      commandId: 'paragraph.heading-3',
      activator: _platformShortcut(LogicalKeyboardKey.digit3),
      description: '三级标题',
    ),
    ShortcutBinding(
      commandId: 'paragraph.heading-4',
      activator: _platformShortcut(LogicalKeyboardKey.digit4),
      description: '四级标题',
    ),
    ShortcutBinding(
      commandId: 'paragraph.heading-5',
      activator: _platformShortcut(LogicalKeyboardKey.digit5),
      description: '五级标题',
    ),
    ShortcutBinding(
      commandId: 'paragraph.heading-6',
      activator: _platformShortcut(LogicalKeyboardKey.digit6),
      description: '六级标题',
    ),
  ],
  ShortcutBinding(
    commandId: 'paragraph.upgrade-heading',
    activator: _platformShortcut(LogicalKeyboardKey.equal),
    description: '提升标题级别',
  ),
  ShortcutBinding(
    commandId: 'paragraph.degrade-heading',
    activator: _platformShortcut(LogicalKeyboardKey.minus),
    description: '降低标题级别',
  ),
  ShortcutBinding(
    commandId: 'paragraph.table',
    activator: _platformShortcut(LogicalKeyboardKey.keyT, shift: true),
    description: '插入表格',
  ),
  ShortcutBinding(
    commandId: 'paragraph.code-fence',
    activator: _isMacOS
        ? _platformShortcut(LogicalKeyboardKey.keyC, alt: true)
        : _platformShortcut(LogicalKeyboardKey.keyK, shift: true),
    description: '代码块',
  ),
  ShortcutBinding(
    commandId: 'paragraph.quote-block',
    activator: _isMacOS
        ? _platformShortcut(LogicalKeyboardKey.keyQ, alt: true)
        : _platformShortcut(LogicalKeyboardKey.keyQ, shift: true),
    description: '引用块',
  ),
  ShortcutBinding(
    commandId: 'paragraph.math-formula',
    activator: _isMacOS
        ? _platformShortcut(LogicalKeyboardKey.keyM, alt: true)
        : _ctrlShortcut(LogicalKeyboardKey.keyN, alt: true),
    description: '数学公式块',
  ),
  ShortcutBinding(
    commandId: 'paragraph.order-list',
    activator: _isMacOS
        ? _platformShortcut(LogicalKeyboardKey.keyO, alt: true)
        : _platformShortcut(LogicalKeyboardKey.keyG),
    description: '有序列表',
  ),
  ShortcutBinding(
    commandId: 'paragraph.bullet-list',
    activator: _isMacOS
        ? _platformShortcut(LogicalKeyboardKey.keyU, alt: true)
        : _platformShortcut(LogicalKeyboardKey.keyH),
    description: '无序列表',
  ),
  ShortcutBinding(
    commandId: 'paragraph.task-list',
    activator: _isMacOS
        ? _platformShortcut(LogicalKeyboardKey.keyX, alt: true)
        : _ctrlShortcut(LogicalKeyboardKey.keyX, alt: true),
    description: '任务列表',
  ),
  ShortcutBinding(
    commandId: 'paragraph.paragraph',
    activator: _platformShortcut(LogicalKeyboardKey.digit0, shift: !_isMacOS),
    description: '普通段落',
  ),
  ShortcutBinding(
    commandId: 'paragraph.horizontal-line',
    activator: _isMacOS
        ? _platformShortcut(LogicalKeyboardKey.minus, alt: true)
        : _platformShortcut(LogicalKeyboardKey.keyU, shift: true),
    description: '水平分割线',
  ),
];

// ==================== 格式快捷键 ====================

/// 格式菜单快捷键
final List<ShortcutBinding> formatShortcuts = [
  ShortcutBinding(
    commandId: 'format.strong',
    activator: _platformShortcut(LogicalKeyboardKey.keyB),
    description: '加粗',
  ),
  ShortcutBinding(
    commandId: 'format.emphasis',
    activator: _platformShortcut(LogicalKeyboardKey.keyI),
    description: '斜体',
  ),
  ShortcutBinding(
    commandId: 'format.underline',
    activator: _platformShortcut(LogicalKeyboardKey.keyU),
    description: '下划线',
  ),
  ShortcutBinding(
    commandId: 'format.highlight',
    activator: _platformShortcut(LogicalKeyboardKey.keyH, shift: true),
    description: '高亮',
  ),
  ShortcutBinding(
    commandId: 'format.inline-code',
    activator: _platformShortcut(LogicalKeyboardKey.backquote),
    description: '行内代码',
  ),
  ShortcutBinding(
    commandId: 'format.inline-math',
    activator: _platformShortcut(LogicalKeyboardKey.keyM, shift: true),
    description: '行内数学公式',
  ),
  ShortcutBinding(
    commandId: 'format.strike',
    activator: _platformShortcut(LogicalKeyboardKey.keyD),
    description: '删除线',
  ),
  ShortcutBinding(
    commandId: 'format.hyperlink',
    activator: _platformShortcut(LogicalKeyboardKey.keyL),
    description: '超链接',
  ),
  ShortcutBinding(
    commandId: 'format.image',
    activator: _platformShortcut(LogicalKeyboardKey.keyI, shift: true),
    description: '插入图片',
  ),
  ShortcutBinding(
    commandId: 'format.clear-format',
    activator: _platformShortcut(LogicalKeyboardKey.keyR, shift: true),
    description: '清除格式',
  ),
];

// ==================== 视图快捷键 ====================

/// 视图菜单快捷键
final List<ShortcutBinding> viewShortcuts = [
  ShortcutBinding(
    commandId: 'view.command-palette',
    activator: _platformShortcut(LogicalKeyboardKey.keyP, shift: true),
    description: '命令面板',
  ),
  ShortcutBinding(
    commandId: 'view.source-code-mode',
    activator: _isMacOS
        ? _platformShortcut(LogicalKeyboardKey.keyS, alt: true)
        : _platformShortcut(LogicalKeyboardKey.keyE),
    description: '源码模式',
  ),
  ShortcutBinding(
    commandId: 'view.typewriter-mode',
    activator: _isMacOS
        ? _platformShortcut(LogicalKeyboardKey.keyT, alt: true)
        : _platformShortcut(LogicalKeyboardKey.keyG, shift: true),
    description: '打字机模式',
  ),
  ShortcutBinding(
    commandId: 'view.focus-mode',
    activator: _platformShortcut(LogicalKeyboardKey.keyJ, shift: true),
    description: '专注模式',
  ),
  ShortcutBinding(
    commandId: 'view.toggle-sidebar',
    activator: _platformShortcut(LogicalKeyboardKey.keyJ),
    description: '切换侧边栏',
  ),
  ShortcutBinding(
    commandId: 'view.toggle-toc',
    activator: _platformShortcut(LogicalKeyboardKey.keyK),
    description: '切换目录',
  ),
  ShortcutBinding(
    commandId: 'view.toggle-tabbar',
    activator: _isMacOS
        ? _platformShortcut(LogicalKeyboardKey.keyB, alt: true)
        : _platformShortcut(LogicalKeyboardKey.keyB, shift: true),
    description: '切换标签栏',
  ),
];

// ==================== 窗口快捷键 ====================

/// 窗口菜单快捷键
final List<ShortcutBinding> windowShortcuts = [
  ShortcutBinding(
    commandId: 'window.toggle-full-screen',
    activator: _isMacOS
        ? _ctrlShortcut(LogicalKeyboardKey.keyF, alt: false)
        : const SingleActivator(LogicalKeyboardKey.f11),
    description: '全屏',
  ),
];

// ==================== 标签切换快捷键 ====================

/// 标签切换快捷键
final List<ShortcutBinding> tabShortcuts = [
  ShortcutBinding(
    commandId: 'tabs.cycleForward',
    activator: _ctrlShortcut(LogicalKeyboardKey.tab),
    description: '下一个标签',
  ),
  ShortcutBinding(
    commandId: 'tabs.cycleBackward',
    activator: _ctrlShortcut(LogicalKeyboardKey.tab, shift: true),
    description: '上一个标签',
  ),
];

// ==================== 汇总 ====================

/// 获取所有预定义快捷键
List<ShortcutBinding> get allShortcuts => [
      ...fileShortcuts,
      ...editShortcuts,
      ...paragraphShortcuts,
      ...formatShortcuts,
      ...viewShortcuts,
      ...windowShortcuts,
      ...tabShortcuts,
    ];

/// 根据命令 ID 获取快捷键绑定
ShortcutBinding? getShortcutByCommand(String commandId) {
  try {
    return allShortcuts.firstWhere((s) => s.commandId == commandId);
  } catch (_) {
    return null;
  }
}

/// 获取快捷键的可读文本（用于菜单显示）
String getShortcutLabel(String commandId) {
  final binding = getShortcutByCommand(commandId);
  if (binding == null) return '';
  return _activatorToLabel(binding.activator);
}

/// 将 SingleActivator 转换为可读标签
String _activatorToLabel(SingleActivator activator) {
  final parts = <String>[];
  if (activator.control) {
    parts.add(_isMacOS ? '⌃' : 'Ctrl');
  }
  if (activator.alt) {
    parts.add(_isMacOS ? '⌥' : 'Alt');
  }
  if (activator.shift) {
    parts.add(_isMacOS ? '⇧' : 'Shift');
  }
  if (activator.meta) {
    parts.add(_isMacOS ? '⌘' : 'Win');
  }

  final keyLabel = _keyToLabel(activator.trigger);
  parts.add(keyLabel);

  return _isMacOS ? parts.join() : parts.join('+');
}

/// 将逻辑按键转换为可读标签
String _keyToLabel(LogicalKeyboardKey key) {
  // 字母键
  if (key == LogicalKeyboardKey.keyA) return 'A';
  if (key == LogicalKeyboardKey.keyB) return 'B';
  if (key == LogicalKeyboardKey.keyC) return 'C';
  if (key == LogicalKeyboardKey.keyD) return 'D';
  if (key == LogicalKeyboardKey.keyE) return 'E';
  if (key == LogicalKeyboardKey.keyF) return 'F';
  if (key == LogicalKeyboardKey.keyG) return 'G';
  if (key == LogicalKeyboardKey.keyH) return 'H';
  if (key == LogicalKeyboardKey.keyI) return 'I';
  if (key == LogicalKeyboardKey.keyJ) return 'J';
  if (key == LogicalKeyboardKey.keyK) return 'K';
  if (key == LogicalKeyboardKey.keyL) return 'L';
  if (key == LogicalKeyboardKey.keyM) return 'M';
  if (key == LogicalKeyboardKey.keyN) return 'N';
  if (key == LogicalKeyboardKey.keyO) return 'O';
  if (key == LogicalKeyboardKey.keyP) return 'P';
  if (key == LogicalKeyboardKey.keyQ) return 'Q';
  if (key == LogicalKeyboardKey.keyR) return 'R';
  if (key == LogicalKeyboardKey.keyS) return 'S';
  if (key == LogicalKeyboardKey.keyT) return 'T';
  if (key == LogicalKeyboardKey.keyU) return 'U';
  if (key == LogicalKeyboardKey.keyV) return 'V';
  if (key == LogicalKeyboardKey.keyW) return 'W';
  if (key == LogicalKeyboardKey.keyX) return 'X';
  if (key == LogicalKeyboardKey.keyY) return 'Y';
  if (key == LogicalKeyboardKey.keyZ) return 'Z';

  // 数字键
  if (key == LogicalKeyboardKey.digit0) return '0';
  if (key == LogicalKeyboardKey.digit1) return '1';
  if (key == LogicalKeyboardKey.digit2) return '2';
  if (key == LogicalKeyboardKey.digit3) return '3';
  if (key == LogicalKeyboardKey.digit4) return '4';
  if (key == LogicalKeyboardKey.digit5) return '5';
  if (key == LogicalKeyboardKey.digit6) return '6';
  if (key == LogicalKeyboardKey.digit7) return '7';
  if (key == LogicalKeyboardKey.digit8) return '8';
  if (key == LogicalKeyboardKey.digit9) return '9';

  // 特殊键
  if (key == LogicalKeyboardKey.tab) return 'Tab';
  if (key == LogicalKeyboardKey.enter) return 'Enter';
  if (key == LogicalKeyboardKey.escape) return 'Esc';
  if (key == LogicalKeyboardKey.backquote) return '`';
  if (key == LogicalKeyboardKey.minus) return '-';
  if (key == LogicalKeyboardKey.equal) return '=';
  if (key == LogicalKeyboardKey.f3) return 'F3';
  if (key == LogicalKeyboardKey.f11) return 'F11';

  return key.keyLabel;
}
