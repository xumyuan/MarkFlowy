/// 验证 CodeBlockMarkdownParser 的 markdown → code_block 节点解析
library;

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markflowy/widgets/editor/code_block.dart';

void main() {
  group('CodeBlockMarkdownParser — 解析fenced code block', () {
    test('应解析带语言的代码块', () {
      const markdown = '```dart\nvoid main() {\n  print("hello");\n}\n```';

      final doc = markdownToDocument(
        markdown,
        markdownParsers: const [CodeBlockMarkdownParser()],
      );

      final rootChildren = doc.root.children;
      expect(rootChildren.length, greaterThan(0),
          reason: 'document should have at least one child node');

      // 检查是否生成了 code_block 节点（而非 paragraph）
      final hasCodeBlock =
          rootChildren.any((n) => n.type == CodeBlockKeys.type);
      expect(hasCodeBlock, isTrue,
          reason: '应为 code_block 节点，非普通 paragraph。'
              '实际类型: ${rootChildren.map((n) => n.type).toList()}');
    });

    test('应解析多行代码块', () {
      const markdown = '```python\n'
          'def hello():\n'
          '    print("world")\n'
          '```';

      final doc = markdownToDocument(
        markdown,
        markdownParsers: const [CodeBlockMarkdownParser()],
      );

      final node = doc.root.children
          .firstWhere((n) => n.type == CodeBlockKeys.type,
              orElse: () => Node(type: 'none'));

      expect(node.type, CodeBlockKeys.type);

      final lang = node.attributes[CodeBlockKeys.language];
      final code = node.attributes[CodeBlockKeys.code];

      expect(lang, 'python');
      expect(code, contains('def hello():'));
      expect(code, contains('print("world")'));
    });

    test('应解析无语言的代码块', () {
      const markdown = '```\nplain text\n```';

      final doc = markdownToDocument(
        markdown,
        markdownParsers: const [CodeBlockMarkdownParser()],
      );

      final node = doc.root.children.firstWhere(
        (n) => n.type == CodeBlockKeys.type,
        orElse: () => Node(type: 'none'),
      );

      expect(node.type, CodeBlockKeys.type);
      expect(node.attributes[CodeBlockKeys.language], isEmpty);
      expect(node.attributes[CodeBlockKeys.code], contains('plain text'));
    });

    test('应解析代码块后跟着常规段落', () {
      const markdown = '```js\nconsole.log(1);\n```\n\nAfter code block';

      final doc = markdownToDocument(
        markdown,
        markdownParsers: const [CodeBlockMarkdownParser()],
      );

      final types = doc.root.children.map((n) => n.type).toList();
      expect(types, contains(CodeBlockKeys.type),
          reason: '应有 code_block 节点，实际类型: $types');
      expect(types, contains('paragraph'),
          reason: '后面应有 paragraph 节点');
    });

    test('自定义编码器应正确往返', () {
      const markdown = '```rust\nfn main() {\n    println!("hi");\n}\n```';

      final doc = markdownToDocument(
        markdown,
        markdownParsers: const [CodeBlockMarkdownParser()],
      );

      final roundtrip = documentToMarkdown(
        doc,
        customParsers: const [CustomCodeBlockNodeParser()],
      );

      expect(roundtrip, contains('```rust'));
      expect(roundtrip, contains('println!("hi")'));
      expect(roundtrip, contains('```'));
    });

    test('空代码块应正确解析和往返', () {
      const markdown = '```\n\n```';

      final doc = markdownToDocument(
        markdown,
        markdownParsers: const [CodeBlockMarkdownParser()],
      );

      final roundtrip = documentToMarkdown(
        doc,
        customParsers: const [CustomCodeBlockNodeParser()],
      );

      expect(roundtrip, contains('```'));
    });
  });
}
