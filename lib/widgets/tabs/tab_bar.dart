/// 标签栏组件
/// 参考: marktext/src/renderer/src/components/editorWithTabs/tabs.vue
///
/// 功能:
/// - 多标签显示（文件名 + 关闭按钮）
/// - 当前活动标签高亮（底部蓝线）
/// - 未保存标签显示小圆点
/// - 支持拖拽排序（ReorderableListView）
/// - 新建标签按钮
/// - 鼠标中键关闭标签
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/document.dart';
import '../../providers/editor_provider.dart';

/// 标签栏状态 — 管理多标签页
class TabBarState {
  /// 所有打开的标签页
  final List<Document> tabs;

  /// 当前活动标签的 ID
  final String? activeTabId;

  const TabBarState({
    this.tabs = const [],
    this.activeTabId,
  });

  /// 当前活动的文档
  Document? get activeDocument {
    if (activeTabId == null) return null;
    return tabs.where((t) => t.id == activeTabId).firstOrNull;
  }

  TabBarState copyWith({
    List<Document>? tabs,
    String? Function()? activeTabId,
  }) {
    return TabBarState(
      tabs: tabs ?? this.tabs,
      activeTabId:
          activeTabId != null ? activeTabId() : this.activeTabId,
    );
  }
}

/// 标签栏状态 Notifier（使用 Riverpod 2+ 的 Notifier API）
class TabBarNotifier extends Notifier<TabBarState> {
  @override
  TabBarState build() {
    final initialDoc = Document.empty();
    return TabBarState(
      tabs: [initialDoc],
      activeTabId: initialDoc.id,
    );
  }

  /// 选中标签（对应 selectFile）并同步编辑器内容
  void selectTab(String tabId) {
    state = state.copyWith(activeTabId: () => tabId);
    // 同步加载对应文档内容到编辑器
    final doc = state.tabs.where((t) => t.id == tabId).firstOrNull;
    if (doc != null) {
      ref.read(editorProvider.notifier).loadDocument(doc.id, doc.content);
    }
  }

  /// 新建标签（对应 newFile）
  void addTab() {
    final newDoc = Document.empty();
    state = TabBarState(
      tabs: [...state.tabs, newDoc],
      activeTabId: newDoc.id,
    );
  }

  /// 关闭标签（对应 removeFileInTab）
  void closeTab(String tabId) {
    final newTabs = state.tabs.where((t) => t.id != tabId).toList();
    String? newActiveId = state.activeTabId;

    // 如果关闭的是当前活动标签，切换到相邻标签
    if (state.activeTabId == tabId) {
      final oldIndex = state.tabs.indexWhere((t) => t.id == tabId);
      if (newTabs.isEmpty) {
        newActiveId = null;
      } else if (oldIndex >= newTabs.length) {
        newActiveId = newTabs.last.id;
      } else {
        newActiveId = newTabs[oldIndex].id;
      }
    }

    state = TabBarState(tabs: newTabs, activeTabId: newActiveId);
  }

  /// 拖拽排序（对应 dragula 的 drop 事件）
  void reorderTab(int oldIndex, int newIndex) {
    final tabs = List<Document>.from(state.tabs);
    if (newIndex > oldIndex) newIndex--;
    final tab = tabs.removeAt(oldIndex);
    tabs.insert(newIndex, tab);
    state = state.copyWith(tabs: tabs);
  }

  /// 打开文件到新标签页
  void openFileTab(Document doc) {
    // 检查是否已存在该文件的标签
    final existingIndex = state.tabs.indexWhere((t) => t.filePath == doc.filePath && doc.filePath.isNotEmpty);
    if (existingIndex >= 0) {
      state = state.copyWith(activeTabId: () => state.tabs[existingIndex].id);
      return;
    }
    state = TabBarState(
      tabs: [...state.tabs, doc],
      activeTabId: doc.id,
    );
  }

  /// 标记标签为已保存状态
  void updateTabSaved(String tabId) {
    final updatedTabs = state.tabs.map((t) {
      if (t.id == tabId) {
        return t.copyWith(isSaved: true);
      }
      return t;
    }).toList();
    state = state.copyWith(tabs: updatedTabs);
  }

