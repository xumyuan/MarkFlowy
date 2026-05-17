/// 共享常量
/// 参考: marktext/src/main/config.js 和 marktext/src/common/ 目录
///
/// 包含窗口配置、支持的文件扩展名、主题列表、编码映射等。
library;

// ============ 窗口配置常量（对应 marktext config.js） ============

/// 编辑器窗口最小宽度
const double kEditorMinWidth = 550;

/// 编辑器窗口最小高度
const double kEditorMinHeight = 350;

/// 设置窗口默认宽度
const double kPreferencesWidth = 950;

/// 设置窗口默认高度
const double kPreferencesHeight = 650;

/// macOS 标题栏高度
const double kTitleBarHeightMacOS = 21;

/// Windows/Linux 标题栏高度
const double kTitleBarHeightOther = 32;

// ============ 文件扩展名（对应 marktext PANDOC_EXTENSIONS） ============

/// 支持通过 Pandoc 导出的格式
const List<String> kPandocExtensions = [
  'html',
  'docx',
  'odt',
  'latex',
  'tex',
  'ltx',
  'rst',
  'rest',
  'org',
  'wiki',
  'dokuwiki',
  'textile',
  'opml',
  'epub',
];

/// 导出文件扩展名映射（对应 EXTENSION_HASN）
const Map<String, String> kExportExtensions = {
  'styledHtml': '.html',
  'pdf': '.pdf',
};

/// 黑名单目录（对应 BLACK_LIST）
const List<String> kBlackList = [r'$RECYCLE.BIN'];

// ============ 主题列表（对应 marktext/src/common/theme.js） ============

/// 深色主题（Railscasts 风格）
const List<String> kRailscastsThemes = [
  'dark',
  'material-dark',
  'dracula',
  'nord',
  'catppuccin-mocha',
  'gruvbox-dark',
  'tokyo-night',
  'tokyo-night-storm',
  'solarized-dark',
  'ayu-dark',
  'ayu-mirage',
  'everforest-dark',
  'rose-pine',
  'rose-pine-moon',
  'monokai-pro',
  'synthwave-84',
  'horizon-dark',
  'palenight',
  'oxocarbon-dark',
  'kanagawa',
  'nightfox',
  'cyberdream',
];

/// One Dark 主题
const List<String> kOneDarkThemes = ['one-dark'];

/// 判断是否为深色主题（对应 isDarkThemeId）
bool isDarkTheme(String theme) {
  return kRailscastsThemes.contains(theme) || kOneDarkThemes.contains(theme);
}

/// 所有深色主题列表
List<String> get allDarkThemes => [...kRailscastsThemes, ...kOneDarkThemes];

/// 亮色主题列表
const List<String> kLightThemes = [
  'light',
  'ulysses',
  'graphite',
  'one-light',
];

// ============ 编码映射（对应 marktext/src/common/encoding.js） ============

/// 编码名称到显示名的映射
const Map<String, String> kEncodingNameMap = {
  'utf8': 'UTF-8',
  'utf16be': 'UTF-16 BE',
  'utf16le': 'UTF-16 LE',
  'utf32be': 'UTF-32 BE',
  'utf32le': 'UTF-32 LE',
  'ascii': 'Western (ISO 8859-1)',
  'latin3': 'Western (ISO 8859-3)',
  'iso885915': 'Western (ISO 8859-15)',
  'cp1252': 'Western (Windows 1252)',
  'arabic': 'Arabic (ISO 8859-6)',
  'cp1256': 'Arabic (Windows 1256)',
  'latin4': 'Baltic (ISO 8859-4)',
  'cp1257': 'Baltic (Windows 1257)',
  'iso88592': 'Central European (ISO 8859-2)',
  'windows1250': 'Central European (Windows 1250)',
  'cp866': 'Cyrillic (CP 866)',
  'iso88595': 'Cyrillic (ISO 8859-5)',
  'koi8r': 'Cyrillic (KOI8-R)',
  'koi8u': 'Cyrillic (KOI8-U)',
  'cp1251': 'Cyrillic (Windows 1251)',
  'iso885913': 'Estonian (ISO 8859-13)',
  'greek': 'Greek (ISO 8859-7)',
  'cp1253': 'Greek (Windows 1253)',
  'hebrew': 'Hebrew (ISO 8859-8)',
  'cp1255': 'Hebrew (Windows 1255)',
  'latin5': 'Turkish (ISO 8859-9)',
  'cp1254': 'Turkish (Windows 1254)',
  'gb2312': 'Simplified Chinese (GB2312)',
  'gb18030': 'Simplified Chinese (GB18030)',
  'gbk': 'Simplified Chinese (GBK)',
  'big5': 'Traditional Chinese (Big5)',
  'big5hkscs': 'Traditional Chinese (Big5-HKSCS)',
  'shiftjis': 'Japanese (Shift JIS)',
  'eucjp': 'Japanese (EUC-JP)',
  'euckr': 'Korean (EUC-KR)',
  'latin6': 'Nordic (ISO 8859-10)',
};

/// 获取编码的显示名称（对应 getEncodingName）
String getEncodingDisplayName(String encoding, {bool isBom = false}) {
  final name = kEncodingNameMap[encoding] ?? encoding;
  return isBom ? '$name with BOM' : name;
}

// ============ 正则表达式（对应 marktext config.js） ============

/// 行尾匹配正则（对应 LINE_ENDING_REG）
final RegExp kLineEndingRegExp = RegExp(r'(?:\r\n|\n)');

/// LF 行尾匹配正则（对应 LF_LINE_ENDING_REG）
final RegExp kLfLineEndingRegExp = RegExp(r'(?:[^\r]\n)|(?:^\n$)');

/// CRLF 行尾匹配正则（对应 CRLF_LINE_ENDING_REG）
final RegExp kCrlfLineEndingRegExp = RegExp(r'\r\n');

/// URL 匹配正则（对应 URL_REG）
final RegExp kUrlRegExp = RegExp(
  r'^http(s)?://([a-z0-9\-._~]+\.[a-z]{2,}|[0-9.]+|localhost|\[[a-f0-9.:]+\])(:[0-9]{1,5})?(\/[\S]+)?',
  caseSensitive: false,
);

// ============ 应用信息 ============

/// 应用名称
const String kAppName = 'Flutter Markdown Editor';

/// GitHub 仓库地址（参考 GITHUB_REPO_URL）
const String kGithubRepoUrl =
    'https://github.com/user/flutter_markdown_editor';
