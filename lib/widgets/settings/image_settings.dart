/// 图片设置面板
/// 参考: marktext/src/renderer/src/prefComponents/image/index.vue
///
/// 包含:
/// - 图片保存位置（相对路径/绝对路径/云存储）
/// - 图片优先策略
/// - 上传服务配置
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_settings.dart';
import '../../providers/settings_provider.dart';

/// 图片设置（对应 prefComponents/image/index.vue）
class ImageSettings extends ConsumerWidget {
  const ImageSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('图片', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),

        // 图片插入默认行为
        ListTile(
          title: const Text('图片插入行为'),
          subtitle: const Text('粘贴或拖入图片时的默认操作'),
        ),
        RadioListTile<ImageInsertAction>(
          title: const Text('保存到指定路径'),
          subtitle: const Text('将图片复制到与文档相关的目录'),
          value: ImageInsertAction.path,
          groupValue: settings.imageInsertAction,
          onChanged: (value) => notifier.setImageInsertAction(value!),
        ),
        RadioListTile<ImageInsertAction>(
          title: const Text('保存到文件夹'),
          subtitle: const Text('将图片保存到固定文件夹'),
          value: ImageInsertAction.folder,
          groupValue: settings.imageInsertAction,
          onChanged: (value) => notifier.setImageInsertAction(value!),
        ),
        RadioListTile<ImageInsertAction>(
          title: const Text('上传到云端'),
          subtitle: const Text('使用图片上传服务'),
          value: ImageInsertAction.upload,
          groupValue: settings.imageInsertAction,
          onChanged: (value) => notifier.setImageInsertAction(value!),
        ),
        const Divider(),

        // 相对路径设置（仅在 path/folder 模式下显示）
        if (settings.imageInsertAction != ImageInsertAction.upload) ...[
          _SectionHeader(title: '路径设置'),
          SwitchListTile(
            title: const Text('优先使用相对路径'),
            subtitle: const Text('图片路径相对于文档位置'),
            value: settings.imagePreferRelativeDirectory,
            onChanged: (value) =>
                notifier.setImagePreferRelativeDirectory(value),
          ),
          ListTile(
            title: const Text('图片目录名'),
            subtitle: Text('图片将保存在 "${settings.imageRelativeDirectoryName}" 子目录中'),
            trailing: SizedBox(
              width: 150,
              child: TextField(
                controller: TextEditingController(
                  text: settings.imageRelativeDirectoryName,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  hintText: 'assets',
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    notifier.setImageRelativeDirectoryName(value);
                  }
                },
              ),
            ),
          ),
        ],

        // 上传服务配置（仅在 upload 模式下显示）
        if (settings.imageInsertAction == ImageInsertAction.upload) ...[
          _SectionHeader(title: '上传服务'),
          const ListTile(
            title: Text('上传服务配置'),
            subtitle: Text('暂不支持，请使用路径模式'),
            enabled: false,
          ),
        ],
      ],
    );
  }
}

/// 设置分组标题
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
