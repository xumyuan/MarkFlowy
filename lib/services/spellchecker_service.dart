/// 拼写检查服务
/// 参考: marktext/src/main/spellchecker/index.js
///
/// 提供拼写检查功能:
/// - 多语言词典支持（en-US, en-GB, fr, de, es, etc.）
/// - 错误词下划线显示
/// - 右键菜单提供修正建议
/// - 添加用户自定义词典
/// - 忽略词列表
library;

/// 拼写建议
class SpellSuggestion {
  /// 建议词
  final String word;

  /// 编辑距离（越小越接近）
  final int distance;

  const SpellSuggestion({
    required this.word,
    this.distance = 0,
  });
}

/// 拼写检查结果
class SpellCheckResult {
  /// 原文
  final String text;

  /// 错误词位置
  final int startOffset;

  /// 错误词结束位置
  final int endOffset;

  /// 修正建议列表
  final List<SpellSuggestion> suggestions;

  const SpellCheckResult({
    required this.text,
    required this.startOffset,
    required this.endOffset,
    this.suggestions = const [],
  });

  /// 是否有可用建议
  bool get hasSuggestions => suggestions.isNotEmpty;
}

/// 拼写检查服务
/// 当前为基础实现，后续可通过 native platform channel 接入系统拼写检查
class SpellcheckerService {
  /// 是否启用
  bool _enabled = false;

  /// 是否隐藏下划线
  bool _noUnderline = false;

  /// 当前语言
  String _language = 'en-US';

  /// 用户忽略的词集合
  final Set<String> _ignoredWords = {};

  /// 用户自定义词典
  final Set<String> _customDictionary = {};

  /// 基础英文词典（常用词，实际项目应使用更完整的词典）
  static const _basicEnglishWords = {
    'the', 'be', 'to', 'of', 'and', 'a', 'in', 'that', 'have',
    'it', 'for', 'not', 'on', 'with', 'he', 'as', 'you', 'do',
    'at', 'this', 'but', 'his', 'by', 'from', 'they', 'we',
    'say', 'her', 'she', 'or', 'an', 'will', 'my', 'one', 'all',
    'would', 'there', 'their', 'what', 'so', 'up', 'out', 'if',
    'about', 'who', 'get', 'which', 'go', 'me', 'when', 'make',
    'can', 'like', 'time', 'no', 'just', 'him', 'know', 'take',
    'people', 'into', 'year', 'your', 'good', 'some', 'could',
    'them', 'see', 'other', 'than', 'then', 'now', 'look',
    'only', 'come', 'its', 'over', 'think', 'also', 'back',
    'after', 'use', 'two', 'how', 'our', 'work', 'first', 'well',
    'way', 'even', 'new', 'want', 'because', 'any', 'these',
    'give', 'day', 'most', 'us', 'great',
  };

  // ============ 配置 ============

  /// 是否启用拼写检查
  bool get isEnabled => _enabled;

  /// 启用/禁用拼写检查
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// 是否隐藏下划线
  bool get noUnderline => _noUnderline;

  /// 设置是否隐藏下划线
  void setNoUnderline(bool value) {
    _noUnderline = value;
  }

  /// 当前语言
  String get language => _language;

  /// 设置语言
  void setLanguage(String lang) {
    _language = lang;
  }

  /// 支持的语言列表
  static const supportedLanguages = [
    'en-US', 'en-GB', 'en-CA', 'en-AU',
    'fr-FR', 'fr-CA',
    'de-DE', 'de-AT', 'de-CH',
    'es-ES', 'es-MX',
    'it-IT', 'pt-BR', 'pt-PT',
    'nl-NL', 'ru-RU', 'pl-PL',
    'ja-JP', 'ko-KR', 'zh-CN', 'zh-TW',
  ];

  // ============ 词典管理 ============

  /// 添加忽略词
  void addIgnoredWord(String word) {
    _ignoredWords.add(word.toLowerCase());
  }

  /// 移除忽略词
  void removeIgnoredWord(String word) {
    _ignoredWords.remove(word.toLowerCase());
  }

