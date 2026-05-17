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
  Future<String?> exportToPdf(
    String markdown, {
    ExportSettings? settings,
  }) async {
    final effectiveSettings = settings ?? const ExportSettings();
    final pdf = pw.Document();

    // 将 Markdown 转换为简单的 PDF 文本段落
    final lines = markdown.split('\n');
    final widgets = <pw.Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(pw.SizedBox(height: 8));
        continue;
      }

      // 简单的标题检测
      if (line.startsWith('# ')) {
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.only(top: 12, bottom: 4),
          child: pw.Text(
            line.substring(2),
            style: pw.TextStyle(
              fontSize: effectiveSettings.fontSize * 1.8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ));
      } else if (line.startsWith('## ')) {
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
          child: pw.Text(
            line.substring(3),
            style: pw.TextStyle(
              fontSize: effectiveSettings.fontSize * 1.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ));
      } else if (line.startsWith('### ')) {
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
          child: pw.Text(
            line.substring(4),
            style: pw.TextStyle(
              fontSize: effectiveSettings.fontSize * 1.3,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ));
      } else {
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Text(
            line,
            style: pw.TextStyle(
              fontSize: effectiveSettings.fontSize,
              lineSpacing: effectiveSettings.lineHeight *
                  effectiveSettings.fontSize -
                  effectiveSettings.fontSize,
            ),
          ),
        ));
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: effectiveSettings.pdfPageFormat,
        build: (context) => widgets,
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
