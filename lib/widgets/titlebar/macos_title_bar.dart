/// macOS 风格标题栏
/// 参考: marktext/src/renderer/src/components/titleBar/index.vue
///
/// macOS 使用 hiddenInset 标题栏样式，红绿灯按钮由系统绘制，
/// 这里只负责标题栏区域的拖拽和标题显示。
library;

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../utils/constants.dart';

/// macOS 风格标题栏
/// - 左侧预留红绿灯按钮区域（系统自动绘制）
/// - 中间显示文件名
/// - 双击标题栏切换最大化（对应 toggleMaxmizeOnMacOS）
class MacOSTitleBar extends StatelessWidget {
  /// 当前文件名
  final String? filename;

  /// 文件是否已保存
  final bool isSaved;

  /// 窗口是否活跃
  final bool isActive;

  const MacOSTitleBar({
    super.key,
    this.filename,
    this.isSaved = true,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      // 双击标题栏最大化/还原（对应 marktext toggleMaxmizeOnMacOS）
      onDoubleTap: () async {
        final isMaximized = await windowManager.isMaximized();
        if (isMaximized) {
          await windowManager.unmaximize();
        } else {
          await windowManager.maximize();
        }
      },
      child: DragToMoveArea(
        child: SizedBox(
          height: kTitleBarHeightMacOS + 7, // macOS 标题栏略高一些以适应内容
          child: Row(
            children: [
              // 左侧预留红绿灯按钮空间（约 70px）
              const SizedBox(width: 70),

              // 中间标题区域
              Expanded(
                child: Center(
                  child: _buildTitle(theme),
                ),
              ),

              // 右侧留白（对称）
              const SizedBox(width: 70),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建标题文本（对应 marktext title 区域逻辑）
  Widget _buildTitle(ThemeData theme) {
    if (filename == null || filename!.isEmpty) {
      return Text(
        'MarkText',
        style: TextStyle(
          fontSize: 13,
          color: isActive
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 文件名
        Flexible(
          child: Text(
            filename!,
            style: TextStyle(
              fontSize: 13,
              color: isActive
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // 未保存标记（对应 marktext save-dot）
        if (!isSaved) ...[
          const SizedBox(width: 6),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }
}
