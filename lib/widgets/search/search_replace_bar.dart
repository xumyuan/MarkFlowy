/// 搜索替换栏 Widget
/// 参考: marktext/src/renderer/src/components/search/index.vue
///
/// 浮动显示在编辑器顶部的搜索替换栏:
/// - 搜索输入框 + 上/下导航 + 匹配计数
/// - 替换输入框 + 替换/全部替换按钮
/// - 选项：大小写敏感、全词匹配、正则表达式
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/search_provider.dart';

/// 搜索替换栏
/// 浮动定位于编辑器区域右上角
class SearchReplaceBar extends ConsumerStatefulWidget {
  /// 当搜索内容变化时的回调（传入文档内容执行搜索）
  final String Function() getDocumentContent;

  /// 替换后更新文档内容
  final void Function(String newContent)? onReplace;

  const SearchReplaceBar({
    super.key,
    required this.getDocumentContent,
    this.onReplace,
  });

  @override
  ConsumerState<SearchReplaceBar> createState() => _SearchReplaceBarState();
}

class _SearchReplaceBarState extends ConsumerState<SearchReplaceBar> {
  final _searchController = TextEditingController();
  final _replaceController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _replaceController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final theme = Theme.of(context);

    if (!searchState.isVisible) {
      return const SizedBox.shrink();
    }

    // 同步控制器文本（避免循环）
    if (_searchController.text != searchState.query) {
      _searchController.text = searchState.query;
    }
    if (_replaceController.text != searchState.replacement) {
      _replaceController.text = searchState.replacement;
    }

    // 自动聚焦搜索框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (searchState.isVisible && !_searchFocusNode.hasFocus) {
        _searchFocusNode.requestFocus();
      }
    });

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(4),
      color: theme.colorScheme.surface,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 搜索行
            _buildSearchRow(searchState, theme),
            // 替换行（仅在替换模式显示）
            if (searchState.panelType == SearchPanelType.replace)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: _buildReplaceRow(searchState, theme),
              ),
            // 错误信息
            if (searchState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  searchState.errorMessage!,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建搜索行
  Widget _buildSearchRow(SearchState searchState, ThemeData theme) {
    return Row(
      children: [
        // 展开/折叠替换区域的箭头
        _buildToggleArrow(searchState),
        const SizedBox(width: 4),
        // 搜索输入框
        Expanded(child: _buildSearchInput(searchState, theme)),
        const SizedBox(width: 4),
        // 匹配计数
        _buildMatchCount(searchState, theme),
        // 搜索选项按钮
        _buildOptionButton(
          icon: Icons.text_fields,
          tooltip: '大小写敏感',
          isActive: searchState.options.caseSensitive,
          onPressed: () => ref.read(searchProvider.notifier).toggleCaseSensitive(),
          theme: theme,
        ),
        _buildOptionButton(
          icon: Icons.abc,
          tooltip: '全词匹配',
          isActive: searchState.options.wholeWord,
          onPressed: () => ref.read(searchProvider.notifier).toggleWholeWord(),
          theme: theme,
        ),
        _buildOptionButton(
          icon: Icons.data_object,
          tooltip: '正则表达式',
          isActive: searchState.options.useRegex,
          onPressed: () => ref.read(searchProvider.notifier).toggleRegex(),
          theme: theme,
        ),
        const SizedBox(width: 4),
        // 上一个/下一个按钮
        _buildNavButton(Icons.keyboard_arrow_up, '上一个', () {
          ref.read(searchProvider.notifier).findPrevious();
        }),
        _buildNavButton(Icons.keyboard_arrow_down, '下一个', () {
          ref.read(searchProvider.notifier).findNext();
        }),
        // 关闭按钮
        _buildNavButton(Icons.close, '关闭', () {
          ref.read(searchProvider.notifier).close();
        }),
      ],
    );
  }

  /// 构建替换行
  Widget _buildReplaceRow(SearchState searchState, ThemeData theme) {
    return Row(
      children: [
        const SizedBox(width: 28), // 对齐箭头区域
        // 替换输入框
        Expanded(child: _buildReplaceInput(theme)),
        const SizedBox(width: 4),
        // 替换按钮
        _buildNavButton(Icons.find_replace, '替换', () {
          _replaceCurrent();
        }),
        // 全部替换按钮
        _buildNavButton(Icons.find_replace_outlined, '全部替换', () {
          _replaceAll();
        }),
      ],
    );
  }

  /// 展开/折叠箭头
  Widget _buildToggleArrow(SearchState searchState) {
    final isReplace = searchState.panelType == SearchPanelType.replace;
    return InkWell(
      onTap: () => ref.read(searchProvider.notifier).togglePanelType(),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          isReplace ? Icons.expand_more : Icons.chevron_right,
          size: 16,
        ),
      ),
    );
  }

  /// 搜索输入框
  Widget _buildSearchInput(SearchState searchState, ThemeData theme) {
    return SizedBox(
      height: 28,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: '搜索',
          hintStyle: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(color: theme.colorScheme.primary),
          ),
          errorBorder: searchState.errorMessage != null
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(color: theme.colorScheme.error),
                )
              : null,
        ),
        onChanged: (value) {
          ref.read(searchProvider.notifier).updateQuery(value);
          _performSearch();
        },
        onSubmitted: (_) {
          ref.read(searchProvider.notifier).findNext();
        },
      ),
    );
  }

  /// 替换输入框
  Widget _buildReplaceInput(ThemeData theme) {
    return SizedBox(
      height: 28,
      child: TextField(
        controller: _replaceController,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: '替换',
          hintStyle: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(color: theme.colorScheme.primary),
          ),
        ),
        onChanged: (value) {
          ref.read(searchProvider.notifier).updateReplacement(value);
        },
      ),
    );
  }

  /// 匹配计数显示
  Widget _buildMatchCount(SearchState searchState, ThemeData theme) {
    final result = searchState.result;
    if (searchState.query.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '${result.hasMatches ? result.currentIndex + 1 : 0}/${result.count}',
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  /// 搜索选项按钮
  Widget _buildOptionButton({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    required VoidCallback onPressed,
    required ThemeData theme,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          onPressed();
          _performSearch();
        },
        borderRadius: BorderRadius.circular(3),
        child: Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: isActive
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : null,
          ),
          child: Icon(
            icon,
            size: 14,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  /// 导航按钮
  Widget _buildNavButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(3),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 16),
        ),
      ),
    );
  }

  /// 执行搜索
  void _performSearch() {
    final content = widget.getDocumentContent();
    ref.read(searchProvider.notifier).performSearch(content);
  }

  /// 替换当前匹配
  void _replaceCurrent() {
    final content = widget.getDocumentContent();
    final newContent = ref.read(searchProvider.notifier).replaceCurrent(content);
    if (newContent != null) {
      widget.onReplace?.call(newContent);
      _performSearch();
    }
  }

  /// 替换所有匹配
  void _replaceAll() {
    final content = widget.getDocumentContent();
    final newContent = ref.read(searchProvider.notifier).replaceAll(content);
    widget.onReplace?.call(newContent);
    _performSearch();
  }
}
