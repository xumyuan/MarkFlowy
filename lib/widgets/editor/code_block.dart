/// 代码块节点：解析器 + 渲染器
library;

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;

// ============ 节点 ============

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

// ============ 解析器 ============

class CodeBlockMarkdownParser extends CustomMarkdownParser {
  const CodeBlockMarkdownParser();

  @override
  List<Node> transform(
    md.Node element, List<CustomMarkdownParser> parsers, {
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

// ============ 编码器 ============

class CustomCodeBlockNodeParser extends NodeParser {
  const CustomCodeBlockNodeParser();
  @override String get id => 'code_block_encoder';
  @override String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final lang = node.attributes[CodeBlockKeys.language] ?? '';
    final code = node.attributes[CodeBlockKeys.code] ?? '';
    return '```$lang\n$code\n```\n';
  }
}

// ============ Builder ============

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
      actionTrailingBuilder: (c, s) => actionTrailingBuilder(blockComponentContext, s),
    );
  }

  @override
  BlockComponentValidate get validate => (node) => node.type == CodeBlockKeys.type;
}

// ============ Widget（最小化）============

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

  @override BlockComponentConfiguration get configuration => widget.configuration;
  @override Node get node => widget.node;

  @override
  Widget build(BuildContext context) {
    final lang = node.attributes[CodeBlockKeys.language] ?? '';
    final code = node.attributes[CodeBlockKeys.code] ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        border: Border.all(color: Colors.red, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lang.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('[$lang]', style: const TextStyle(
                fontFamily: 'monospace', fontSize: 11,
                fontWeight: FontWeight.bold, color: Colors.grey,
              )),
            ),
          SelectableText(
            code.trim().isEmpty ? '(empty)' : code,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }

  // ========== SelectableMixin（最小实现）==========
  @override Position start() => Position(path: node.path, offset: 0);
  @override Position end() => Position(path: node.path, offset: 1);
  @override Position getPositionInOffset(Offset start) => end();
  @override bool get shouldCursorBlink => false;
  @override CursorStyle get cursorStyle => CursorStyle.cover;
  @override Rect getBlockRect({bool shiftWithBaseOffset = false}) => Rect.zero;
  @override Rect? getCursorRectInPosition(Position p, {bool shiftWithBaseOffset = false}) => null;
  @override List<Rect> getRectsInSelection(Selection s, {bool shiftWithBaseOffset = false}) => [];
  @override Selection getSelectionInRange(Offset s, Offset e) =>
      Selection.single(path: node.path, startOffset: 0, endOffset: 1);
  @override Offset localToGlobal(Offset o, {bool shiftWithBaseOffset = false}) => o;
}
