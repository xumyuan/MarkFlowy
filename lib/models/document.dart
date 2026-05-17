/// 文档数据模型
/// 参考: marktext/src/main/editorBufferStore/index.js
///
/// EditorBufferStore 管理多个窗口/标签页的文档状态，
/// 每个文档包含路径、内容、保存状态、编码等信息。
/// 这里翻译为 Dart 中的不可变数据模型。
library;

/// 单个文档（标签页）的状态
/// 对应 marktext buffer store 中 tabs 数组的每一项
class Document {
  /// 文档唯一标识符
  final String id;

  /// 文件路径（未保存的文档为空字符串）
  final String filePath;

  /// 文件名（从路径提取或 "Untitled"）
  final String filename;

  /// 文档的 Markdown 内容
  final String content;

  /// 是否已保存（对应 marktext 的 isSaved）
  final bool isSaved;

  /// 文件编码（如 utf8, gbk 等）
  final String encoding;

  /// 是否有 BOM 标记
  final bool hasBom;

  /// 行尾符类型（lf, crlf, 或空表示跟随系统默认）
  final String lineEnding;

  /// 文档创建时间
  final DateTime createdAt;

  /// 最后修改时间
  final DateTime lastModifiedAt;

  /// 光标位置（行号）
  final int cursorLine;

  /// 光标位置（列号）
  final int cursorColumn;

  /// 滚动位置
  final double scrollOffset;

  /// 是否处于源码模式
  final bool isSourceMode;

  const Document({
    required this.id,
    this.filePath = '',
    this.filename = 'Untitled',
    this.content = '',
    this.isSaved = true,
    this.encoding = 'utf8',
    this.hasBom = false,
    this.lineEnding = '',
    required this.createdAt,
    required this.lastModifiedAt,
    this.cursorLine = 0,
    this.cursorColumn = 0,
    this.scrollOffset = 0.0,
    this.isSourceMode = false,
  });

  /// 创建一个新的空白文档
  factory Document.empty() {
    final now = DateTime.now();
    return Document(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: now,
      lastModifiedAt: now,
    );
  }

  /// 是否为新建的未保存文档
  bool get isUntitled => filePath.isEmpty;

  /// 文档是否被修改（未保存）
  bool get isModified => !isSaved;

  /// 创建副本并修改指定字段
  Document copyWith({
    String? id,
    String? filePath,
    String? filename,
    String? content,
    bool? isSaved,
    String? encoding,
    bool? hasBom,
    String? lineEnding,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    int? cursorLine,
    int? cursorColumn,
    double? scrollOffset,
    bool? isSourceMode,
  }) {
    return Document(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      filename: filename ?? this.filename,
      content: content ?? this.content,
      isSaved: isSaved ?? this.isSaved,
      encoding: encoding ?? this.encoding,
      hasBom: hasBom ?? this.hasBom,
      lineEnding: lineEnding ?? this.lineEnding,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      cursorLine: cursorLine ?? this.cursorLine,
      cursorColumn: cursorColumn ?? this.cursorColumn,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      isSourceMode: isSourceMode ?? this.isSourceMode,
    );
  }
}

/// 编辑器缓冲区状态（对应 marktext 的 EditorBufferStore）
/// 管理一个窗口中所有打开的标签页
class EditorBufferState {
  /// 缓冲区唯一标识（对应 restoreBufferId）
  final String bufferId;

  /// 所有打开的文档标签页
  final List<Document> tabs;

  /// 当前活动标签页的索引
  final int activeTabIndex;

  const EditorBufferState({
    required this.bufferId,
    this.tabs = const [],
    this.activeTabIndex = 0,
  });

  /// 当前活动的文档
  Document? get activeDocument =>
      tabs.isNotEmpty && activeTabIndex < tabs.length
          ? tabs[activeTabIndex]
          : null;

  /// 是否所有文档都已保存（对应 marktext 的 allSaved 检查）
  bool get allSaved => tabs.every((doc) => doc.isSaved);

  /// 创建副本并修改指定字段
  EditorBufferState copyWith({
    String? bufferId,
    List<Document>? tabs,
    int? activeTabIndex,
  }) {
    return EditorBufferState(
      bufferId: bufferId ?? this.bufferId,
      tabs: tabs ?? this.tabs,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
    );
  }
}
