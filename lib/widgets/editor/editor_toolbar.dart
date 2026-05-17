/// 编辑器工具栏组件
/// 参考: marktext/src/muya/lib/ui/formatPicker/config.js — 工具栏按钮配置
/// 参考: marktext/src/muya/lib/contentState/formatCtrl.js — 格式化控制
///
/// 功能:
/// - 格式化按钮行（粗体/斜体/下划线/删除线/代码）
/// - 块类型按钮（标题H1-H6/段落/引用/列表）
/// - 插入按钮（链接/图片/代码块/表格/分割线）
/// - 接收编辑器状态来控制按钮激活状态
library;

import 'package:flutter/material.dart';

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
class EditorToolbar extends StatelessWidget {
  /// 格式化按钮点击回调（对应 formatCtrl.format(type)）
  final void Function(String type)? onFormatAction;

  /// 块类型按钮点击回调（对应 editor.updateParagraph(type)）
  final void Function(String type)? onBlockAction;

  /// 插入按钮点击回调
  final void Function(String type)? onInsertAction;

  /// 当前活跃的内联格式（对应 marktext selectionFormats）
  final Set<String> activeFormats;

  /// 当前块类型
  final String? currentBlockType;

  const EditorToolbar({
    super.key,
    this.onFormatAction,
    this.onBlockAction,
    this.onInsertAction,
    this.activeFormats = const {},
    this.currentBlockType,
  });

  @override
  Widget build(BuildContext context) {
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
            // 格式化按钮组（对应 formatPicker/config.js 中的 icons）
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

  /// 构建格式化按钮（对应 formatPicker/config.js）
  List<Widget> _buildFormatButtons(ThemeData theme) {
    // 参考 marktext formatPicker 配置: strong, em, u, del, inline_code
    final items = [
      EditorToolbarItem(
        type: 'bold',
        tooltip: '粗体 (Ctrl+B)',
        icon: Icons.format_bold,
        isActive: activeFormats.contains('bold'),
      ),
      EditorToolbarItem(
        type: 'italic',
        tooltip: '斜体 (Ctrl+I)',
        icon: Icons.format_italic,
        isActive: activeFormats.contains('italic'),
      ),
      EditorToolbarItem(
        type: 'underline',
        tooltip: '下划线 (Ctrl+U)',
        icon: Icons.format_underline,
        isActive: activeFormats.contains('underline'),
      ),
      EditorToolbarItem(
        type: 'strikethrough',
        tooltip: '删除线 (Ctrl+D)',
        icon: Icons.format_strikethrough,
        isActive: activeFormats.contains('strikethrough'),
      ),
      EditorToolbarItem(
        type: 'code',
        tooltip: '行内代码 (Ctrl+`)',
        icon: Icons.code,
        isActive: activeFormats.contains('code'),
      ),
    ];

    return items.map((item) => _ToolbarButton(
      item: item,
      onTap: () => onFormatAction?.call(item.type),
    )).toList();
  }

  /// 构建块类型按钮（对应 marktext paragraph 菜单）
  List<Widget> _buildBlockButtons(ThemeData theme) {
    final items = [
      EditorToolbarItem(
        type: 'heading1',
        tooltip: '标题 1',
        icon: Icons.looks_one,
        isActive: currentBlockType == 'heading1',
      ),
      EditorToolbarItem(
        type: 'heading2',
        tooltip: '标题 2',
        icon: Icons.looks_two,
        isActive: currentBlockType == 'heading2',
      ),
      EditorToolbarItem(
        type: 'heading3',
        tooltip: '标题 3',
        icon: Icons.looks_3,
        isActive: currentBlockType == 'heading3',
      ),
      EditorToolbarItem(
        type: 'paragraph',
        tooltip: '段落',
        icon: Icons.notes,
        isActive: currentBlockType == 'paragraph',
      ),
      EditorToolbarItem(
        type: 'quote',
        tooltip: '引用',
        icon: Icons.format_quote,
        isActive: currentBlockType == 'quote',
      ),
      EditorToolbarItem(
        type: 'bulleted_list',
        tooltip: '无序列表',
        icon: Icons.format_list_bulleted,
        isActive: currentBlockType == 'bulleted_list',
      ),
      EditorToolbarItem(
        type: 'numbered_list',
        tooltip: '有序列表',
        icon: Icons.format_list_numbered,
        isActive: currentBlockType == 'numbered_list',
      ),
    ];

    return items.map((item) => _ToolbarButton(
      item: item,
      onTap: () => onBlockAction?.call(item.type),
    )).toList();
  }

  /// 构建插入按钮（对应 marktext quickInsert 菜单中的部分项目）
  List<Widget> _buildInsertButtons(ThemeData theme) {
    final items = [
      const EditorToolbarItem(
        type: 'link',
        tooltip: '插入链接 (Ctrl+L)',
        icon: Icons.link,
      ),
      const EditorToolbarItem(
        type: 'image',
        tooltip: '插入图片 (Shift+Ctrl+I)',
        icon: Icons.image,
      ),
      const EditorToolbarItem(
        type: 'code_block',
        tooltip: '插入代码块',
        icon: Icons.integration_instructions,
      ),
      const EditorToolbarItem(
        type: 'table',
        tooltip: '插入表格',
        icon: Icons.table_chart_outlined,
      ),
      const EditorToolbarItem(
        type: 'divider',
        tooltip: '插入分割线',
        icon: Icons.horizontal_rule,
      ),
    ];

    return items.map((item) => _ToolbarButton(
      item: item,
      onTap: () => onInsertAction?.call(item.type),
    )).toList();
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
