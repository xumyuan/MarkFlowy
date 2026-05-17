/// Material Dark 主题
/// 参考: marktext/src/renderer/src/assets/themes/material-dark.theme.css
///
/// 以深灰蓝为主调，橙色作为强调色的暗色主题
library;

import 'package:flutter/material.dart';

/// Material Dark 主题颜色常量
class MaterialDarkColors {
  MaterialDarkColors._();

  // 主题色
  static const Color themeColor = Color(0xFFF48237);
  static const Color highlightThemeColor = Color(0xFFF48237);

  // 编辑器颜色
  static const Color editorBg = Color(0xFF34393F);
  static const Color editorText = Color(0xCCABB2BF); // rgba(171,178,191,.8)
  static const Color editorTextStrong = Color(0xFFABB2BF); // rgba(171,178,191,1)
  static const Color selectionColor = Color(0x33FFFFFF);
  static const Color highlightColor = Color(0x66F48237);

  // 代码块
  static const Color codeBg = Color(0x69D8D8D8);
  static const Color codeBlockBg = Color(0xFF3F454C);

  // Markdown 元素
  static const Color headingColor = Color(0xFFABB2BF);
  static const Color h1Color = Color(0xFFF48237);
  static const Color h2Color = Color(0xFF56B6C2);
  static const Color h3Color = Color(0xFFC678DD);
  static const Color h4Color = Color(0xFF98C379);
  static const Color h5Color = Color(0xFFE5C07B);
  static const Color h6Color = Color(0xFF61AFEF);
  static const Color linkColor = Color(0xFF61AFEF);
  static const Color blockquoteBorder = Color(0xFFF48237);
  static const Color blockquoteText = Color(0xB3ABB2BF);
  static const Color hrColor = Color(0x4DABB2BF);
  static const Color strongColor = Color(0xFFABB2BF);
  static const Color emColor = Color(0xFFC678DD);
  static const Color listMarkerColor = Color(0xFFF48237);

  // 侧边栏
  static const Color sideBarBg = Color(0xE61A2129);
  static const Color sideBarText = Color(0x66FFFFFF);
  static const Color sideBarTitle = Color(0xFFFFFFFF);
  static const Color sideBarIcon = Color(0x8FFFFFFF);
  static const Color sideBarHover = Color(0x08FFFFFF);

  // 浮动面板
  static const Color floatBg = Color(0xFF3C4650);
  static const Color floatHover = Color(0x0AFFFFFF);
  static const Color floatBorder = Color(0x08000000);
  static const Color floatText = Color(0xCCABB2BF);

  // 按钮
  static const Color buttonBg = Color(0xFF58606A);
  static const Color buttonBorder = Color(0xFF383D44);
  static const Color primaryButtonBg = Color(0xFFF48237);
  static const Color primaryButtonText = Color(0xFFFFFFFF);

  // 输入框
  static const Color inputBg = Color(0x1A000000);

  // 表格
  static const Color tableBorder = Color(0xFF4F585E);
}
