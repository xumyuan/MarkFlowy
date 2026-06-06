/// 代码块节点定义、解析器和渲染器
/// 
/// appflowy_editor 6.2.0 不原生支持 fenced code blocks 的 WYSIWYG 渲染，
/// 这里实现自定义的代码块解析（markdown → 节点）和渲染（节点 → widgets）。
///
/// 参考: marktext/src/muya/lib/contentState/codeBlockCtrl.js
library;

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';

// ============ 代码块节点类型定义 ============

/// 代码块节点的属性键
class CodeBlockKeys {
  CodeBlockKeys._();

  static const String type = 'code_block';

  /// 编程语言（如 dart, python, javascript）
  static const String language = 'language';

  /// 代码文本内容（存储为纯文本）
  static const String code = 'code';
}

/// 创建代码块节点
Node codeBlockNode({
  required String code,
  String language = '',
}) {
  return Node(
    type: CodeBlockKeys.type,
    attributes: {
      CodeBlockKeys.language: language,
      CodeBlockKeys.code: code,
    },
  );
}

// ============ Markdown → 节点 解析器 ============

/// 自定义 Markdown 解析器：将 fenced code blocks 解析为代码块节点
///
/// 对应 marktext 中 muya 的 code block parser
class CodeBlockMarkdownParser extends CustomMarkdownParser {
  const CodeBlockMarkdownParser();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownParser> parsers, {
    MarkdownListType listType = MarkdownListType.unknown,
    int? startNumber,
  }) {
    // 处理 <pre><code> 结构（来自 fenced code blocks）
    if (element is! md.Element) {
      return [];
    }

    if (element.tag != 'pre') {
      return [];
    }

    // 提取 <code> 子元素
    md.Element? codeElement;
    for (final child in element.children ?? []) {
      if (child is md.Element && child.tag == 'code') {
        codeElement = child;
        break;
      }
    }

    if (codeElement == null) {
      return [];
    }

    // 提取语言信息
    String language = '';
    final classAttr = codeElement.attributes['class'];
    if (classAttr != null && classAttr.startsWith('language-')) {
      language = classAttr.substring('language-'.length);
    }

    // 提取代码文本
    final codeText = codeElement.textContent;

    return [codeBlockNode(code: codeText, language: language)];
  }
}

// ============ 节点 → Markdown 编码器 ============

/// 将自定义 code_block 节点转换回 Markdown fenced code block
///
/// 与 appflowy_editor 内置的 CodeBlockNodeParser（处理 'code' 类型）区分，
/// 本类处理自定义的 'code_block' 节点类型。
class CustomCodeBlockNodeParser extends NodeParser {
  const CustomCodeBlockNodeParser();

  @override
  String get id => 'code_block_encoder';

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final language = node.attributes[CodeBlockKeys.language] ?? '';
    final code = node.attributes[CodeBlockKeys.code] ?? '';

    if (code.isEmpty) {
      // 空代码块
      return '```$language\n\n```\n';
    }

    final suffix = node.next == null ? '' : '\n';
    return '```$language\n$code\n```$suffix';
  }
}

// ============ 代码块渲染器（WYSIWYG 中显示语法高亮） ============

/// 代码块组件构建器
///
/// 在 WYSIWYG 编辑器中渲染带语法高亮的代码块
class CodeBlockComponentBuilder extends BlockComponentBuilder {
  CodeBlockComponentBuilder({super.configuration});

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return CodeBlockComponentWidget(
      key: node.key,
      node: node,
      showActions: showActions(node),
      configuration: configuration,
      actionBuilder: (context, state) => actionBuilder(
        blockComponentContext,
        state,
      ),
      actionTrailingBuilder: (context, state) => actionTrailingBuilder(
        blockComponentContext,
        state,
      ),
    );
  }

  @override
  BlockComponentValidate get validate =>
      (node) => node.type == CodeBlockKeys.type;
}

/// 代码块组件 Widget
class CodeBlockComponentWidget extends BlockComponentStatefulWidget {
  const CodeBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.actionTrailingBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  @override
  State<CodeBlockComponentWidget> createState() =>
      _CodeBlockComponentWidgetState();
}

