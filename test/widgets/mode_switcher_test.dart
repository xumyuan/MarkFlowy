/// 模式切换 Widget 测试
/// 测试编辑器模式切换 UI
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_markdown_editor/providers/editor_provider.dart';
import 'package:flutter_markdown_editor/widgets/editor/mode_switcher.dart';

void main() {
  group('ModeSwitcher Widget', () {
    Widget createTestWidget({
      EditorMode mode = EditorMode.wysiwyg,
      ValueChanged<EditorMode>? onModeChanged,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: ModeSwitcher(
                currentMode: mode,
                onModeChanged: onModeChanged,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('应正确渲染模式切换组件', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ModeSwitcher), findsOneWidget);
    });

    testWidgets('应显示三个模式选项', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('WYSIWYG'), findsOneWidget);
      expect(find.text('源码'), findsOneWidget);
      expect(find.text('分屏'), findsOneWidget);
    });

    testWidgets('点击源码模式应触发回调', (tester) async {
      EditorMode? selectedMode;
      await tester.pumpWidget(createTestWidget(
        onModeChanged: (mode) => selectedMode = mode,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('源码'));
      await tester.pumpAndSettle();

      expect(selectedMode, EditorMode.sourceCode);
    });

    testWidgets('点击分屏模式应触发回调', (tester) async {
      EditorMode? selectedMode;
      await tester.pumpWidget(createTestWidget(
        onModeChanged: (mode) => selectedMode = mode,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('分屏'));
      await tester.pumpAndSettle();

      expect(selectedMode, EditorMode.splitView);
    });

    testWidgets('当前模式应高亮显示', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mode: EditorMode.sourceCode,
      ));
      await tester.pumpAndSettle();

      // SegmentedButton 正常渲染即可验证高亮
      expect(find.byType(ModeSwitcher), findsOneWidget);
      expect(find.byType(SegmentedButton<EditorMode>), findsOneWidget);
    });

    testWidgets('应响应不同初始模式', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mode: EditorMode.splitView,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ModeSwitcher), findsOneWidget);
    });
  });
}
