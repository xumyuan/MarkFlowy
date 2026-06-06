/// WYSIWYG 编辑器组件
/// 参考: appflowy_editor 6.2.0 官方 desktop_editor.dart 示例
/// 参考: marktext/src/muya/ — Muya 编辑器引擎功能对照
///
/// 功能:
/// - WYSIWYG 所见即所得 Markdown 编辑
/// - 打字机模式（typewriter）：光标始终垂直居中
/// - 焦点模式（focus）：高亮当前段落，淡化其他内容
/// - 浮动工具栏（FloatingToolbar）
/// - 内容同步（通过 GlobalKey 暴露 getMarkdown）
/// - 代码块语法高亮（自定义 CodeBlockComponentBuilder）
library;

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

import '../../utils/markdown_utils.dart';
import 'code_block.dart';

/// 合并标准组件构建器和自定义构建器的映射
///
/// appflowy_editor 6.2.0 不原生支持 code_block 节点类型，
/// 这里注册自定义的代码块构建器（语法高亮）
final Map<String, BlockComponentBuilder> _blockComponentBuilders = {
  ...standardBlockComponentBuilderMap,
  CodeBlockKeys.type: CodeBlockComponentBuilder(),
};

/// WYSIWYG 所见即所得编辑器
class WysiwygEditor extends StatefulWidget {
  /// 初始 Markdown 内容
  final String initialContent;

  /// 内容变化回调
  final ValueChanged<String>? onContentChanged;

  /// 是否自动获取焦点
  final bool autoFocus;

  /// 是否启用打字机模式（对应 marktext typewriter mode）
  final bool typewriterMode;

  /// 是否启用焦点模式（对应 marktext focus mode）
  final bool focusMode;

  const WysiwygEditor({
    super.key,
    this.initialContent = '',
    this.onContentChanged,
    this.autoFocus = true,
    this.typewriterMode = false,
    this.focusMode = false,
  });

  @override
  State<WysiwygEditor> createState() => WysiwygEditorState();
}

class WysiwygEditorState extends State<WysiwygEditor> {
  late EditorState _editorState;
  late EditorScrollController _scrollController;

  /// 最后一次从外部同步的内容（用于判断是否需要更新编辑器）
  String _lastExternalContent = '';

  /// 内部变更追踪，避免循环更新
  bool _isInternalChange = false;

  /// 编辑器是否已初始化
  bool _initialized = false;

  /// 编辑器代数 —— 每次重建 EditorState 自增，
  /// 用于强制 Flutter 重建 AppFlowyEditor 的 State（否则会复用旧 EditorState）
  int _editorGeneration = 0;

  @override
  void initState() {
    super.initState();
    _lastExternalContent = widget.initialContent;
    _initEditor();
  }

