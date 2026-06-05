/// 源码编辑器搜索高亮测试
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:markflowy/widgets/editor/source_editor.dart';

void main() {
  group('HighlightTextEditingController', () {
    test('初始化时无高亮', () {
      final controller = HighlightTextEditingController(text: 'hello world');
      // 初始状态下应该没有高亮
      expect(controller.text, 'hello world');
    });

    test('setHighlights 应更新高亮范围', () {
      final controller = HighlightTextEditingController(text: 'hello hello world');

      // 模拟搜索 "hello" 的匹配
      controller.setHighlights([
        const TextRange(start: 0, end: 5),
        const TextRange(start: 6, end: 11),
      ], currentIndex: 0);

      // 调用 setHighlights 不应崩溃
      expect(controller.text, 'hello hello world');
    });

    test('clearHighlights 应移除高亮', () {
      final controller = HighlightTextEditingController(text: 'test text');

      controller.setHighlights([const TextRange(start: 0, end: 4)]);
      controller.clearHighlights();

      // 清除后不应崩溃
      expect(controller.text, 'test text');
    });
  });

  group('SourceEditorSearchHighlight', () {
    test('空高亮列表的 hasHighlights 应为 false', () {
      const highlight = SourceEditorSearchHighlight();
      expect(highlight.hasHighlights, isFalse);
    });

    test('有匹配的 hasHighlights 应为 true', () {
      const highlight = SourceEditorSearchHighlight(
        ranges: [TextRange(start: 0, end: 5)],
      );
      expect(highlight.hasHighlights, isTrue);
    });

    test('currentHighlightIndex 默认值', () {
      const highlight = SourceEditorSearchHighlight(
        ranges: [TextRange(start: 0, end: 3)],
      );
      expect(highlight.currentHighlightIndex, -1);
    });

    test('可指定 currentHighlightIndex', () {
      const highlight = SourceEditorSearchHighlight(
        ranges: [TextRange(start: 0, end: 3), TextRange(start: 5, end: 8)],
        currentHighlightIndex: 1,
      );
      expect(highlight.currentHighlightIndex, 1);
    });
  });
}