class _CodeBlockComponentWidgetState extends State<CodeBlockComponentWidget>
    with SelectableMixin, BlockComponentConfigurable {
  final codeBlockKey = GlobalKey();

  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final language = node.attributes[CodeBlockKeys.language] ?? '';
    final code = node.attributes[CodeBlockKeys.code] ?? '';
    final editorState = context.read<EditorState>();

    final hasLanguage = language.isNotEmpty;

    Widget child;

    if (code.trim().isEmpty) {
      child = Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF0D1117)
              : const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          hasLanguage ? '$language (empty)' : 'Empty code block',
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
    } else {
      child = HighlightView(
        code,
        language: hasLanguage ? language : 'plaintext',
        theme: isDark ? _githubDarkTheme : githubTheme,
        padding: const EdgeInsets.all(16),
        textStyle: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
        ),
      );
    }

    // 添加语言标签
    if (hasLanguage) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 语言标签栏
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF161B22)
                  : const Color(0xFFEBECF0),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              language,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          // 代码块主体
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            child: child,
          ),
        ],
      );
    }

    // 块选择容器
    child = Padding(
      key: codeBlockKey,
      padding: padding,
      child: child,
    );

    child = BlockSelectionContainer(
      node: node,
      delegate: this,
      listenable: editorState.selectionNotifier,
      remoteSelection: editorState.remoteSelections,
      blockColor: editorState.editorStyle.selectionColor,
      cursorColor: editorState.editorStyle.cursorColor,
      selectionColor: editorState.editorStyle.selectionColor,
      supportTypes: const [
        BlockSelectionType.block,
        BlockSelectionType.cursor,
        BlockSelectionType.selection,
      ],
      child: child,
    );

    return child;
  }

  /// GitHub Dark 主题（与 split_view.dart 保持一致）
  static final _githubDarkTheme = {
    'root': const TextStyle(
      backgroundColor: Color(0xFF0D1117),
      color: Color(0xFFC9D1D9),
    ),
    'comment': const TextStyle(
      color: Color(0xFF8B949E),
      fontStyle: FontStyle.italic,
    ),
    'keyword': const TextStyle(color: Color(0xFFFF7B72)),
    'string': const TextStyle(color: Color(0xFFA5D6FF)),
    'number': const TextStyle(color: Color(0xFF79C0FF)),
    'title': const TextStyle(color: Color(0xFFD2A8FF)),
    'type': const TextStyle(color: Color(0xFFFFA657)),
    'function': const TextStyle(color: Color(0xFFD2A8FF)),
    'built_in': const TextStyle(color: Color(0xFFFFA657)),
    'literal': const TextStyle(color: Color(0xFF79C0FF)),
    'params': const TextStyle(color: Color(0xFFC9D1D9)),
    'attr': const TextStyle(color: Color(0xFF79C0FF)),
    'meta': const TextStyle(color: Color(0xFFC9D1D9)),
    'tag': const TextStyle(color: Color(0xFFFF7B72)),
    'name': const TextStyle(color: Color(0xFFD2A8FF)),
    'attribute': const TextStyle(color: Color(0xFF79C0FF)),
    'selector-tag': const TextStyle(color: Color(0xFF7EE787)),
    'selector-id': const TextStyle(color: Color(0xFFD2A8FF)),
    'selector-class': const TextStyle(color: Color(0xFFD2A8FF)),
    'selector-pseudo': const TextStyle(color: Color(0xFFD2A8FF)),
    'variable': const TextStyle(color: Color(0xFFFFA657)),
    'deletion': const TextStyle(color: Color(0xFFFF7B72)),
    'addition': const TextStyle(color: Color(0xFF7EE787)),
  };

  // ========== 选择/光标相关 ==========

  @override
  Position start() => Position(path: node.path, offset: 0);

  @override
  Position end() => Position(path: node.path, offset: 1);

  @override
  Position getPositionInOffset(Offset start) => Position(path: node.path, offset: 0);

  @override
  bool get shouldCursorBlink => false;

  @override
  CursorStyle get cursorStyle => CursorStyle.cover;

  @override
  Rect getBlockRect({bool shiftWithBaseOffset = false}) {
    return getRectsInSelection(Selection.invalid(),
        shiftWithBaseOffset: shiftWithBaseOffset).first;
  }

  @override
  Rect? getCursorRectInPosition(
    Position position, {
    bool shiftWithBaseOffset = false,
  }) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return null;
    return getRectsInSelection(
      Selection.collapsed(position),
      shiftWithBaseOffset: shiftWithBaseOffset,
    ).firstOrNull;
  }

  @override
  List<Rect> getRectsInSelection(
    Selection selection, {
    bool shiftWithBaseOffset = false,
  }) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return [];
    final parentBox = context.findRenderObject();
    final codeBox = codeBlockKey.currentContext?.findRenderObject();
    if (parentBox is RenderBox && codeBox is RenderBox) {
      return [
        (shiftWithBaseOffset
                ? codeBox.localToGlobal(Offset.zero, ancestor: parentBox)
                : Offset.zero) &
            codeBox.size,
      ];
    }
    return [Offset.zero & box.size];
  }

  @override
  Selection getSelectionInRange(Offset start, Offset end) => Selection.single(
        path: node.path,
        startOffset: 0,
        endOffset: 1,
      );

  @override
  Offset localToGlobal(
    Offset offset, {
    bool shiftWithBaseOffset = false,
  }) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      return box.localToGlobal(offset);
    }
    return offset;
  }
}
