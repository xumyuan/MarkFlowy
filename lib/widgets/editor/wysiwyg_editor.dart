/// WYSIWYG 编辑器组件
/// 参考: marktext/src/renderer/src/components/editorWithTabs/editor.vue
///
/// 使用 appflowy_editor 替代 Muya 编辑器，还原以下核心功能:
/// - 富文本编辑（粗体、斜体、下划线、删除线、代码等）
/// - 块级元素（标题、段落、引用、列表、代码块、表格等）
/// - 浮动工具栏（选中文字弹出格式栏 — 对应 muya formatPicker）
/// - Slash command（输入 / 弹出块插入菜单 — 对应 muya quickInsert）
/// - 内置 undo/redo（对应 muya history.js）
library;

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

import '../../utils/markdown_utils.dart';

/// WYSIWYG 所见即所得编辑器
/// 封装 appflowy_editor + FloatingToolbar，对应 marktext 的 Muya 编辑器
class WysiwygEditor extends StatefulWidget {
  /// 初始 Markdown 内容
  final String initialContent;

  /// 内容变化回调（对应 muya editor.on('change', ...)）
  final ValueChanged<String>? onContentChanged;

  /// 是否自动获取焦点
  final bool autoFocus;

  const WysiwygEditor({
    super.key,
    this.initialContent = '',
    this.onContentChanged,
    this.autoFocus = true,
  });

  @override
  State<WysiwygEditor> createState() => _WysiwygEditorState();
}

class _WysiwygEditorState extends State<WysiwygEditor> {
  late EditorState _editorState;
  late EditorScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _initEditor();
  }

  void _initEditor() {
    // 将 Markdown 内容转换为 appflowy_editor Document
    // 对应 marktext editor.vue onMounted 中 new Muya(ele, { markdown })
    final document = MarkdownUtils.createDocumentFromContent(
      widget.initialContent,
    );
    _editorState = EditorState(document: document);

    _scrollController = EditorScrollController(
      editorState: _editorState,
    );

    // 监听内容变化（对应 muya editor.on('change', ...)）
    _editorState.transactionStream.listen((_) {
      if (widget.onContentChanged != null) {
        final markdown = MarkdownUtils.docToMarkdown(
          _editorState.document,
        );
        widget.onContentChanged!(markdown);
      }
    });
  }

  @override
  void didUpdateWidget(WysiwygEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当外部内容变化时重新初始化（对应 marktext file-changed 事件）
    if (oldWidget.initialContent != widget.initialContent) {
      _editorState.dispose();
      _scrollController.dispose();
      _initEditor();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _editorState.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 FloatingToolbar 包裹编辑器
    // 对应 marktext Muya.use(FormatPicker) — 选中文字时弹出格式化浮层
    return FloatingToolbar(
      items: _buildFloatingToolbarItems(),
      editorState: _editorState,
      editorScrollController: _scrollController,
      textDirection: TextDirection.ltr,
      style: _buildToolbarStyle(context),
      child: AppFlowyEditor(
        editorState: _editorState,
        editorScrollController: _scrollController,
        autoFocus: widget.autoFocus,
        editorStyle: _buildEditorStyle(context),
        // Slash command: 输入 / 弹出块插入菜单（对应 muya quickInsert）
        characterShortcutEvents: [
          slashCommand,
          ...standardCharacterShortcutEvents,
        ],
        // 键盘快捷键（对应 muya formatCtrl 中的快捷键）
        commandShortcutEvents: standardCommandShortcutEvents,
        // 块组件（对应 muya 各种 block 类型）
        blockComponentBuilders: _buildBlockComponentBuilders(),
      ),
    );
  }

  /// 构建浮动工具栏项（对应 marktext formatPicker/config.js 的 icons 列表）
  /// 包含: 段落/标题、粗体/斜体/下划线/删除线/代码、引用、列表、链接、颜色
  List<ToolbarItem> _buildFloatingToolbarItems() {
    return [
      paragraphItem,
      ...headingItems,
      ...markdownFormatItems,
      quoteItem,
      bulletedListItem,
      numberedListItem,
      linkItem,
      buildTextColorItem(),
      buildHighlightColorItem(),
    ];
  }

  /// 构建浮动工具栏样式
  FloatingToolbarStyle _buildToolbarStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FloatingToolbarStyle(
      backgroundColor: isDark ? const Color(0xFF333333) : Colors.black,
      toolbarActiveColor: Theme.of(context).colorScheme.primary,
      toolbarIconColor: Colors.white,
    );
  }

  /// 构建编辑器样式（对应 marktext editor-wrapper 的 CSS 样式）
  EditorStyle _buildEditorStyle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return EditorStyle.desktop(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 24),
      cursorColor: theme.colorScheme.primary,
      selectionColor: theme.colorScheme.primary.withValues(alpha: 0.3),
      textStyleConfiguration: TextStyleConfiguration(
        text: TextStyle(
          fontSize: 16,
          height: 1.6,
          color: isDark ? Colors.white : Colors.black87,
        ),
        code: TextStyle(
          fontSize: 14,
          fontFamily: 'monospace',
          color: isDark ? Colors.orange.shade200 : Colors.deepOrange,
          backgroundColor:
              isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
      ),
    );
  }

  /// 构建块组件（对应 muya 的各种 block 类型）
  Map<String, BlockComponentBuilder> _buildBlockComponentBuilders() {
    final configuration = BlockComponentConfiguration(
      padding: (_) => const EdgeInsets.symmetric(vertical: 2),
    );

    return {
      // 段落（对应 muya paragraphCtrl）
      ParagraphBlockKeys.type: ParagraphBlockComponentBuilder(
        configuration: configuration,
      ),
      // 标题 H1~H6（对应 muya paragraphCtrl 中的 heading）
      HeadingBlockKeys.type: HeadingBlockComponentBuilder(
        configuration: configuration,
      ),
      // 引用块（对应 muya paragraphCtrl 中的 blockquote）
      QuoteBlockKeys.type: QuoteBlockComponentBuilder(
        configuration: configuration,
      ),
      // 无序列表
      BulletedListBlockKeys.type: BulletedListBlockComponentBuilder(
        configuration: configuration,
      ),
      // 有序列表
      NumberedListBlockKeys.type: NumberedListBlockComponentBuilder(
        configuration: configuration,
      ),
      // 待办列表（对应 muya 的 task list）
      TodoListBlockKeys.type: TodoListBlockComponentBuilder(
        configuration: configuration,
      ),
      // 分割线
      DividerBlockKeys.type: DividerBlockComponentBuilder(
        configuration: configuration,
      ),
      // 图片块（对应 muya imageCtrl）
      ImageBlockKeys.type: ImageBlockComponentBuilder(
        configuration: configuration,
      ),
    };
  }

  /// 获取当前文档的 Markdown 内容
  /// 对应 marktext contentState.getMarkdown()
  String getMarkdown() {
    return MarkdownUtils.docToMarkdown(_editorState.document);
  }

  /// 设置新的 Markdown 内容
  /// 对应 marktext editor.setMarkdown(newMarkdown)
  void setMarkdown(String markdown) {
    final document = MarkdownUtils.markdownToDoc(markdown);
    _editorState.dispose();
    _scrollController.dispose();
    _editorState = EditorState(document: document);
    _scrollController = EditorScrollController(editorState: _editorState);
    setState(() {});
  }
}
