/// 设置页面
/// 参考: marktext/src/renderer/src/pages/preference.vue
///
/// 桌面端: 左侧导航栏 + 右侧设置面板
/// 移动端: ListView + 分组
library;

import 'package:flutter/material.dart';

import '../widgets/settings/editor_settings.dart';
import '../widgets/settings/general_settings.dart';
import '../widgets/settings/image_settings.dart';
import '../widgets/settings/keybinding_settings.dart';
import '../widgets/settings/markdown_settings.dart';
import '../widgets/settings/theme_settings.dart';

/// 设置分区枚举
enum SettingsSection {
  general('通用', Icons.settings),
  editor('编辑器', Icons.edit),
  markdown('Markdown', Icons.text_fields),
  theme('主题', Icons.palette),
  image('图片', Icons.image),
  keybindings('快捷键', Icons.keyboard);

  final String label;
  final IconData icon;
  const SettingsSection(this.label, this.icon);
}

/// 设置页面（对应 marktext preference.vue 的左右分栏布局）
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsSection _currentSection = SettingsSection.general;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        elevation: 0,
      ),
      body: isWide ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  /// 桌面端左右分栏布局（对应 preference.vue 的 side-bar + pref-content）
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // 左侧导航栏
        SizedBox(
          width: 220,
          child: _buildNavList(),
        ),
        const VerticalDivider(width: 1),
        // 右侧设置面板
        Expanded(
          child: _buildSettingsPanel(_currentSection),
        ),
      ],
    );
  }

  /// 移动端列表布局
  Widget _buildMobileLayout() {
    return ListView(
      children: SettingsSection.values.map((section) {
        return ListTile(
          leading: Icon(section.icon),
          title: Text(section.label),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: Text(section.label)),
                  body: _buildSettingsPanel(section),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  /// 左侧导航列表
  Widget _buildNavList() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: SettingsSection.values.map((section) {
        final isSelected = section == _currentSection;
        return ListTile(
          leading: Icon(
            section.icon,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          title: Text(
            section.label,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : null,
              fontWeight: isSelected ? FontWeight.w600 : null,
            ),
          ),
          selected: isSelected,
          selectedTileColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onTap: () {
            setState(() {
              _currentSection = section;
            });
          },
        );
      }).toList(),
    );
  }

  /// 根据分区返回对应设置面板
  Widget _buildSettingsPanel(SettingsSection section) {
    return switch (section) {
      SettingsSection.general => const GeneralSettings(),
      SettingsSection.editor => const EditorSettings(),
      SettingsSection.markdown => const MarkdownSettings(),
      SettingsSection.theme => const ThemeSettingsPanel(),
      SettingsSection.image => const ImageSettings(),
      SettingsSection.keybindings => const KeybindingSettings(),
    };
  }
}
