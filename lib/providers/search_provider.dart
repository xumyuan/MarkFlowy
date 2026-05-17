/// 搜索状态管理 Provider
/// 参考: marktext/src/renderer/src/components/search/index.vue 的状态逻辑
///
/// 管理搜索/替换的界面状态及搜索结果。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/search_service.dart';

/// 搜索面板类型
enum SearchPanelType {
  /// 仅搜索
  search,

  /// 搜索 + 替换
  replace,
}

/// 搜索面板状态
class SearchState {
  /// 是否显示搜索面板
  final bool isVisible;

  /// 面板类型（搜索 / 搜索+替换）
  final SearchPanelType panelType;

  /// 搜索查询文本
  final String query;

  /// 替换文本
  final String replacement;

  /// 搜索选项
  final SearchOptions options;

  /// 搜索结果
  final SearchResult result;

  /// 搜索错误信息
  final String? errorMessage;

  const SearchState({
    this.isVisible = false,
    this.panelType = SearchPanelType.search,
    this.query = '',
    this.replacement = '',
    this.options = const SearchOptions(),
    this.result = const SearchResult(matches: []),
    this.errorMessage,
  });

  SearchState copyWith({
    bool? isVisible,
    SearchPanelType? panelType,
    String? query,
    String? replacement,
    SearchOptions? options,
    SearchResult? result,
    String? Function()? errorMessage,
  }) {
    return SearchState(
      isVisible: isVisible ?? this.isVisible,
      panelType: panelType ?? this.panelType,
      query: query ?? this.query,
      replacement: replacement ?? this.replacement,
      options: options ?? this.options,
      result: result ?? this.result,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

/// 搜索状态 Notifier
class SearchNotifier extends Notifier<SearchState> {
  final SearchService _searchService = SearchService();

  @override
  SearchState build() {
    return const SearchState();
  }

  /// 打开搜索面板（对应 Cmd/Ctrl+F）
  void openSearch() {
    state = state.copyWith(
      isVisible: true,
      panelType: SearchPanelType.search,
    );
  }

  /// 打开搜索+替换面板（对应 Cmd+Option+F / Ctrl+R）
  void openReplace() {
    state = state.copyWith(
      isVisible: true,
      panelType: SearchPanelType.replace,
    );
  }

  /// 关闭搜索面板
  void close() {
    state = state.copyWith(
      isVisible: false,
      query: '',
      replacement: '',
      result: const SearchResult(matches: []),
      errorMessage: () => null,
    );
  }

  /// 切换面板类型（搜索 ↔ 替换）
  void togglePanelType() {
    final newType = state.panelType == SearchPanelType.search
        ? SearchPanelType.replace
        : SearchPanelType.search;
    state = state.copyWith(panelType: newType);
  }

  /// 更新搜索查询
  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  /// 更新替换文本
  void updateReplacement(String replacement) {
    state = state.copyWith(replacement: replacement);
  }

  /// 切换大小写敏感
  void toggleCaseSensitive() {
    state = state.copyWith(
      options: state.options.copyWith(
        caseSensitive: !state.options.caseSensitive,
      ),
    );
  }

  /// 切换全词匹配
  void toggleWholeWord() {
    state = state.copyWith(
      options: state.options.copyWith(
        wholeWord: !state.options.wholeWord,
      ),
    );
  }

  /// 切换正则表达式
  void toggleRegex() {
    state = state.copyWith(
      options: state.options.copyWith(
        useRegex: !state.options.useRegex,
      ),
    );
  }

  /// 执行搜索（在给定文本内容中）
  void performSearch(String documentContent) {
    if (state.query.isEmpty) {
      state = state.copyWith(
        result: const SearchResult(matches: []),
        errorMessage: () => null,
      );
      return;
    }

    // 如果是正则模式，先验证
    if (state.options.useRegex) {
      final error = _searchService.validateRegex(state.query);
      if (error != null) {
        state = state.copyWith(
          result: const SearchResult(matches: []),
          errorMessage: () => error,
        );
        return;
      }
    }

    final result = _searchService.search(
      documentContent,
      state.query,
      state.options,
    );
    state = state.copyWith(
      result: result,
      errorMessage: () => null,
    );
  }

  /// 导航到下一个匹配
  void findNext() {
    if (!state.result.hasMatches) return;
    final newIndex = (state.result.currentIndex + 1) % state.result.count;
    state = state.copyWith(
      result: state.result.copyWith(currentIndex: newIndex),
    );
  }

  /// 导航到上一个匹配
  void findPrevious() {
    if (!state.result.hasMatches) return;
    final newIndex = (state.result.currentIndex - 1 + state.result.count) %
        state.result.count;
    state = state.copyWith(
      result: state.result.copyWith(currentIndex: newIndex),
    );
  }

  /// 替换当前匹配项，返回新的文档内容
  String? replaceCurrent(String documentContent) {
    final match = state.result.currentMatch;
    if (match == null) return null;

    return _searchService.replaceSingle(
      documentContent,
      match,
      state.replacement,
      state.options,
    );
  }

  /// 替换所有匹配项，返回新的文档内容
  String replaceAll(String documentContent) {
    return _searchService.replaceAll(
      documentContent,
      state.query,
      state.replacement,
      state.options,
    );
  }
}

/// 搜索 Provider
final searchProvider =
    NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);
