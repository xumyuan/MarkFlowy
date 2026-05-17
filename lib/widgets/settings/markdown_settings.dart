/// Markdown 设置面板
/// 参考: marktext/src/renderer/src/prefComponents/markdown/index.vue
///
/// 包含:
/// - 有序列表标记样式
/// - 列表缩进方式
/// - Markdown 扩展（表格、脚注、数学公式等开关）
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_settings.dart';
import '../../providers/settings_provider.dart';

/// Markdown 设置（对应 prefComponents/markdown/index.vue）
class MarkdownSettings extends ConsumerWidget {
  const MarkdownSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Markdown', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),

        // ===== 列表 =====
        _SectionHeader(title: '列表'),
        SwitchListTile(
          title: const Text('偏好松散列表'),
          subtitle: const Text('列表项之间添加空行'),
          value: settings.preferLooseListItem,
          onChanged: (value) => notifier.setPreferLooseListItem(value),
        ),
        ListTile(
          title: const Text('无序列表标记'),
          trailing: DropdownButton<BulletListMarker>(
            value: settings.bulletListMarker,
            items: const [
              DropdownMenuItem(
                value: BulletListMarker.dash,
                child: Text('- (破折号)'),
              ),
              DropdownMenuItem(
                value: BulletListMarker.asterisk,
                child: Text('* (星号)'),
              ),
              DropdownMenuItem(
                value: BulletListMarker.plus,
                child: Text('+ (加号)'),
              ),
            ],
            onChanged: (value) {
              if (value != null) notifier.setBulletListMarker(value);
            },
          ),
        ),
        ListTile(
          title: const Text('有序列表分隔符'),
          trailing: DropdownButton<OrderListDelimiter>(
            value: settings.orderListDelimiter,
            items: const [
              DropdownMenuItem(
                value: OrderListDelimiter.dot,
                child: Text('. (点号)'),
              ),
              DropdownMenuItem(
                value: OrderListDelimiter.parenthesis,
                child: Text(') (括号)'),
              ),
            ],
            onChanged: (value) {
              if (value != null) notifier.setOrderListDelimiter(value);
            },
          ),
        ),
        ListTile(
          title: const Text('列表缩进方式'),
          trailing: DropdownButton<String>(
            value: settings.listIndentation,
            items: const [
              DropdownMenuItem(value: '1', child: Text('1 个空格')),
              DropdownMenuItem(value: 'dfm', child: Text('DFM 风格')),
              DropdownMenuItem(value: 'tab', child: Text('Tab 宽度')),
            ],
            onChanged: (value) {
              if (value != null) notifier.setListIndentation(value);
            },
          ),
        ),
        const Divider(),

        // ===== 扩展 =====
        _SectionHeader(title: '扩展'),
        SwitchListTile(
          title: const Text('上标/下标'),
          subtitle: const Text('启用 ^上标^ 和 ~下标~ 语法'),
          value: settings.superSubScript,
          onChanged: (value) => notifier.setSuperSubScript(value),
        ),
        SwitchListTile(
          title: const Text('脚注'),
          subtitle: const Text('启用 [^ref] 脚注语法'),
          value: settings.footnote,
          onChanged: (value) => notifier.setFootnote(value),
        ),
        const Divider(),

        // ===== 兼容性 =====
        _SectionHeader(title: '兼容性'),
        SwitchListTile(
          title: const Text('启用 HTML 渲染'),
          subtitle: const Text('允许在 Markdown 中使用 HTML 标签'),
          value: settings.isHtmlEnabled,
          onChanged: (value) => notifier.setIsHtmlEnabled(value),
        ),
        SwitchListTile(
          title: const Text('GitLab 兼容模式'),
          subtitle: const Text('启用 GitLab 风格的 Markdown 扩展'),
          value: settings.isGitlabCompatibilityEnabled,
          onChanged: (value) =>
              notifier.setIsGitlabCompatibilityEnabled(value),
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
