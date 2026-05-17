/// 文件树组件
/// 参考: marktext/src/renderer/src/components/sideBar/tree.vue
///       + treeFile.vue + treeFolder.vue
///
/// 功能:
/// - 递归渲染文件夹和文件
/// - 支持展开/折叠
/// - 文件图标区分类型
/// - 右键菜单（新建、重命名、删除）
/// - 点击文件在编辑器中打开
/// - 当前文件高亮
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/file_provider.dart';
import '../../services/file_service.dart';

/// 文件树面板组件（对应 marktext tree.vue）
class FileTreePanel extends ConsumerWidget {
  const FileTreePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileState = ref.watch(fileProvider);

    if (fileState.isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (fileState.projectTree == null) {
      return _buildNoProjectView(context, ref);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 项目名标题栏
        _ProjectHeader(
          projectName: fileState.projectTree!.name,
        ),
        // 文件树内容
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // 渲染文件夹
              ...fileState.projectTree!.folders.map(
                (folder) => _FolderNode(node: folder, depth: 0),
              ),
              // 渲染文件
              ...fileState.projectTree!.files.map(
                (file) => _FileNode(node: file, depth: 0),
              ),
              // 空项目提示
              if (fileState.projectTree!.folders.isEmpty &&
                  fileState.projectTree!.files.isEmpty)
                _buildEmptyProjectHint(context, ref),
            ],
          ),
        ),
      ],
    );
  }

  /// 无项目时显示「打开文件夹」按钮
  Widget _buildNoProjectView(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '未打开文件夹',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () => ref.read(fileProvider.notifier).openFolder(),
            child: const Text('打开文件夹'),
          ),
        ],
      ),
    );
  }

  /// 空项目提示（对应 marktext empty-project）
  Widget _buildEmptyProjectHint(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: [
            Text(
              '此文件夹为空',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // 创建文件
                _showCreateFileDialog(context, ref);
              },
              child: const Text('新建文件'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateFileDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: 'untitled.md');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建文件'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入文件名'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final projectPath = ref.read(fileProvider).projectPath;
                if (projectPath != null) {
                  ref.read(fileProvider.notifier).createFileInProject(projectPath, name);
                }
              }
              Navigator.pop(ctx);
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}

/// 项目头部标题（对应 marktext project-tree > .title）
class _ProjectHeader extends StatelessWidget {
  final String projectName;

