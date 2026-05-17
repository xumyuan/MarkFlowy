/// 编辑器设置面板
/// 参考: marktext/src/renderer/src/prefComponents/editor/index.vue
///
/// 包含:
/// - 字体设置（字体族、大小、行高）
/// - 自动配对符号
/// - Tab 大小
/// - 打字机模式 / 焦点模式
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_provider.dart';

/// 编辑器设置（对应 prefComponents/editor/index.vue）
class EditorSettings extends ConsumerWidget {
  const EditorSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('编辑器', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),

        // ===== 文本编辑器 =====
        _SectionHeader(title: '文本编辑器'),
        // 字体大小
        ListTile(
          title: const Text('字体大小'),
          subtitle: Text('${settings.fontSize}px'),
          trailing: SizedBox(
            width: 200,
            child: Slider(
              value: settings.fontSize.toDouble(),
              min: 12,
              max: 32,
              divisions: 20,
              label: '${settings.fontSize}px',
              onChanged: (value) => notifier.setFontSize(value.toInt()),
            ),
          ),
        ),
        // 行高
        ListTile(
          title: const Text('行高'),
          subtitle: Text('${settings.lineHeight.toStringAsFixed(1)}'),
          trailing: SizedBox(
            width: 200,
            child: Slider(
              value: settings.lineHeight,
              min: 1.2,
              max: 2.0,
              divisions: 8,
              label: settings.lineHeight.toStringAsFixed(1),
              onChanged: (value) => notifier.setLineHeight(
                (value * 10).round() / 10.0,
              ),
            ),
          ),
        ),
        // 字体族
        ListTile(
          title: const Text('编辑器字体'),
          subtitle: Text(settings.editorFontFamily),
          trailing: SizedBox(
            width: 180,
            child: TextField(
              controller: TextEditingController(
                text: settings.editorFontFamily,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) notifier.setEditorFontFamily(value);
              },
            ),
          ),
        ),
        const Divider(),

        // ===== 代码块 =====
        _SectionHeader(title: '代码块'),
        // 代码字体大小
        ListTile(
          title: const Text('代码字体大小'),
          subtitle: Text('${settings.codeFontSize}px'),
          trailing: SizedBox(
            width: 200,
            child: Slider(
              value: settings.codeFontSize.toDouble(),
              min: 12,
              max: 28,
              divisions: 16,
              label: '${settings.codeFontSize}px',
              onChanged: (value) => notifier.setCodeFontSize(value.toInt()),
            ),
          ),
        ),
        // 代码字体
        ListTile(
          title: const Text('代码字体'),
          subtitle: Text(settings.codeFontFamily),
          trailing: SizedBox(
            width: 180,
            child: TextField(
              controller: TextEditingController(
                text: settings.codeFontFamily,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) notifier.setCodeFontFamily(value);
              },
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('代码块自动换行'),
          value: settings.wrapCodeBlocks,
          onChanged: (value) => notifier.setWrapCodeBlocks(value),
        ),
        const Divider(),

        // ===== 编写行为 =====
        _SectionHeader(title: '编写行为'),
        SwitchListTile(
          title: const Text('自动配对括号'),
          subtitle: const Text('输入左括号时自动补全右括号'),
          value: settings.autoPairBracket,
          onChanged: (value) => notifier.setAutoPairBracket(value),
        ),
        SwitchListTile(
          title: const Text('自动配对 Markdown 语法'),
          subtitle: const Text('如 ** 粗体 **、_ 斜体 _ 等'),
          value: settings.autoPairMarkdownSyntax,
          onChanged: (value) => notifier.setAutoPairMarkdownSyntax(value),
        ),
        SwitchListTile(
          title: const Text('自动配对引号'),
          value: settings.autoPairQuote,
          onChanged: (value) => notifier.setAutoPairQuote(value),
        ),
        const Divider(),

        // ===== 文件表示 =====
        _SectionHeader(title: '文件表示'),
        ListTile(
          title: const Text('Tab 宽度'),
          trailing: DropdownButton<int>(
            value: settings.tabSize,
            items: const [
              DropdownMenuItem(value: 2, child: Text('2')),
              DropdownMenuItem(value: 4, child: Text('4')),
              DropdownMenuItem(value: 8, child: Text('8')),
            ],
            onChanged: (value) {
              if (value != null) notifier.setTabSize(value);
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
