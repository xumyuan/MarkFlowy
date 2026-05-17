/// WYSIWYG 编辑器组件
/// 参考: appflowy_editor 6.2.0 官方 desktop_editor.dart 示例
///
/// 使用 appflowy_editor 替代 Muya 编辑器
library;

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

import '../../utils/markdown_utils.dart';

/// WYSIWYG 所见即所得编辑器
class WysiwygEditor extends StatefulWidget {
  /// 初始 Markdown 内容
  final String initialContent;

  /// 内容变化回调
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
      if (event.$1 == TransactionTime.after) {
        widget.onContentChanged?.call(
          MarkdownUtils.docToMarkdown(_editorState.document),
        );
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
      });
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
          editorState: _editorState,
          editorScrollController: _scrollController,
          autoFocus: widget.autoFocus,
          editorStyle: _buildEditorStyle(context),
          blockComponentBuilders: standardBlockComponentBuilderMap,
          commandShortcutEvents: standardCommandShortcutEvents,
          footer: _buildFooter(),
        ),
      ),
    );
  }

  /// 编辑器样式
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
      ),
    );
  }

  /// 底部空白区域，点击时创建新段落并聚焦
  /// 参考 appflowy_editor 官方 desktop_editor.dart 的 _buildFooter
  Widget _buildFooter() {
    return SizedBox(
      height: 100,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          // 如果文档为空，插入一个新段落节点
          if (_editorState.document.root.children.isEmpty) {
            final transaction = _editorState.transaction;
            transaction.insertNode([0], paragraphNode());
            await _editorState.apply(transaction);
          }
          // 聚焦到最后一个节点末尾
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

  /// 获取当前文档的 Markdown 内容
  String getMarkdown() {
    return MarkdownUtils.docToMarkdown(_editorState.document);
  }
}
