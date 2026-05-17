/// Windows 风格标题栏
/// 参考: marktext/src/renderer/src/components/titleBar/index.vue
///
/// Windows 使用自定义无框标题栏，包含:
/// - 左侧汉堡菜单按钮（对应 frameless-titlebar-menu）
/// - 中间标题文本
/// - 右侧最小化/最大化/关闭按钮（对应 frameless-titlebar-button）
library;

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../utils/constants.dart';

/// Windows 风格标题栏
class WindowsTitleBar extends StatefulWidget {
  /// 当前文件名
  final String? filename;

  /// 文件是否已保存
  final bool isSaved;

  /// 窗口是否活跃
  final bool isActive;

  const WindowsTitleBar({
    super.key,
    this.filename,
    this.isSaved = true,
    this.isActive = true,
  });

  @override
  State<WindowsTitleBar> createState() => _WindowsTitleBarState();
}

class _WindowsTitleBarState extends State<WindowsTitleBar> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _checkMaximized();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _checkMaximized() async {
    final maximized = await windowManager.isMaximized();
    if (mounted) setState(() => _isMaximized = maximized);
  }

  // WindowListener 回调（对应 marktext IPC 事件）
  @override
  void onWindowMaximize() => setState(() => _isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _isMaximized = false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DragToMoveArea(
      child: SizedBox(
        height: kTitleBarHeightOther,
        child: Row(
          children: [
            // 左侧汉堡菜单（对应 frameless-titlebar-menu）
            _MenuButton(theme: theme),

            // 中间标题
            Expanded(child: _buildTitle(theme)),

            // 右侧窗口控制按钮（对应 right-toolbar）
            _WindowControlButton(
              icon: Icons.remove,
              onPressed: windowManager.minimize,
              tooltip: '最小化',
            ),
            _WindowControlButton(
              icon: _isMaximized ? Icons.filter_none : Icons.crop_square,
              iconSize: _isMaximized ? 14 : 16,
              onPressed: () async {
                if (_isMaximized) {
                  await windowManager.unmaximize();
                } else {
                  await windowManager.maximize();
                }
              },
              tooltip: _isMaximized ? '向下还原' : '最大化',
            ),
            _CloseButton(theme: theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    final title = widget.filename ?? 'MarkText';
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: widget.isActive
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 未保存标记
          if (!widget.isSaved) ...[
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
      ),
    );
  }
}

/// 汉堡菜单按钮
class _MenuButton extends StatelessWidget {
  final ThemeData theme;

  const _MenuButton({required this.theme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: kTitleBarHeightOther,
      child: IconButton(
        icon: Icon(
          Icons.menu,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        onPressed: () {
          // TODO: 打开应用菜单
        },
        padding: EdgeInsets.zero,
        splashRadius: 16,
      ),
    );
  }
}

/// 窗口控制按钮（最小化/最大化）
class _WindowControlButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final VoidCallback onPressed;
  final String tooltip;

  const _WindowControlButton({
    required this.icon,
    this.iconSize = 16,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 46,
          height: kTitleBarHeightOther,
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}

/// 关闭按钮（对应 frameless-titlebar-close，hover 变红）
class _CloseButton extends StatefulWidget {
  final ThemeData theme;

  const _CloseButton({required this.theme});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => windowManager.close(),
        child: Container(
          width: 46,
          height: kTitleBarHeightOther,
          color: _isHovered ? const Color(0xFFE44F4F) : Colors.transparent,
          child: Center(
            child: Icon(
              Icons.close,
              size: 16,
              color: _isHovered
                  ? Colors.white
                  : widget.theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
