/// 编辑器主页面
/// 对应 marktext 的 /editor 路由
///
/// 使用 EditorScreen 作为实际布局，包含标题栏 + 侧边栏 + 标签栏 + 编辑区
library;

import 'package:flutter/material.dart';

import '../screens/editor_screen.dart';

/// 编辑器页面 — 包裹 EditorScreen 布局
class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EditorScreen(),
    );
  }
}
