/// 编辑器主屏幕布局
/// 参考: marktext/src/renderer/src/pages/app.vue
///
/// 整体布局结构（对应 marktext editor-container 的 flex row 布局）:
/// ┌─────────────────────────────────────────────────────┐
/// │                    标题栏 (TitleBar)                  │
/// ├──────┬──────────────────────────────────────────────┤
/// │      │              标签栏 (TabBar)                   │
/// │ 侧边 ├──────────────────────────────────────────────┤
/// │  栏  │    搜索替换栏 (SearchReplaceBar, Stack overlay) │
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

import 'dart:async';
import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart' as appflowy;
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../models/app_settings.dart';
import '../models/document.dart';
import '../providers/editor_provider.dart';
import '../providers/file_provider.dart';
import '../providers/search_provider.dart';
import '../services/command_bus.dart';
import '../services/image_service.dart';
import '../utils/strings.dart';
import '../widgets/command_palette.dart';
import '../widgets/common/responsive_layout.dart';
import '../widgets/editor/editor_toolbar.dart';
import '../widgets/editor/mode_switcher.dart';
import '../widgets/editor/quick_insert.dart';
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
class _EditorArea extends ConsumerStatefulWidget {
  const _EditorArea();

  @override
  ConsumerState<_EditorArea> createState() => _EditorAreaState();
}

class _EditorAreaState extends ConsumerState<_EditorArea> {
  /// WYSIWYG 编辑器的 GlobalKey，用于获取实时内容
  final _wysiwygKey = GlobalKey<WysiwygEditorState>();

