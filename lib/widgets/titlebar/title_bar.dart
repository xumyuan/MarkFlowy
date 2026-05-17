/// 自适应标题栏
/// 参考: marktext/src/renderer/src/components/titleBar/index.vue
///
/// 根据运行平台自动选择 macOS 或 Windows 风格标题栏。
/// 移动端不显示窗口标题栏。
library;

import 'dart:io';

import 'package:flutter/widgets.dart';

import 'macos_title_bar.dart';
import 'windows_title_bar.dart';

/// 自适应标题栏 — 自动根据平台选择合适的标题栏样式
/// - macOS: 使用系统红绿灯 + 居中标题
/// - Windows/Linux: 使用自定义控制按钮（最小化/最大化/关闭）
/// - 移动端: 不显示
class TitleBar extends StatelessWidget {
  /// 当前文件名
  final String? filename;

  /// 文件是否已保存
  final bool isSaved;

  /// 窗口是否活跃
  final bool isActive;

  const TitleBar({
    super.key,
    this.filename,
    this.isSaved = true,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    // 移动端不显示窗口标题栏
    if (Platform.isIOS || Platform.isAndroid) {
      return const SizedBox.shrink();
    }

    // macOS 使用 macOS 风格
    if (Platform.isMacOS) {
      return MacOSTitleBar(
        filename: filename,
        isSaved: isSaved,
        isActive: isActive,
      );
    }

    // Windows/Linux 使用 Windows 风格
    return WindowsTitleBar(
      filename: filename,
      isSaved: isSaved,
      isActive: isActive,
    );
  }
}
