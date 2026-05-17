/// 编辑器主屏幕布局
/// 参考: marktext/src/renderer/src/pages/app.vue
///
/// 整体布局结构（对应 marktext editor-container 的 flex row 布局）:
/// ┌─────────────────────────────────────────────────────┐
/// │                    标题栏 (TitleBar)                  │
/// ├──────┬──────────────────────────────────────────────┤
/// │      │              标签栏 (TabBar)                   │
/// │ 侧边 ├──────────────────────────────────────────────┤
/// │  栏  │          搜索替换栏 (SearchReplaceBar)         │
/// │      ├──────────────────────────────────────────────┤
/// │      │              编辑区 (Editor)                   │
/// │      │                                               │
/// │      ├──────────────────────────────────────────────┤
/// │      │            状态栏 (ModeSwitcher)               │
/// └──────┴──────────────────────────────────────────────┘
///
/// - 桌面: 完整侧边栏 + 标签栏 + 命令面板 overlay
/// - 平板: 可收起侧边栏
/// - 手机: 抽屉式侧边栏
library;

import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../models/document.dart';
import '../providers/editor_provider.dart';
import '../providers/file_provider.dart';
import '../providers/search_provider.dart';
import '../utils/strings.dart';
import '../widgets/command_palette.dart';
import '../widgets/common/responsive_layout.dart';
import '../widgets/editor/mode_switcher.dart';
import '../widgets/editor/source_editor.dart';
import '../widgets/editor/split_view.dart';
import '../widgets/editor/wysiwyg_editor.dart';
import '../widgets/search/search_replace_bar.dart';
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

