/// 代码块节点定义、解析器和渲染器
///
/// appflowy_editor 6.2.0 不原生支持 fenced code blocks，
/// 这里实现自定义的 markdown → 节点 解析 和 节点 → widget 渲染。
///
/// 渲染参照 appflowy_editor Image/Diver 块的最佳实践：
///   内容 → Padding(key) → BlockSelectionContainer → ActionWrapper
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
      if (c is md.Element && c.tag == 'code') {
        codeEl = c;
        break;
      }
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

  // Image/Diver 模式：通过 _renderBox 获取组件尺寸
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

    // 配色：融合 EditorStyle 与代码块风格
    final bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.1);
    const textStyle = TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5);

    // 构建代码内容
    final codeContent = code.trim().isEmpty
        ? _emptyContent(isDark, lang, bgColor, borderColor, textStyle)
        : _highlightedCode(code, lang, isDark, textStyle);

    // 组合：语言标签 + 代码
    Widget inner = lang.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _langBar(isDark, lang, borderColor),
              codeContent,
            ],
          )
        : codeContent;

    // 整体圆角容器
    Widget child = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: inner,
      ),
    );

    // padding（参照 Image/Diver 模式：Padding(key, padding)）
    child = Padding(
      key: _contentKey,
      padding: padding,
      child: child,
    );

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

    // 可选 action wrapper
    if (widget.showActions && widget.actionBuilder != null) {
      child = BlockComponentActionWrapper(
        node: node,
        actionBuilder: widget.actionBuilder!,
        actionTrailingBuilder: widget.actionTrailingBuilder,
        child: child,
      );
    }

    return child;
  }

  /// 空的代码块占位
  Widget _emptyContent(bool isDark, String lang, Color bg, Color border,
      TextStyle style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        lang.isNotEmpty ? '$lang — empty' : 'Empty code block',
        style: style.copyWith(
          color: isDark
              ? Colors.white.withValues(alpha: 0.35)
              : Colors.black.withValues(alpha: 0.35),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  /// 带语法高亮的内容
  Widget _highlightedCode(
      String code, String lang, bool isDark, TextStyle style) {
    final effectiveLang = lang.isNotEmpty ? lang : 'plaintext';
    // HighlightView 限制最大宽度避免溢出
    return SizedBox(
      width: double.infinity,
      child: HighlightView(
        code,
        language: effectiveLang,
        theme: isDark ? _darkTheme : githubTheme,
        padding: const EdgeInsets.all(16),
        textStyle: style,
      ),
    );
  }

  /// 语言标签栏
  Widget _langBar(bool isDark, String lang, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        border: Border(bottom: BorderSide(color: borderColor)),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Text(
            lang,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

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
              shiftWithBaseOffset: shiftWithBaseOffset)
          .first;

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
    final innerBox = _contentKey.currentContext?.findRenderObject();
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

  // ========== 主题 ==========

  static final _darkTheme = {
    'root': const TextStyle(
        backgroundColor: Color(0xFF1E1E1E), color: Color(0xFFD4D4D4)),
    'keyword': const TextStyle(color: Color(0xFF569CD6)),
    'string': const TextStyle(color: Color(0xFFCE9178)),
    'number': const TextStyle(color: Color(0xFFB5CEA8)),
    'title': const TextStyle(color: Color(0xFF569CD6)),
    'function': const TextStyle(color: Color(0xFFDCDCAA)),
    'built_in': const TextStyle(color: Color(0xFF4EC9B0)),
    'comment': const TextStyle(
        color: Color(0xFF6A9955), fontStyle: FontStyle.italic),
    'type': const TextStyle(color: Color(0xFF4EC9B0)),
    'literal': const TextStyle(color: Color(0xFF569CD6)),
    'meta': const TextStyle(color: Color(0xFF9B9B9B)),
  };
}
