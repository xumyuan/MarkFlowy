/// 主题设置面板
/// 参考: marktext/src/renderer/src/prefComponents/theme/index.vue
///
/// 包含:
/// - 主题选择网格（6 个主题卡片预览）
/// - 当前主题高亮
/// - 点击切换主题
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_provider.dart';
import '../../themes/app_theme.dart';

/// 主题设置面板（对应 prefComponents/theme/index.vue）
class ThemeSettingsPanel extends ConsumerWidget {
  const ThemeSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('主题', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),

        // 主题卡片网格（对应 offcial-themes 区域）
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: availableThemes.length,
              itemBuilder: (context, index) {
                final themeName = availableThemes[index];
                final isActive = settings.theme == themeName;
                final isDark = isThemeDark(themeName);
                final displayName = themeDisplayNames[themeName] ?? themeName;

                return _ThemeCard(
                  themeName: displayName,
                  isDark: isDark,
                  isActive: isActive,
                  isDisabled: settings.followSystemTheme,
                  onTap: settings.followSystemTheme
                      ? null
                      : () => notifier.setTheme(themeName),
                );
              },
            );
          },
        ),
        const SizedBox(height: 24),
        const Divider(),

        // 跟随系统主题
        SwitchListTile(
          title: const Text('跟随系统主题'),
          subtitle: const Text('根据系统的明暗模式自动切换主题'),
          value: settings.followSystemTheme,
          onChanged: (value) => notifier.setFollowSystemTheme(value),
        ),

        // 系统主题映射选项
        if (settings.followSystemTheme) ...[
          const SizedBox(height: 8),
          ListTile(
            title: const Text('亮色模式主题'),
            trailing: DropdownButton<String>(
              value: settings.lightModeTheme,
              items: availableThemes.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(themeDisplayNames[t] ?? t),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) notifier.setLightModeTheme(value);
              },
            ),
          ),
          ListTile(
            title: const Text('暗色模式主题'),
            trailing: DropdownButton<String>(
              value: settings.darkModeTheme,
              items: availableThemes.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(themeDisplayNames[t] ?? t),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) notifier.setDarkModeTheme(value);
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// 主题卡片组件（对应 theme.vue 中的 .theme 卡片）
class _ThemeCard extends StatelessWidget {
  final String themeName;
  final bool isDark;
  final bool isActive;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _ThemeCard({
    required this.themeName,
    required this.isDark,
    required this.isActive,
    required this.isDisabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF282828) : Colors.white;
    final textColor = isDark
        ? Colors.white.withOpacity(0.7)
        : Colors.black.withOpacity(0.7);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : Border.all(color: Colors.grey.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  themeName,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                // 预览行
                Container(
                  height: 3,
                  width: 60,
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
