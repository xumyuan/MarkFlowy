/// 搜索替换服务
/// 参考: marktext/src/renderer/src/components/search/index.vue 的搜索逻辑
///
/// 提供文档内搜索和替换功能:
/// - 支持纯文本搜索
/// - 支持正则表达式
/// - 支持大小写敏感
/// - 支持全词匹配
library;

/// 搜索选项
class SearchOptions {
  /// 是否大小写敏感
  final bool caseSensitive;

  /// 是否全词匹配
  final bool wholeWord;

  /// 是否使用正则表达式
  final bool useRegex;

  const SearchOptions({
    this.caseSensitive = false,
    this.wholeWord = false,
    this.useRegex = false,
  });

  SearchOptions copyWith({
    bool? caseSensitive,
    bool? wholeWord,
    bool? useRegex,
  }) {
    return SearchOptions(
      caseSensitive: caseSensitive ?? this.caseSensitive,
      wholeWord: wholeWord ?? this.wholeWord,
      useRegex: useRegex ?? this.useRegex,
    );
  }
}

/// 搜索匹配项
class SearchMatch {
  /// 匹配的起始位置（文档中的偏移量）
  final int start;

  /// 匹配的结束位置
  final int end;

  /// 匹配所在行号（从 0 开始）
  final int line;

  const SearchMatch({
    required this.start,
    required this.end,
    required this.line,
  });
}

/// 搜索结果
class SearchResult {
  /// 所有匹配项
  final List<SearchMatch> matches;

  /// 当前高亮的匹配索引
  final int currentIndex;

  const SearchResult({
    required this.matches,
    this.currentIndex = 0,
  });

  /// 总匹配数
  int get count => matches.length;

  /// 是否有匹配
  bool get hasMatches => matches.isNotEmpty;

  /// 当前匹配项
  SearchMatch? get currentMatch =>
      hasMatches && currentIndex >= 0 && currentIndex < count
          ? matches[currentIndex]
          : null;

  SearchResult copyWith({
    List<SearchMatch>? matches,
    int? currentIndex,
  }) {
    return SearchResult(
      matches: matches ?? this.matches,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

/// 搜索服务 — 执行文档内搜索和替换
class SearchService {
  /// 在文本中搜索
  SearchResult search(String text, String query, SearchOptions options) {
    if (query.isEmpty || text.isEmpty) {
      return const SearchResult(matches: []);
    }

    // 构建正则表达式
    final pattern = _buildPattern(query, options);
    if (pattern == null) {
      return const SearchResult(matches: []);
    }

    final matches = <SearchMatch>[];
    final lines = text.split('\n');
    int offset = 0;

    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      // 在整个文本上做匹配，但记录行号
      final lineStart = offset;
      final lineEnd = offset + line.length;

      // 查找此行上的所有匹配
      for (final match in pattern.allMatches(text, lineStart)) {
        if (match.start >= lineEnd) break;
        if (match.start >= lineStart) {
          matches.add(SearchMatch(
            start: match.start,
            end: match.end,
            line: lineIndex,
          ));
        }
      }
      offset = lineEnd + 1; // +1 for '\n'
    }

    return SearchResult(matches: matches);
  }

  /// 执行替换（单个）
  String replaceSingle(
    String text,
    SearchMatch match,
    String replacement,
    SearchOptions options,
  ) {
    return text.replaceRange(match.start, match.end, replacement);
  }

  /// 执行全部替换
  String replaceAll(
    String text,
    String query,
    String replacement,
    SearchOptions options,
  ) {
    if (query.isEmpty) return text;

    final pattern = _buildPattern(query, options);
    if (pattern == null) return text;

    return text.replaceAllMapped(pattern, (_) => replacement);
  }

  /// 验证正则表达式是否有效
  String? validateRegex(String pattern) {
    try {
      RegExp(pattern);
      // 检查是否匹配空字符串
      if (pattern.isNotEmpty && RegExp(pattern).hasMatch('')) {
        return '正则表达式匹配了空字符串';
      }
      return null;
    } catch (e) {
      return '无效的正则表达式: $e';
    }
  }

  /// 构建搜索模式
  RegExp? _buildPattern(String query, SearchOptions options) {
    String pattern;

    if (options.useRegex) {
      // 验证正则
      try {
        RegExp(query);
      } catch (_) {
        return null;
      }
      pattern = query;
    } else {
      // 转义特殊字符
      pattern = RegExp.escape(query);
    }

    // 全词匹配
    if (options.wholeWord) {
      pattern = '\\b$pattern\\b';
    }

    try {
      return RegExp(
        pattern,
        caseSensitive: options.caseSensitive,
        multiLine: true,
      );
    } catch (_) {
      return null;
    }
  }
}
