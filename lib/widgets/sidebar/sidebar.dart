/// 侧边栏组件
/// 参考: marktext/src/renderer/src/components/sideBar/index.vue + icon.vue + help.js
///
/// 布局结构:
/// - 左侧图标列（对应 left-column）：文件树、搜索、TOC 图标 + 底部设置图标
/// - 右侧面板区域（对应 right-column）：根据选中的图标显示不同面板
/// - 可拖拽调整宽度（对应 drag-bar）
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/editor_provider.dart';
import '../../providers/file_provider.dart';
import '../tabs/tab_bar.dart';
import 'file_tree.dart';
import 'opened_files.dart';
import 'sidebar_search.dart';
import 'toc_panel.dart';

/// 侧边栏面板类型（对应 marktext help.js 中的 sideBarIcons）
enum SideBarPanel {
  /// 文件树面板
  files,

  /// 搜索面板
  search,

  /// 目录（TOC）面板
  toc,
}

/// 侧边栏状态 Provider
/// - selectedPanel: 当前选中的面板（null 表示收起）
/// - width: 侧边栏宽度
/// - isVisible: 是否可见
class SideBarState {
  /// 当前选中的面板（null 表示仅显示图标列）
  final SideBarPanel? selectedPanel;

  /// 侧边栏右侧面板宽度（对应 marktext sideBarViewWidth）
  final double panelWidth;

  /// 是否显示侧边栏（对应 marktext showSideBar）
  final bool isVisible;

  const SideBarState({
    this.selectedPanel,
    this.panelWidth = 235,
    this.isVisible = true,
  });

