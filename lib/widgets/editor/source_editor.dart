/// 源码编辑器组件
/// 参考: marktext/src/renderer/src/components/editorWithTabs/sourceCode.vue
///
/// 功能:
/// - 显示原始 Markdown 文本
/// - 搜索匹配高亮（对应 marktext .ag-highlight）
/// - 行号显示
/// - 内容同步（切换模式时保持内容一致）
library;

import 'package:flutter/material.dart';

/// 搜索结果匹配信息
class SourceEditorSearchHighlight {
  final List<TextRange> ranges;
  final int currentHighlightIndex;

  const SourceEditorSearchHighlight({
    this.ranges = const [],
    this.currentHighlightIndex = -1,
  });

  bool get hasHighlights => ranges.isNotEmpty;
}

/// 支持搜索高亮的 TextEditingController
class HighlightTextEditingController extends TextEditingController {
  /// 所有匹配的文本范围
  List<TextRange> _highlightRanges = [];

  /// 当前高亮的匹配索引
  int _currentIndex = -1;

  /// 基础文本样式
  TextStyle? baseStyle;

  /// 匹配高亮样式（对应 marktext .ag-highlight）
  Color highlightColor = const Color(0x6688CCFF);

  /// 当前匹配高亮样式（对应 marktext .ag-highlight-current）
  Color currentHighlightColor = const Color(0x996699FF);

  HighlightTextEditingController({String? text}) : super(text: text);

  /// 设置高亮范围
  void setHighlights(List<TextRange> ranges, {int currentIndex = -1}) {
    _highlightRanges = List.from(ranges);
    _currentIndex = currentIndex;
    notifyListeners();
  }

  /// 清除高亮
  void clearHighlights() {
    if (_highlightRanges.isNotEmpty) {
      _highlightRanges = [];
      _currentIndex = -1;
      notifyListeners();
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final effectiveStyle = baseStyle ?? style;
    if (effectiveStyle == null) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    if (_highlightRanges.isEmpty) {
      return TextSpan(text: text, style: effectiveStyle);
    }

    final children = <TextSpan>[];
    int lastEnd = 0;

    for (var i = 0; i < _highlightRanges.length; i++) {
      final range = _highlightRanges[i];
      final isCurrent = i == _currentIndex;

      // 添加匹配前文本
      if (range.start > lastEnd) {
        children.add(TextSpan(
          text: text.substring(lastEnd, range.start),
          style: effectiveStyle,
        ));
      }

      // 添加高亮文本
      children.add(TextSpan(
        text: text.substring(range.start, range.end),
        style: effectiveStyle.copyWith(
          backgroundColor: isCurrent ? currentHighlightColor : highlightColor,
          color: effectiveStyle.color,
        ),
      ));

      lastEnd = range.end;
    }

    // 添加剩余文本
    if (lastEnd < text.length) {
      children.add(TextSpan(
        text: text.substring(lastEnd),
        style: effectiveStyle,
      ));
    }

    return TextSpan(text: '', children: children);
  }
}

/// Markdown 源码编辑器
/// 对应 marktext sourceCode.vue 中的 CodeMirror 编辑器
class SourceEditor extends StatefulWidget {
  /// 初始 Markdown 内容
  final String initialContent;

  /// 内容变化回调
  final ValueChanged<String>? onContentChanged;

  /// 是否显示行号（对应 marktext codeMirrorConfig.lineNumbers）
  final bool showLineNumbers;

  /// 是否自动换行（对应 marktext codeMirrorConfig.lineWrapping）
  final bool lineWrapping;

  /// 是否自动获取焦点
  final bool autoFocus;

  /// 搜索高亮信息
  final SourceEditorSearchHighlight? searchHighlight;

  const SourceEditor({
    super.key,
    this.initialContent = '',
    this.onContentChanged,
    this.showLineNumbers = true,
    this.lineWrapping = true,
    this.autoFocus = true,
    this.searchHighlight,
  });

  @override
  State<SourceEditor> createState() => SourceEditorState();
}

class SourceEditorState extends State<SourceEditor> {
  late HighlightTextEditingController _controller;
  late ScrollController _scrollController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = HighlightTextEditingController(text: widget.initialContent);
    _scrollController = ScrollController();
    _focusNode = FocusNode();

    _controller.addListener(_onTextChanged);

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(SourceEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当外部内容变化时同步（对应 sourceCode.vue handleFileChange）
    if (oldWidget.initialContent != widget.initialContent &&
        _controller.text != widget.initialContent) {
      _controller.text = widget.initialContent;
    }

    // 更新搜索高亮
    if (widget.searchHighlight != null && widget.searchHighlight!.hasHighlights) {
      _controller.setHighlights(
        widget.searchHighlight!.ranges,
        currentIndex: widget.searchHighlight!.currentHighlightIndex,
      );
    } else if (widget.searchHighlight?.hasHighlights == false) {
      _controller.clearHighlights();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onContentChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAFAFA),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 行号栏（对应 CodeMirror-gutters）
          if (widget.showLineNumbers) _buildLineNumbers(theme, isDark),

          // 编辑区域
          Expanded(
            child: _buildEditor(theme, isDark),
          ),
        ],
      ),
    );
  }

  /// 构建行号栏（对应 marktext sourceCode.vue CodeMirror-gutters）
  Widget _buildLineNumbers(ThemeData theme, bool isDark) {
    final lines = _controller.text.split('\n');
    final lineCount = lines.length;

    return Container(
      width: 50,
      padding: const EdgeInsets.only(top: 12, right: 8),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: lineCount,
        itemExtent: 20.0,
        itemBuilder: (context, index) {
          final lineNum = index + 1;
          // 只显示第一行和每10行（对应 marktext lineNumberFormatter）
          final showNumber = lineNum == 1 || lineNum % 10 == 0;
          return SizedBox(
            height: 20,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                showNumber ? '$lineNum' : '',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.3),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建编辑区域
  Widget _buildEditor(ThemeData theme, bool isDark) {
    final textColor = isDark
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.black87;

    // 设置控制器的基础样式
    _controller.baseStyle = TextStyle(
      fontSize: 14,
      fontFamily: 'monospace',
      height: 1.43,
      color: textColor,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: null,
        expands: true,
        keyboardType: TextInputType.multiline,
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'monospace',
          height: 1.43, // 约 20px 行高
          color: textColor,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isCollapsed: true,
        ),
      ),
    );
  }

  /// 获取当前文本内容
  String get content => _controller.text;

  /// 设置文本内容
  set content(String value) {
    _controller.text = value;
  }

  /// 设置搜索高亮
  void setSearchHighlight(List<TextRange> ranges, {int currentIndex = -1}) {
    _controller.setHighlights(ranges, currentIndex: currentIndex);
  }

  /// 清除搜索高亮
  void clearSearchHighlight() {
    _controller.clearHighlights();
  }
}
