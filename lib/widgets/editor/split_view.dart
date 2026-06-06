/// 分屏模式组件
/// marktext 本身未实现分屏，但这是 Markdown 编辑器的常见功能
///
/// 功能:
/// - 左侧源码编辑器，右侧实时预览
/// - 可拖拽分割线调整左右比例
/// - 编辑源码时右侧预览实时更新
/// - 支持本地图片加载（FileImage）
/// - 支持代码块语法高亮（flutter_highlight）
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

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

  /// 构建 Markdown 预览区域（支持本地图片和代码语法高亮）
  Widget _buildPreview(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: theme.colorScheme.surface,
      child: Markdown(
        key: ValueKey(_currentContent.hashCode),
        data: _currentContent,
        selectable: true,
        padding: const EdgeInsets.all(24),
        imageBuilder: (uri, title, alt) => _buildImage(uri, alt ?? ''),
        builders: {
          'code': CodeElementBuilder(isDark: isDark),
        },
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
          codeblockPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  /// 构建图片 Widget（支持本地文件路径和网络 URL）
  Widget _buildImage(Uri uri, String alt) {
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      // 网络图片
      return Image.network(
        uri.toString(),
        errorBuilder: (context, error, stackTrace) => _buildImageError(alt),
      );
    }
    // 尝试本地文件路径
    final filePath = uri.hasScheme ? uri.toFilePath() : uri.toString();
    final file = File(filePath);
    if (file.existsSync()) {
      return Image.file(
        file,
        errorBuilder: (context, error, stackTrace) => _buildImageError(alt),
      );
    }
    return _buildImageError(alt);
  }

  /// 图片加载失败的占位符
  Widget _buildImageError(String alt) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_outlined, size: 32,
                color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 8),
            Text(alt.isNotEmpty ? alt : '图片加载失败',
                style: TextStyle(fontSize: 12, color: Colors.grey.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }
}

/// 代码块语法高亮 ElementBuilder（使用 flutter_highlight）
class CodeElementBuilder extends MarkdownElementBuilder {
  final bool isDark;

  CodeElementBuilder({required this.isDark});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final language = element.attributes['class']
        ?.replaceFirst('language-', '') ?? 'plaintext';

    // 提取代码文本（去除 language- 前缀的影响）
    String codeText = '';
    if (element.textContent.isNotEmpty) {
      codeText = element.textContent;
    } else {
      // 从 children 中提取
      for (final child in element.children ?? []) {
        if (child.textContent.isNotEmpty) {
          codeText += child.textContent;
        }
      }
    }

    if (codeText.trim().isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(' ', style: TextStyle(fontFamily: 'monospace', fontSize: 13)),
      );
    }

    return HighlightView(
      codeText.trimRight(),
      language: language,
      theme: isDark ? githubDarkTheme : githubTheme,
      padding: const EdgeInsets.all(12),
      textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 13),
    );
  }

  static final githubDarkTheme = {
    'root': const TextStyle(
      backgroundColor: Color(0xFF0D1117),
      color: Color(0xFFC9D1D9),
    ),
    'comment': const TextStyle(color: Color(0xFF8B949E), fontStyle: FontStyle.italic),
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
  };
}
