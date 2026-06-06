/// QuickInsert 菜单 + Emoji Picker
/// 参考: marktext/src/muya/lib/ui/quickInsert/ + emojiPicker/
///
/// 提供 MarkText 风格的块插入菜单（22 项，5 个分类）和 Emoji 搜索选择器。
/// 通过工具栏按钮触发，弥补 appflowy_editor 无法拦截 @ 键的局限。
library;

import 'package:flutter/material.dart';

/// QuickInsert 菜单项
class QuickInsertItem {
  final String label;
  final String title;
  final String subtitle;
  final IconData icon;
  final String? shortcut;

  const QuickInsertItem({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.shortcut,
  });
}

/// QuickInsert 分类
class QuickInsertCategory {
  final String title;
  final List<QuickInsertItem> items;

  const QuickInsertCategory({required this.title, required this.items});
}

/// QuickInsert 完整菜单（22 项，5 个分类，对应 MarkText quickInsert/config.js）
class QuickInsertMenu {
  static const categories = [
    QuickInsertCategory(
      title: '基础块',
      items: [
        QuickInsertItem(label: 'paragraph', title: '段落', subtitle: '文本段落', icon: Icons.text_fields, shortcut: '⌘0'),
        QuickInsertItem(label: 'hr', title: '水平分割线', subtitle: '——', icon: Icons.horizontal_rule, shortcut: '⌥⌘-'),
        QuickInsertItem(label: 'front-matter', title: 'Front Matter', subtitle: 'YAML 元数据', icon: Icons.code, shortcut: '⌥⌘Y'),
      ],
    ),
    QuickInsertCategory(
      title: '标题',
      items: [
        QuickInsertItem(label: 'heading 1', title: '一级标题', subtitle: 'H1', icon: Icons.looks_one, shortcut: '⌘1'),
        QuickInsertItem(label: 'heading 2', title: '二级标题', subtitle: 'H2', icon: Icons.looks_two, shortcut: '⌘2'),
        QuickInsertItem(label: 'heading 3', title: '三级标题', subtitle: 'H3', icon: Icons.looks_3, shortcut: '⌘3'),
        QuickInsertItem(label: 'heading 4', title: '四级标题', subtitle: 'H4', icon: Icons.looks_4, shortcut: '⌘4'),
        QuickInsertItem(label: 'heading 5', title: '五级标题', subtitle: 'H5', icon: Icons.looks_5, shortcut: '⌘5'),
        QuickInsertItem(label: 'heading 6', title: '六级标题', subtitle: 'H6', icon: Icons.looks_6, shortcut: '⌘6'),
      ],
    ),
    QuickInsertCategory(
      title: '高级块',
      items: [
        QuickInsertItem(label: 'table', title: '表格', subtitle: '创建表格', icon: Icons.table_chart, shortcut: '⇧⌘T'),
        QuickInsertItem(label: 'mathblock', title: '数学公式块', subtitle: 'LaTeX', icon: Icons.functions, shortcut: '⌥⌘M'),
        QuickInsertItem(label: 'pre', title: '代码块', subtitle: 'Fenced code', icon: Icons.integration_instructions, shortcut: '⌥⌘C'),
        QuickInsertItem(label: 'blockquote', title: '引用块', subtitle: '引用内容', icon: Icons.format_quote, shortcut: '⌥⌘Q'),
      ],
    ),
    QuickInsertCategory(
      title: '列表',
      items: [
        QuickInsertItem(label: 'ol-order', title: '有序列表', subtitle: '1. 2. 3.', icon: Icons.format_list_numbered, shortcut: '⌥⌘O'),
        QuickInsertItem(label: 'ul-bullet', title: '无序列表', subtitle: '• 项目', icon: Icons.format_list_bulleted, shortcut: '⌥⌘U'),
        QuickInsertItem(label: 'ul-task', title: '任务列表', subtitle: '☑ 待办', icon: Icons.checklist, shortcut: '⌥⌘X'),
      ],
    ),
    QuickInsertCategory(
      title: '图表',
      items: [
        QuickInsertItem(label: 'mermaid', title: 'Mermaid', subtitle: 'Mermaid 图表', icon: Icons.account_tree),
        QuickInsertItem(label: 'flowchart', title: '流程图', subtitle: 'Flowchart', icon: Icons.schema),
        QuickInsertItem(label: 'sequence', title: '序列图', subtitle: 'Sequence', icon: Icons.linear_scale),
      ],
    ),
  ];

