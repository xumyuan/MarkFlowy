/// 已打开文件列表组件
/// 参考: marktext/src/renderer/src/components/sideBar/treeOpenedTab.vue
///
/// 功能:
/// - 显示所有已打开的文件
/// - 标记未保存文件（圆点）
/// - 点击切换当前文件
/// - 关闭按钮
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/document.dart';
import '../../widgets/tabs/tab_bar.dart';

/// 已打开文件列表面板（对应 marktext tree.vue 中的 opened-files 区域）
class OpenedFilesPanel extends ConsumerWidget {
  const OpenedFilesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(tabBarProvider);
    final theme = Theme.of(context);

    if (tabState.tabs.isEmpty) {
      return Center(
        child: Text(
          '没有打开的文件',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题栏（对应 marktext opened-files > .title）
        _OpenedFilesHeader(
          fileCount: tabState.tabs.length,
          onSaveAll: () {
            // TODO: 保存所有文件
          },
          onCloseAll: () {
            // 逐个关闭所有标签
            for (final tab in tabState.tabs) {
              ref.read(tabBarProvider.notifier).closeTab(tab.id);
            }
          },
        ),
        // 已打开文件列表
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: tabState.tabs.length,
            itemBuilder: (context, index) {
              final tab = tabState.tabs[index];
              final isActive = tab.id == tabState.activeTabId;
              return _OpenedFileItem(
                document: tab,
                isActive: isActive,
                onTap: () => ref.read(tabBarProvider.notifier).selectTab(tab.id),
                onClose: () => ref.read(tabBarProvider.notifier).closeTab(tab.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 已打开文件列表头部
class _OpenedFilesHeader extends StatelessWidget {
  final int fileCount;
  final VoidCallback onSaveAll;
  final VoidCallback onCloseAll;

  const _OpenedFilesHeader({
    required this.fileCount,
    required this.onSaveAll,
    required this.onCloseAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '已打开 ($fileCount)',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // 保存所有按钮
          _SmallIconButton(
            icon: Icons.save_outlined,
            tooltip: '保存全部',
            onTap: onSaveAll,
          ),
          const SizedBox(width: 4),
          // 关闭所有按钮
          _SmallIconButton(
            icon: Icons.close_fullscreen,
            tooltip: '关闭全部',
            onTap: onCloseAll,
          ),
        ],
      ),
    );
  }
}

/// 单个已打开文件项（对应 marktext treeOpenedTab.vue）
class _OpenedFileItem extends StatefulWidget {
  final Document document;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _OpenedFileItem({
    required this.document,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  State<_OpenedFileItem> createState() => _OpenedFileItemState();
}

class _OpenedFileItemState extends State<_OpenedFileItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTap: widget.onClose,
        child: Container(
          height: 28,
          padding: const EdgeInsets.only(left: 8, right: 8),
          color: _isHovered
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : Colors.transparent,
          child: Row(
            children: [
              // 关闭按钮 或 未保存圆点
              SizedBox(
                width: 20,
                child: _buildLeadingWidget(theme),
              ),
              const SizedBox(width: 4),
              // 文件名
              Expanded(
                child: Text(
                  widget.document.filename,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: widget.isActive
                        ? theme.colorScheme.primary
                        : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingWidget(ThemeData theme) {
    // hover 时显示关闭按钮
    if (_isHovered) {
      return InkWell(
        onTap: widget.onClose,
        borderRadius: BorderRadius.circular(4),
        child: Icon(
          Icons.close,
          size: 14,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }
    // 未保存时显示圆点（对应 marktext unsaved-circle-icon）
    if (!widget.document.isSaved) {
      return Center(
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

/// 小图标按钮
class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _SmallIconButton({
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
            size: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
