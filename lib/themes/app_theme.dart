/// 主题工厂
/// 参考: marktext 的多主题系统
///
/// 提供 ThemeData 生成方法，根据主题名称返回对应的 Flutter ThemeData。
/// 每个主题从对应的颜色常量文件中提取色值。
library;

import 'package:flutter/material.dart';

import 'cadmium_dark.dart';
import 'cadmium_light.dart';
import 'graphite_light.dart';
import 'material_dark.dart';
import 'one_dark.dart';
import 'ulysses_light.dart';

/// 可用主题名称列表
const List<String> availableThemes = [
  'cadmiumLight',
  'cadmiumDark',
  'graphiteLight',
  'materialDark',
  'oneDark',
  'ulyssesLight',
];

/// 主题显示名称映射
const Map<String, String> themeDisplayNames = {
  'cadmiumLight': 'Cadmium Light',
  'cadmiumDark': 'Cadmium Dark',
  'graphiteLight': 'Graphite Light',
  'materialDark': 'Material Dark',
  'oneDark': 'One Dark',
  'ulyssesLight': 'Ulysses Light',
};

/// 判断主题是否是暗色主题
bool isThemeDark(String themeName) {
  return switch (themeName) {
    'cadmiumDark' || 'materialDark' || 'oneDark' => true,
    _ => false,
  };
}

/// 根据主题名称获取 ThemeData
ThemeData getTheme(String themeName) {
  return switch (themeName) {
    'cadmiumLight' => _buildCadmiumLight(),
    'cadmiumDark' => _buildCadmiumDark(),
    'graphiteLight' => _buildGraphiteLight(),
    'materialDark' => _buildMaterialDark(),
    'oneDark' => _buildOneDark(),
    'ulyssesLight' => _buildUlyssesLight(),
    _ => _buildCadmiumLight(), // 默认主题
  };
}

