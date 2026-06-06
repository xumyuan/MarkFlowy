/// 验证代码块 widget 在 AppFlowyEditor 中被正确渲染
library;

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:markflowy/widgets/editor/code_block.dart';

final _builders = <String, BlockComponentBuilder>{
  ...standardBlockComponentBuilderMap,
  CodeBlockKeys.type: CodeBlockComponentBuilder(),
};

Document _makeDoc(String md) {
  return markdownToDocument(md, markdownParsers: const [CodeBlockMarkdownParser()]);
}

void main() {
  testWidgets('代码块节点应正确渲染，内容可见', (tester) async {
    final doc = _makeDoc('```dart\nvoid main() {}\n```');
    final types = doc.root.children.map((n) => n.type).toList();
    expect(types, contains(CodeBlockKeys.type), reason: '解析为: $types');

    final es = EditorState(document: doc);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: AppFlowyEditor(
      editorState: es,
      blockComponentBuilders: _builders,
    ))));
    await tester.pump();

    // 代码文本在 SelectableText 中可见
    expect(find.textContaining('void main'), findsOneWidget);
  });

  testWidgets('语言标签应渲染', (tester) async {
    final doc = _makeDoc('```python\nprint(1)\n```');
    final es = EditorState(document: doc);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: AppFlowyEditor(
      editorState: es,
      blockComponentBuilders: _builders,
    ))));
    await tester.pump();

    expect(find.text('python'), findsOneWidget);
    expect(find.textContaining('print(1)'), findsOneWidget);
  });

  testWidgets('代码块 + 后跟段落不应崩溃', (tester) async {
    final doc = _makeDoc('```js\nx=1\n```\n\nhello world');
    final es = EditorState(document: doc);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: AppFlowyEditor(
      editorState: es,
      blockComponentBuilders: _builders,
    ))));
    await tester.pump();

    // 代码块内容可见，段落由 AppFlowyRichText 渲染（TextSpan 不可用 textContaining 查找）
    expect(find.textContaining('x=1'), findsOneWidget);
    expect(find.byType(AppFlowyEditor), findsOneWidget);
  });

  testWidgets('无语言代码块也应渲染', (tester) async {
    final doc = _makeDoc('```\nplain code\n```');
    final es = EditorState(document: doc);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: AppFlowyEditor(
      editorState: es,
      blockComponentBuilders: _builders,
    ))));
    await tester.pump();

    expect(find.textContaining('plain code'), findsOneWidget);
  });
}