  void _initEditor() {
    final document = MarkdownUtils.createDocumentFromContent(
      widget.initialContent,
    );
    _editorState = EditorState(document: document);

    _scrollController = EditorScrollController(
      editorState: _editorState,
      shrinkWrap: false,
    );

    // 监听内容变化
    _editorState.transactionStream.listen((event) {
      if (event.$1 == TransactionTime.after && _initialized) {
        _isInternalChange = true;
        final markdown = MarkdownUtils.docToMarkdown(_editorState.document);
        _lastExternalContent = markdown;
        widget.onContentChanged?.call(markdown);
        _isInternalChange = false;
      }
    });

    // 初始化后自动设置光标到第一个节点
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_editorState.document.root.children.isNotEmpty) {
          _editorState.selection = Selection.collapsed(
            Position(path: [0]),
          );
        }
        _initialized = true;
      });
    } else {
      _initialized = true;
    }
  }

  @override
  void didUpdateWidget(WysiwygEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当外部内容变化且不是内部编辑导致时，重新加载编辑器内容
    if (!_isInternalChange &&
        oldWidget.initialContent != widget.initialContent &&
        widget.initialContent != _lastExternalContent) {
      _reloadContent(widget.initialContent);
    }
  }

  /// 重新加载编辑器内容（切换文档时）
  void _reloadContent(String markdown) {
    _lastExternalContent = markdown;
    _editorState.dispose();
    _scrollController.dispose();
    final document = MarkdownUtils.createDocumentFromContent(markdown);
    _editorState = EditorState(document: document);
    _scrollController = EditorScrollController(
      editorState: _editorState,
      shrinkWrap: false,
    );

    // 重新注册事务监听器（原来的已被 dispose 移除）
    _editorState.transactionStream.listen((event) {
      if (event.$1 == TransactionTime.after && _initialized) {
        _isInternalChange = true;
        final newMarkdown = MarkdownUtils.docToMarkdown(_editorState.document);
        _lastExternalContent = newMarkdown;
        widget.onContentChanged?.call(newMarkdown);
        _isInternalChange = false;
      }
    });

    // 递增代数：强制 Flutter 重建 AppFlowyEditor 的 State
    // 否则 AppFlowyEditor 会复用旧的 State，继续引用已 dispose 的旧 EditorState
    _editorGeneration++;
    setState(() {});
  }

  /// 加载新文档内容（外部调用，如标签切换）
  void loadContent(String markdown) {
    _lastExternalContent = markdown;
    _reloadContent(markdown);
  }

  @override
  void dispose() {
    _editorState.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: FloatingToolbar(
        items: [
          paragraphItem,
          ...headingItems,
          ...markdownFormatItems,
          quoteItem,
          bulletedListItem,
          numberedListItem,
          linkItem,
          buildTextColorItem(),
          buildHighlightColorItem(),
        ],
        editorState: _editorState,
        editorScrollController: _scrollController,
        textDirection: TextDirection.ltr,
        child: AppFlowyEditor(
          key: ValueKey('editor_gen_$_editorGeneration'),
          editorState: _editorState,
          editorScrollController: _scrollController,
          autoFocus: widget.autoFocus,
          editorStyle: _buildEditorStyle(context),
          blockComponentBuilders: _blockComponentBuilders,
          commandShortcutEvents: standardCommandShortcutEvents,
          footer: _buildFooter(),
        ),
      ),
    );
  }

  /// 编辑器样式（支持打字机模式的大间距）
  EditorStyle _buildEditorStyle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 打字机模式：使用超大垂直间距让光标保持屏幕中央
    // 对应 marktext typewriter CSS: padding-top/bottom: calc(50vh - 2em)
    final verticalPadding = widget.typewriterMode
        ? MediaQuery.of(context).size.height * 0.35
        : 24.0;

    return EditorStyle.desktop(
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: verticalPadding),
      cursorColor: theme.colorScheme.primary,
      selectionColor: theme.colorScheme.primary.withValues(alpha: 0.3),
      // 改善内联代码和文本样式
      textStyleConfiguration: TextStyleConfiguration(
        text: TextStyle(
          fontSize: 16,
          height: 1.8,
          color: isDark ? const Color(0xFFD4D4D4) : const Color(0xFF24292F),
        ),
        bold: const TextStyle(fontWeight: FontWeight.w700),
        code: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          backgroundColor: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
        href: TextStyle(
          color: isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA),
          decoration: TextDecoration.underline,
        ),
        lineHeight: 1.8,
      ),
    );
  }

  /// 底部空白区域，点击时创建新段落并聚焦
  Widget _buildFooter() {
    // 打字机模式下也需要底部留白
    final extraHeight = widget.typewriterMode ? 300.0 : 100.0;
    return SizedBox(
      height: extraHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          if (_editorState.document.root.children.isEmpty) {
            final transaction = _editorState.transaction;
            transaction.insertNode([0], paragraphNode());
            await _editorState.apply(transaction);
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final lastIndex =
                _editorState.document.root.children.length - 1;
            if (lastIndex >= 0) {
              _editorState.selection = Selection.collapsed(
                Position(path: [lastIndex]),
              );
            }
          });
        },
      ),
    );
  }

  /// 获取当前文档的 Markdown 内容（供外部保存/搜索/模式切换时使用）
  String getMarkdown() {
    return MarkdownUtils.docToMarkdown(_editorState.document);
  }

  /// 获取编辑器状态（供高级操作使用）
  EditorState get editorState => _editorState;
}
