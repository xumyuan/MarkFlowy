/// 分屏模式组件
/// marktext 本身未实现分屏，但这是 Markdown 编辑器的常见功能
///
/// 功能:
/// - 左侧源码编辑器，右侧实时预览
/// - 可拖拽分割线调整左右比例
/// - 编辑源码时右侧预览实时更新
library;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'source_editor.dart';

/// 分屏编辑器（左源码 + 右预览）
class SplitView extends StatefulWidget {
  /// 初始 Markdown 内容
  final String initialContent;

  /// 内容变化回调
  final ValueChanged<String>? onContentChanged;

  /// 初始分割比例（0.0~1.0，表示左侧占比）
  final double initialSplitRatio;

  /// 搜索高亮信息
  final SourceEditorSearchHighlight? searchHighlight;

  const SplitView({
    super.key,
    this.initialContent = '',
    this.onContentChanged,
    this.initialSplitRatio = 0.5,
    this.searchHighlight,
  });

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  late double _splitRatio;
  late String _currentContent;

  /// 分割线拖拽最小比例
  static const double _minRatio = 0.2;

  /// 分割线拖拽最大比例
  static const double _maxRatio = 0.8;

  @override
  void initState() {
    super.initState();
    _splitRatio = widget.initialSplitRatio;
    _currentContent = widget.initialContent;
  }

  @override
  void didUpdateWidget(SplitView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialContent != widget.initialContent) {
      setState(() {
        _currentContent = widget.initialContent;
      });
    }
  }

  void _onContentChanged(String content) {
    setState(() {
      _currentContent = content;
    });
    widget.onContentChanged?.call(content);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final leftWidth = totalWidth * _splitRatio;
        final rightWidth = totalWidth * (1 - _splitRatio) - 6; // 6px 分割线

        return Row(
          children: [
            // 左侧：源码编辑器
            SizedBox(
              width: leftWidth,
              child: SourceEditor(
                initialContent: _currentContent,
                onContentChanged: _onContentChanged,
                showLineNumbers: true,
                searchHighlight: widget.searchHighlight,
              ),
            ),

            // 可拖拽分割线
            _buildDivider(totalWidth),

            // 右侧：Markdown 预览
            SizedBox(
              width: rightWidth,
              child: _buildPreview(context),
            ),
          ],
        );
      },
    );
  }

  /// 构建可拖拽分割线
  Widget _buildDivider(double totalWidth) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (details) {
        setState(() {
          _splitRatio += details.delta.dx / totalWidth;
          _splitRatio = _splitRatio.clamp(_minRatio, _maxRatio);
        });
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: Container(
          width: 6,
          color: Theme.of(context).dividerColor,
          child: Center(
            child: Container(
              width: 2,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: 0.2,
                    ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建 Markdown 预览区域
  Widget _buildPreview(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: Markdown(
        data: _currentContent,
        selectable: true,
        padding: const EdgeInsets.all(24),
        styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
          h1: theme.textTheme.headlineLarge,
          h2: theme.textTheme.headlineMedium,
          h3: theme.textTheme.headlineSmall,
          p: theme.textTheme.bodyLarge,
          code: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
          codeblockDecoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
