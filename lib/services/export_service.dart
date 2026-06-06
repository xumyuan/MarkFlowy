/// 导出服务
/// 参考: marktext/src/renderer/src/components/exportSettings/index.vue
///
/// 功能:
/// - 导出为 HTML（Markdown → HTML 字符串）
/// - 导出为 PDF（使用 pdf + printing 包）
/// - 导出设置（纸张大小、边距、是否包含样式等）
/// - 支持选择导出路径
library;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// 纸张大小枚举（对应 exportOptions.js 中的 pageSizeList）
enum ExportPageSize {
  a3,
  a4,
  a5,
  legal,
  letter,
  tabloid,
}

/// 导出设置（对应 exportSettings/index.vue 中的选项）
class ExportSettings {
  /// 纸张大小
  final ExportPageSize pageSize;

  /// 是否横向
  final bool isLandscape;

  /// 页边距（毫米）- 上
  final double marginTop;

  /// 页边距（毫米）- 右
  final double marginRight;

  /// 页边距（毫米）- 下
  final double marginBottom;

  /// 页边距（毫米）- 左
  final double marginLeft;

  /// 是否包含样式（仅 HTML 导出）
  final bool includeStyle;

  /// HTML 标题
  final String htmlTitle;

  /// 字体大小
  final double fontSize;

  /// 行高
  final double lineHeight;

  const ExportSettings({
    this.pageSize = ExportPageSize.a4,
    this.isLandscape = false,
    this.marginTop = 20,
    this.marginRight = 15,
    this.marginBottom = 20,
    this.marginLeft = 15,
    this.includeStyle = true,
    this.htmlTitle = '',
    this.fontSize = 14,
    this.lineHeight = 1.5,
  });

  /// 获取 pdf 包对应的 PdfPageFormat
  PdfPageFormat get pdfPageFormat {
    PdfPageFormat base = switch (pageSize) {
      ExportPageSize.a3 => PdfPageFormat.a3,
      ExportPageSize.a4 => PdfPageFormat.a4,
      ExportPageSize.a5 => PdfPageFormat.a5,
      ExportPageSize.legal => PdfPageFormat.legal,
      ExportPageSize.letter => PdfPageFormat.letter,
      ExportPageSize.tabloid => PdfPageFormat(279.4 * PdfPageFormat.mm,
          431.8 * PdfPageFormat.mm),
    };

    if (isLandscape) {
      base = base.landscape;
    }

    return base.copyWith(
      marginTop: marginTop * PdfPageFormat.mm,
      marginRight: marginRight * PdfPageFormat.mm,
      marginBottom: marginBottom * PdfPageFormat.mm,
      marginLeft: marginLeft * PdfPageFormat.mm,
    );
  }

  ExportSettings copyWith({
    ExportPageSize? pageSize,
    bool? isLandscape,
    double? marginTop,
    double? marginRight,
    double? marginBottom,
    double? marginLeft,
    bool? includeStyle,
    String? htmlTitle,
    double? fontSize,
    double? lineHeight,
  }) {
    return ExportSettings(
      pageSize: pageSize ?? this.pageSize,
      isLandscape: isLandscape ?? this.isLandscape,
      marginTop: marginTop ?? this.marginTop,
      marginRight: marginRight ?? this.marginRight,
      marginBottom: marginBottom ?? this.marginBottom,
      marginLeft: marginLeft ?? this.marginLeft,
      includeStyle: includeStyle ?? this.includeStyle,
      htmlTitle: htmlTitle ?? this.htmlTitle,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }
}

/// 行内格式化 Span
class _InlineSpan {
  final String text;
  final bool isBold;
  final bool isItalic;
  final bool isCode;
  final bool isStrikethrough;

