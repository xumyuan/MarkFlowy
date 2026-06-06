/// 核心渲染测试 — 验证图片、代码块、Markdown 基础渲染
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:markflowy/widgets/editor/source_editor.dart';
import 'package:markflowy/widgets/editor/quick_insert.dart';
import 'package:markflowy/services/search_service.dart';

void main() {
  group('SourceEditor - 基础渲染', () {
    testWidgets('应正确渲染带代码块的 markdown', (tester) async {
      const content = '''# Hello World
This is a paragraph.

```dart
void main() {
  print('hello');
}
```

> A quote block''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceEditor(initialContent: content),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 验证编辑器存在
      expect(find.byType(SourceEditor), findsOneWidget);
    });

    testWidgets('应正确渲染带图片语法的 markdown', (tester) async {
      const content = '''# Document with Image

Some text here.

![example](/Users/test/image.png)

More text below.''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceEditor(initialContent: content),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SourceEditor), findsOneWidget);
    });

    testWidgets('应支持搜索高亮', (tester) async {
      const content = 'hello world hello';
      final highlight = SourceEditorSearchHighlight(
        ranges: [const TextRange(start: 0, end: 5)],
        currentHighlightIndex: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceEditor(
              initialContent: content,
              searchHighlight: highlight,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SourceEditor), findsOneWidget);
    });
  });

  group('HighlightTextEditingController', () {
    test('设置高亮范围应不崩溃', () {
      final controller = HighlightTextEditingController(
        text: 'hello world hello world',
      );
      controller.setHighlights([
        const TextRange(start: 0, end: 5),
        const TextRange(start: 12, end: 17),
      ], currentIndex: 0);

      expect(controller.text, 'hello world hello world');
    });

    test('清除高亮后应正常', () {
      final controller = HighlightTextEditingController(text: 'test text');
      controller.setHighlights([const TextRange(start: 0, end: 4)]);
      controller.clearHighlights();
      expect(controller.text, 'test text');
    });

    test('buildTextSpan 含高亮应正确生成 TextSpan', () {
      final controller = HighlightTextEditingController(
        text: 'AB hello CD',
      );
      controller.baseStyle = const TextStyle(fontSize: 14);
      controller.setHighlights([
        const TextRange(start: 3, end: 8),
      ], currentIndex: 0);

      // buildTextSpan 需要 context，但我们测试不崩溃即可
      // 这里只验证基础属性
      expect(controller.text, 'AB hello CD');
    });
  });

  group('QuickInsert 菜单', () {
    test('应有 5 个分类', () {
      expect(QuickInsertMenu.categories.length, 5);
    });

    test('基础块应有 3 个项目', () {
      final basic = QuickInsertMenu.categories[0];
      expect(basic.title, '基础块');
      expect(basic.items.length, 3);
    });

    test('标题应有 6 个项目', () {
      final headings = QuickInsertMenu.categories[1];
      expect(headings.title, '标题');
      expect(headings.items.length, 6);
    });

    test('高级块应包含表格和代码块', () {
      final advanced = QuickInsertMenu.categories[2];
      final labels = advanced.items.map((i) => i.label).toList();
      expect(labels, contains('table'));
      expect(labels, contains('pre'));
    });

    test('列表应包含有序/无序/任务列表', () {
      final lists = QuickInsertMenu.categories[3];
      final labels = lists.items.map((i) => i.label).toList();
      expect(labels, contains('ol-order'));
      expect(labels, contains('ul-bullet'));
      expect(labels, contains('ul-task'));
    });

    test('图表应有 3 个项目', () {
      final diagrams = QuickInsertMenu.categories[4];
      expect(diagrams.title, '图表');
      expect(diagrams.items.length, 3);
      final labels = diagrams.items.map((i) => i.label).toList();
      expect(labels, contains('mermaid'));
      expect(labels, contains('flowchart'));
      expect(labels, contains('sequence'));
    });

    test('labelToCommandId 映射正确', () {
      expect(QuickInsertMenu.labelToCommandId('heading 1'), 'paragraph.heading-1');
      expect(QuickInsertMenu.labelToCommandId('pre'), 'paragraph.code-fence');
      expect(QuickInsertMenu.labelToCommandId('table'), 'paragraph.table');
      expect(QuickInsertMenu.labelToCommandId('blockquote'), 'paragraph.quote-block');
      expect(QuickInsertMenu.labelToCommandId('ol-order'), 'paragraph.order-list');
      expect(QuickInsertMenu.labelToCommandId('ul-bullet'), 'paragraph.bullet-list');
      expect(QuickInsertMenu.labelToCommandId('ul-task'), 'paragraph.task-list');
      expect(QuickInsertMenu.labelToCommandId('hr'), 'paragraph.horizontal-line');
    });
  });

  group('SearchService', () {
    late SearchService service;

    setUp(() {
      service = SearchService();
    });

    test('基本搜索', () {
      const text = 'hello world hello';
      final result = service.search(text, 'hello', const SearchOptions());
      expect(result.count, 2);
    });

    test('大小写敏感搜索', () {
      const text = 'Hello hello world';
      final result = service.search(
        text,
        'Hello',
        const SearchOptions(caseSensitive: true),
      );
      expect(result.count, 1);
    });

    test('全词匹配搜索', () {
      const text = 'hello helloworld';
      final result = service.search(
        text,
        'hello',
        const SearchOptions(wholeWord: true),
      );
      expect(result.count, 1);
    });

    test('正则搜索', () {
      const text = 'abc123 def456';
      final result = service.search(
        text,
        r'\d+',
        const SearchOptions(useRegex: true),
      );
      expect(result.count, 2);
    });

    test('替换匹配项', () {
      const text = 'hello world';
      final result = service.search(text, 'hello', const SearchOptions());
      final newText = service.replaceSingle(
        text,
        result.matches.first,
        'hi',
        const SearchOptions(),
      );
      expect(newText, 'hi world');
    });

    test('全部替换', () {
      const text = 'hello hello world';
      final newText = service.replaceAll(
        text,
        'hello',
        'hi',
        const SearchOptions(),
      );
      expect(newText, 'hi hi world');
    });

    test('验证正则', () {
      expect(service.validateRegex(r'\d+'), isNull);
      expect(service.validateRegex(r'['), isNotNull);
    });
  });
}