  /// 从 label 映射到对应的 MarkText 命令 ID 或块类型
  static String labelToCommandId(String label) {
    return switch (label) {
      'heading 1' => 'paragraph.heading-1',
      'heading 2' => 'paragraph.heading-2',
      'heading 3' => 'paragraph.heading-3',
      'heading 4' => 'paragraph.heading-4',
      'heading 5' => 'paragraph.heading-5',
      'heading 6' => 'paragraph.heading-6',
      'paragraph' => 'paragraph.paragraph',
      'table' => 'paragraph.table',
      'pre' => 'paragraph.code-fence',
      'blockquote' => 'paragraph.quote-block',
      'ol-order' => 'paragraph.order-list',
      'ul-bullet' => 'paragraph.bullet-list',
      'ul-task' => 'paragraph.task-list',
      'hr' => 'paragraph.horizontal-line',
      'mathblock' => 'paragraph.math-formula',
      'front-matter' => 'paragraph.front-matter',
      _ => 'paragraph.paragraph',
    };
  }
}

/// Emoji 数据（精选常用 emoji，实际项目可加载完整 JSON）
class EmojiData {
  final String emoji;
  final String alias;
  final String description;
  final List<String> tags;

  const EmojiData({
    required this.emoji,
    required this.alias,
    required this.description,
    this.tags = const [],
  });
}

/// 常用 Emoji 列表（对应 MarkText emojisJson.json 的精选子集）
const commonEmojis = [
  // Smileys
  EmojiData(emoji: '😀', alias: 'grinning', description: '笑脸', tags: ['smile', 'happy']),
  EmojiData(emoji: '😂', alias: 'joy', description: '笑哭', tags: ['tears', 'laugh']),
  EmojiData(emoji: '😍', alias: 'heart_eyes', description: '爱心眼', tags: ['love', 'heart']),
  EmojiData(emoji: '🤔', alias: 'thinking', description: '思考', tags: ['think', 'hmm']),
  EmojiData(emoji: '😎', alias: 'sunglasses', description: '墨镜', tags: ['cool']),
  EmojiData(emoji: '😢', alias: 'cry', description: '哭泣', tags: ['tear', 'sad']),
  EmojiData(emoji: '😡', alias: 'rage', description: '愤怒', tags: ['angry', 'mad']),
  EmojiData(emoji: '👍', alias: '+1', description: '赞', tags: ['thumbsup', 'like']),
  EmojiData(emoji: '👎', alias: '-1', description: '踩', tags: ['thumbsdown']),
  EmojiData(emoji: '👏', alias: 'clap', description: '鼓掌', tags: ['applause']),
  EmojiData(emoji: '🙏', alias: 'pray', description: '祈祷', tags: ['please', 'thanks']),
  EmojiData(emoji: '💪', alias: 'muscle', description: '肌肉', tags: ['strong', 'strength']),
  // Objects
  EmojiData(emoji: '❤️', alias: 'heart', description: '红心', tags: ['love']),
  EmojiData(emoji: '🔥', alias: 'fire', description: '火', tags: ['hot', 'lit']),
  EmojiData(emoji: '⭐', alias: 'star', description: '星星', tags: ['favorite']),
  EmojiData(emoji: '💡', alias: 'bulb', description: '灯泡', tags: ['idea', 'light']),
  EmojiData(emoji: '📝', alias: 'memo', description: '备忘录', tags: ['note', 'write']),
  EmojiData(emoji: '🎉', alias: 'tada', description: '庆祝', tags: ['party', 'congratulations']),
  EmojiData(emoji: '🚀', alias: 'rocket', description: '火箭', tags: ['launch', 'ship']),
  EmojiData(emoji: '✅', alias: 'white_check_mark', description: '勾选', tags: ['check', 'done']),
  EmojiData(emoji: '❌', alias: 'x', description: '叉号', tags: ['cancel', 'delete']),
  EmojiData(emoji: '⚠️', alias: 'warning', description: '警告', tags: ['caution', 'alert']),
  EmojiData(emoji: '💻', alias: 'computer', description: '电脑', tags: ['tech', 'code']),
  EmojiData(emoji: '📊', alias: 'bar_chart', description: '图表', tags: ['chart', 'data']),
  EmojiData(emoji: '🔗', alias: 'link', description: '链接', tags: ['url', 'chain']),
  EmojiData(emoji: '📌', alias: 'pushpin', description: '图钉', tags: ['pin', 'marker']),
  EmojiData(emoji: '🎯', alias: 'dart', description: '靶心', tags: ['target', 'goal']),
  EmojiData(emoji: '💯', alias: '100', description: '一百分', tags: ['score', 'perfect']),
];

