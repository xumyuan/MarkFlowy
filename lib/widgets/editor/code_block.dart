/// 代码块节点：解析器 + 渲染器
///
/// appflowy_editor 6.2.0 不原生支持 fenced code blocks，
/// 这里实现 markdown → 节点 和 节点 → widget 的全链路。
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

// ============ 编码器 ============

class CustomCodeBlockNodeParser extends NodeParser {
  const CustomCodeBlockNodeParser();
  @override String get id => 'code_block_encoder';
  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
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
      actionTrailingBuilder: (c, s) =>
          actionTrailingBuilder(blockComponentContext, s),
    );
  }

  @override
  BlockComponentValidate get validate =>
      (node) => node.type == CodeBlockKeys.type;
}

// ============ Widget ============

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
  final _contentKey = GlobalKey();

  @override BlockComponentConfiguration get configuration => widget.configuration;
  @override Node get node => widget.node;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = node.attributes[CodeBlockKeys.language] ?? '';
    final code = node.attributes[CodeBlockKeys.code] ?? '';

    // 背景与文字配色
    final bg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
    final border = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.1);
    final fg = isDark
        ? Colors.white.withValues(alpha: 0.85)
        : Colors.black.withValues(alpha: 0.85);

    const mono = TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.6);

    // 代码文本
    final showCode = code.trim().isEmpty ? ' ' : code;

    // 语言标签
    final langBar = lang.isNotEmpty
        ? Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
              border: Border(bottom: BorderSide(color: border)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Text(lang, style: mono.copyWith(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : Colors.black.withValues(alpha: 0.45),
            )),
          )
        : const SizedBox.shrink();

    // 代码区
    final codeArea = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          showCode,
          style: mono.copyWith(color: fg),
        ),
      ),
    );

    Widget inner = lang.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [langBar, codeArea],
          )
        : codeArea;

    // 外框
    Widget child = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(color: bg, border: Border.all(color: border)),
        child: inner,
      ),
    );

    // padding
    child = Padding(
      key: _contentKey,
      padding: padding,
      child: child,
    );

    // 选择容器 — 不使用 BlockSelectionContainer 以避免 Null 崩溃
    child = Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );

    return child;
  }

  // ========== SelectableMixin（最小实现，避免 crash）==========

  @override Position start() => Position(path: node.path, offset: 0);
  @override Position end() => Position(path: node.path, offset: 1);
  @override Position getPositionInOffset(Offset start) => end();

  @override
  Rect getBlockRect({bool shiftWithBaseOffset = false}) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) return Offset.zero & box.size;
    return Rect.zero;
  }

  @override
  Rect? getCursorRectInPosition(Position position,
          {bool shiftWithBaseOffset = false}) =>
      null;

  @override
  List<Rect> getRectsInSelection(Selection selection,
      {bool shiftWithBaseOffset = false}) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) return [Offset.zero & box.size];
    return [];
  }

  @override
  Selection getSelectionInRange(Offset start, Offset end) =>
      Selection.single(path: node.path, startOffset: 0, endOffset: 1);

  @override
  Offset localToGlobal(Offset offset,
          {bool shiftWithBaseOffset = false}) {
    final box = context.findRenderObject() as RenderBox?;
    return box?.localToGlobal(offset) ?? offset;
  }

  @override bool get shouldCursorBlink => false;
  @override CursorStyle get cursorStyle => CursorStyle.cover;
}
