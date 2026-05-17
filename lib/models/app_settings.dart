/// 应用设置数据模型
/// 参考: marktext/src/main/preferences/schema.json
///
/// 包含 MarkText 所有配置项的 Dart 等价实现。
/// 分类: General, Editor, Markdown, Theme, Spelling, Image, View, Search
library;

/// 启动行为枚举（对应 startUpAction）
enum StartUpAction {
  folder,
  openLastFolder,
  blank,
  restoreAll,
}

/// 文件排序方式（对应 fileSortBy）
enum FileSortBy {
  modified,
  created,
  title,
}

/// 标题栏样式（对应 titleBarStyle）
enum TitleBarStyle {
  custom,
  native,
}

/// 行尾符（对应 endOfLine）
enum EndOfLine {
  /// 使用操作系统默认
  defaultEnding,
  lf,
  crlf,
}

/// 文本方向（对应 textDirection）
enum EditorTextDirection {
  ltr,
  rtl,
}

/// 列表标记符（对应 bulletListMarker）
enum BulletListMarker {
  dash, // "-"
  asterisk, // "*"
  plus, // "+"
}

/// 有序列表分隔符（对应 orderListDelimiter）
enum OrderListDelimiter {
  dot, // "."
  parenthesis, // ")"
}

/// 标题样式（对应 preferHeadingStyle）
enum HeadingStyle {
  atx,
  setext,
}

/// Frontmatter 类型（对应 frontmatterType）
enum FrontmatterType {
  dash, // "-"
  plus, // "+"
  semicolon, // ";"
  brace, // "{"
}

/// 序列图主题（对应 sequenceTheme）
enum SequenceTheme {
  hand,
  simple,
}

/// 图片插入行为（对应 imageInsertAction）
enum ImageInsertAction {
  upload,
  folder,
  path,
}

/// 图片相对路径基准（对应 imageRelativeDirectoryBase）
enum ImageRelativeDirectoryBase {
  file,
  folder,
}

/// 尾部换行处理（对应 trimTrailingNewline）
enum TrimTrailingNewline {
  /// 不做任何处理
  doNothing, // 0
  /// 确保文件末尾有一个换行
  ensureOne, // 1
  /// 确保文件末尾恰好有一个换行（移除多余的）
  ensureExactlyOne, // 2
  /// 移除所有尾部换行
  removeAll, // 3
}

/// 应用设置（完整对应 marktext preferences/schema.json）
class AppSettings {
  // ============ General（通用设置） ============

  /// 是否自动保存
  final bool autoSave;

  /// 自动保存延迟（毫秒），最小 1000
  final int autoSaveDelay;

  /// 标题栏样式（Windows/Linux）
  final TitleBarStyle titleBarStyle;

  /// 是否在新窗口中打开文件
  final bool openFilesInNewWindow;

  /// 是否在新窗口中打开文件夹
  final bool openFolderInNewWindow;

  /// 缩放级别 (0.5 ~ 2.0)
  final double zoom;

  /// 是否隐藏滚动条
  final bool hideScrollbar;

  /// 目录是否自动换行
  final bool wordWrapInToc;

  /// 文件排序方式
  final FileSortBy fileSortBy;

  /// 上次打开的文件夹路径
  final String lastOpenedFolder;

  /// 启动行为
  final StartUpAction startUpAction;

  /// 启动时默认打开的目录
  final String defaultDirectoryToOpen;

  /// 语言
  final String language;

  /// 是否恢复上次的布局状态
  final bool restoreLayoutState;

  // ============ Editor（编辑器设置） ============

  /// 编辑器字体
  final String editorFontFamily;

  /// 字体大小 (12 ~ 32)
  final int fontSize;

  /// 行高 (1.2 ~ 2.0)
  final double lineHeight;

  /// 是否在代码块中换行
  final bool wrapCodeBlocks;

  /// 编辑器最大宽度（如 "80ch", "800px", "90%", 或空字符串表示不限制）
  final String editorLineWidth;

  /// 代码字体大小 (12 ~ 28)
  final int codeFontSize;

  /// 代码字体
  final String codeFontFamily;

  /// 是否显示代码块行号
  final bool codeBlockLineNumbers;

  /// 是否裁剪代码块首尾空行
  final bool trimUnnecessaryCodeBlockEmptyLines;

  /// 自动配对括号
  final bool autoPairBracket;

  /// 自动配对 Markdown 语法
  final bool autoPairMarkdownSyntax;

  /// 自动配对引号
  final bool autoPairQuote;

  /// 行尾符
  final EndOfLine endOfLine;

  /// 默认文件编码
  final String defaultEncoding;

  /// 是否自动猜测文件编码
  final bool autoGuessEncoding;

  /// 尾部换行处理方式
  final TrimTrailingNewline trimTrailingNewline;

  /// 文本方向
  final EditorTextDirection textDirection;