/// QuickInsert 面板 Widget
/// 通过工具栏按钮显示块插入菜单（5 个分类，22 项）
class QuickInsertPanel extends StatelessWidget {
  final void Function(String label) onItemSelected;
  final String? filterQuery;

  const QuickInsertPanel({
    super.key,
    required this.onItemSelected,
    this.filterQuery,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = (filterQuery ?? '').toLowerCase();

    return Container(
      width: 320,
      constraints: const BoxConstraints(maxHeight: 480),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: QuickInsertMenu.categories.map((category) {
          final filtered = query.isEmpty
              ? category.items
              : category.items.where((item) =>
                  item.title.toLowerCase().contains(query) ||
                  item.subtitle.toLowerCase().contains(query) ||
                  item.label.toLowerCase().contains(query)).toList();

          if (filtered.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
                child: Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              ...filtered.map((item) => _QuickInsertTile(
                    item: item,
                    onTap: () => onItemSelected(item.label),
                  )),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// QuickInsert 菜单项
class _QuickInsertTile extends StatefulWidget {
  final QuickInsertItem item;
  final VoidCallback onTap;

  const _QuickInsertTile({required this.item, required this.onTap});

  @override
  State<_QuickInsertTile> createState() => _QuickInsertTileState();
}

class _QuickInsertTileState extends State<_QuickInsertTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: _isHovered
              ? theme.colorScheme.surfaceContainerHighest
              : Colors.transparent,
          child: Row(
            children: [
              Icon(widget.item.icon, size: 18,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.title,
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                    Text(widget.item.subtitle,
                        style: TextStyle(fontSize: 11,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                  ],
                ),
              ),
              if (widget.item.shortcut != null)
                Text(widget.item.shortcut!,
                    style: TextStyle(fontSize: 10, fontFamily: 'monospace',
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
            ],
          ),
        ),
      ),
    );
  }
}

/// Emoji Picker Widget
/// 搜索和选择 Emoji（对应 MarkText emojiPicker）
class EmojiPickerPanel extends StatefulWidget {
  final void Function(String alias) onEmojiSelected;

  const EmojiPickerPanel({super.key, required this.onEmojiSelected});

  @override
  State<EmojiPickerPanel> createState() => _EmojiPickerPanelState();
}

class _EmojiPickerPanelState extends State<EmojiPickerPanel> {
  final _searchController = TextEditingController();
  String _query = '';

  List<EmojiData> get _filteredEmojis {
    if (_query.isEmpty) return commonEmojis;
    final q = _query.toLowerCase();
    return commonEmojis.where((e) =>
        e.alias.toLowerCase().contains(q) ||
        e.description.contains(q) ||
        e.tags.any((t) => t.contains(q))
    ).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emojis = _filteredEmojis;

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '搜索 Emoji...',
                hintStyle: TextStyle(fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                prefixIcon: Icon(Icons.search, size: 18,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),

          // Emoji 网格
          if (emojis.isNotEmpty)
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 1,
                ),
                itemCount: emojis.length,
                itemBuilder: (context, index) {
                  final emoji = emojis[index];
                  return Tooltip(
                    message: ':${emoji.alias}:',
                    child: InkWell(
                      onTap: () => widget.onEmojiSelected(emoji.alias),
                      borderRadius: BorderRadius.circular(4),
                      child: Center(
                        child: Text(emoji.emoji, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                  );
                },
              ),
            ),

          if (emojis.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('未找到匹配的 Emoji',
                  style: TextStyle(fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
            ),
        ],
      ),
    );
  }
}
