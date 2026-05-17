/// 编辑器 Provider 单元测试
/// 测试编辑模式切换和文档状态管理
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:markflowy/providers/editor_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('EditorNotifier', () {
    group('初始状态', () {
      test('初始模式应为 WYSIWYG', () {
        final state = container.read(editorProvider);
        expect(state.mode, EditorMode.wysiwyg);
      });

      test('初始文档 ID 应为 null', () {
        final state = container.read(editorProvider);
        expect(state.activeDocumentId, isNull);
      });

      test('初始 markdown 应为空', () {
        final state = container.read(editorProvider);
        expect(state.markdown, isEmpty);
      });

      test('初始修改状态应为 false', () {
        final state = container.read(editorProvider);
        expect(state.isModified, isFalse);
      });

      test('初始焦点模式应为 false', () {
        final state = container.read(editorProvider);
        expect(state.isFocusMode, isFalse);
      });

      test('初始打字机模式应为 false', () {
        final state = container.read(editorProvider);
        expect(state.isTypewriterMode, isFalse);
      });
    });

    group('setMode', () {
      test('应切换到源码模式', () {
        container.read(editorProvider.notifier).setMode(EditorMode.sourceCode);
        final state = container.read(editorProvider);
        expect(state.mode, EditorMode.sourceCode);
      });

      test('应切换到分屏模式', () {
        container.read(editorProvider.notifier).setMode(EditorMode.splitView);
        final state = container.read(editorProvider);
        expect(state.mode, EditorMode.splitView);
      });

      test('应切换回 WYSIWYG 模式', () {
        container.read(editorProvider.notifier).setMode(EditorMode.sourceCode);
        container.read(editorProvider.notifier).setMode(EditorMode.wysiwyg);
        final state = container.read(editorProvider);
        expect(state.mode, EditorMode.wysiwyg);
      });
    });

    group('cycleMode', () {
      test('从 WYSIWYG 应切换到源码', () {
        container.read(editorProvider.notifier).cycleMode();
        expect(container.read(editorProvider).mode, EditorMode.sourceCode);
      });

      test('从源码应切换到分屏', () {
        container.read(editorProvider.notifier).setMode(EditorMode.sourceCode);
        container.read(editorProvider.notifier).cycleMode();
        expect(container.read(editorProvider).mode, EditorMode.splitView);
      });

      test('从分屏应切换到 WYSIWYG', () {
        container.read(editorProvider.notifier).setMode(EditorMode.splitView);
        container.read(editorProvider.notifier).cycleMode();
        expect(container.read(editorProvider).mode, EditorMode.wysiwyg);
      });
    });

    group('updateMarkdown', () {
      test('应更新 markdown 内容', () {
        container
            .read(editorProvider.notifier)
            .updateMarkdown('# Hello');
        final state = container.read(editorProvider);
        expect(state.markdown, '# Hello');
      });

      test('更新内容后应标记为已修改', () {
        container
            .read(editorProvider.notifier)
            .updateMarkdown('content');
        final state = container.read(editorProvider);
        expect(state.isModified, isTrue);
      });
    });

    group('loadDocument', () {
      test('应加载文档内容', () {
        container
            .read(editorProvider.notifier)
            .loadDocument('doc-1', '# Test');
        final state = container.read(editorProvider);
        expect(state.activeDocumentId, 'doc-1');
        expect(state.markdown, '# Test');
      });

      test('加载文档后修改状态应为 false', () {
        container
            .read(editorProvider.notifier)
            .loadDocument('doc-1', 'content');
        final state = container.read(editorProvider);
        expect(state.isModified, isFalse);
      });
    });

    group('markModified / markSaved', () {
      test('markModified 应设置为已修改', () {
        container.read(editorProvider.notifier).markModified();
        expect(container.read(editorProvider).isModified, isTrue);
      });

      test('markSaved 应设置为未修改', () {
        container.read(editorProvider.notifier).markModified();
        container.read(editorProvider.notifier).markSaved();
        expect(container.read(editorProvider).isModified, isFalse);
      });
    });

    group('toggleFocusMode', () {
      test('应切换焦点模式', () {
        container.read(editorProvider.notifier).toggleFocusMode();
        expect(container.read(editorProvider).isFocusMode, isTrue);
      });

      test('再次切换应关闭焦点模式', () {
        container.read(editorProvider.notifier).toggleFocusMode();
        container.read(editorProvider.notifier).toggleFocusMode();
        expect(container.read(editorProvider).isFocusMode, isFalse);
      });
    });

    group('toggleTypewriterMode', () {
      test('应切换打字机模式', () {
        container.read(editorProvider.notifier).toggleTypewriterMode();
        expect(container.read(editorProvider).isTypewriterMode, isTrue);
      });

      test('再次切换应关闭打字机模式', () {
        container.read(editorProvider.notifier).toggleTypewriterMode();
        container.read(editorProvider.notifier).toggleTypewriterMode();
        expect(container.read(editorProvider).isTypewriterMode, isFalse);
      });
    });

    group('setActiveDocument', () {
      test('应设置活动文档 ID', () {
        container
            .read(editorProvider.notifier)
            .setActiveDocument('doc-abc');
        expect(
          container.read(editorProvider).activeDocumentId,
          'doc-abc',
        );
      });

      test('应支持设置为 null', () {
        container
            .read(editorProvider.notifier)
            .setActiveDocument('doc-1');
        container.read(editorProvider.notifier).setActiveDocument(null);
        expect(container.read(editorProvider).activeDocumentId, isNull);
      });
    });
  });
}
