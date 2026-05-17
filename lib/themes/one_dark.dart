/// One Dark 主题
/// 参考: marktext/src/renderer/src/assets/themes/one-dark.theme.css
///
/// 经典 One Dark 配色，深蓝灰底色搭配鲜明的语法高亮色
library;

import 'package:flutter/material.dart';

/// One Dark 主题颜色常量
class OneDarkColors {
  OneDarkColors._();

  // 主题色
  static const Color themeColor = Color(0xFF4D78CC);
  static const Color highlightThemeColor = Color(0xFFE2C08D);

  // 编辑器颜色
  static const Color editorBg = Color(0xFF282C34);
  static const Color editorText = Color(0xFF9DA5B4);
  static const Color editorTextStrong = Color(0xFF9DA5B4);
  static const Color selectionColor = Color(0x60677696);
  static const Color highlightColor = Color(0x10FFFFFF);

  // 代码块
  static const Color codeBg = Color(0xFF3A3F4B);
  static const Color codeBlockBg = Color(0xFF3A3F4B);

  // Markdown 元素
  static const Color headingColor = Color(0xFFE2C08D);
  static const Color h1Color = Color(0xFFE06C75);
  static const Color h2Color = Color(0xFF61AFEF);
  static const Color h3Color = Color(0xFF98C379);
  static const Color h4Color = Color(0xFF56B6C2);
  static const Color h5Color = Color(0xFFC678DD);
  static const Color h6Color = Color(0xFFE5C07B);
  static const Color linkColor = Color(0xFF61AFEF);
  static const Color blockquoteBorder = Color(0xFFE2C08D);
  static const Color blockquoteText = Color(0x999DA5B4);
  static const Color hrColor = Color(0xFF4B5362);
  static const Color strongColor = Color(0xFFE2C08D);
  static const Color emColor = Color(0xFFC678DD);
  static const Color listMarkerColor = Color(0xFFE06C75);

  // 侧边栏
  static const Color sideBarBg = Color(0xFF21252B);
  static const Color sideBarText = Color(0xFF9DA5B4);
  static const Color sideBarTitle = Color(0xFF9DA5B4);
  static const Color sideBarIcon = Color(0x8FFFFFFF);
  static const Color sideBarHover = Color(0xFF3A3F4B);

  // 浮动面板
  static const Color floatBg = Color(0xFF21252B);
  static const Color floatHover = Color(0xFF3A3F4B);
  static const Color floatBorder = Color(0xFF181A1F);
  static const Color floatText = Color(0xFF9DA5B4);

  // 按钮
  static const Color buttonBg = Color(0xFF3A3F4B);
  static const Color buttonBorder = Color(0xFF181A1F);
  static const Color primaryButtonBg = Color(0xFF4D78CC);
  static const Color primaryButtonText = Color(0xFFFFFFFF);

  // 输入框
  static const Color inputBg = Color(0xFF1B1D23);

  // 焦点色
  static const Color focusColor = Color(0xFF568AF2);

  // 表格
  static const Color tableBorder = Color(0xFF363839);

  // 滚动条
  static const Color scrollbarThumb = Color(0xFF414956);
  static const Color scrollbarThumbHover = Color(0xFF4B5362);
}
