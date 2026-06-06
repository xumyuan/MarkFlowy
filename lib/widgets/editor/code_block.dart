/// 代码块节点定义、解析器和渲染器
///
/// appflowy_editor 6.2.0 不原生支持 fenced code blocks，
/// 这里实现自定义的 markdown → 节点 解析 和 节点 → widget 渲染。
library;

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';

// ============ 节点类型定义 ============

class CodeBlockKeys {
  CodeBlockKeys._();
  static const String type = 'code_block';
  static const String language = 'language';
  static const String code = 'code';
}

Node codeBlockNode({required String code, String language = ''}) {
  return Node(type: CodeBlockKeys.type, attributes: {
    CodeBlockKeys.language: language,
    CodeBlockKeys.code: code,
  });
}

// ============ Markdown → 节点 解析器 ============

class CodeBlockMarkdownParser extends CustomMarkdownParser {
  const CodeBlockMarkdownParser();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownParser> parsers, {
    MarkdownListType listType = MarkdownListType.unknown,
    int? startNumber,
  }) {
    if (element is! md.Element || element.tag != 'pre') return [];

    md.Element? codeEl;
    for (final c in element.children ?? <md.Node>[]) {
      if (c is md.Element && c.tag == 'code') { codeEl = c; break; }
    }
    if (codeEl == null) return [];

    String lang = '';
    final cls = codeEl.attributes['class'];
    if (cls != null && cls.startsWith('language-')) {
      lang = cls.substring('language-'.length);
    }

    return [codeBlockNode(code: codeEl.textContent, language: lang)];
  }
}

// ============ 节点 → Markdown 编码器 ============

class CustomCodeBlockNodeParser extends NodeParser {
  const CustomCodeBlockNodeParser();

  @override
  String get id => 'code_block_encoder';

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final lang = node.attributes[CodeBlockKeys.language] ?? '';
    final code = node.attributes[CodeBlockKeys.code] ?? '';
    return '```$lang\n$code\n```\n';
  }
}

// ============ 渲染器 ============

class CodeBlockComponentBuilder extends BlockComponentBuilder {
  CodeBlockComponentBuilder({super.configuration});

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return _CodeBlockWidget(
      key: node.key,
      node: node,
      showActions: showActions(node),
      configuration: configuration,
      actionBuilder: (c, s) => actionBuilder(blockComponentContext, s),
      actionTrailingBuilder: (c, s) =>
          actionTrailingBuilder(blockComponentContext, s),
    );
  }

  @override
  BlockComponentValidate get validate =>
      (node) => node.type == CodeBlockKeys.type;
}

class _CodeBlockWidget extends BlockComponentStatefulWidget {
  const _CodeBlockWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.actionTrailingBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  @override
  State<_CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<_CodeBlockWidget>
    with SelectableMixin, BlockComponentConfigurable {
  final _key = GlobalKey();
  RenderBox? get _renderBox => context.findRenderObject() as RenderBox?;

  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  @override
  Widget build(BuildContext context) {
    final editorState = context.read<EditorState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = node.attributes[CodeBlockKeys.language] ?? '';
    final code = node.attributes[CodeBlockKeys.code] ?? '';

    // 代码内容
    Widget content;
    if (code.trim().isEmpty) {
      content = _emptyPlaceholder(isDark, lang);
    } else {
      content = HighlightView(
        code,
        language: lang.isNotEmpty ? lang : 'plaintext',
        theme: isDark ? _darkTheme : githubTheme,
        padding: const EdgeInsets.all(16),
        textStyle:
            const TextStyle(fontFamily: 'monospace', fontSize: 13),
      );
    }

    // 语言标签
    Widget child = lang.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _langBar(isDark, lang),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8)),
                child: content,
              ),
            ],
          )
        : content;

    // padding + key（用于 getRectsInSelection 定位）
    child = Padding(key: _key, padding: padding, child: child);

    // BlockSelectionContainer
    child = BlockSelectionContainer(
      node: node,
      delegate: this,
      listenable: editorState.selectionNotifier,
      remoteSelection: editorState.remoteSelections,
      blockColor: editorState.editorStyle.selectionColor,
      cursorColor: editorState.editorStyle.cursorColor,
      selectionColor: editorState.editorStyle.selectionColor,
      supportTypes: BlockSelectionType.values,
      child: child,
    );

    return child;
  }

  Widget _emptyPlaceholder(bool isDark, String lang) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          lang.isNotEmpty ? '$lang (empty)' : 'Empty code block',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: isDark
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.4),
          ),
        ),
      );

  Widget _langBar(bool isDark, String lang) => Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color:
              isDark ? const Color(0xFF161B22) : const Color(0xFFEBECF0),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8)),
        ),
        child: Text(
          lang,
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'monospace',
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.5),
          ),
        ),
      );

  // ========== SelectableMixin ==========

  @override
  Position start() => Position(path: node.path, offset: 0);

  @override
  Position end() => Position(path: node.path, offset: 1);

  @override
  Position getPositionInOffset(Offset start) => end();

  @override
  bool get shouldCursorBlink => false;

  @override
  CursorStyle get cursorStyle => CursorStyle.cover;

  @override
  Rect getBlockRect({bool shiftWithBaseOffset = false}) =>
      getRectsInSelection(Selection.invalid(),
          shiftWithBaseOffset: shiftWithBaseOffset).first;

  @override
  Rect? getCursorRectInPosition(Position position,
          {bool shiftWithBaseOffset = false}) =>
      getRectsInSelection(Selection.collapsed(position),
              shiftWithBaseOffset: shiftWithBaseOffset)
          .firstOrNull;

  @override
  List<Rect> getRectsInSelection(Selection selection,
      {bool shiftWithBaseOffset = false}) {
    final renderBox = _renderBox;
    if (renderBox == null) return [];
    final parentBox = context.findRenderObject();
    final innerBox = _key.currentContext?.findRenderObject();
    if (parentBox is RenderBox && innerBox is RenderBox) {
      return [
        (shiftWithBaseOffset
                ? innerBox.localToGlobal(Offset.zero, ancestor: parentBox)
                : Offset.zero) &
            innerBox.size
      ];
    }
    return [Offset.zero & renderBox.size];
  }

  @override
  Selection getSelectionInRange(Offset start, Offset end) =>
      Selection.single(path: node.path, startOffset: 0, endOffset: 1);

  @override
  Offset localToGlobal(Offset offset,
          {bool shiftWithBaseOffset = false}) =>
      _renderBox!.localToGlobal(offset);

  static final _darkTheme = {
    'root': const TextStyle(
        backgroundColor: Color(0xFF0D1117), color: Color(0xFFC9D1D9)),
    'comment': const TextStyle(
        color: Color(0xFF8B949E), fontStyle: FontStyle.italic),
    'keyword': const TextStyle(color: Color(0xFFFF7B72)),
    'string': const TextStyle(color: Color(0xFFA5D6FF)),
    'number': const TextStyle(color: Color(0xFF79C0FF)),
    'title': const TextStyle(color: Color(0xFFD2A8FF)),
    'type': const TextStyle(color: Color(0xFFFFA657)),
    'function': const TextStyle(color: Color(0xFFD2A8FF)),
    'built_in': const TextStyle(color: Color(0xFFFFA657)),
  };
}
