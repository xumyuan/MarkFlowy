/// 欢迎页/最近文件
/// 参考: marktext/src/renderer/src/components/recent/index.vue
///
/// 功能:
/// - 最近打开的文件列表
/// - 快速操作按钮（新建文件、打开文件、打开文件夹）
/// - 应用 Logo 和版本信息
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/file_provider.dart';
import '../utils/constants.dart';
import '../widgets/tabs/tab_bar.dart';

/// 欢迎页面（对应 marktext recent/index.vue + 启动页）
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fileState = ref.watch(fileProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 应用 Logo
              _buildLogo(theme),
              const SizedBox(height: 32),

              // 快速操作
              _buildQuickActions(context, ref),
              const SizedBox(height: 40),

              // 最近文件列表
              if (fileState.recentFiles.isNotEmpty)
                _buildRecentFiles(context, ref, fileState.recentFiles),
            ],
          ),
        ),
      ),
    );
  }

  /// 应用 Logo 和版本信息
  Widget _buildLogo(ThemeData theme) {
    return Column(
      children: [
        Icon(
          Icons.edit_note_rounded,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(
          kAppName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'v1.0.0',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  /// 快速操作按钮（对应 marktext recent 中的 button 区域）
  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _QuickActionButton(
          icon: Icons.add,
          label: '新建文件',
          onTap: () => ref.read(tabBarProvider.notifier).addTab(),
        ),
        _QuickActionButton(
          icon: Icons.file_open_outlined,
          label: '打开文件',
          onTap: () => ref.read(fileProvider.notifier).openFile(),
        ),
        _QuickActionButton(
          icon: Icons.folder_open_outlined,
          label: '打开文件夹',
          onTap: () => ref.read(fileProvider.notifier).openFolder(),
        ),
      ],
    );
  }

  /// 最近文件列表
  Widget _buildRecentFiles(
    BuildContext context,
    WidgetRef ref,
    List<String> recentFiles,
  ) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(
                  '最近文件',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ref.read(fileProvider.notifier).setRecentFiles([]);
                  },
                  child: const Text('清空'),
                ),
              ],
            ),
          ),
          // 文件列表
          ...recentFiles.take(10).map(
            (filePath) => _RecentFileItem(
              filePath: filePath,
              onTap: () => ref.read(fileProvider.notifier).openFile(filePath),
            ),
          ),
        ],
      ),
    );
  }
}

/// 快速操作按钮
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// 最近文件项
class _RecentFileItem extends StatefulWidget {
  final String filePath;
  final VoidCallback onTap;

  const _RecentFileItem({required this.filePath, required this.onTap});

  @override
  State<_RecentFileItem> createState() => _RecentFileItemState();
}

class _RecentFileItemState extends State<_RecentFileItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileName = widget.filePath.split('/').last;
    final dirPath = widget.filePath.substring(
      0,
      widget.filePath.length - fileName.length - 1,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: _isHovered
                ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 18,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      dirPath,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