  /// 自动保存定时器
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    // 延迟注册命令到 frame 结束后，避免在 widget 构建期间修改 provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerCommands();
    });
  }

  /// 向 CommandBus 注册所有可处理的命令
  /// 对应 marktext 中所有 menu actions 的实现
  void _registerCommands() {
    final bus = ref.read(commandBusProvider.notifier);
    bus.registerHandlers({
      // ========== 文件操作 ==========
      'file.save': (_) => _saveCurrentDocument(),
      'file.save-as': (_) => _saveAs(),
      'file.new-tab': (_) => ref.read(tabBarProvider.notifier).addTab(),
      'file.open-file': (_) => _openFile(ref),
      'file.open-folder': (_) => ref.read(fileProvider.notifier).openFolder(),
      'file.close-tab': (_) => _closeCurrentTab(ref),
      'file.quick-open': (_) => ref.read(commandPaletteVisibleProvider.notifier).show(),

      // ========== 编辑操作 ==========
      'edit.find': (_) => ref.read(searchProvider.notifier).openSearch(),
      'edit.find-next': (_) => ref.read(searchProvider.notifier).findNext(),
      'edit.find-previous': (_) => ref.read(searchProvider.notifier).findPrevious(),
      'edit.replace': (_) => ref.read(searchProvider.notifier).openReplace(),

      // ========== 段落操作 ==========
      'paragraph.heading-1': (_) => _insertMarkdownBlock('# ', 'heading1'),
      'paragraph.heading-2': (_) => _insertMarkdownBlock('## ', 'heading2'),
      'paragraph.heading-3': (_) => _insertMarkdownBlock('### ', 'heading3'),
      'paragraph.heading-4': (_) => _insertMarkdownBlock('#### ', 'heading4'),
      'paragraph.heading-5': (_) => _insertMarkdownBlock('##### ', 'heading5'),
      'paragraph.heading-6': (_) => _insertMarkdownBlock('###### ', 'heading6'),
      'paragraph.paragraph': (_) => _insertMarkdownBlock('', 'paragraph'),
      'paragraph.code-fence': (_) => _insertMarkdownBlock('```\n\n```', 'code_block'),
      'paragraph.quote-block': (_) => _insertMarkdownBlock('> ', 'quote'),
      'paragraph.order-list': (_) => _insertMarkdownBlock('1. ', 'numbered_list'),
      'paragraph.bullet-list': (_) => _insertMarkdownBlock('- ', 'bulleted_list'),
      'paragraph.task-list': (_) => _insertMarkdownBlock('- [ ] ', 'todo_list'),
      'paragraph.horizontal-line': (_) => _insertMarkdownBlock('\n---\n', 'divider'),
      'paragraph.table': (_) => _handleInsertBlock('table'),
      'paragraph.math-formula': (_) => _insertMarkdownBlock('\$\$\n\n\$\$', 'math'),
      'paragraph.front-matter': (_) => _insertMarkdownBlock('---\n\n---\n', 'front_matter'),

      // ========== 格式操作 ==========
      'format.image': (_) => _handleInsertImage(),
      'format.hyperlink': (_) => _handleInsertLink(),
      'format.highlight': (_) => _handleFormatCommand('highlight'),
      'format.clear-format': (_) => _handleFormatCommand('clear'),

      // ========== 视图操作 ==========
      'view.command-palette': (_) => ref.read(commandPaletteVisibleProvider.notifier).show(),
      'view.source-code-mode': (_) => ref.read(editorProvider.notifier).cycleMode(),
      'view.typewriter-mode': (_) => ref.read(editorProvider.notifier).toggleTypewriterMode(),
      'view.focus-mode': (_) => ref.read(editorProvider.notifier).toggleFocusMode(),
      'view.toggle-sidebar': (_) => ref.read(sideBarProvider.notifier).toggleVisibility(),
      'view.toggle-toc': (_) => ref.read(sideBarProvider.notifier).togglePanel(SideBarPanel.toc),

      // ========== 标签切换 ==========
      'tabs.cycleForward': (_) => _cycleTab(1),
      'tabs.cycleBackward': (_) => _cycleTab(-1),

      // ========== 窗口 ==========
      'window.toggle-full-screen': (_) => _toggleFullScreen(context),
    });
  }

  /// 插入 Markdown 块文本（源码模式下追加文本，WYSIWYG 模式下通过编辑器 API）
  void _insertMarkdownBlock(String prefix, String blockType) {
    final editorState = ref.read(editorProvider);
    if (editorState.mode == EditorMode.wysiwyg) {
      // WYSIWYG 模式：通过 appflowy_editor 事务插入对应节点
      _insertWysiwygBlock(blockType);
    } else {
      // 源码模式：直接插入 markdown 文本
      final content = _getCurrentContent();
      final newContent = content.isEmpty
          ? prefix
          : '$content\n$prefix';
      ref.read(editorProvider.notifier).updateMarkdown(newContent);
    }
  }

  /// WYSIWYG 模式下插入块（使用 markdown 文本 + 重新解析）
  void _insertWysiwygBlock(String blockType) {
    final wysiwygState = _wysiwygKey.currentState;
    if (wysiwygState == null) return;

    String insertText;
    switch (blockType) {
      case 'heading1': insertText = '# '; break;
      case 'heading2': insertText = '## '; break;
      case 'heading3': insertText = '### '; break;
      case 'heading4': insertText = '#### '; break;
      case 'heading5': insertText = '##### '; break;
      case 'heading6': insertText = '###### '; break;
      case 'code_block': insertText = '```\n\n```'; break;
      case 'quote': insertText = '> '; break;
      case 'bulleted_list': insertText = '- '; break;
      case 'numbered_list': insertText = '1. '; break;
      case 'todo_list': insertText = '- [ ] '; break;
      case 'divider': insertText = '\n---\n'; break;
      case 'table': insertText = '\n| 列1 | 列2 | 列3 |\n| --- | --- | --- |\n| | | |\n'; break;
      default: insertText = '\n';
    }

    final currentMarkdown = wysiwygState.getMarkdown();
    final newMarkdown = currentMarkdown.isEmpty
        ? insertText
        : '$currentMarkdown\n$insertText';
    wysiwygState.loadContent(newMarkdown);
    ref.read(editorProvider.notifier).syncContent(newMarkdown);
  }

  /// 处理块插入（QuickInsert 通过工具栏触发）
  void _handleInsertBlock(String type) {
    final editorState = ref.read(editorProvider);
    if (editorState.mode == EditorMode.wysiwyg) {
      _insertWysiwygBlock(type);
    } else {
      _insertMarkdownBlock('', type);
    }
  }

  /// 处理插入图片 — 打开文件选择器，调用 ImageService
  Future<void> _handleInsertImage() async {
    final imageService = ImageService();
    final result = await imageService.pickImage(action: ImageInsertAction.path);
    if (result == null) return;

    final editorState = ref.read(editorProvider);
    if (editorState.mode == EditorMode.wysiwyg) {
      // WYSIWYG：通过 appflowy_editor 事务直接插入 imageNode
      _insertWysiwygImage(result.absolutePath ?? result.markdownPath);
    } else {
      final content = _getCurrentContent();
      final newContent = content.isEmpty
          ? result.toMarkdown()
          : '$content\n\n${result.toMarkdown()}';
      ref.read(editorProvider.notifier).updateMarkdown(newContent);
    }
  }

  /// 通过 appflowy_editor 事务直接插入图片节点（绕过 markdown 解析）
  void _insertWysiwygImage(String filePath) {
    final wysiwygState = _wysiwygKey.currentState;
    if (wysiwygState == null) return;
    final editorState = wysiwygState.editorState;
    final transaction = editorState.transaction;

    // 使用 appflowy_editor 内置的 imageNode() 创建图片节点（绕过 markdown 解析）
    final node = appflowy.imageNode(url: filePath);
    final lastIndex = editorState.document.root.children.length;

    // 先插入一个空段落，再插入图片节点
    if (lastIndex > 0) {
      transaction.insertNode([lastIndex], node);
    } else {
      transaction.insertNode([0], node);
    }

    editorState.apply(transaction);

    // 同步 markdown 内容到 provider
    final newMarkdown = wysiwygState.getMarkdown();
    ref.read(editorProvider.notifier).syncContent(newMarkdown);
  }

  /// 处理插入链接
  void _handleInsertLink() {
    _insertMarkdownBlock('[链接文字](https://)', 'link');
  }

  /// 格式化命令（委托给 appflowy_editor 的 toolbar）
  void _handleFormatCommand(String type) {
    // appflowy_editor 通过 FloatingToolbar 或快捷键处理格式化
    // 这里作为菜单入口记录命令
  }

  /// 循环切换标签
  void _cycleTab(int direction) {
    final tabState = ref.read(tabBarProvider);
    if (tabState.tabs.isEmpty) return;
    final currentId = tabState.activeTabId;
    if (currentId == null) {
      ref.read(tabBarProvider.notifier).selectTab(tabState.tabs.first.id);
      return;
    }
    final currentIndex = tabState.tabs.indexWhere((t) => t.id == currentId);
    if (currentIndex < 0) return;
    final newIndex = (currentIndex + direction) % tabState.tabs.length;
    final target = newIndex < 0 ? tabState.tabs.length - 1 : newIndex;
    ref.read(tabBarProvider.notifier).selectTab(tabState.tabs[target].id);
  }

  /// 全屏切换
  void _toggleFullScreen(BuildContext context) {
    // 简化处理：最大化窗口
    if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) return;
    // 通过 windowManager 或系统调用切换全屏
  }

  /// 另存为
  void _saveAs() {
    final tabState = ref.read(tabBarProvider);
    final activeDoc = tabState.activeDocument;
    if (activeDoc == null) return;

    final editorState = ref.read(editorProvider);
    final content = editorState.mode == EditorMode.wysiwyg
        ? _wysiwygKey.currentState?.getMarkdown() ?? editorState.markdown
        : editorState.markdown;

    final docToSave = activeDoc.copyWith(content: content);
    ref.read(fileProvider.notifier).saveFileAs(docToSave).then((success) {
      if (success) {
        ref.read(editorProvider.notifier).markSaved();
        ref.read(tabBarProvider.notifier).updateTabSaved(activeDoc.id);
      }
    });
  }

  /// 保存当前文档（从编辑器获取最新内容）
  void _saveCurrentDocument() {
    final tabState = ref.read(tabBarProvider);
    final activeDoc = tabState.activeDocument;
    if (activeDoc == null) return;

    final editorState = ref.read(editorProvider);
    String content;

    // 根据当前模式获取最新内容
    if (editorState.mode == EditorMode.wysiwyg) {
      content = _wysiwygKey.currentState?.getMarkdown() ?? editorState.markdown;
    } else {
      content = editorState.markdown;
    }

    final docToSave = activeDoc.copyWith(content: content);
    // 同步 provider 中的内容
    ref.read(editorProvider.notifier).syncContent(content);

    ref.read(fileProvider.notifier).saveFile(docToSave).then((success) {
      if (success) {
        ref.read(editorProvider.notifier).markSaved();
        ref.read(tabBarProvider.notifier).updateTabSaved(activeDoc.id);
      }
    });
  }

  /// 获取当前文档内容的通用方法
  String _getCurrentContent() {
    final editorState = ref.read(editorProvider);
    if (editorState.mode == EditorMode.wysiwyg) {
      return _wysiwygKey.currentState?.getMarkdown() ?? editorState.markdown;
    }
    return editorState.markdown;
  }

  /// 启动自动保存
  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    // 默认 5000ms 延迟自动保存（对应 marktext autoSaveDelay）
    _autoSaveTimer = Timer(const Duration(seconds: 5), () {
      final tabState = ref.read(tabBarProvider);
      if (tabState.activeDocument != null && !tabState.activeDocument!.isSaved) {
        _saveCurrentDocument();
      }
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);
    final searchState = ref.watch(searchProvider);

    return Focus(
      autofocus: true,
      child: Column(
        children: [
          // 工具栏（WYSIWYG 模式下显示）
          if (editorState.mode == EditorMode.wysiwyg)
            EditorToolbar(
              onFormatAction: (type) => _handleFormatAction(type, editorNotifier),
              onBlockAction: (type) => _handleBlockAction(type, editorNotifier),
              onInsertAction: (type) => _handleInsertAction(type, editorNotifier),
              onQuickInsert: (label) => _handleQuickInsert(label, editorNotifier),
            ),

          // 编辑器主体（Stack: 编辑区 + 搜索栏 overlay）
          Expanded(
            child: Stack(
              children: [
                // 编辑器（根据模式切换）
                _buildEditorByMode(editorState, editorNotifier),

                // 搜索替换栏（浮动在编辑器右上角 overlay）
                if (searchState.isVisible)
                  Positioned(
                    top: 8,
                    right: 20,
                    child: SearchReplaceBar(
                      getDocumentContent: _getCurrentContent,
                      onReplace: (newContent) {
                        if (editorState.mode == EditorMode.wysiwyg) {
                          _wysiwygKey.currentState?.loadContent(newContent);
                        }
                        ref.read(editorProvider.notifier).updateMarkdown(newContent);
                      },
                    ),
                  ),
              ],
            ),
          ),

          // 底部状态栏：模式切换器
          _buildStatusBar(context, editorState, editorNotifier),
        ],
      ),
    );
  }

  /// 格式化操作处理
  void _handleFormatAction(String type, EditorNotifier notifier) {
    // appflowy_editor 的 FloatingToolbar 处理快捷键格式化（⌘B/⌘I 等）
    // 工具栏按钮作为视觉入口转发到 CommandBus
    ref.read(commandBusProvider.notifier).execute('format.$type');
  }

  /// 块类型操作处理
  void _handleBlockAction(String type, EditorNotifier notifier) {
    // 工具栏块按钮转发到段落命令
    final commandId = QuickInsertMenu.labelToCommandId(type);
    if (commandId.isNotEmpty) {
      ref.read(commandBusProvider.notifier).execute(commandId);
    }
  }

  /// 插入操作处理（工具栏插入按钮：链接、图片、表格、分割线、emoji）
  void _handleInsertAction(String type, EditorNotifier notifier) {
    switch (type) {
      case 'image':
        _handleInsertImage();
        break;
      case 'link':
        _handleInsertLink();
        break;
      case 'table':
        _handleInsertBlock('table');
        break;
      case 'hr':
        _insertMarkdownBlock('\n---\n', 'divider');
        break;
      default:
        if (type.startsWith('emoji:')) {
          final alias = type.substring(6);
          final emoji = commonEmojis.where((e) => e.alias == alias).firstOrNull;
          if (emoji != null) {
            _insertMarkdownBlock(':${emoji.alias}:', 'emoji');
          }
        }
    }
  }

  /// QuickInsert 处理
  void _handleQuickInsert(String label, EditorNotifier notifier) {
    final commandId = QuickInsertMenu.labelToCommandId(label);
    if (commandId.isNotEmpty) {
      ref.read(commandBusProvider.notifier).execute(commandId);
    }
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
    // 构建搜索高亮信息（源码和分屏模式需要）
    final searchState = ref.watch(searchProvider);
    SourceEditorSearchHighlight? searchHighlight;
    if (searchState.isVisible && searchState.result.hasMatches) {
      final ranges = searchState.result.matches
          .map((m) => TextRange(start: m.start, end: m.end))
          .toList();
      searchHighlight = SourceEditorSearchHighlight(
        ranges: ranges,
        currentHighlightIndex: searchState.result.currentIndex,
      );
    }

    return switch (state.mode) {
      EditorMode.wysiwyg => WysiwygEditor(
          key: _wysiwygKey,
          initialContent: state.markdown,
          typewriterMode: state.isTypewriterMode,
          focusMode: state.isFocusMode,
          onContentChanged: (content) {
            notifier.syncContent(content);
            _syncToTab(content);
            _scheduleAutoSave();
          },
        ),
      EditorMode.sourceCode => SourceEditor(
          initialContent: state.markdown,
          searchHighlight: searchHighlight,
          onContentChanged: (content) {
            notifier.updateMarkdown(content);
            _syncToTab(content);
            _scheduleAutoSave();
          },
        ),
      EditorMode.splitView => SplitView(
          initialContent: state.markdown,
          searchHighlight: searchHighlight,
          onContentChanged: (content) {
            notifier.updateMarkdown(content);
            _syncToTab(content);
            _scheduleAutoSave();
          },
        ),
    };
  }

  /// 同步内容到 TabBarProvider（使 TOC、文件保存等能拿到最新内容）
  void _syncToTab(String content) {
    final tabState = ref.read(tabBarProvider);
    final activeId = tabState.activeTabId;
    if (activeId != null) {
      ref.read(tabBarProvider.notifier).updateTabContent(activeId, content);
    }
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
          // 焦点模式指示
          if (state.isFocusMode) ...[
            const SizedBox(width: 8),
            Icon(Icons.center_focus_strong, size: 12, color: theme.colorScheme.secondary),
            const SizedBox(width: 2),
            Text('Focus', style: TextStyle(fontSize: 11, color: theme.colorScheme.secondary)),
          ],
          // 打字机模式指示
          if (state.isTypewriterMode) ...[
            const SizedBox(width: 8),
            Icon(Icons.keyboard_double_arrow_down, size: 12, color: theme.colorScheme.tertiary),
            const SizedBox(width: 2),
            Text('Typewriter', style: TextStyle(fontSize: 11, color: theme.colorScheme.tertiary)),
          ],
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

