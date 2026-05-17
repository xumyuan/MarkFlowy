/// Markdown 工具类单元测试
/// 测试 Markdown ↔ Document 转换
import 'package:flutter_test/flutter_test.dart';

import 'package:markflowy/utils/markdown_utils.dart';

void main() {
  group('MarkdownUtils', () {
    group('markdownToDoc', () {
      test('空字符串应返回文档对象', () {
        final doc = MarkdownUtils.markdownToDoc('');
        expect(doc, isNotNull);
      });

      test('纯文本段落应正确转换', () {
        const markdown = 'Hello, World!';
        final doc = MarkdownUtils.markdownToDoc(markdown);
        expect(doc, isNotNull);
        expect(doc.root.children.isNotEmpty, isTrue);
      });

      test('标题应正确转换', () {
        const markdown = '# 一级标题\n## 二级标题\n### 三级标题';
        final doc = MarkdownUtils.markdownToDoc(markdown);
        expect(doc, isNotNull);
        expect(doc.root.children.length, greaterThanOrEqualTo(3));
      });

      test('无序列表应正确转换', () {
        const markdown = '- item 1\n- item 2\n- item 3';
        final doc = MarkdownUtils.markdownToDoc(markdown);
        expect(doc, isNotNull);
        expect(doc.root.children, isNotEmpty);
      });

      test('有序列表应正确转换', () {
        const markdown = '1. first\n2. second\n3. third';
        final doc = MarkdownUtils.markdownToDoc(markdown);
        expect(doc, isNotNull);
        expect(doc.root.children, isNotEmpty);
      });

      test('代码块应正确转换', () {
        const markdown = 'text before\n\n```\ncode\n```\n\ntext after';
        final doc = MarkdownUtils.markdownToDoc(markdown);
        expect(doc, isNotNull);
        // 至少包含 text before 段落
        expect(doc.root.children.length, greaterThanOrEqualTo(1));
      });

      test('链接应正确转换', () {
        const markdown = '[Flutter](https://flutter.dev)';
        final doc = MarkdownUtils.markdownToDoc(markdown);
        expect(doc, isNotNull);
        expect(doc.root.children, isNotEmpty);
      });

      test('引用块应正确转换', () {
        const markdown = '> This is a quote';
        final doc = MarkdownUtils.markdownToDoc(markdown);
        expect(doc, isNotNull);
        expect(doc.root.children, isNotEmpty);
      });
    });

    group('docToMarkdown', () {
      test('空文档应返回字符串', () {
        final doc = MarkdownUtils.createEmptyDocument();
        final markdown = MarkdownUtils.docToMarkdown(doc);
        expect(markdown, isA<String>());
      });

      test('往返转换应保留内容（标题）', () {
        const original = '# Hello World';
        final doc = MarkdownUtils.markdownToDoc(original);
        final result = MarkdownUtils.docToMarkdown(doc);
        expect(result.trim(), contains('Hello World'));
      });

      test('往返转换应保留内容（段落）', () {
        const original = 'This is a paragraph.';
        final doc = MarkdownUtils.markdownToDoc(original);
        final result = MarkdownUtils.docToMarkdown(doc);
        expect(result.trim(), contains('This is a paragraph.'));
      });
    });

    group('createEmptyDocument', () {
      test('应创建一个有效的文档', () {
        final doc = MarkdownUtils.createEmptyDocument();
        expect(doc, isNotNull);
        expect(doc.root, isNotNull);
      });
    });

    group('createDocumentFromContent', () {
      test('空内容应创建有效文档', () {
        final doc = MarkdownUtils.createDocumentFromContent('');
        expect(doc, isNotNull);
        expect(doc.root, isNotNull);
      });

      test('有内容应正确解析', () {
        final doc = MarkdownUtils.createDocumentFromContent('# Test');
        expect(doc, isNotNull);
        expect(doc.root.children, isNotEmpty);
      });
    });
  });
}
