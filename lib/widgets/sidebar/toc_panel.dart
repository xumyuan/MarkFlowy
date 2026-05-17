/// 目录大纲面板
/// 参考: marktext/src/renderer/src/components/sideBar/toc.vue
///
/// 功能:
/// - 从当前文档生成 H1-H6 目录大纲
/// - 显示层级结构（缩进）
/// - 点击跳转到对应位置
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/strings.dart';
import '../../widgets/tabs/tab_bar.dart';

/// TOC 条目数据
class TocEntry {
  /// 标题文本
  final String title;

  /// 标题级别 (1-6)
  final int level;

  /// 标题在文档中的行号
  final int lineNumber;

  /// 标题 slug（用于锚点跳转）
  final String slug;

  const TocEntry({
    required this.title,
    required this.level,
    required this.lineNumber,
    required this.slug,
  });
}

/// TOC Provider — 从当前文档内容解析目录
final tocProvider = Provider<List<TocEntry>>((ref) {
  final tabState = ref.watch(tabBarProvider);
  final activeDoc = tabState.activeDocument;
  if (activeDoc == null || activeDoc.content.isEmpty) {
    return [];
  }
  return _parseToc(activeDoc.content);
});

/// 解析 Markdown 内容中的标题生成 TOC
List<TocEntry> _parseToc(String content) {
  final lines = content.split('\n');
  final entries = <TocEntry>[];
  final headingRegExp = RegExp(r'^(#{1,6})\s+(.+)$');

  for (int i = 0; i < lines.length; i++) {
    final match = headingRegExp.firstMatch(lines[i]);
    if (match != null) {
      final level = match.group(1)!.length;
      final title = match.group(2)!.trim();
      // 生成 slug（对应 marktext 的 slug 生成）
      final slug = title
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '-');

      entries.add(TocEntry(
        title: title,
        level: level,
        lineNumber: i,
        slug: slug,
      ));
    }
  }
  return entries;
}

/// 目录大纲面板组件（对应 marktext toc.vue）
class TocPanel extends ConsumerWidget {
  /// 点击标题时的回调（行号）
  final void Function(int lineNumber)? onNavigate;

  const TocPanel({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(tocProvider);
    final theme = Theme.of(context);

    if (entries.isEmpty) {
      return Center(
        child: Text(
          AppStrings.tocHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _TocItem(
          entry: entry,
          onTap: () => onNavigate?.call(entry.lineNumber),
        );
      },
    );
  }
}

/// 单个 TOC 条目（对应 marktext el-tree 节点）
class _TocItem extends StatefulWidget {
  final TocEntry entry;
  final VoidCallback onTap;

  const _TocItem({required this.entry, required this.onTap});

  @override
  State<_TocItem> createState() => _TocItemState();
}

class _TocItemState extends State<_TocItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 根据标题级别计算缩进（对应 marktext el-tree indent=10）
    final indent = (widget.entry.level - 1) * 12.0 + 12.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: EdgeInsets.only(left: indent, right: 12, top: 6, bottom: 6),
          color: _isHovered
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : Colors.transparent,
          child: Text(
            widget.entry.title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: widget.entry.level <= 2
                  ? FontWeight.w600
                  : FontWeight.normal,
              fontSize: widget.entry.level == 1 ? 13 : 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