/// 构建编辑区域：搜索栏 + 编辑器 + 状态栏(模式切换)
/// 根据当前 EditorMode 显示不同的编辑器组件
/// 包含应用级快捷键绑定
class _EditorArea extends ConsumerWidget {
  const _EditorArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);
    final searchState = ref.watch(searchProvider);

    return CallbackShortcuts(
      bindings: {
        // Cmd/Ctrl+S: 保存
        SingleActivator(
          LogicalKeyboardKey.keyS,
          meta: Platform.isMacOS,
          control: !Platform.isMacOS,
        ): () => _saveCurrentDocument(ref),
        // Cmd/Ctrl+F: 打开搜索栏
        SingleActivator(
          LogicalKeyboardKey.keyF,
          meta: Platform.isMacOS,
          control: !Platform.isMacOS,
        ): () => ref.read(searchProvider.notifier).openSearch(),
        // Cmd/Ctrl+H: 打开搜索替换栏
        SingleActivator(
          LogicalKeyboardKey.keyH,
          meta: Platform.isMacOS,
          control: !Platform.isMacOS,
        ): () => ref.read(searchProvider.notifier).openReplace(),
        // Cmd/Ctrl+Shift+P: 打开命令面板
        SingleActivator(
          LogicalKeyboardKey.keyP,
          meta: Platform.isMacOS,
          control: !Platform.isMacOS,
          shift: true,
        ): () => ref.read(commandPaletteVisibleProvider.notifier).show(),
        // Cmd/Ctrl+N: 新建标签
        SingleActivator(
          LogicalKeyboardKey.keyN,
          meta: Platform.isMacOS,
          control: !Platform.isMacOS,
        ): () => ref.read(tabBarProvider.notifier).addTab(),
        // Cmd/Ctrl+O: 打开文件
        SingleActivator(
          LogicalKeyboardKey.keyO,
          meta: Platform.isMacOS,
          control: !Platform.isMacOS,
        ): () => _openFile(ref),
        // Cmd/Ctrl+W: 关闭当前标签
        SingleActivator(
          LogicalKeyboardKey.keyW,
          meta: Platform.isMacOS,
          control: !Platform.isMacOS,
        ): () => _closeCurrentTab(ref),
      },
      child: Focus(
        autofocus: true,
        child: Column(
          children: [
            // 搜索替换栏（当 searchProvider.isVisible 时显示）
            if (searchState.isVisible)
              SearchReplaceBar(
                getDocumentContent: () => ref.read(editorProvider).markdown,
                onReplace: (newContent) =>
                    ref.read(editorProvider.notifier).updateMarkdown(newContent),
              ),

            // 编辑器主体（根据模式切换）
            Expanded(
              child: _buildEditorByMode(editorState, editorNotifier),
            ),

            // 底部状态栏：模式切换器
            _buildStatusBar(context, editorState, editorNotifier),
          ],
        ),
      ),
    );
  }

  /// 保存当前文档
  void _saveCurrentDocument(WidgetRef ref) {
    final tabState = ref.read(tabBarProvider);
    final activeDoc = tabState.activeDocument;
    if (activeDoc == null) return;

    // 从 editorProvider 获取最新内容
    final editorState = ref.read(editorProvider);
    final docToSave = activeDoc.copyWith(content: editorState.markdown);

    ref.read(fileProvider.notifier).saveFile(docToSave).then((success) {
      if (success) {
        ref.read(editorProvider.notifier).markSaved();
        // 同步标签栏文档状态
        ref.read(tabBarProvider.notifier).updateTabSaved(activeDoc.id);
      }
    });
  }

  /// 打开文件（通过文件选择器）
  void _openFile(WidgetRef ref) {
    ref.read(fileProvider.notifier).openFile().then((doc) {
      if (doc != null) {
        ref.read(tabBarProvider.notifier).openFileTab(doc);
      }
    });
  }

  /// 关闭当前标签
  void _closeCurrentTab(WidgetRef ref) {
    final tabState = ref.read(tabBarProvider);
    final activeId = tabState.activeTabId;
    if (activeId != null) {
      ref.read(tabBarProvider.notifier).closeTab(activeId);
    }
  }

  /// 根据当前模式构建对应的编辑器
  Widget _buildEditorByMode(AppEditorState state, EditorNotifier notifier) {
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
    AppEditorState state,
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
              AppStrings.modified,
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
/// 支持拖拽 .md/.markdown/.txt 文件到编辑器打开
class _DesktopLayout extends ConsumerStatefulWidget {
  final String? filename;
  final bool isSaved;

  const _DesktopLayout({this.filename, this.isSaved = true});

  @override
  ConsumerState<_DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends ConsumerState<_DesktopLayout> {
  /// 是否正在拖拽文件到窗口上
  bool _isDragging = false;

  /// 支持的文件扩展名
  static const _supportedExtensions = ['.md', '.markdown', '.txt'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: (details) {
        setState(() => _isDragging = false);
        _handleDroppedFiles(details);
      },
      child: Stack(
        children: [
          // 主布局
          Column(
            children: [
              // 标题栏（对应 marktext title-bar，在 editor-middle 内）
              TitleBar(
                filename: widget.filename,
                isSaved: widget.isSaved,
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

                          // 编辑区域：编辑器 + 状态栏
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
          ),

          // 命令面板（overlay 覆盖层）
          const CommandPalette(),

          // 拖拽视觉反馈遮罩
          if (_isDragging)
            Positioned.fill(
              child: Container(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppStrings.dropToOpen,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 处理拖拽释放的文件
  void _handleDroppedFiles(DropDoneDetails details) {
    for (final xFile in details.files) {
      final path = xFile.path;
      final ext = p.extension(path).toLowerCase();
      if (!_supportedExtensions.contains(ext)) continue;

      // 读取文件内容并打开为新标签
      File(path).readAsString().then((content) {
        final doc = Document(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          filePath: path,
          filename: p.basename(path),
          content: content,
          isSaved: true,
          createdAt: DateTime.now(),
          lastModifiedAt: DateTime.now(),
        );
        ref.read(tabBarProvider.notifier).openFileTab(doc);
        ref.read(editorProvider.notifier).loadDocument(doc.id, content);
      });
    }
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

