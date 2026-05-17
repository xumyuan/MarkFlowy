/// 平台自适应工具组件
/// 参考: marktext 根据 platform 判断显示不同 UI 的逻辑
///
/// 提供根据运行平台（macOS/Windows/Linux/移动端）自动选择子组件的能力。
library;

import 'dart:io';

import 'package:flutter/widgets.dart';

/// 当前平台是否为桌面环境
bool get isDesktopPlatform =>
    Platform.isMacOS || Platform.isWindows || Platform.isLinux;

/// 当前平台是否为移动环境
bool get isMobilePlatform => Platform.isIOS || Platform.isAndroid;

/// 平台自适应组件 — 根据平台选择不同的子 Widget
/// 类似 marktext 中 titleBar 对 isOsx / titleBarStyle === 'custom' 的判断
class PlatformAdaptive extends StatelessWidget {
  /// macOS 平台显示的组件
  final Widget? macOS;

  /// Windows 平台显示的组件
  final Widget? windows;

  /// Linux 平台显示的组件
  final Widget? linux;

  /// 移动端 (iOS/Android) 显示的组件
  final Widget? mobile;

  /// 默认组件（无匹配平台时使用）
  final Widget fallback;

  const PlatformAdaptive({
    super.key,
    this.macOS,
    this.windows,
    this.linux,
    this.mobile,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS && macOS != null) return macOS!;
    if (Platform.isWindows && windows != null) return windows!;
    if (Platform.isLinux && linux != null) return linux!;
    if (isMobilePlatform && mobile != null) return mobile!;
    return fallback;
  }
}

/// 仅在桌面平台显示的组件包装
class DesktopOnly extends StatelessWidget {
  final Widget child;

  const DesktopOnly({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (isDesktopPlatform) return child;
    return const SizedBox.shrink();
  }
}
