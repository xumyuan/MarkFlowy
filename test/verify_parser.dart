import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;

void main() {
  test('markdown 包解析 fenced code block', () {
    final ast = [
      '```dart',
      'void main() {',
      '  print("hello");',
      '}',
      '```',
      '',
      'After code block.',
    ].join('\n');

    final doc = markdownToDocument(ast);
    final types = doc.root.children.map((n) => n.type).toList();
    
    // 不使用自定义 parser，看看默认结果
    print('DEFAULT types: $types');
    
    // 至少应该有一个 paragraph 节点（appflowy_editor 没有 code parser 所以代码块被当作 paragraph）
    expect(types, isNotEmpty);
  });

  test('自定义 code_block parser 应正确创建 code_block 节点', () {
    final ast = [
      '```dart',
      'void main() {',
      '  print("hello");',
      '}',
      '```',
      '',
      'After code block.',
    ].join('\n');

    // 使用自定义 parser
    final doc = markdownToDocument(
      ast,
      markdownParsers: const [_TestCodeBlockParser()],
    );
    final types = doc.root.children.map((n) => n.type).toList();
    print('CUSTOM types: $types');

    // 应该包含 code_block 类型
    final hasCodeBlock = doc.root.children.any((n) => n.type == 'code_block');
    print('hasCodeBlock: $hasCodeBlock');

    if (!hasCodeBlock) {
      for (final n in doc.root.children) {
        print('  node: type=${n.type}, delta=${n.delta?.toPlainText()}');
      }
    }

    expect(hasCodeBlock, isTrue, reason: 'code_block 节点未被创建，实际类型为: $types');
  });
}

// ===== 自定义 parser（复制 code_block.dart 中的逻辑）=====

class _TestCodeBlockParser extends CustomMarkdownParser {
  const _TestCodeBlockParser();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownParser> parsers, {
    MarkdownListType listType = MarkdownListType.unknown,
    int? startNumber,
  }) {
    if (element is! md.Element || element.tag != 'pre') return [];

    md.Element? codeEl;
    for (final c in element.children ?? <md.Node>[]) {
      if (c is md.Element && c.tag == 'code') { codeEl = c; break; }
    }
    if (codeEl == null) return [];

    String lang = '';
    final cls = codeEl.attributes['class'];
    if (cls != null && cls.startsWith('language-')) {
      lang = cls.substring('language-'.length);
    }

    print('PARSER HIT: lang=$lang code="${codeEl.textContent.trim()}"');
    return [
      Node(type: 'code_block', attributes: {
        'language': lang,
        'code': codeEl.textContent,
      })
    ];
  }
}
