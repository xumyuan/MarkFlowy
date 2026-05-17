/// Flutter Markdown Editor — 应用入口
/// 参考: marktext/src/main/index.js
///
/// 负责初始化:
/// 1. WidgetsFlutterBinding
/// 2. WindowManager (桌面端窗口配置)
/// 3. ProviderScope (Riverpod 状态管理)
/// 4. 启动 App
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 桌面端初始化窗口管理器（参考 marktext config.js 中 editorWinOptions）
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      // 最小窗口尺寸，参考 marktext editorWinOptions.minWidth/minHeight
      minimumSize: Size(550, 350),
      size: Size(1280, 800),
      center: true,
      title: 'Flutter Markdown Editor',
      // macOS 使用 hiddenInset 样式标题栏
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // 使用 ProviderScope 包裹应用，启用 Riverpod 状态管理
  runApp(
    const ProviderScope(
      child: MarkdownEditorApp(),
    ),
  );
}
