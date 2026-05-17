/// 主题状态管理 Provider
/// 参考: marktext/src/renderer/src/prefComponents/theme/ 的主题切换逻辑
///
/// 管理:
/// - 当前主题名称
/// - 主题切换
/// - 持久化主题选择
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../themes/app_theme.dart';

/// 主题持久化使用的 key
const _themePrefsKey = 'selected_theme';

/// 主题状态
class ThemeState {
  /// 当前主题名称
  final String themeName;

  /// 当前 ThemeData
  final ThemeData themeData;

  /// 编辑器专属颜色
  final EditorThemeColors editorColors;

  /// 是否是暗色主题
  bool get isDark => isThemeDark(themeName);

  const ThemeState({
    required this.themeName,
    required this.themeData,
    required this.editorColors,
  });
}

/// 主题状态 Notifier
class ThemeNotifier extends AsyncNotifier<ThemeState> {
  @override
  Future<ThemeState> build() async {
    // 从 SharedPreferences 加载已保存的主题
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themePrefsKey) ?? 'cadmiumLight';

    return ThemeState(
      themeName: savedTheme,
      themeData: getTheme(savedTheme),
      editorColors: getEditorColors(savedTheme),
    );
  }

  /// 切换主题
  Future<void> setTheme(String themeName) async {
    if (!availableThemes.contains(themeName)) return;

    // 持久化
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePrefsKey, themeName);

    // 更新状态
    state = AsyncData(ThemeState(
      themeName: themeName,
      themeData: getTheme(themeName),
      editorColors: getEditorColors(themeName),
    ));
  }

  /// 循环切换到下一个主题
  Future<void> cycleTheme() async {
    final current = state.value?.themeName ?? 'cadmiumLight';
    final currentIndex = availableThemes.indexOf(current);
    final nextIndex = (currentIndex + 1) % availableThemes.length;
    await setTheme(availableThemes[nextIndex]);
  }
}

/// 主题 Provider
final themeProvider =
    AsyncNotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);

/// 便捷访问当前 ThemeData 的 Provider
final currentThemeDataProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeProvider);
  return themeState.value?.themeData ??
      getTheme('cadmiumLight');
});

/// 便捷访问编辑器颜色的 Provider
final editorColorsProvider = Provider<EditorThemeColors>((ref) {
  final themeState = ref.watch(themeProvider);
  return themeState.value?.editorColors ??
      getEditorColors('cadmiumLight');
});