  /// 更新标签的内容（标记为未保存）
  void updateTabContent(String tabId, String content) {
    final updatedTabs = state.tabs.map((t) {
      if (t.id == tabId) {
        return t.copyWith(content: content, isSaved: false);
      }
      return t;
    }).toList();
    state = state.copyWith(tabs: updatedTabs);
  }
}

/// 标签栏 Provider
final tabBarProvider =
    NotifierProvider<TabBarNotifier, TabBarState>(TabBarNotifier.new);

/// 标签栏组件
/// 对应 marktext editorWithTabs/tabs.vue
class EditorTabBar extends ConsumerWidget {
  const EditorTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(tabBarProvider);
    final theme = Theme.of(context);

    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 可滚动标签列表（对应 scrollable-tabs + tabs-container）
          Expanded(
            child: _buildTabList(tabState, theme, ref),
          ),

          // 新建标签按钮（对应 new-file）
          _NewTabButton(
            onTap: () => ref.read(tabBarProvider.notifier).addTab(),
          ),
        ],
      ),
    );
  }

  /// 构建可拖拽排序的标签列表
  Widget _buildTabList(TabBarState state, ThemeData theme, WidgetRef ref) {
    if (state.tabs.isEmpty) return const SizedBox.shrink();

    return ReorderableListView.builder(
      scrollDirection: Axis.horizontal,
      buildDefaultDragHandles: false,
      proxyDecorator: (child, index, animation) {
        return Material(
          elevation: 2,
          color: Colors.transparent,
          child: child,
        );
      },
      onReorder: (oldIndex, newIndex) {
        ref.read(tabBarProvider.notifier).reorderTab(oldIndex, newIndex);
      },
      itemCount: state.tabs.length,
      itemBuilder: (context, index) {
        final tab = state.tabs[index];
        final isActive = tab.id == state.activeTabId;

        return ReorderableDragStartListener(
          key: ValueKey(tab.id),
          index: index,
          child: _TabItem(
            tab: tab,
            isActive: isActive,
            onSelect: () =>
                ref.read(tabBarProvider.notifier).selectTab(tab.id),
            onClose: () =>
                ref.read(tabBarProvider.notifier).closeTab(tab.id),
          ),
        );
      },
    );
  }
}

/// 单个标签项（对应 tabs.vue 中的 li 元素）
class _TabItem extends StatefulWidget {
  final Document tab;
  final bool isActive;
  final VoidCallback onSelect;
  final VoidCallback onClose;

  const _TabItem({
    required this.tab,
    required this.isActive,
    required this.onSelect,
    required this.onClose,
  });

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Listener(
      // 鼠标中键关闭标签（对应 @click.middle="closeTab"）
      onPointerDown: (event) {
        if (event.buttons == kMiddleMouseButton) {
          widget.onClose();
        }
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onSelect,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _isHovered
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  : (widget.isActive
                      ? theme.colorScheme.surfaceContainerHighest
                      : Colors.transparent),
              // 活动标签底部蓝线（对应 li.active:after 的 2px 蓝色线）
              border: widget.isActive
                  ? Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 文件名
                Flexible(
                  child: Text(
                    widget.tab.filename,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isActive
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),

                const SizedBox(width: 4),

                // 关闭按钮或未保存圆点
                _buildCloseOrDot(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建关闭按钮或未保存标记
  /// - hover 或 active 时显示关闭按钮
  /// - 未保存且非 hover 时显示圆点（对应 unsaved-circle-icon）
  Widget _buildCloseOrDot(ThemeData theme) {
    final showClose = _isHovered || widget.isActive;
    final showDot = !widget.tab.isSaved && !_isHovered;

    if (showDot && !widget.isActive) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary,
        ),
      );
    }

    return AnimatedOpacity(
      opacity: showClose ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 150),
      child: InkWell(
        onTap: widget.onClose,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            Icons.close,
            size: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

/// 新建标签按钮（对应 tabs.vue 中的 new-file div）
class _NewTabButton extends StatefulWidget {
  final VoidCallback onTap;

  const _NewTabButton({required this.onTap});

  @override
  State<_NewTabButton> createState() => _NewTabButtonState();
}

class _NewTabButtonState extends State<_NewTabButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 35,
          height: 35,
          color: Colors.transparent,
          child: Center(
            child: Icon(
              Icons.add,
              size: 18,
              color: _isHovered
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