  SideBarState copyWith({
    SideBarPanel? Function()? selectedPanel,
    double? panelWidth,
    bool? isVisible,
  }) {
    return SideBarState(
      selectedPanel:
          selectedPanel != null ? selectedPanel() : this.selectedPanel,
      panelWidth: panelWidth ?? this.panelWidth,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

/// 侧边栏状态 Notifier（使用 Riverpod 2+ 的 Notifier API）
class SideBarNotifier extends Notifier<SideBarState> {
  @override
  SideBarState build() => const SideBarState();

  /// 点击图标切换面板（对应 handleLeftIconClick）
  void togglePanel(SideBarPanel panel) {
    if (state.selectedPanel == panel) {
      // 再次点击同一图标，收起面板
      state = state.copyWith(selectedPanel: () => null);
    } else {
      state = state.copyWith(selectedPanel: () => panel);
    }
  }

  /// 设置面板宽度（对应拖拽调整）
  void setPanelWidth(double width) {
    // 最小宽度 175，与 marktext 中 min-width: 220 - 45(图标列) 类似
    final clampedWidth = width.clamp(175.0, 500.0);
    state = state.copyWith(panelWidth: clampedWidth);
  }

  /// 切换侧边栏可见性
  void toggleVisibility() {
    state = state.copyWith(isVisible: !state.isVisible);
  }

  /// 隐藏侧边栏
  void hide() {
    state = state.copyWith(isVisible: false);
  }

  /// 显示侧边栏
  void show() {
    state = state.copyWith(isVisible: true);
  }
}

/// 侧边栏状态 Provider
final sideBarProvider =
    NotifierProvider<SideBarNotifier, SideBarState>(SideBarNotifier.new);

/// 侧边栏组件
/// 对应 marktext sideBar/index.vue 的完整结构
class SideBar extends ConsumerStatefulWidget {
  const SideBar({super.key});

  @override
  ConsumerState<SideBar> createState() => _SideBarState();
}

class _SideBarState extends ConsumerState<SideBar> {
  /// 是否正在拖拽调整宽度
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final sideBarState = ref.watch(sideBarProvider);
    final theme = Theme.of(context);

    if (!sideBarState.isVisible) return const SizedBox.shrink();

    // 计算总宽度：图标列(45) + 面板宽度（如果有选中面板）
    final totalWidth = sideBarState.selectedPanel != null
        ? 45.0 + sideBarState.panelWidth
        : 45.0;

    return SizedBox(
      width: totalWidth,
      child: Row(
        children: [
          // 左侧图标列（对应 left-column）
          _buildIconColumn(sideBarState, theme),

          // 右侧面板区域（对应 right-column）
          if (sideBarState.selectedPanel != null)
            Expanded(
              child: _buildPanelArea(sideBarState, theme),
            ),

          // 拖拽调整宽度的把手（对应 drag-bar）
          if (sideBarState.selectedPanel != null)
            _buildDragHandle(theme),
        ],
      ),
    );
  }

  /// 构建图标列（对应 marktext left-column）
  Widget _buildIconColumn(SideBarState state, ThemeData theme) {
    return Container(
      width: 45,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // 顶部留空（标题栏区域）
          const SizedBox(height: 40),

          // 上方图标（文件、搜索、TOC）— 对应 sideBarIcons
          _SideBarIcon(
            icon: Icons.folder_outlined,
            tooltip: '文件树',
            isActive: state.selectedPanel == SideBarPanel.files,
            onTap: () => ref
                .read(sideBarProvider.notifier)
                .togglePanel(SideBarPanel.files),
          ),
          _SideBarIcon(
            icon: Icons.search,
            tooltip: '搜索',
            isActive: state.selectedPanel == SideBarPanel.search,
            onTap: () => ref
                .read(sideBarProvider.notifier)
                .togglePanel(SideBarPanel.search),
          ),
          _SideBarIcon(
            icon: Icons.list_alt,
            tooltip: '目录',
            isActive: state.selectedPanel == SideBarPanel.toc,
            onTap: () => ref
                .read(sideBarProvider.notifier)
                .togglePanel(SideBarPanel.toc),
          ),

          const Spacer(),

          // 底部图标（设置）— 对应 sideBarBottomIcons
          _SideBarIcon(
            icon: Icons.settings_outlined,
            tooltip: '设置',
            isActive: false,
            onTap: () => GoRouter.of(context).push('/settings'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// 构建右侧面板内容区域
  Widget _buildPanelArea(SideBarState state, ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部留空
          const SizedBox(height: 40),

          // 面板标题 + 操作按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text(
                  _getPanelTitle(state.selectedPanel!),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // 文件面板顶部的打开按钮
                if (state.selectedPanel == SideBarPanel.files) ...[
                  _PanelActionButton(
                    icon: Icons.create_new_folder_outlined,
                    tooltip: '打开文件夹',
                    onTap: () => ref.read(fileProvider.notifier).openFolder(),
                  ),
                  const SizedBox(width: 4),
                  _PanelActionButton(
                    icon: Icons.note_add_outlined,
                    tooltip: '打开文件',
                    onTap: () async {
                      final doc = await ref.read(fileProvider.notifier).openFile();
                      if (doc != null) {
                        ref.read(tabBarProvider.notifier).openFileTab(doc);
                        ref.read(editorProvider.notifier).loadDocument(doc.id, doc.content);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          // 面板内容
          Expanded(
            child: _buildPanelContent(state.selectedPanel!),
          ),
        ],
      ),
    );
  }

  /// 根据面板类型构建实际内容组件
  Widget _buildPanelContent(SideBarPanel panel) {
    switch (panel) {
      case SideBarPanel.files:
        return const Column(
          children: [
            // 已打开文件列表
            SizedBox(height: 120, child: OpenedFilesPanel()),
            Divider(height: 1),
            // 文件树
            Expanded(child: FileTreePanel()),
          ],
        );
      case SideBarPanel.search:
        return const SidebarSearchPanel();
      case SideBarPanel.toc:
        return const TocPanel();
    }
  }

  /// 构建拖拽把手（对应 marktext drag-bar）
  Widget _buildDragHandle(ThemeData theme) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onHorizontalDragStart: (_) => _isDragging = true,
        onHorizontalDragUpdate: (details) {
          if (_isDragging) {
            final currentWidth = ref.read(sideBarProvider).panelWidth;
            ref
                .read(sideBarProvider.notifier)
                .setPanelWidth(currentWidth + details.delta.dx);
          }
        },
        onHorizontalDragEnd: (_) => _isDragging = false,
        child: Container(
          width: 3,
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 1,
              color: theme.dividerColor.withValues(alpha: 0.2),
            ),
          ),
        ),
      ),
    );
  }

  /// 获取面板标题
  String _getPanelTitle(SideBarPanel panel) {
    switch (panel) {
      case SideBarPanel.files:
        return '文件';
      case SideBarPanel.search:
        return '搜索';
      case SideBarPanel.toc:
        return '目录';
    }
  }
}

/// 面板标题栏操作按钮
class _PanelActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _PanelActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

/// 侧边栏图标按钮（对应 marktext icon.vue 中的图标显示）
class _SideBarIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  const _SideBarIcon({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 45,
          height: 45,
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}
