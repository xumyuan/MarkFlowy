/// 设置持久化服务
/// 参考: marktext/src/main/preferences/index.js
///
/// 使用 shared_preferences 实现应用设置和最近文件记录的持久化存储。
library;

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

/// SharedPreferences key 常量
const _kRecentFiles = 'recent_files';
const _kRecentFolders = 'recent_folders';
const _kLastOpenedFolder = 'last_opened_folder';
const _kWindowWidth = 'window_width';
const _kWindowHeight = 'window_height';
const _kWindowX = 'window_x';
const _kWindowY = 'window_y';
const _kIsMaximized = 'is_maximized';
const _kAutoSave = 'auto_save';
const _kAutoSaveDelay = 'auto_save_delay';
const _kTheme = 'theme';
const _kFontSize = 'font_size';
const _kSideBarVisibility = 'side_bar_visibility';
const _kTabBarVisibility = 'tab_bar_visibility';
const _kMaxRecentFiles = 20;

/// 窗口状态
class WindowState {
  final double width;
  final double height;
  final double? x;
  final double? y;
  final bool isMaximized;

  const WindowState({
    this.width = 950,
    this.height = 650,
    this.x,
    this.y,
    this.isMaximized = false,
  });
}

/// 设置服务（对应 marktext Preference 类）
class SettingsService {
  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  // ============ 应用设置 ============

  /// 加载应用设置
  AppSettings loadSettings() {
    return AppSettings(
      autoSave: _prefs.getBool(_kAutoSave) ?? false,
      autoSaveDelay: _prefs.getInt(_kAutoSaveDelay) ?? 5000,
      theme: _prefs.getString(_kTheme) ?? 'light',
      fontSize: _prefs.getInt(_kFontSize) ?? 16,
      sideBarVisibility: _prefs.getBool(_kSideBarVisibility) ?? false,
      tabBarVisibility: _prefs.getBool(_kTabBarVisibility) ?? true,
      lastOpenedFolder: _prefs.getString(_kLastOpenedFolder) ?? '',
    );
  }

  /// 保存单个设置项（对应 marktext setItem）
  Future<void> setSetting(String key, dynamic value) async {
    if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    }
  }

  /// 保存自动保存设置
  Future<void> setAutoSave(bool value) async {
    await _prefs.setBool(_kAutoSave, value);
  }

  /// 保存主题设置
  Future<void> setTheme(String theme) async {
    await _prefs.setString(_kTheme, theme);
  }

  /// 保存字体大小
  Future<void> setFontSize(int size) async {
    await _prefs.setInt(_kFontSize, size);
  }

  /// 保存侧边栏可见性
  Future<void> setSideBarVisibility(bool visible) async {
    await _prefs.setBool(_kSideBarVisibility, visible);
  }

  // ============ 最近文件 ============

  /// 获取最近打开的文件列表
  List<String> getRecentFiles() {
    final json = _prefs.getString(_kRecentFiles);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.cast<String>();
  }

  /// 添加文件到最近列表
  Future<void> addRecentFile(String filePath) async {
    final files = getRecentFiles();
    // 移除重复项
    files.remove(filePath);
    // 添加到头部
    files.insert(0, filePath);
    // 限制最大数量
    if (files.length > _kMaxRecentFiles) {
      files.removeRange(_kMaxRecentFiles, files.length);
    }
    await _prefs.setString(_kRecentFiles, jsonEncode(files));
  }

  /// 从最近列表中移除文件
  Future<void> removeRecentFile(String filePath) async {
    final files = getRecentFiles();
    files.remove(filePath);
    await _prefs.setString(_kRecentFiles, jsonEncode(files));
  }

  /// 清空最近文件列表
  Future<void> clearRecentFiles() async {
    await _prefs.setString(_kRecentFiles, jsonEncode([]));
  }

  // ============ 最近文件夹 ============

  /// 获取最近打开的文件夹列表
  List<String> getRecentFolders() {
    final json = _prefs.getString(_kRecentFolders);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.cast<String>();
  }

  /// 添加文件夹到最近列表
  Future<void> addRecentFolder(String folderPath) async {
    final folders = getRecentFolders();
    folders.remove(folderPath);
    folders.insert(0, folderPath);
    if (folders.length > _kMaxRecentFiles) {
      folders.removeRange(_kMaxRecentFiles, folders.length);
    }
    await _prefs.setString(_kRecentFolders, jsonEncode(folders));
  }

  /// 保存最后打开的文件夹
  Future<void> setLastOpenedFolder(String path) async {
    await _prefs.setString(_kLastOpenedFolder, path);
  }

  /// 获取最后打开的文件夹
  String getLastOpenedFolder() {
    return _prefs.getString(_kLastOpenedFolder) ?? '';
  }

  // ============ 窗口状态 ============

  /// 保存窗口状态
  Future<void> saveWindowState(WindowState state) async {
    await _prefs.setDouble(_kWindowWidth, state.width);
    await _prefs.setDouble(_kWindowHeight, state.height);
    if (state.x != null) await _prefs.setDouble(_kWindowX, state.x!);
    if (state.y != null) await _prefs.setDouble(_kWindowY, state.y!);
    await _prefs.setBool(_kIsMaximized, state.isMaximized);
  }

  /// 加载窗口状态
  WindowState loadWindowState() {
    return WindowState(
      width: _prefs.getDouble(_kWindowWidth) ?? 950,
      height: _prefs.getDouble(_kWindowHeight) ?? 650,
      x: _prefs.getDouble(_kWindowX),
      y: _prefs.getDouble(_kWindowY),
      isMaximized: _prefs.getBool(_kIsMaximized) ?? false,
    );
  }
}

/// SettingsService Provider
final settingsServiceProvider = Provider<SettingsService>((ref) {
  // 需要在 main.dart 中使用 ProviderScope override 提供实例
  throw UnimplementedError(
    'settingsServiceProvider 需要在 ProviderScope 中 override',
  );
});
