/// Cadmium Dark 主题（暗色主题）
/// 参考: marktext/src/renderer/src/assets/themes/dark.theme.css
///
/// 以深灰色为主调，蓝色作为强调色的暗色主题
library;

import 'package:flutter/material.dart';

/// Cadmium Dark 主题颜色常量
class CadmiumDarkColors {
  CadmiumDarkColors._();

  // 主题色
  static const Color themeColor = Color(0xFF409EFF);
  static const Color highlightThemeColor = Color(0xFF66B1FF);

  // 编辑器颜色
  static const Color editorBg = Color(0xFF282828);
  static const Color editorText = Color(0xB3FFFFFF); // rgba(255,255,255,.7)
  static const Color editorTextStrong = Color(0xCCFFFFFF); // rgba(255,255,255,.8)
  static const Color selectionColor = Color(0x4D66B1FF);
  static const Color highlightColor = Color(0x9966B1FF);

  // 代码块
  static const Color codeBg = Color(0xFF424344);
  static const Color codeBlockBg = Color(0xFF424344);

  // Markdown 元素
  static const Color headingColor = Color(0xCCFFFFFF);
  static const Color h1Color = Color(0xCCFFFFFF);
  static const Color h2Color = Color(0xCCFFFFFF);
  static const Color h3Color = Color(0xCCFFFFFF);
  static const Color h4Color = Color(0xCCFFFFFF);
  static const Color h5Color = Color(0xCCFFFFFF);
  static const Color h6Color = Color(0xCCFFFFFF);
  static const Color linkColor = Color(0xFF409EFF);
  static const Color blockquoteBorder = Color(0xFF409EFF);
  static const Color hrColor = Color(0x1AFFFFFF);
  static const Color listMarkerColor = Color(0xFF409EFF);

  // 侧边栏
  static const Color sideBarBg = Color(0xFF1E1E1E);
  static const Color sideBarText = Color(0x99FFFFFF);
  static const Color sideBarTitle = Color(0xCCFFFFFF);
  static const Color sideBarIcon = Color(0x8FFFFFFF);
  static const Color sideBarHover = Color(0x08FFFFFF);

  // 浮动面板
  static const Color floatBg = Color(0xFF3F3F3F);
  static const Color floatHover = Color(0x0AFFFFFF);
  static const Color floatBorder = Color(0x0D000000);
  static const Color floatText = Color(0xB3FFFFFF);

  // 按钮
  static const Color buttonBg = Color(0xFF424344);
  static const Color buttonBorder = Color(0x33000000);
  static const Color primaryButtonBg = Color(0xFF409EFF);
  static const Color primaryButtonText = Color(0xFFFFFFFF);

  // 输入框
  static const Color inputBg = Color(0xFF2F3336);

  // 表格
  static const Color tableBorder = Color(0xFF363839);
}
