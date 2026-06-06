/// Markdown ↔ AppFlowy Editor Document 转换工具
/// 参考: marktext/src/muya/lib/contentState/marktext.js 中的 markdown 解析逻辑
///
/// 使用 appflowy_editor 内置的 Markdown 转换 API 实现:
/// - markdown 字符串 → appflowy_editor Document（加载文件时）
/// - appflowy_editor Document → markdown 字符串（保存文件时）
library;

import 'package:appflowy_editor/appflowy_editor.dart';

import '../widgets/editor/code_block.dart';

/// Markdown 工具类
/// 封装 appflowy_editor 的 Markdown 转换功能
class MarkdownUtils {
  MarkdownUtils._();

  /// 自定义 markdown 解析器（用于解析 appflowy_editor 不原生支持的语法）
  static const _customMarkdownParsers = [
    CodeBlockMarkdownParser(),
  ];

  /// 自定义节点编码器（用于将自定义节点导出为 markdown）
  static const _customNodeParsers = [
    CustomCodeBlockNodeParser(),
  ];

  /// 将 Markdown 字符串转换为 appflowy_editor Document
  /// 用于加载文件时将 Markdown 内容渲染到编辑器中
  ///
  /// 对应 marktext editor.vue onMounted 中:
  /// `editor.value = new Muya(ele, { markdown: props.markdown, ... })`
  static Document markdownToDoc(String markdown) {
    return markdownToDocument(
      markdown,
      markdownParsers: _customMarkdownParsers,
    );
  }

  /// 将 appflowy_editor Document 转换为 Markdown 字符串
  /// 用于保存文件时从编辑器导出 Markdown 内容
  ///
  /// 对应 marktext contentState 中的 getMarkdown() 方法
  static String docToMarkdown(Document document) {
    return documentToMarkdown(
      document,
      customParsers: _customNodeParsers,
    );
  }

  /// 创建一个空白文档（包含一个空段落）
  /// 对应 marktext 中新建文件时的初始状态
  /// 确保文档至少有一个 paragraph 节点，以便 appflowy_editor 能正常获取焦点
  static Document createEmptyDocument() {
    final doc = Document.blank();
    // Document.blank() 可能创建没有子节点的空文档，确保至少有一个段落节点
    if (doc.root.children.isEmpty) {
      doc.insert([0], [paragraphNode()]);
    }
    return doc;
  }

  /// 从 Markdown 内容创建带有初始光标位置的文档
  static Document createDocumentFromContent(String content) {
    if (content.isEmpty) {
      return createEmptyDocument();
    }
    return markdownToDoc(content);
  }
}
