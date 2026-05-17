/// 设置页面入口
/// 对应 marktext 的 /preference 路由及其子路由
///
/// 此文件作为路由入口，实际 UI 实现在 screens/settings_screen.dart
library;

import 'package:flutter/material.dart';

import '../screens/settings_screen.dart';

/// 设置页面 — 应用偏好设置
class SettingsPage extends StatelessWidget {
  /// 当前显示的设置分区（保留参数兼容性）
  final String section;

  const SettingsPage({super.key, this.section = 'general'});

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen();
  }
}
