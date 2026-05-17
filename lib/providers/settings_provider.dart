/// 设置状态管理 Provider
/// 参考: marktext/src/renderer/src/store/preferences.js
///
/// 使用 flutter_riverpod Notifier 管理应用设置:
/// - 加载/保存设置到 SettingsService
/// - 各设置项的修改方法
/// - 响应式更新 UI
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../services/settings_service.dart';

/// 设置状态 Notifier（对应 marktext usePreferencesStore）
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    // 从 SettingsService 加载初始设置
    final service = ref.read(settingsServiceProvider);
    return service.loadSettings();
  }

  /// 获取 SettingsService 实例
  SettingsService get _service => ref.read(settingsServiceProvider);

  // ============ 通用设置 ============

  /// 设置自动保存
  void setAutoSave(bool value) {
    state = state.copyWith(autoSave: value);
    _service.setSetting('auto_save', value);
  }

  /// 设置自动保存延迟
  void setAutoSaveDelay(int value) {
    state = state.copyWith(autoSaveDelay: value);
    _service.setSetting('auto_save_delay', value);
  }

  /// 设置语言
  void setLanguage(String value) {
    state = state.copyWith(language: value);
    _service.setSetting('language', value);
  }

  /// 设置启动行为
  void setStartUpAction(StartUpAction value) {
    state = state.copyWith(startUpAction: value);
    _service.setSetting('start_up_action', value.index);
  }

  /// 设置侧边栏可见性
  void setSideBarVisibility(bool value) {
    state = state.copyWith(sideBarVisibility: value);
    _service.setSideBarVisibility(value);
  }

  /// 设置是否隐藏滚动条
  void setHideScrollbar(bool value) {
    state = state.copyWith(hideScrollbar: value);
    _service.setSetting('hide_scrollbar', value);
  }

  // ============ 编辑器设置 ============

  /// 设置编辑器字体
  void setEditorFontFamily(String value) {
    state = state.copyWith(editorFontFamily: value);
    _service.setSetting('editor_font_family', value);
  }

  /// 设置字体大小
  void setFontSize(int value) {
    state = state.copyWith(fontSize: value);
    _service.setFontSize(value);
  }

  /// 设置行高
  void setLineHeight(double value) {
    state = state.copyWith(lineHeight: value);
    _service.setSetting('line_height', value);
  }

  /// 设置自动配对括号
  void setAutoPairBracket(bool value) {
    state = state.copyWith(autoPairBracket: value);
    _service.setSetting('auto_pair_bracket', value);
  }

  /// 设置自动配对 Markdown 语法
  void setAutoPairMarkdownSyntax(bool value) {
    state = state.copyWith(autoPairMarkdownSyntax: value);
    _service.setSetting('auto_pair_markdown_syntax', value);
  }

  /// 设置自动配对引号
  void setAutoPairQuote(bool value) {
    state = state.copyWith(autoPairQuote: value);
    _service.setSetting('auto_pair_quote', value);
  }

  /// 设置 Tab 大小
  void setTabSize(int value) {
    state = state.copyWith(tabSize: value);
    _service.setSetting('tab_size', value);
  }

  /// 设置代码字体大小
  void setCodeFontSize(int value) {
    state = state.copyWith(codeFontSize: value);
    _service.setSetting('code_font_size', value);
  }

  /// 设置代码字体
  void setCodeFontFamily(String value) {
    state = state.copyWith(codeFontFamily: value);
    _service.setSetting('code_font_family', value);
  }

  /// 设置是否换行代码块
  void setWrapCodeBlocks(bool value) {
    state = state.copyWith(wrapCodeBlocks: value);
    _service.setSetting('wrap_code_blocks', value);
  }

  // ============ Markdown 设置 ============

  /// 设置有序列表分隔符
  void setOrderListDelimiter(OrderListDelimiter value) {
    state = state.copyWith(orderListDelimiter: value);
    _service.setSetting('order_list_delimiter', value.index);
  }

  /// 设置无序列表标记符
  void setBulletListMarker(BulletListMarker value) {
    state = state.copyWith(bulletListMarker: value);
    _service.setSetting('bullet_list_marker', value.index);
  }

  /// 设置列表缩进方式
  void setListIndentation(String value) {
    state = state.copyWith(listIndentation: value);
    _service.setSetting('list_indentation', value);
  }

  /// 设置是否偏好松散列表
  void setPreferLooseListItem(bool value) {
    state = state.copyWith(preferLooseListItem: value);
    _service.setSetting('prefer_loose_list_item', value);
  }

  /// 设置是否启用上标/下标
  void setSuperSubScript(bool value) {
    state = state.copyWith(superSubScript: value);
    _service.setSetting('super_sub_script', value);
  }

  /// 设置是否启用脚注
  void setFootnote(bool value) {
    state = state.copyWith(footnote: value);
    _service.setSetting('footnote', value);
  }

  /// 设置是否启用 HTML 渲染
  void setIsHtmlEnabled(bool value) {
    state = state.copyWith(isHtmlEnabled: value);
    _service.setSetting('is_html_enabled', value);
  }

  /// 设置是否启用 GitLab 兼容模式
  void setIsGitlabCompatibilityEnabled(bool value) {
    state = state.copyWith(isGitlabCompatibilityEnabled: value);
    _service.setSetting('is_gitlab_compatibility_enabled', value);
  }

  // ============ 主题设置 ============

  /// 设置主题
  void setTheme(String value) {
    state = state.copyWith(theme: value);
    _service.setTheme(value);
  }

  /// 设置是否跟随系统主题
  void setFollowSystemTheme(bool value) {
    state = state.copyWith(followSystemTheme: value);
    _service.setSetting('follow_system_theme', value);
  }

  /// 设置亮色模式主题
  void setLightModeTheme(String value) {
    state = state.copyWith(lightModeTheme: value);
    _service.setSetting('light_mode_theme', value);
  }

  /// 设置暗色模式主题
  void setDarkModeTheme(String value) {
    state = state.copyWith(darkModeTheme: value);
    _service.setSetting('dark_mode_theme', value);
  }

  // ============ 图片设置 ============

  /// 设置图片插入行为
  void setImageInsertAction(ImageInsertAction value) {
    state = state.copyWith(imageInsertAction: value);
    _service.setSetting('image_insert_action', value.index);
  }

  /// 设置是否偏好相对路径图片目录
  void setImagePreferRelativeDirectory(bool value) {
    state = state.copyWith(imagePreferRelativeDirectory: value);
    _service.setSetting('image_prefer_relative_directory', value);
  }

  /// 设置图片相对路径目录名
  void setImageRelativeDirectoryName(String value) {
    state = state.copyWith(imageRelativeDirectoryName: value);
    _service.setSetting('image_relative_directory_name', value);
  }

  // ============ 通用修改方法 ============

  /// 直接更新整个设置对象（用于批量更新）
  void updateSettings(AppSettings newSettings) {
    state = newSettings;
  }
}

/// 设置 Provider
final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
