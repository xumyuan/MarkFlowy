/// MarkFlowy — 应用与路由配置
/// 参考: marktext/src/renderer/src/main.js 和 src/renderer/src/router/index.js
///
/// MarkText 的路由结构:
/// - /editor — 主编辑器页面
/// - /preference — 设置页面（含子路由: general, editor, markdown, theme 等）
///
/// 在 Flutter 中使用 GoRouter 实现类似的路由结构。
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/editor_page.dart';
import 'pages/settings_page.dart';
import 'screens/welcome_screen.dart';

/// 路由配置（参考 marktext router/index.js）
final GoRouter _router = GoRouter(
  initialLocation: '/editor',
  routes: [
    // 主编辑器路由
    GoRoute(
      path: '/editor',
      name: 'editor',
      builder: (context, state) => const EditorPage(),
    ),
    // 欢迎页路由（最近文件/快速操作）
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    // 设置页路由（对应 marktext 的 /preference）
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
      routes: [
        // 子路由对应 marktext 的 preference 子页面
        GoRoute(
          path: 'general',
          name: 'settings-general',
          builder: (context, state) => const SettingsPage(section: 'general'),
        ),
        GoRoute(
          path: 'editor',
          name: 'settings-editor',
          builder: (context, state) => const SettingsPage(section: 'editor'),
        ),
        GoRoute(
          path: 'markdown',
          name: 'settings-markdown',
          builder: (context, state) => const SettingsPage(section: 'markdown'),
        ),
        GoRoute(
          path: 'theme',
          name: 'settings-theme',
          builder: (context, state) => const SettingsPage(section: 'theme'),
        ),
        GoRoute(
          path: 'image',
          name: 'settings-image',
          builder: (context, state) => const SettingsPage(section: 'image'),
        ),
        GoRoute(
          path: 'keybindings',
          name: 'settings-keybindings',
          builder: (context, state) =>
              const SettingsPage(section: 'keybindings'),
        ),
      ],
    ),
  ],
);

/// 应用根 Widget
class MarkdownEditorApp extends StatelessWidget {
  const MarkdownEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MarkFlowy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // 跟随系统主题（对应 marktext 的 followSystemTheme 设置）
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
