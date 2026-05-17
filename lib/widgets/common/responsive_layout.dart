/// 响应式布局组件
/// 参考: marktext 中侧边栏可收起/展开的逻辑
///
/// 提供桌面宽屏、平板、手机三种布局断点的自适应能力。
library;

import 'package:flutter/widgets.dart';

/// 布局断点常量
class LayoutBreakpoints {
  /// 手机最大宽度
  static const double mobile = 600;

  /// 平板最大宽度
  static const double tablet = 1024;

  // 大于 tablet 即为桌面
  const LayoutBreakpoints._();
}

/// 当前布局类型
enum LayoutType {
  /// 手机布局：侧边栏为抽屉
  mobile,

  /// 平板布局：可收起侧边栏
  tablet,

  /// 桌面布局：完整侧边栏 + 标签
  desktop,
}

/// 根据宽度获取当前布局类型
LayoutType getLayoutType(double width) {
  if (width <= LayoutBreakpoints.mobile) return LayoutType.mobile;
  if (width <= LayoutBreakpoints.tablet) return LayoutType.tablet;
  return LayoutType.desktop;
}

/// 响应式布局构建器
/// 根据可用宽度自动选择桌面/平板/手机布局
class ResponsiveLayout extends StatelessWidget {
  /// 桌面布局构建器（宽度 > 1024）
  final Widget Function(BuildContext context) desktop;

  /// 平板布局构建器（600 < 宽度 <= 1024）
  final Widget Function(BuildContext context)? tablet;

  /// 手机布局构建器（宽度 <= 600）
  final Widget Function(BuildContext context)? mobile;

  const ResponsiveLayout({
    super.key,
    required this.desktop,
    this.tablet,
    this.mobile,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final type = getLayoutType(constraints.maxWidth);
        switch (type) {
          case LayoutType.mobile:
            return (mobile ?? tablet ?? desktop).call(context);
          case LayoutType.tablet:
            return (tablet ?? desktop).call(context);
          case LayoutType.desktop:
            return desktop(context);
        }
      },
    );
  }
}