  /// 是否隐藏快速插入提示
  final bool hideQuickInsertHint;

  /// 是否隐藏链接弹窗
  final bool hideLinkPopup;

  /// 是否自动勾选任务
  final bool autoCheck;

  /// 是否自动规范化行尾
  final bool autoNormalizeLineEndings;

  // ============ Markdown 设置 ============

  /// 是否偏好松散列表
  final bool preferLooseListItem;

  /// 无序列表标记符
  final BulletListMarker bulletListMarker;

  /// 有序列表分隔符
  final OrderListDelimiter orderListDelimiter;

  /// 标题样式
  final HeadingStyle preferHeadingStyle;

  /// Tab 大小（空格数）
  final int tabSize;

  /// 列表缩进方式
  final String listIndentation;

  /// Frontmatter 类型
  final FrontmatterType frontmatterType;

  /// 是否启用上标/下标
  final bool superSubScript;

  /// 是否启用脚注
  final bool footnote;

  /// 是否启用 HTML 渲染
  final bool isHtmlEnabled;

  /// 是否启用 GitLab 兼容模式
  final bool isGitlabCompatibilityEnabled;

  /// 序列图主题
  final SequenceTheme sequenceTheme;

  // ============ Theme（主题设置） ============

  /// 当前主题
  final String theme;

  /// 是否跟随系统主题
  final bool followSystemTheme;

  /// 亮色模式主题
  final String lightModeTheme;

  /// 暗色模式主题
  final String darkModeTheme;

  /// 自定义 CSS
  final String customCss;

  // ============ Spelling（拼写检查） ============

  /// 是否启用拼写检查
  final bool spellcheckerEnabled;

  /// 是否隐藏拼写错误下划线
  final bool spellcheckerNoUnderline;

  /// 拼写检查语言
  final String spellcheckerLanguage;

  // ============ Image（图片设置） ============

  /// 图片插入行为
  final ImageInsertAction imageInsertAction;

  /// 是否偏好相对路径图片目录
  final bool imagePreferRelativeDirectory;

  /// 图片相对路径基准
  final ImageRelativeDirectoryBase imageRelativeDirectoryBase;

  /// 图片相对路径目录名
  final String imageRelativeDirectoryName;

  // ============ View（视图设置，内部状态） ============

  /// 侧边栏是否可见
  final bool sideBarVisibility;

  /// 标签栏是否可见
  final bool tabBarVisibility;

  /// 是否默认启用源码模式
  final bool sourceCodeModeEnabled;

  // ============ Search（搜索设置，内部状态） ============

  /// 搜索排除的 glob 模式列表
  final List<String> searchExclusions;

  /// 搜索最大文件大小
  final String searchMaxFileSize;

  /// 是否搜索隐藏文件
  final bool searchIncludeHidden;

  /// 是否忽略 .gitignore 等文件
  final bool searchNoIgnore;

  /// 是否跟随符号链接
  final bool searchFollowSymlinks;

  // ============ Watcher（监视器设置） ============

  /// 是否使用轮询监视文件变化
  final bool watcherUsePolling;

  const AppSettings({
    // General
    this.autoSave = false,
    this.autoSaveDelay = 5000,
    this.titleBarStyle = TitleBarStyle.custom,
    this.openFilesInNewWindow = false,
    this.openFolderInNewWindow = false,
    this.zoom = 1.0,
    this.hideScrollbar = false,
    this.wordWrapInToc = false,
    this.fileSortBy = FileSortBy.modified,
    this.lastOpenedFolder = '',
    this.startUpAction = StartUpAction.restoreAll,
    this.defaultDirectoryToOpen = '',
    this.language = 'en',
    this.restoreLayoutState = true,
    // Editor
    this.editorFontFamily = 'Open Sans',
    this.fontSize = 16,
    this.lineHeight = 1.6,
    this.wrapCodeBlocks = true,
    this.editorLineWidth = '',
    this.codeFontSize = 14,
    this.codeFontFamily = 'DejaVu Sans Mono',
    this.codeBlockLineNumbers = true,
    this.trimUnnecessaryCodeBlockEmptyLines = true,
    this.autoPairBracket = true,
    this.autoPairMarkdownSyntax = true,
    this.autoPairQuote = true,
    this.endOfLine = EndOfLine.defaultEnding,
    this.defaultEncoding = 'utf8',
    this.autoGuessEncoding = true,
    this.trimTrailingNewline = TrimTrailingNewline.ensureExactlyOne,
    this.textDirection = EditorTextDirection.ltr,
    this.hideQuickInsertHint = false,
    this.hideLinkPopup = false,
    this.autoCheck = false,
    this.autoNormalizeLineEndings = false,
    // Markdown
    this.preferLooseListItem = true,
    this.bulletListMarker = BulletListMarker.dash,
    this.orderListDelimiter = OrderListDelimiter.dot,
    this.preferHeadingStyle = HeadingStyle.atx,
    this.tabSize = 4,
    this.listIndentation = '1',
    this.frontmatterType = FrontmatterType.dash,
    this.superSubScript = false,
    this.footnote = false,
    this.isHtmlEnabled = true,
    this.isGitlabCompatibilityEnabled = false,
    this.sequenceTheme = SequenceTheme.hand,
    // Theme
    this.theme = 'light',
    this.followSystemTheme = false,
    this.lightModeTheme = 'light',
    this.darkModeTheme = 'dark',
    this.customCss = '',
    // Spelling
    this.spellcheckerEnabled = false,
    this.spellcheckerNoUnderline = false,
    this.spellcheckerLanguage = 'en-US',
    // Image
    this.imageInsertAction = ImageInsertAction.path,
    this.imagePreferRelativeDirectory = false,
    this.imageRelativeDirectoryBase = ImageRelativeDirectoryBase.file,
    this.imageRelativeDirectoryName = 'assets',
    // View
    this.sideBarVisibility = false,
    this.tabBarVisibility = false,
    this.sourceCodeModeEnabled = false,
    // Search
    this.searchExclusions = const [],
    this.searchMaxFileSize = '',
    this.searchIncludeHidden = false,
    this.searchNoIgnore = false,
    this.searchFollowSymlinks = true,
    // Watcher
    this.watcherUsePolling = false,
  });

