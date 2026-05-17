/// Cadmium Light 主题（浅色主题）
/// 参考: marktext/src/renderer/src/assets/themes/graphite.theme.css 中的浅色配色
///
/// 以浅灰色为主调，蓝灰色作为强调色的清新主题
library;

import 'package:flutter/material.dart';

/// Cadmium Light 主题颜色常量
class CadmiumLightColors {
  CadmiumLightColors._();

  // 主题色
  static const Color themeColor = Color(0xFF6886AA);
  static const Color highlightThemeColor = Color(0xFF6886AA);

  // 编辑器颜色
  static const Color editorBg = Color(0xFFF7F7F7);
  static const Color editorText = Color(0xB32B3032); // rgba(43,48,50,.7)
  static const Color editorTextStrong = Color(0xCC2B3032); // rgba(43,48,50,.8)
  static const Color selectionColor = Color(0x1A000000);
  static const Color highlightColor = Color(0x666886AA);

  // 代码块
  static const Color codeBg = Color(0x69D8D8D8);
  static const Color codeBlockBg = Color(0x0D6886AA);

  // Markdown 元素
  static const Color headingColor = Color(0xCC2B3032);
  static const Color h1Color = Color(0xFF6886AA);
  static const Color h2Color = Color(0xFF5F9EA0);
  static const Color h3Color = Color(0xFFB8860B);
  static const Color h4Color = Color(0xFF7B68EE);
  static const Color h5Color = Color(0xFFCD5C5C);
  static const Color h6Color = Color(0xFF708090);
  static const Color linkColor = Color(0xFF6886AA);
  static const Color blockquoteBorder = Color(0xFF6886AA);
  static const Color hrColor = Color(0x1A2B3032);
  static const Color listMarkerColor = Color(0xFF6886AA);

  // 侧边栏
  static const Color sideBarBg = Color(0xFF454B50);
  static const Color sideBarText = Color(0xCCBCC1C5);
  static const Color sideBarTitle = Color(0xFFFFFFFF);
  static const Color sideBarIcon = Color(0xCCAFAFAF);
  static const Color sideBarHover = Color(0x08FFFFFF);

  // 浮动面板
  static const Color floatBg = Color(0xFFEDEDEE);
  static const Color floatHover = Color(0x0A2B3032);
  static const Color floatBorder = Color(0x08000000);
  static const Color floatText = Color(0xB32B3032);

  // 按钮
  static const Color buttonBg = Color(0xFFFFFFFF);
  static const Color buttonBorder = Color(0xFFDCDFE6);
  static const Color primaryButtonBg = Color(0xFF6886AA);
  static const Color primaryButtonText = Color(0xFFFFFFFF);

  // 输入框
  static const Color inputBg = Color(0x0F000000);

  // 表格
  static const Color tableBorder = Color(0xFFE5E5E5);
}