  const _InlineSpan(
    this.text, {
    this.isBold = false,
    this.isItalic = false,
    this.isCode = false,
    this.isStrikethrough = false,
  });
}

/// 导出服务（对应 marktext 的 export 流程）
class ExportService {
  /// 将 Markdown 转换为 HTML 字符串
  String markdownToHtml(String markdown, {ExportSettings? settings}) {
    final effectiveSettings = settings ?? const ExportSettings();
    final htmlBody = md.markdownToHtml(
      markdown,
      extensionSet: md.ExtensionSet.gitHubWeb,
    );

    if (!effectiveSettings.includeStyle) {
      return htmlBody;
    }

    // 带样式的完整 HTML 文档
    final title = effectiveSettings.htmlTitle.isNotEmpty
        ? effectiveSettings.htmlTitle
        : 'Exported Document';

    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>$title</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
      font-size: ${effectiveSettings.fontSize}px;
      line-height: ${effectiveSettings.lineHeight};
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
      color: #333;
    }
    h1, h2, h3, h4, h5, h6 { margin-top: 1.5em; margin-bottom: 0.5em; }
    code { background: #f5f5f5; padding: 2px 4px; border-radius: 3px; }
    pre { background: #f5f5f5; padding: 16px; border-radius: 6px; overflow-x: auto; }
    pre code { background: transparent; padding: 0; }
    blockquote { border-left: 4px solid #ddd; margin-left: 0; padding-left: 16px; color: #666; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid #ddd; padding: 8px 12px; text-align: left; }
    th { background: #f5f5f5; }
    img { max-width: 100%; }
  </style>
</head>
<body>
$htmlBody
</body>
</html>''';
  }

  /// 导出为 HTML 文件
  Future<String?> exportToHtml(
    String markdown, {
    ExportSettings? settings,
  }) async {
    final html = markdownToHtml(markdown, settings: settings);

    // 选择保存路径
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: '导出 HTML',
      fileName: 'export.html',
      type: FileType.custom,
      allowedExtensions: ['html', 'htm'],
    );

    if (outputPath == null) return null;

    final file = File(outputPath);
    await file.writeAsString(html);
    return outputPath;
  }

  /// 导出为 PDF 文件
  /// 使用 HTML 管道渲染：Markdown → HTML → 在内存中预览并导出为 PDF
  Future<String?> exportToPdf(
    String markdown, {
    ExportSettings? settings,
  }) async {
    final effectiveSettings = settings ?? const ExportSettings();
    final pdf = pw.Document();

    // 将 Markdown 解析为段落和块
    final blocks = _parseMarkdownBlocks(markdown, effectiveSettings);
    pdf.addPage(
      pw.MultiPage(
        pageFormat: effectiveSettings.pdfPageFormat,
        build: (context) => blocks,
      ),
    );

    // 选择保存路径
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: '导出 PDF',
      fileName: 'export.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (outputPath == null) return null;

    final file = File(outputPath);
    await file.writeAsBytes(await pdf.save());
    return outputPath;
  }

  /// 解析 Markdown 为 PDF Widget 列表
  /// 支持：标题、段落、粗体/斜体、代码块、引用块、列表、分隔线、表格
  List<pw.Widget> _parseMarkdownBlocks(String markdown, ExportSettings settings) {
    final lines = markdown.split('\n');
    final widgets = <pw.Widget>[];
    int i = 0;

    while (i < lines.length) {
      final line = lines[i];

      // 空行
      if (line.trim().isEmpty) {
        widgets.add(pw.SizedBox(height: 6));
        i++;
        continue;
      }

      // 水平分割线
      if (RegExp(r'^(-{3,}|\*{3,}|_{3,})$').hasMatch(line.trim())) {
        widgets.add(pw.Divider(
          thickness: 1,
          color: PdfColors.grey400,
          height: 16,
        ));
        i++;
        continue;
      }

      // 图片 ![alt](url) — 在 PDF 中以文本标注替代
      final imageMatch = RegExp(r'^!\[(.+?)\]\((.+?)\)$').firstMatch(line.trim());
      if (imageMatch != null) {
        final alt = imageMatch.group(1) ?? 'image';
        final url = imageMatch.group(2) ?? '';
        widgets.add(pw.Container(
          margin: const pw.EdgeInsets.only(top: 4, bottom: 4),
          padding: const pw.EdgeInsets.all(8),
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '[图片] $alt',
                style: pw.TextStyle(
                  fontSize: settings.fontSize * 0.9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey600,
                ),
              ),
              if (url.isNotEmpty)
                pw.Text(
                  url,
                  style: pw.TextStyle(
                    fontSize: settings.fontSize * 0.75,
                    color: PdfColors.grey500,
                  ),
                ),
            ],
          ),
        ));
        i++;
        continue;
      }

      // H1-H6 标题
      final headingMatch = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(line);
      if (headingMatch != null) {
        final level = headingMatch.group(1)!.length;
        final text = headingMatch.group(2)!;
        final sizeMultiplier = switch (level) {
          1 => 2.0,
          2 => 1.7,
          3 => 1.4,
          4 => 1.2,
          5 => 1.1,
          _ => 1.0,
        };
        widgets.add(pw.Padding(
          padding: pw.EdgeInsets.only(top: level <= 2 ? 16 : 10, bottom: 4),
          child: pw.Text(
            _stripInlineMarkdown(text),
            style: pw.TextStyle(
              fontSize: settings.fontSize * sizeMultiplier,
              fontWeight: level <= 3 ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ));
        i++;
        continue;
      }

      // 代码块 ```
      if (line.trim().startsWith('```')) {
        final codeLines = <String>[];
        i++;
        while (i < lines.length && !lines[i].trim().startsWith('```')) {
          codeLines.add(lines[i]);
          i++;
        }
        i++; // skip closing ```
        widgets.add(_buildCodeBlock(codeLines, settings));
        continue;
      }

      // 引用块 >
      if (line.trim().startsWith('>')) {
        final quoteLines = <String>[];
        while (i < lines.length && lines[i].trim().startsWith('>')) {
          quoteLines.add(
            lines[i].trim().startsWith('> ')
                ? lines[i].trim().substring(2)
                : lines[i].trim().substring(1),
          );
          i++;
        }
        widgets.add(_buildBlockquote(quoteLines, settings));
        continue;
      }

      // 无序列表
      if (RegExp(r'^\s*[-*+]\s+').hasMatch(line)) {
        final listItems = <String>[];
        while (i < lines.length && RegExp(r'^\s*[-*+]\s+').hasMatch(lines[i])) {
          final itemText = lines[i].replaceFirst(RegExp(r'^\s*[-*+]\s+'), '');
          listItems.add(itemText);
          i++;
        }
        widgets.add(_buildUnorderedList(listItems, settings));
        continue;
      }

      // 有序列表
      if (RegExp(r'^\s*\d+\.\s+').hasMatch(line)) {
        final listItems = <String>[];
        while (i < lines.length && RegExp(r'^\s*\d+\.\s+').hasMatch(lines[i])) {
          final itemText = lines[i].replaceFirst(RegExp(r'^\s*\d+\.\s+'), '');
          listItems.add(itemText);
          i++;
        }
        widgets.add(_buildOrderedList(listItems, settings));
        continue;
      }

      // 表格（简单检测：包含 | 的行）
      if (line.contains('|') && i + 1 < lines.length && lines[i + 1].contains('|')) {
        final tableLines = <String>[line];
        i++;
        while (i < lines.length && lines[i].contains('|')) {
          tableLines.add(lines[i]);
          i++;
        }
        widgets.add(_buildTable(tableLines, settings));
        continue;
      }

      // 普通段落
      final paraLines = <String>[line];
      i++;
      while (i < lines.length &&
          lines[i].trim().isNotEmpty &&
          !lines[i].trim().startsWith('#') &&
          !lines[i].trim().startsWith('```') &&
          !lines[i].trim().startsWith('>') &&
          !RegExp(r'^\s*[-*+]\s+').hasMatch(lines[i]) &&
          !RegExp(r'^\s*\d+\.\s+').hasMatch(lines[i]) &&
          !lines[i].contains('|') &&
          !RegExp(r'^(-{3,}|\*{3,}|_{3,})$').hasMatch(lines[i].trim())) {
        paraLines.add(lines[i]);
        i++;
      }
      widgets.add(_buildParagraph(paraLines.join(' '), settings));
    }

    return widgets;
  }

  /// 构建带格式的段落（支持粗体、斜体、行内代码）
  pw.Widget _buildParagraph(String text, ExportSettings settings) {
    final spans = _parseInlineFormatting(text);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6, top: 2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: spans.map((span) {
            return pw.TextSpan(
              text: span.text,
              style: pw.TextStyle(
                fontSize: settings.fontSize,
                lineSpacing: 4,
                fontWeight: span.isBold ? pw.FontWeight.bold : null,
                fontStyle: span.isItalic ? pw.FontStyle.italic : null,
                font: span.isCode
                    ? pw.Font.courier()
                    : null,
                background: span.isCode
                    ? const pw.BoxDecoration(color: PdfColors.grey200)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 构建代码块
  pw.Widget _buildCodeBlock(List<String> lines, ExportSettings settings) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      margin: const pw.EdgeInsets.only(top: 8, bottom: 8),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: lines.map((line) {
          return pw.Text(
            line,
            style: pw.TextStyle(
              fontSize: settings.fontSize * 0.9,
              font: pw.Font.courier(),
              lineSpacing: 1.5,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建引用块
  pw.Widget _buildBlockquote(List<String> lines, ExportSettings settings) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(left: 16, top: 4, bottom: 4),
      margin: const pw.EdgeInsets.only(top: 4, bottom: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.grey500, width: 3),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: lines.map((line) {
          return pw.Text(
            line,
            style: pw.TextStyle(
              fontSize: settings.fontSize,
              color: PdfColors.grey700,
              fontStyle: pw.FontStyle.italic,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建无序列表
  pw.Widget _buildUnorderedList(List<String> items, ExportSettings settings) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 20, top: 4, bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items
            .map((item) => pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      width: 16,
                      child: pw.Text(
                        '\u2022',
                        style: pw.TextStyle(fontSize: settings.fontSize),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        item,
                        style: pw.TextStyle(fontSize: settings.fontSize),
                      ),
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }

  /// 构建有序列表
  pw.Widget _buildOrderedList(List<String> items, ExportSettings settings) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 20, top: 4, bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.asMap().entries.map((entry) {
          return pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 24,
                child: pw.Text(
                  '${entry.key + 1}.',
                  style: pw.TextStyle(fontSize: settings.fontSize),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  entry.value,
                  style: pw.TextStyle(fontSize: settings.fontSize),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// 构建表格
  pw.Widget _buildTable(List<String> lines, ExportSettings settings) {
    if (lines.length < 2) return pw.SizedBox.shrink();

    // 解析表头
    final headerCells = lines[0]
        .split('|')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();

    // 跳过分隔行（如 |---|---|）
    int dataStart = 1;
    if (lines.length > 1 && lines[1].contains('---')) {
      dataStart = 2;
    }

    final dataRows = lines.sublist(dataStart).map((line) {
      return line
          .split('|')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();
    }).toList();

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8, bottom: 8),
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey400),
        children: [
          // 表头行
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
            children: headerCells
                .map((cell) => pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        cell,
                        style: pw.TextStyle(
                          fontSize: settings.fontSize,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ))
                .toList(),
          ),
          // 数据行
          ...dataRows.map((row) => pw.TableRow(
                children: row
                    .map((cell) => pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            cell,
                            style: pw.TextStyle(fontSize: settings.fontSize),
                          ),
                        ))
                    .toList(),
              )),
        ],
      ),
    );
  }

  /// 去除行内 Markdown 语法
  String _stripInlineMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*(.+?)\*'), r'$1')
        .replaceAll(RegExp(r'__(.+?)__'), r'$1')
        .replaceAll(RegExp(r'_(.+?)_'), r'$1')
        .replaceAll(RegExp(r'`(.+?)`'), r'$1')
        .replaceAll(RegExp(r'~~(.+?)~~'), r'$1')
        .replaceAll(RegExp(r'\[(.+?)\]\(.+?\)'), r'$1');
  }

  /// 行内格式化 Span
  List<_InlineSpan> _parseInlineFormatting(String text) {
    final spans = <_InlineSpan>[];
    final pattern = RegExp(
      r'(\*\*(.+?)\*\*)|' // bold
      r'(\*(.+?)\*)|' // italic
      r'(__(.+?)__)|' // bold __
      r'(_(.+?)_)|' // italic _
      r'(`(.+?)`)|' // inline code
      r'(~~(.+?)~~)', // strikethrough
    );

    int lastEnd = 0;
    for (final match in pattern.allMatches(text)) {
      // 添加前面的普通文本
      if (match.start > lastEnd) {
        spans.add(_InlineSpan(text.substring(lastEnd, match.start)));
      }

      if (match.group(2) != null) {
        spans.add(_InlineSpan(match.group(2)!, isBold: true));
      } else if (match.group(4) != null) {
        spans.add(_InlineSpan(match.group(4)!, isItalic: true));
      } else if (match.group(6) != null) {
        spans.add(_InlineSpan(match.group(6)!, isBold: true));
      } else if (match.group(8) != null) {
        spans.add(_InlineSpan(match.group(8)!, isItalic: true));
      } else if (match.group(10) != null) {
        spans.add(_InlineSpan(match.group(10)!, isCode: true));
      } else if (match.group(12) != null) {
        spans.add(_InlineSpan(match.group(12)!, isStrikethrough: true));
      }
      lastEnd = match.end;
    }

    // 添加剩余文本
    if (lastEnd < text.length) {
      spans.add(_InlineSpan(text.substring(lastEnd)));
    }

    return spans.isEmpty ? [_InlineSpan(text)] : spans;
  }

  /// 使用系统打印对话框打印 PDF
  Future<void> printDocument(
    String markdown, {
    ExportSettings? settings,
  }) async {
    final effectiveSettings = settings ?? const ExportSettings();
    final pdf = pw.Document();

    final lines = markdown.split('\n');
    final widgets = <pw.Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(pw.SizedBox(height: 8));
        continue;
      }
      widgets.add(pw.Text(
        line,
        style: pw.TextStyle(fontSize: effectiveSettings.fontSize),
      ));
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: effectiveSettings.pdfPageFormat,
        build: (context) => widgets,
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
    );
  }
}