  /// 创建副本并修改指定字段
  AppSettings copyWith({
    bool? autoSave,
    int? autoSaveDelay,
    TitleBarStyle? titleBarStyle,
    bool? openFilesInNewWindow,
    bool? openFolderInNewWindow,
    double? zoom,
    bool? hideScrollbar,
    bool? wordWrapInToc,
    FileSortBy? fileSortBy,
    String? lastOpenedFolder,
    StartUpAction? startUpAction,
    String? defaultDirectoryToOpen,
    String? language,
    bool? restoreLayoutState,
    String? editorFontFamily,
    int? fontSize,
    double? lineHeight,
    bool? wrapCodeBlocks,
    String? editorLineWidth,
    int? codeFontSize,
    String? codeFontFamily,
    bool? codeBlockLineNumbers,
    bool? trimUnnecessaryCodeBlockEmptyLines,
    bool? autoPairBracket,
    bool? autoPairMarkdownSyntax,
    bool? autoPairQuote,
    EndOfLine? endOfLine,
    String? defaultEncoding,
    bool? autoGuessEncoding,
    TrimTrailingNewline? trimTrailingNewline,
    EditorTextDirection? textDirection,
    bool? hideQuickInsertHint,
    bool? hideLinkPopup,
    bool? autoCheck,
    bool? autoNormalizeLineEndings,
    bool? preferLooseListItem,
    BulletListMarker? bulletListMarker,
    OrderListDelimiter? orderListDelimiter,
    HeadingStyle? preferHeadingStyle,
    int? tabSize,
    String? listIndentation,
    FrontmatterType? frontmatterType,
    bool? superSubScript,
    bool? footnote,
    bool? isHtmlEnabled,
    bool? isGitlabCompatibilityEnabled,
    SequenceTheme? sequenceTheme,
    String? theme,
    bool? followSystemTheme,
    String? lightModeTheme,
    String? darkModeTheme,
    String? customCss,
    bool? spellcheckerEnabled,
    bool? spellcheckerNoUnderline,
    String? spellcheckerLanguage,
    ImageInsertAction? imageInsertAction,
    bool? imagePreferRelativeDirectory,
    ImageRelativeDirectoryBase? imageRelativeDirectoryBase,
    String? imageRelativeDirectoryName,
    bool? sideBarVisibility,
    bool? tabBarVisibility,
    bool? sourceCodeModeEnabled,
    List<String>? searchExclusions,
    String? searchMaxFileSize,
    bool? searchIncludeHidden,
    bool? searchNoIgnore,
    bool? searchFollowSymlinks,
    bool? watcherUsePolling,
  }) {
    return AppSettings(
      autoSave: autoSave ?? this.autoSave,
      autoSaveDelay: autoSaveDelay ?? this.autoSaveDelay,
      titleBarStyle: titleBarStyle ?? this.titleBarStyle,
      openFilesInNewWindow: openFilesInNewWindow ?? this.openFilesInNewWindow,
      openFolderInNewWindow:
          openFolderInNewWindow ?? this.openFolderInNewWindow,
      zoom: zoom ?? this.zoom,
      hideScrollbar: hideScrollbar ?? this.hideScrollbar,
      wordWrapInToc: wordWrapInToc ?? this.wordWrapInToc,
      fileSortBy: fileSortBy ?? this.fileSortBy,
      lastOpenedFolder: lastOpenedFolder ?? this.lastOpenedFolder,
      startUpAction: startUpAction ?? this.startUpAction,
      defaultDirectoryToOpen:
          defaultDirectoryToOpen ?? this.defaultDirectoryToOpen,
      language: language ?? this.language,
      restoreLayoutState: restoreLayoutState ?? this.restoreLayoutState,
      editorFontFamily: editorFontFamily ?? this.editorFontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      wrapCodeBlocks: wrapCodeBlocks ?? this.wrapCodeBlocks,
      editorLineWidth: editorLineWidth ?? this.editorLineWidth,
      codeFontSize: codeFontSize ?? this.codeFontSize,
      codeFontFamily: codeFontFamily ?? this.codeFontFamily,
      codeBlockLineNumbers:
          codeBlockLineNumbers ?? this.codeBlockLineNumbers,
      trimUnnecessaryCodeBlockEmptyLines: trimUnnecessaryCodeBlockEmptyLines ??
          this.trimUnnecessaryCodeBlockEmptyLines,
      autoPairBracket: autoPairBracket ?? this.autoPairBracket,
      autoPairMarkdownSyntax:
          autoPairMarkdownSyntax ?? this.autoPairMarkdownSyntax,
      autoPairQuote: autoPairQuote ?? this.autoPairQuote,
      endOfLine: endOfLine ?? this.endOfLine,
      defaultEncoding: defaultEncoding ?? this.defaultEncoding,
      autoGuessEncoding: autoGuessEncoding ?? this.autoGuessEncoding,
      trimTrailingNewline: trimTrailingNewline ?? this.trimTrailingNewline,
      textDirection: textDirection ?? this.textDirection,
      hideQuickInsertHint: hideQuickInsertHint ?? this.hideQuickInsertHint,
      hideLinkPopup: hideLinkPopup ?? this.hideLinkPopup,
      autoCheck: autoCheck ?? this.autoCheck,
      autoNormalizeLineEndings:
          autoNormalizeLineEndings ?? this.autoNormalizeLineEndings,
      preferLooseListItem: preferLooseListItem ?? this.preferLooseListItem,
      bulletListMarker: bulletListMarker ?? this.bulletListMarker,
      orderListDelimiter: orderListDelimiter ?? this.orderListDelimiter,
      preferHeadingStyle: preferHeadingStyle ?? this.preferHeadingStyle,
      tabSize: tabSize ?? this.tabSize,
      listIndentation: listIndentation ?? this.listIndentation,
      frontmatterType: frontmatterType ?? this.frontmatterType,
      superSubScript: superSubScript ?? this.superSubScript,
      footnote: footnote ?? this.footnote,
      isHtmlEnabled: isHtmlEnabled ?? this.isHtmlEnabled,
      isGitlabCompatibilityEnabled:
          isGitlabCompatibilityEnabled ?? this.isGitlabCompatibilityEnabled,
      sequenceTheme: sequenceTheme ?? this.sequenceTheme,
      theme: theme ?? this.theme,
      followSystemTheme: followSystemTheme ?? this.followSystemTheme,
      lightModeTheme: lightModeTheme ?? this.lightModeTheme,
      darkModeTheme: darkModeTheme ?? this.darkModeTheme,
      customCss: customCss ?? this.customCss,
      spellcheckerEnabled: spellcheckerEnabled ?? this.spellcheckerEnabled,
      spellcheckerNoUnderline:
          spellcheckerNoUnderline ?? this.spellcheckerNoUnderline,
      spellcheckerLanguage: spellcheckerLanguage ?? this.spellcheckerLanguage,
      imageInsertAction: imageInsertAction ?? this.imageInsertAction,
      imagePreferRelativeDirectory:
          imagePreferRelativeDirectory ?? this.imagePreferRelativeDirectory,
      imageRelativeDirectoryBase:
          imageRelativeDirectoryBase ?? this.imageRelativeDirectoryBase,
      imageRelativeDirectoryName:
          imageRelativeDirectoryName ?? this.imageRelativeDirectoryName,
      sideBarVisibility: sideBarVisibility ?? this.sideBarVisibility,
      tabBarVisibility: tabBarVisibility ?? this.tabBarVisibility,
      sourceCodeModeEnabled:
          sourceCodeModeEnabled ?? this.sourceCodeModeEnabled,
      searchExclusions: searchExclusions ?? this.searchExclusions,
      searchMaxFileSize: searchMaxFileSize ?? this.searchMaxFileSize,
      searchIncludeHidden: searchIncludeHidden ?? this.searchIncludeHidden,
      searchNoIgnore: searchNoIgnore ?? this.searchNoIgnore,
      searchFollowSymlinks: searchFollowSymlinks ?? this.searchFollowSymlinks,
      watcherUsePolling: watcherUsePolling ?? this.watcherUsePolling,
    );
  }
}