/// 获取编辑器专属颜色（不直接属于 ThemeData 的部分）
EditorThemeColors getEditorColors(String themeName) {
  return switch (themeName) {
    'cadmiumLight' => EditorThemeColors(
        headingColor: CadmiumLightColors.headingColor,
        h1Color: CadmiumLightColors.h1Color,
        h2Color: CadmiumLightColors.h2Color,
        h3Color: CadmiumLightColors.h3Color,
        h4Color: CadmiumLightColors.h4Color,
        h5Color: CadmiumLightColors.h5Color,
        h6Color: CadmiumLightColors.h6Color,
        linkColor: CadmiumLightColors.linkColor,
        codeBgColor: CadmiumLightColors.codeBg,
        codeBlockBgColor: CadmiumLightColors.codeBlockBg,
        blockquoteBorderColor: CadmiumLightColors.blockquoteBorder,
        hrColor: CadmiumLightColors.hrColor,
        listMarkerColor: CadmiumLightColors.listMarkerColor,
        highlightColor: CadmiumLightColors.highlightColor,
        selectionColor: CadmiumLightColors.selectionColor,
      ),
    'cadmiumDark' => EditorThemeColors(
        headingColor: CadmiumDarkColors.headingColor,
        h1Color: CadmiumDarkColors.h1Color,
        h2Color: CadmiumDarkColors.h2Color,
        h3Color: CadmiumDarkColors.h3Color,
        h4Color: CadmiumDarkColors.h4Color,
        h5Color: CadmiumDarkColors.h5Color,
        h6Color: CadmiumDarkColors.h6Color,
        linkColor: CadmiumDarkColors.linkColor,
        codeBgColor: CadmiumDarkColors.codeBg,
        codeBlockBgColor: CadmiumDarkColors.codeBlockBg,
        blockquoteBorderColor: CadmiumDarkColors.blockquoteBorder,
        hrColor: CadmiumDarkColors.hrColor,
        listMarkerColor: CadmiumDarkColors.listMarkerColor,
        highlightColor: CadmiumDarkColors.highlightColor,
        selectionColor: CadmiumDarkColors.selectionColor,
      ),
    'graphiteLight' => EditorThemeColors(
        headingColor: GraphiteLightColors.headingColor,
        h1Color: GraphiteLightColors.h1Color,
        h2Color: GraphiteLightColors.h2Color,
        h3Color: GraphiteLightColors.h3Color,
        h4Color: GraphiteLightColors.h4Color,
        h5Color: GraphiteLightColors.h5Color,
        h6Color: GraphiteLightColors.h6Color,
        linkColor: GraphiteLightColors.linkColor,
        codeBgColor: GraphiteLightColors.codeBg,
        codeBlockBgColor: GraphiteLightColors.codeBlockBg,
        blockquoteBorderColor: GraphiteLightColors.blockquoteBorder,
        hrColor: GraphiteLightColors.hrColor,
        listMarkerColor: GraphiteLightColors.listMarkerColor,
        highlightColor: GraphiteLightColors.highlightColor,
        selectionColor: GraphiteLightColors.selectionColor,
      ),
    'materialDark' => EditorThemeColors(
        headingColor: MaterialDarkColors.headingColor,
        h1Color: MaterialDarkColors.h1Color,
        h2Color: MaterialDarkColors.h2Color,
        h3Color: MaterialDarkColors.h3Color,
        h4Color: MaterialDarkColors.h4Color,
        h5Color: MaterialDarkColors.h5Color,
        h6Color: MaterialDarkColors.h6Color,
        linkColor: MaterialDarkColors.linkColor,
        codeBgColor: MaterialDarkColors.codeBg,
        codeBlockBgColor: MaterialDarkColors.codeBlockBg,
        blockquoteBorderColor: MaterialDarkColors.blockquoteBorder,
        hrColor: MaterialDarkColors.hrColor,
        listMarkerColor: MaterialDarkColors.listMarkerColor,
        highlightColor: MaterialDarkColors.highlightColor,
        selectionColor: MaterialDarkColors.selectionColor,
      ),
    'oneDark' => EditorThemeColors(
        headingColor: OneDarkColors.headingColor,
        h1Color: OneDarkColors.h1Color,
        h2Color: OneDarkColors.h2Color,
        h3Color: OneDarkColors.h3Color,
        h4Color: OneDarkColors.h4Color,
        h5Color: OneDarkColors.h5Color,
        h6Color: OneDarkColors.h6Color,
        linkColor: OneDarkColors.linkColor,
        codeBgColor: OneDarkColors.codeBg,
        codeBlockBgColor: OneDarkColors.codeBlockBg,
        blockquoteBorderColor: OneDarkColors.blockquoteBorder,
        hrColor: OneDarkColors.hrColor,
        listMarkerColor: OneDarkColors.listMarkerColor,
        highlightColor: OneDarkColors.highlightColor,
        selectionColor: OneDarkColors.selectionColor,
      ),
    'ulyssesLight' => EditorThemeColors(
        headingColor: UlyssesLightColors.headingColor,
        h1Color: UlyssesLightColors.h1Color,
        h2Color: UlyssesLightColors.h2Color,
        h3Color: UlyssesLightColors.h3Color,
        h4Color: UlyssesLightColors.h4Color,
        h5Color: UlyssesLightColors.h5Color,
        h6Color: UlyssesLightColors.h6Color,
        linkColor: UlyssesLightColors.linkColor,
        codeBgColor: UlyssesLightColors.codeBg,
        codeBlockBgColor: UlyssesLightColors.codeBlockBg,
        blockquoteBorderColor: UlyssesLightColors.blockquoteBorder,
        hrColor: UlyssesLightColors.hrColor,
        listMarkerColor: UlyssesLightColors.listMarkerColor,
        highlightColor: UlyssesLightColors.highlightColor,
        selectionColor: UlyssesLightColors.selectionColor,
      ),
    _ => getEditorColors('cadmiumLight'),
  };
}

/// 编辑器专属颜色（Markdown 渲染相关）
class EditorThemeColors {
  final Color headingColor;
  final Color h1Color;
  final Color h2Color;
  final Color h3Color;
  final Color h4Color;
  final Color h5Color;
  final Color h6Color;
  final Color linkColor;
  final Color codeBgColor;
  final Color codeBlockBgColor;
  final Color blockquoteBorderColor;
  final Color hrColor;
  final Color listMarkerColor;
  final Color highlightColor;
  final Color selectionColor;

  const EditorThemeColors({
    required this.headingColor,
    required this.h1Color,
    required this.h2Color,
    required this.h3Color,
    required this.h4Color,
    required this.h5Color,
    required this.h6Color,
    required this.linkColor,
    required this.codeBgColor,
    required this.codeBlockBgColor,
    required this.blockquoteBorderColor,
    required this.hrColor,
    required this.listMarkerColor,
    required this.highlightColor,
    required this.selectionColor,
  });
}