  const _ProjectHeader({required this.projectName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(
            Icons.folder_open,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              projectName,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// 文件夹节点（对应 marktext treeFolder.vue）
class _FolderNode extends ConsumerStatefulWidget {
  final FileTreeNode node;
  final int depth;

  const _FolderNode({required this.node, required this.depth});

  @override
  ConsumerState<_FolderNode> createState() => _FolderNodeState();
}

class _FolderNodeState extends ConsumerState<_FolderNode> {
  bool _isCollapsed = true;
  List<FileTreeNode> _folders = [];
  List<FileTreeNode> _files = [];
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.node.isCollapsed;
    _folders = widget.node.folders;
    _files = widget.node.files;
  }

  Future<void> _toggle() async {
    if (_isCollapsed && !_isLoaded) {
      // 懒加载子目录内容
      final expanded = await ref.read(fileProvider.notifier).expandFolder(widget.node.pathname);
      if (expanded != null) {
        setState(() {
          _folders = expanded.folders;
          _files = expanded.files;
          _isLoaded = true;
          _isCollapsed = false;
        });
      }
    } else {
      setState(() {
        _isCollapsed = !_isCollapsed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indent = widget.depth * 16.0 + 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 文件夹行
        InkWell(
          onTap: _toggle,
          onSecondaryTap: () => _showContextMenu(context),
          child: Container(
            height: 28,
            padding: EdgeInsets.only(left: indent, right: 8),
            child: Row(
              children: [
                // 展开/折叠箭头
                AnimatedRotation(
                  turns: _isCollapsed ? 0 : 0.25,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 4),
                // 文件夹图标
                Icon(
                  _isCollapsed ? Icons.folder : Icons.folder_open,
                  size: 16,
                  color: theme.colorScheme.primary.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 6),
                // 文件夹名
                Expanded(
                  child: Text(
                    widget.node.name,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 子节点（展开时显示）
        if (!_isCollapsed) ...[
          ..._folders.map(
            (folder) => _FolderNode(node: folder, depth: widget.depth + 1),
          ),
          ..._files.map(
            (file) => _FileNode(node: file, depth: widget.depth + 1),
          ),
        ],
      ],
    );
  }

  void _showContextMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + renderBox.size.width / 2,
        offset.dy + renderBox.size.height,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height + 100,
      ),
      items: [
        const PopupMenuItem(value: 'new_file', child: Text('新建文件')),
        const PopupMenuItem(value: 'rename', child: Text('重命名')),
        const PopupMenuItem(value: 'delete', child: Text('删除')),
      ],
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case 'new_file':
          _createFile();
        case 'rename':
          _rename();
        case 'delete':
          _delete();
      }
    });
  }

  void _createFile() {
    final controller = TextEditingController(text: 'untitled.md');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建文件'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入文件名'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(fileProvider.notifier).createFileInProject(
                  widget.node.pathname,
                  name,
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _rename() {
    final controller = TextEditingController(text: widget.node.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(fileProvider.notifier).renameItem(widget.node.pathname, name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _delete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定删除文件夹 "${widget.node.name}" 及其所有内容？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () {
              ref.read(fileProvider.notifier).deleteItem(widget.node.pathname);
              Navigator.pop(ctx);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 文件节点（对应 marktext treeFile.vue）
class _FileNode extends ConsumerWidget {
  final FileTreeNode node;
  final int depth;

  const _FileNode({required this.node, required this.depth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fileState = ref.watch(fileProvider);
    final isCurrent = fileState.activeFilePath == node.pathname;
    final indent = depth * 16.0 + 8.0;

    return InkWell(
      onTap: () {
        if (node.isMarkdown) {
          ref.read(fileProvider.notifier).openFile(node.pathname);
        }
      },
      onSecondaryTap: () => _showContextMenu(context, ref),
      child: Container(
        height: 28,
        padding: EdgeInsets.only(left: indent + 20, right: 8),
        decoration: isCurrent
            ? BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              )
            : null,
        child: Row(
          children: [
            // 文件图标
            Icon(
              _getFileIcon(node.name),
              size: 16,
              color: isCurrent
                  ? theme.colorScheme.primary
                  : (node.isMarkdown
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            ),
            const SizedBox(width: 6),
            // 文件名
            Expanded(
              child: Text(
                node.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isCurrent
                      ? theme.colorScheme.primary
                      : (node.isMarkdown
                          ? null
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 根据文件名返回图标
  IconData _getFileIcon(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    return switch (ext) {
      'md' || 'markdown' || 'mdown' || 'mkd' => Icons.description,
      'png' || 'jpg' || 'jpeg' || 'gif' || 'svg' || 'webp' => Icons.image,
      'pdf' => Icons.picture_as_pdf,
      'json' => Icons.data_object,
      'yaml' || 'yml' => Icons.settings,
      _ => Icons.insert_drive_file,
    };
  }

  void _showContextMenu(BuildContext context, WidgetRef ref) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + renderBox.size.width / 2,
        offset.dy + renderBox.size.height,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height + 100,
      ),
      items: [
        const PopupMenuItem(value: 'rename', child: Text('重命名')),
        const PopupMenuItem(value: 'delete', child: Text('删除')),
      ],
    ).then((value) {
      if (value == null || !context.mounted) return;
      switch (value) {
        case 'rename':
          _rename(context, ref);
        case 'delete':
          _delete(context, ref);
      }
    });
  }

  void _rename(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: node.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(fileProvider.notifier).renameItem(node.pathname, name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _delete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定删除文件 "${node.name}"？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () {
              ref.read(fileProvider.notifier).deleteItem(node.pathname);
              Navigator.pop(ctx);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