  /// 清空忽略词列表
  void clearIgnoredWords() {
    _ignoredWords.clear();
  }

  /// 添加到自定义词典
  void addToDictionary(String word) {
    _customDictionary.add(word.toLowerCase());
  }

  /// 从自定义词典移除
  void removeFromDictionary(String word) {
    _customDictionary.remove(word.toLowerCase());
  }

  // ============ 拼写检查 ============

  /// 检查单个词是否拼写正确
  bool checkWord(String word) {
    if (!_enabled) return true;
    if (word.length <= 1) return true;

    final lower = word.toLowerCase();

    // 忽略纯数字、URL、代码等
    if (_shouldSkipWord(word)) return true;
    if (_ignoredWords.contains(lower)) return true;
    if (_customDictionary.contains(lower)) return true;

    // 基础词典检查
    // 实际项目中应使用 Hunspell 或其他拼写检查引擎
    return _basicEnglishWords.contains(lower) || _isLikelyCorrect(word);
  }

  /// 检查文本并返回所有拼写错误
  List<SpellCheckResult> checkText(String text) {
    if (!_enabled) return [];

    final results = <SpellCheckResult>[];
    final wordRegex = RegExp(r'\b[a-zA-Z]+\b');
    final matches = wordRegex.allMatches(text);

    for (final match in matches) {
      final word = match.group(0)!;
      if (word.length <= 1) continue;

      if (!checkWord(word)) {
        results.add(SpellCheckResult(
          text: word,
          startOffset: match.start,
          endOffset: match.end,
          suggestions: _getSuggestions(word),
        ));
      }
    }

    return results;
  }

  // ============ 建议生成 ============

  /// 为拼写错误的词生成修正建议
  List<SpellSuggestion> _getSuggestions(String word) {
    if (!_enabled || word.length < 2) return [];

    final suggestions = <SpellSuggestion>[];
    final lower = word.toLowerCase();

    // 简单基于编辑距离的建议
    for (final dictWord in _basicEnglishWords) {
      final distance = _levenshteinDistance(lower, dictWord);
      if (distance <= 2 && distance > 0) {
        suggestions.add(SpellSuggestion(
          word: dictWord,
          distance: distance,
        ));
      }
    }

    // 按编辑距离排序，取前 5 个
    suggestions.sort((a, b) => a.distance.compareTo(b.distance));
    return suggestions.take(5).toList();
  }

  // ============ 辅助方法 ============

  /// 判断是否应该跳过检查（数字、URL 等）
  bool _shouldSkipWord(String word) {
    // 纯数字
    if (RegExp(r'^\d+$').hasMatch(word)) return true;
    // URL
    if (word.contains('://') || word.startsWith('www.')) return true;
    // 驼峰命名（likely code）
    if (RegExp(r'[a-z][A-Z]').hasMatch(word)) return true;
    // 含下划线的词（likely code）
    if (word.contains('_')) return true;
    // 全大写缩写
    if (word == word.toUpperCase() && word.length <= 5) return true;
    return false;
  }

  /// 判断词是否可能拼写正确（大写开头、常见后缀等）
  bool _isLikelyCorrect(String word) {
    // 短词
    if (word.length <= 2) return true;
    // 常见词缀
    final commonSuffixes = ['ing', 'ed', 'ly', 'er', 'es', 'ies', 'tion', 'ment', 'ness'];
    for (final suffix in commonSuffixes) {
      if (word.endsWith(suffix) && word.length > suffix.length + 1) {
        return true;
      }
    }
    // 常见前缀
    final commonPrefixes = ['un', 're', 'pre', 'dis', 'mis', 'over', 'under'];
    for (final prefix in commonPrefixes) {
      if (word.startsWith(prefix) && word.length > prefix.length + 1) {
        return true;
      }
    }
    return false;
  }

  /// 计算编辑距离（Levenshtein distance）
  int _levenshteinDistance(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final matrix = List.generate(a.length + 1, (i) => List.filled(b.length + 1, 0));

    for (var i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((x, y) => x < y ? x : y);
      }
    }

    return matrix[a.length][b.length];
  }
}
