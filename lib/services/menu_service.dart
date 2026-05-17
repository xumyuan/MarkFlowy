/// 原生菜单栏服务
/// 参考: marktext/src/main/menu/templates/ (file.js, edit.js, paragraph.js, format.js, view.js, window.js, help.js)
///
/// 使用 PlatformMenuBar 实现原生菜单。
/// 菜单结构: 文件、编辑、段落、格式、视图、窗口、帮助
library;

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/keyboard_shortcuts.dart';

/// 菜单服务 — 构建原生菜单栏
/// 对应 marktext src/main/menu/templates/index.js 的菜单组装逻辑
class MenuService {
  /// 菜单命令回调
  final void Function(String commandId) onCommand;

  MenuService({required this.onCommand});

  /// 构建完整的菜单栏 Widget
  Widget buildMenuBar({required Widget child}) {
    return PlatformMenuBar(
      menus: [
        _buildFileMenu(),
        _buildEditMenu(),
        _buildParagraphMenu(),
        _buildFormatMenu(),
        _buildViewMenu(),
        _buildWindowMenu(),
        _buildHelpMenu(),
      ],
      child: child,
    );
  }

  // ==================== 文件菜单 ====================
  // 参考: marktext/src/main/menu/templates/file.js

  PlatformMenu _buildFileMenu() {
    return PlatformMenu(
      label: '文件',
      menus: [
        _menuItem('file.new-tab', '新建标签'),
        _menuItem('file.new-window', '新建窗口'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('file.open-file', '打开文件'),
        _menuItem('file.open-folder', '打开文件夹'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('file.save', '保存'),
        _menuItem('file.save-as', '另存为'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('file.close-tab', '关闭标签'),
        _menuItem('file.close-window', '关闭窗口'),
        if (!Platform.isMacOS) ...[
          const PlatformMenuItemGroup(members: []),
          _menuItem('file.preferences', '偏好设置'),
          const PlatformMenuItemGroup(members: []),
          _menuItem('file.quit', '退出'),
        ],
      ],
    );
  }

  // ==================== 编辑菜单 ====================
  // 参考: marktext/src/main/menu/templates/edit.js

  PlatformMenu _buildEditMenu() {
    return PlatformMenu(
      label: '编辑',
      menus: [
        _menuItem('edit.undo', '撤销'),
        _menuItem('edit.redo', '重做'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('edit.cut', '剪切'),
        _menuItem('edit.copy', '复制'),
        _menuItem('edit.paste', '粘贴'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('edit.copy-as-rich', '复制为富文本'),
        _menuItem('edit.paste-as-plaintext', '粘贴为纯文本'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('edit.select-all', '全选'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('edit.duplicate', '复制段落'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('edit.find', '查找'),
        _menuItem('edit.find-next', '查找下一个'),
        _menuItem('edit.find-previous', '查找上一个'),
        _menuItem('edit.replace', '替换'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('edit.find-in-folder', '在文件夹中查找'),
      ],
    );
  }

  // ==================== 段落菜单 ====================
  // 参考: marktext/src/main/menu/templates/paragraph.js

  PlatformMenu _buildParagraphMenu() {
    return PlatformMenu(
      label: '段落',
      menus: [
        _menuItem('paragraph.heading-1', '一级标题'),
        _menuItem('paragraph.heading-2', '二级标题'),
        _menuItem('paragraph.heading-3', '三级标题'),
        _menuItem('paragraph.heading-4', '四级标题'),
        _menuItem('paragraph.heading-5', '五级标题'),
        _menuItem('paragraph.heading-6', '六级标题'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('paragraph.upgrade-heading', '提升标题级别'),
        _menuItem('paragraph.degrade-heading', '降低标题级别'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('paragraph.table', '表格'),
        _menuItem('paragraph.code-fence', '代码块'),
        _menuItem('paragraph.quote-block', '引用块'),
        _menuItem('paragraph.math-formula', '数学公式'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('paragraph.order-list', '有序列表'),
        _menuItem('paragraph.bullet-list', '无序列表'),
        _menuItem('paragraph.task-list', '任务列表'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('paragraph.paragraph', '普通段落'),
        _menuItem('paragraph.horizontal-line', '水平分割线'),
        _menuItem('paragraph.front-matter', 'Front Matter'),
      ],
    );
  }

  // ==================== 格式菜单 ====================
  // 参考: marktext/src/main/menu/templates/format.js

  PlatformMenu _buildFormatMenu() {
    return PlatformMenu(
      label: '格式',
      menus: [
        _menuItem('format.strong', '加粗'),
        _menuItem('format.emphasis', '斜体'),
        _menuItem('format.underline', '下划线'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('format.superscript', '上标'),
        _menuItem('format.subscript', '下标'),
        _menuItem('format.highlight', '高亮'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('format.inline-code', '行内代码'),
        _menuItem('format.inline-math', '行内数学公式'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('format.strike', '删除线'),
        _menuItem('format.hyperlink', '超链接'),
        _menuItem('format.image', '插入图片'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('format.clear-format', '清除格式'),
      ],
    );
  }

  // ==================== 视图菜单 ====================
  // 参考: marktext/src/main/menu/templates/view.js

  PlatformMenu _buildViewMenu() {
    return PlatformMenu(
      label: '视图',
      menus: [
        _menuItem('view.command-palette', '命令面板'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('view.source-code-mode', '源码模式'),
        _menuItem('view.typewriter-mode', '打字机模式'),
        _menuItem('view.focus-mode', '专注模式'),
        const PlatformMenuItemGroup(members: []),
        _menuItem('view.toggle-sidebar', '切换侧边栏'),
        _menuItem('view.toggle-tabbar', '切换标签栏'),
        _menuItem('view.toggle-toc', '切换目录'),
      ],
    );
  }

  // ==================== 窗口菜单 ====================
  // 参考: marktext/src/main/menu/templates/window.js

  PlatformMenu _buildWindowMenu() {
    return PlatformMenu(
      label: '窗口',
      menus: [
        _menuItem('window.minimize', '最小化'),
        _menuItem('window.toggle-full-screen', '全屏'),
        if (Platform.isMacOS)
          PlatformMenuItem(
            label: '前置所有窗口',
            onSelected: () => onCommand('window.bring-all-to-front'),
          ),
      ],
    );
  }

  // ==================== 帮助菜单 ====================
  // 参考: marktext/src/main/menu/templates/help.js

  PlatformMenu _buildHelpMenu() {
    return PlatformMenu(
      label: '帮助',
      menus: [
        PlatformMenuItem(
          label: '快捷键参考',
          onSelected: () => onCommand('help.keybindings'),
        ),
        PlatformMenuItem(
          label: 'Markdown 参考',
          onSelected: () => onCommand('help.markdown-reference'),
        ),
        const PlatformMenuItemGroup(members: []),
        PlatformMenuItem(
          label: '关于',
          onSelected: () => onCommand('help.about'),
        ),
      ],
    );
  }

  // ==================== 辅助方法 ====================

  /// 创建带快捷键的菜单项
  PlatformMenuItem _menuItem(String commandId, String label) {
    final binding = getShortcutByCommand(commandId);
    return PlatformMenuItem(
      label: label,
      shortcut: binding != null
          ? _toMenuSerializableShortcut(binding.activator)
          : null,
      onSelected: () => onCommand(commandId),
    );
  }

  /// 将 SingleActivator 转换为菜单可序列化的快捷键
  MenuSerializableShortcut _toMenuSerializableShortcut(
      SingleActivator activator) {
    return activator;
  }
}

/// 菜单服务 Provider
final menuServiceProvider = Provider<MenuService>((ref) {
  // 默认空实现，在应用层级注入具体回调
  return MenuService(onCommand: (_) {});
});
