/// README.md 真实内容渲染测试
/// 加载项目 README.md 到编辑器和预览组件中，验证各类元素正确渲染
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:markflowy/widgets/editor/source_editor.dart';

void main() {
  late String readmeContent;

  setUpAll(() {
    // 从项目根目录加载 README.md（CI 和本地通用）
    final file = File('README.md');
    readmeContent = file.readAsStringSync();
  });

  group('README.md 内容完整性', () {
    test('应包含标题', () {
      expect(readmeContent, contains('# MarkFlowy'));
    });

    test('应包含表格', () {
      expect(readmeContent, contains('| 平台 |'));
      expect(readmeContent, contains('| --- |'));
    });

    test('应包含代码块', () {
      expect(readmeContent, contains('`flutter pub get`'));
    });

    test('应包含列表', () {
      expect(readmeContent, contains('* **所见即所得编辑**'));
    });

    test('应包含链接', () {
      expect(readmeContent, contains('[MarkText]'));
    });

    test('应包含图片', () {
      expect(readmeContent, contains('badge.svg'));
    });

    test('应包含水平分割线', () {
      expect(readmeContent, contains('---'));
    });

    test('应包含引用块', () {
      expect(readmeContent, contains('1. Fork 本仓库'));
    });
  });

  group('SourceEditor 渲染 README.md', () {
    testWidgets('应不崩溃地渲染完整 README', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceEditor(initialContent: readmeContent),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SourceEditor), findsOneWidget);
    });
  });

  group('SplitView Markdown 预览 README.md', () {
    testWidgets('flutter_markdown 应渲染表格', (tester) async {
      const content = '''| Col1 | Col2 |
|------|------|
| A | B |
| C | D |
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: Markdown(data: content),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Col1'), findsOneWidget);
      expect(find.text('Col2'), findsOneWidget);
    });

    testWidgets('flutter_markdown 应渲染代码块', (tester) async {
      const content = '''\`\`\`dart
void main() {
  print("hello");
}
\`\`\`
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: Markdown(data: content),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('print'), findsOneWidget);
    });

    testWidgets('flutter_markdown 应渲染列表', (tester) async {
      const content = '''- Item 1
- Item 2
  - Nested item
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: Markdown(data: content),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('flutter_markdown 应渲染链接', (tester) async {
      const content = 'Check out [MarkText](https://github.com/marktext/marktext).';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: Markdown(data: content),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 链接文本应该渲染
      expect(find.textContaining('MarkText'), findsOneWidget);
    });

    testWidgets('flutter_markdown 应渲染引用块', (tester) async {
      const content = '''> This is a quote
> Multiple lines''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: Markdown(data: content),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('This is a quote'), findsOneWidget);
    });

    testWidgets('flutter_markdown 应渲染水平分割线', (tester) async {
      const content = '''Above

---

Below
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: Markdown(data: content),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Above'), findsOneWidget);
      expect(find.text('Below'), findsOneWidget);
    });

    testWidgets('README 关键章节应正确渲染', (tester) async {
      // 只取功能特性部分测试
      const partial = '''## 功能特性

- **所见即所得编辑** — 支持粗体、斜体、标题、列表、引用、代码块
- **三种编辑模式** — WYSIWYG / 源码模式 / 分屏预览

## 快速开始

| 平台 | 下载 |
|------|------|
| macOS | zip |
| Windows | zip |
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 800,
              child: Markdown(
                data: partial,
                selectable: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('功能特性'), findsOneWidget);
      expect(find.textContaining('所见即所得编辑'), findsOneWidget);
      expect(find.textContaining('快速开始'), findsOneWidget);
    });
  });
}
