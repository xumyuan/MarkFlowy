/// 代码块节点：解析器 + 渲染器
///
/// appflowy_editor 6.2.0 不原生支持 fenced code blocks，
/// 这里实现完整链路：markdown → 节点 → widget 渲染
library;

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;

// ============ 节点定义 ============

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

// ============ 解析器：markdown → 节点 ============

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

// ============ 编码器：节点 → markdown ============

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
  BlockComponentWidget build(BlockComponentContext bcc) {
    final node = bcc.node;
    return _CodeBlockWidget(
      key: node.key,
      node: node,
      showActions: showActions(node),
      configuration: configuration,
      actionBuilder: (c, s) => actionBuilder(bcc, s),
      actionTrailingBuilder: (c, s) => actionTrailingBuilder(bcc, s),
    );
  }

  @override
  BlockComponentValidate get validate => (node) => node.type == CodeBlockKeys.type;
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

  @override BlockComponentConfiguration get configuration => widget.configuration;
  @override Node get node => widget.node;

  // 颜色定义
  static const _bgDark = Color(0xFF1E1E1E);
  static const _bgLight = Color(0xFFF6F8FA);
  static const _borderDark = Color(0xFF30363D);
  static const _borderLight = Color(0xFFD0D7DE);
  static const _langBgDark = Color(0xFF161B22);
  static const _langBgLight = Color(0xFFEBECF0);
  static const _textFgDark = Color(0xFFC9D1D9);
  static const _textFgLight = Color(0xFF24292F);
  static const _langFgDark = Color(0xFF7D8590);
  static const _langFgLight = Color(0xFF656D76);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = node.attributes[CodeBlockKeys.language] ?? '';
    final code = node.attributes[CodeBlockKeys.code] ?? '';
    final showCode = code.trim().isEmpty ? ' ' : code;
    final preview = code.length > 60 ? '${code.substring(0, 60)}...' : code;
    print('[CODE_BLOCK] BUILD lang=$lang codeLen=${code.length} preview="$preview"');

    final bg = isDark ? _bgDark : _bgLight;
    final border = isDark ? _borderDark : _borderLight;
    final fg = isDark ? _textFgDark : _textFgLight;

    const mono = TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.6);

    // 代码内容
    final codeArea = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(showCode, style: mono.copyWith(color: fg)),
      ),
    );

    // 组合：语言标签 + 代码区
    Widget inner = lang.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? _langBgDark : _langBgLight,
                  border: Border(bottom: BorderSide(color: border)),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Text(
                  lang,
                  style: mono.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? _langFgDark : _langFgLight,
                  ),
                ),
              ),
              codeArea,
            ],
          )
        : codeArea;

    // 外框：GitHub 风格圆角 + 边框
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
        ),
        child: inner,
      ),
    );
  }

  // ========== SelectableMixin ==========
  @override Position start() => Position(path: node.path, offset: 0);
  @override Position end() => Position(path: node.path, offset: 1);
  @override Position getPositionInOffset(Offset s) => end();
  @override bool get shouldCursorBlink => false;
  @override CursorStyle get cursorStyle => CursorStyle.cover;
  @override Rect getBlockRect({bool shiftWithBaseOffset = false}) => Rect.zero;
  @override Rect? getCursorRectInPosition(Position p, {bool shiftWithBaseOffset = false}) => null;
  @override List<Rect> getRectsInSelection(Selection s, {bool shiftWithBaseOffset = false}) => [];
  @override Selection getSelectionInRange(Offset s, Offset e) =>
      Selection.single(path: node.path, startOffset: 0, endOffset: 1);
  @override Offset localToGlobal(Offset o, {bool shiftWithBaseOffset = false}) => o;
}