// ==================== 主题构建方法 ====================

ThemeData _buildCadmiumLight() {
  return ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: CadmiumLightColors.themeColor,
      secondary: CadmiumLightColors.themeColor,
      surface: CadmiumLightColors.editorBg,
      onSurface: CadmiumLightColors.editorText,
      outline: CadmiumLightColors.buttonBorder,
      surfaceContainerHighest: CadmiumLightColors.floatBg,
    ),
    scaffoldBackgroundColor: CadmiumLightColors.editorBg,
    cardColor: CadmiumLightColors.floatBg,
    dividerColor: CadmiumLightColors.tableBorder,
    inputDecorationTheme: InputDecorationTheme(
      fillColor: CadmiumLightColors.inputBg,
      filled: true,
    ),
  );
}

ThemeData _buildCadmiumDark() {
  return ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: CadmiumDarkColors.themeColor,
      secondary: CadmiumDarkColors.highlightThemeColor,
      surface: CadmiumDarkColors.editorBg,
      onSurface: CadmiumDarkColors.editorText,
      outline: CadmiumDarkColors.buttonBorder,
      surfaceContainerHighest: CadmiumDarkColors.floatBg,
    ),
    scaffoldBackgroundColor: CadmiumDarkColors.editorBg,
    cardColor: CadmiumDarkColors.floatBg,
    dividerColor: CadmiumDarkColors.tableBorder,
    inputDecorationTheme: InputDecorationTheme(
      fillColor: CadmiumDarkColors.inputBg,
      filled: true,
    ),
  );
}

ThemeData _buildGraphiteLight() {
  return ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: GraphiteLightColors.themeColor,
      secondary: GraphiteLightColors.themeColor,
      surface: GraphiteLightColors.editorBg,
      onSurface: GraphiteLightColors.editorText,
      outline: GraphiteLightColors.buttonBorder,
      surfaceContainerHighest: GraphiteLightColors.floatBg,
    ),
    scaffoldBackgroundColor: GraphiteLightColors.editorBg,
    cardColor: GraphiteLightColors.floatBg,
    dividerColor: GraphiteLightColors.tableBorder,
    inputDecorationTheme: InputDecorationTheme(
      fillColor: GraphiteLightColors.inputBg,
      filled: true,
    ),
  );
}

ThemeData _buildMaterialDark() {
  return ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: MaterialDarkColors.themeColor,
      secondary: MaterialDarkColors.highlightThemeColor,
      surface: MaterialDarkColors.editorBg,
      onSurface: MaterialDarkColors.editorText,
      outline: MaterialDarkColors.buttonBorder,
      surfaceContainerHighest: MaterialDarkColors.floatBg,
    ),
    scaffoldBackgroundColor: MaterialDarkColors.editorBg,
    cardColor: MaterialDarkColors.floatBg,
    dividerColor: MaterialDarkColors.tableBorder,
    inputDecorationTheme: InputDecorationTheme(
      fillColor: MaterialDarkColors.inputBg,
      filled: true,
    ),
  );
}

ThemeData _buildOneDark() {
  return ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: OneDarkColors.themeColor,
      secondary: OneDarkColors.highlightThemeColor,
      surface: OneDarkColors.editorBg,
      onSurface: OneDarkColors.editorText,
      outline: OneDarkColors.floatBorder,
      surfaceContainerHighest: OneDarkColors.floatBg,
    ),
    scaffoldBackgroundColor: OneDarkColors.editorBg,
    cardColor: OneDarkColors.floatBg,
    dividerColor: OneDarkColors.tableBorder,
    inputDecorationTheme: InputDecorationTheme(
      fillColor: OneDarkColors.inputBg,
      filled: true,
    ),
  );
}

ThemeData _buildUlyssesLight() {
  return ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: UlyssesLightColors.themeColor,
      secondary: UlyssesLightColors.themeColor,
      surface: UlyssesLightColors.editorBg,
      onSurface: UlyssesLightColors.editorText,
      outline: UlyssesLightColors.buttonBorder,
      surfaceContainerHighest: UlyssesLightColors.floatBg,
    ),
    scaffoldBackgroundColor: UlyssesLightColors.editorBg,
    cardColor: UlyssesLightColors.floatBg,
    dividerColor: UlyssesLightColors.tableBorder,
    inputDecorationTheme: InputDecorationTheme(
      fillColor: UlyssesLightColors.inputBg,
      filled: true,
    ),
  );
}
