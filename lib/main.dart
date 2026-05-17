/// MarkFlowy — 应用入口
/// 参考: marktext/src/main/index.js
///
/// 负责初始化:
/// 1. WidgetsFlutterBinding
/// 2. WindowManager (桌面端窗口配置)
/// 3. SettingsService (持久化设置)
/// 4. ProviderScope (Riverpod 状态管理)
/// 5. 启动 App
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 桌面端初始化窗口管理器（参考 marktext config.js 中 editorWinOptions）
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      minimumSize: Size(550, 350),
      size: Size(1280, 800),
      center: true,
      title: 'MarkFlowy',
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // 初始化设置服务
  final prefs = await SharedPreferences.getInstance();
  final settingsService = SettingsService(prefs);

  // 使用 ProviderScope 包裹应用，override settingsServiceProvider
  runApp(
    ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWithValue(settingsService),
      ],
      child: const MarkdownEditorApp(),
    ),
  );
}
