/// 通用设置面板
/// 参考: marktext/src/renderer/src/prefComponents/general/index.vue
///
/// 包含:
/// - 语言选择
/// - 自动保存（开关 + 间隔设置）
/// - 启动行为
/// - 侧边栏默认显示
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_settings.dart';
import '../../providers/settings_provider.dart';

/// 通用设置（对应 prefComponents/general/index.vue）
class GeneralSettings extends ConsumerWidget {
  const GeneralSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 标题
        Text('通用', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),

        // ===== 自动保存 =====
        _SectionHeader(title: '自动保存'),
        SwitchListTile(
          title: const Text('启用自动保存'),
          subtitle: const Text('自动保存当前编辑的文件'),
          value: settings.autoSave,
          onChanged: (value) => notifier.setAutoSave(value),
        ),
        ListTile(
          title: const Text('自动保存延迟'),
          subtitle: Text('${settings.autoSaveDelay} 毫秒'),
          trailing: SizedBox(
            width: 200,
            child: Slider(
              value: settings.autoSaveDelay.toDouble(),
              min: 1000,
              max: 10000,
              divisions: 18,
              label: '${settings.autoSaveDelay}ms',
              onChanged: settings.autoSave
                  ? (value) => notifier.setAutoSaveDelay(value.toInt())
                  : null,
            ),
          ),
        ),
        const Divider(),

        // ===== 窗口设置 =====
        _SectionHeader(title: '窗口'),
        SwitchListTile(
          title: const Text('隐藏滚动条'),
          value: settings.hideScrollbar,
          onChanged: (value) => notifier.setHideScrollbar(value),
        ),
        const Divider(),

        // ===== 侧边栏 =====
        _SectionHeader(title: '侧边栏'),
        SwitchListTile(
          title: const Text('默认显示侧边栏'),
          value: settings.sideBarVisibility,
          onChanged: (value) => notifier.setSideBarVisibility(value),
        ),
        const Divider(),

        // ===== 启动行为 =====
        _SectionHeader(title: '启动'),
        ListTile(
          title: const Text('启动行为'),
          subtitle: const Text('应用启动时的默认操作'),
        ),
        RadioListTile<StartUpAction>(
          title: const Text('恢复上次所有文件'),
          value: StartUpAction.restoreAll,
          groupValue: settings.startUpAction,
          onChanged: (value) => notifier.setStartUpAction(value!),
        ),
        RadioListTile<StartUpAction>(
          title: const Text('打开上次文件夹'),
          value: StartUpAction.openLastFolder,
          groupValue: settings.startUpAction,
          onChanged: (value) => notifier.setStartUpAction(value!),
        ),
        RadioListTile<StartUpAction>(
          title: const Text('打开空白页'),
          value: StartUpAction.blank,
          groupValue: settings.startUpAction,
          onChanged: (value) => notifier.setStartUpAction(value!),
        ),
        const Divider(),

        // ===== 语言 =====
        _SectionHeader(title: '其他'),
        ListTile(
          title: const Text('语言'),
          trailing: DropdownButton<String>(
            value: settings.language,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'zh-CN', child: Text('简体中文')),
              DropdownMenuItem(value: 'zh-TW', child: Text('繁體中文')),
              DropdownMenuItem(value: 'ja', child: Text('日本語')),
              DropdownMenuItem(value: 'ko', child: Text('한국어')),
            ],
            onChanged: (value) {
              if (value != null) notifier.setLanguage(value);
            },
          ),
        ),
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
