/// Ulysses Light 主题
/// 参考: marktext/src/renderer/src/assets/themes/ulysses.theme.css
///
/// 以青蓝色为主调的清新浅色主题，标题居中显示
library;

import 'package:flutter/material.dart';

/// Ulysses Light 主题颜色常量
class UlyssesLightColors {
  UlyssesLightColors._();

  // 主题色
  static const Color themeColor = Color(0xFF0C8BBA);
  static const Color highlightThemeColor = Color(0xFF0C8BBA);

  // 编辑器颜色
  static const Color editorBg = Color(0xFFF3F3F3);
  static const Color editorText = Color(0xB3656565); // rgba(101,101,101,.7)
  static const Color editorTextStrong = Color(0xCC656565); // rgba(101,101,101,.8)
  static const Color selectionColor = Color(0x1A000000);
  static const Color highlightColor = Color(0x660C8BBA);

  // 代码块
  static const Color codeBg = Color(0x69D8D8D8);
  static const Color codeBlockBg = Color(0x0D0C8BBA);

  // Markdown 元素
  static const Color headingColor = Color(0xFF0C8BBA);
  static const Color h1Color = Color(0xFF0C8BBA);
  static const Color h2Color = Color(0xFF1A9F7F);
  static const Color h3Color = Color(0xFFD16A3D);
  static const Color h4Color = Color(0xFF7A70BA);
  static const Color h5Color = Color(0xFFC75991);
  static const Color h6Color = Color(0xFF708090);
  static const Color linkColor = Color(0xFF0C8BBA);
  static const Color blockquoteBorder = Color(0xFF0C8BBA);
  static const Color blockquoteText = Color(0x80656565);
  static const Color hrColor = Color(0x1A656565);
  static const Color strongColor = Color(0xCC656565);
  static const Color emColor = Color(0xFF1A9F7F);
  static const Color listMarkerColor = Color(0xFF0C8BBA);

  // 侧边栏
  static const Color sideBarBg = Color(0xE6F8F8F8);
  static const Color sideBarText = Color(0x66656565);
  static const Color sideBarTitle = Color(0xFF656565);
  static const Color sideBarIcon = Color(0xCC656565);
  static const Color sideBarHover = Color(0x08656565);

  // 浮动面板
  static const Color floatBg = Color(0xFFFFFFFF);
  static const Color floatHover = Color(0x0A656565);
  static const Color floatBorder = Color(0x08000000);
  static const Color floatText = Color(0xB3656565);

  // 按钮
  static const Color buttonBg = Color(0xFFFFFFFF);
  static const Color buttonBorder = Color(0xFFDCDFE6);
  static const Color primaryButtonBg = Color(0xFF0C8BBA);
  static const Color primaryButtonText = Color(0xFFFFFFFF);

  // 输入框
  static const Color inputBg = Color(0x0F000000);

  // 表格
  static const Color tableBorder = Color(0xFFE5E5E5);
}
