/// 编辑器主屏幕布局
/// 参考: marktext/src/renderer/src/pages/app.vue
///
/// 整体布局结构（对应 marktext editor-container 的 flex row 布局）:
/// ┌─────────────────────────────────────────────────────┐
/// │                    标题栏 (TitleBar)                  │
/// ├──────┬──────────────────────────────────────────────┤
/// │      │              标签栏 (TabBar)                   │
/// │ 侧边 ├──────────────────────────────────────────────┤
/// │  栏  │            工具栏 (EditorToolbar)              │
/// │      ├──────────────────────────────────────────────┤
/// │      │              编辑区 (Editor)                   │
/// │      │                                               │
/// │      ├──────────────────────────────────────────────┤
/// │      │            状态栏 (ModeSwitcher)               │
/// └──────┴──────────────────────────────────────────────┘
///
/// - 桌面: 完整侧边栏 + 标签栏
/// - 平板: 可收起侧边栏
/// - 手机: 抽屉式侧边栏
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/editor_provider.dart';
import '../widgets/common/responsive_layout.dart';
import '../widgets/editor/editor_toolbar.dart';
import '../widgets/editor/mode_switcher.dart';
import '../widgets/editor/source_editor.dart';
import '../widgets/editor/split_view.dart';
import '../widgets/editor/wysiwyg_editor.dart';
import '../widgets/sidebar/sidebar.dart';
import '../widgets/tabs/tab_bar.dart';
import '../widgets/titlebar/title_bar.dart';

/// 编辑器主屏幕
/// 对应 marktext app.vue 中的 editor-container 整体布局
class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(tabBarProvider);
    final activeDoc = tabState.activeDocument;

    return ResponsiveLayout(
      // 桌面布局：完整侧边栏 + 标签
      desktop: (context) => _DesktopLayout(
        filename: activeDoc?.filename,
        isSaved: activeDoc?.isSaved ?? true,
      ),
      // 平板布局：可收起侧边栏
      tablet: (context) => _TabletLayout(
        filename: activeDoc?.filename,
        isSaved: activeDoc?.isSaved ?? true,
      ),
      // 手机布局：抽屉式侧边栏
      mobile: (context) => _MobileLayout(
        filename: activeDoc?.filename,
        isSaved: activeDoc?.isSaved ?? true,
      ),
    );
  }
}

/// 构建编辑区域：工具栏 + 编辑器 + 状态栏(模式切换)
/// 根据当前 EditorMode 显示不同的编辑器组件
class _EditorArea extends ConsumerWidget {
  const _EditorArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);

    return Column(
      children: [
        // 工具栏（仅 WYSIWYG 模式下显示，对应 marktext FormatPicker）
        if (editorState.mode == EditorMode.wysiwyg)
          EditorToolbar(
            onFormatAction: (type) {
              // TODO: 连接到 appflowy_editor 的 format 操作
            },
            onBlockAction: (type) {
              // TODO: 连接到 appflowy_editor 的 block 操作
            },
            onInsertAction: (type) {
              // TODO: 连接到 appflowy_editor 的插入操作
            },
          ),

        // 编辑器主体（根据模式切换）
        Expanded(
          child: _buildEditorByMode(editorState, editorNotifier),
        ),

        // 底部状态栏：模式切换器
        _buildStatusBar(context, editorState, editorNotifier),
      ],
    );
  }

  /// 根据当前模式构建对应的编辑器
  Widget _buildEditorByMode(EditorState state, EditorNotifier notifier) {
    return switch (state.mode) {
      // WYSIWYG 模式：编辑器内部自管理文档状态，仅标记脏状态
      // 避免 state.markdown 变化触发整个编辑器重建的死循环
      EditorMode.wysiwyg => WysiwygEditor(
          key: const ValueKey('wysiwyg'),
          initialContent: state.markdown,
          onContentChanged: (_) => notifier.updateMarkdown('', markDirtyOnly: true),
        ),
      EditorMode.sourceCode => SourceEditor(
          initialContent: state.markdown,
          onContentChanged: (content) => notifier.updateMarkdown(content),
        ),
      EditorMode.splitView => SplitView(
          initialContent: state.markdown,
          onContentChanged: (content) => notifier.updateMarkdown(content),
        ),
    };
  }

  /// 构建底部状态栏（包含模式切换器）
  Widget _buildStatusBar(
    BuildContext context,
    EditorState state,
    EditorNotifier notifier,
  ) {
    final theme = Theme.of(context);

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // 左侧：文档修改状态
          if (state.isModified)
            Text(
              '已修改',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.primary,
              ),
            ),
          const Spacer(),
          // 右侧：模式切换器
          ModeSwitcher(
            currentMode: state.mode,
            onModeChanged: (mode) => notifier.setMode(mode),
          ),
        ],
      ),
    );
  }
}

/// 桌面布局（对应 marktext editor-container 的默认宽屏布局）
class _DesktopLayout extends StatelessWidget {
  final String? filename;
  final bool isSaved;

  const _DesktopLayout({this.filename, this.isSaved = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 标题栏（对应 marktext title-bar，在 editor-middle 内）
        TitleBar(
          filename: filename,
          isSaved: isSaved,
        ),

        // 主体区域：侧边栏 + 编辑区
        Expanded(
          child: Row(
            children: [
              // 侧边栏（对应 marktext side-bar）
              const SideBar(),

              // 编辑器中间区域（对应 editor-middle）
              const Expanded(
                child: Column(
                  children: [
                    // 标签栏（对应 editorWithTabs/tabs）
                    EditorTabBar(),

                    // 编辑区域：工具栏 + 编辑器 + 状态栏
                    Expanded(
                      child: _EditorArea(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 平板布局 — 可收起侧边栏
class _TabletLayout extends ConsumerWidget {
  final String? filename;
  final bool isSaved;

  const _TabletLayout({this.filename, this.isSaved = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        TitleBar(filename: filename, isSaved: isSaved),
        Expanded(
          child: Row(
            children: [
              // 平板模式下侧边栏仍在左侧，但默认收起面板
              const SideBar(),
              const Expanded(
                child: Column(
                  children: [
                    EditorTabBar(),
                    Expanded(child: _EditorArea()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 手机布局 — 使用 Drawer 实现侧边栏
class _MobileLayout extends StatelessWidget {
  final String? filename;
  final bool isSaved;

  const _MobileLayout({this.filename, this.isSaved = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 手机端使用 Drawer 作为侧边栏
      drawer: const Drawer(
        child: SideBar(),
      ),
      appBar: AppBar(
        title: Text(
          filename ?? 'MarkText',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          // 未保存标记
          if (!isSaved)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
      body: const Column(
        children: [
          EditorTabBar(),
          Expanded(child: _EditorArea()),
        ],
      ),
    );
  }
}

