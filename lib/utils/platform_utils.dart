/// 平台工具类
/// 参考: marktext/src/main/app/env.js 和 marktext/src/main/app/paths.js
///       marktext/src/common/envPaths.js
///
/// 提供跨平台的路径管理和环境信息。
library;

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// 平台检测（对应 marktext config.js 中的 isOsx/isWindows/isLinux）
bool get isDesktop => Platform.isMacOS || Platform.isWindows || Platform.isLinux;
bool get isMobile => Platform.isIOS || Platform.isAndroid;

/// 应用环境信息（对应 marktext AppEnvironment 类）
class AppEnvironment {
  /// 应用路径管理
  final AppPaths paths;

  /// 是否为调试模式
  final bool debug;

  /// 是否为开发模式
  final bool isDevMode;

  const AppEnvironment({
    required this.paths,
    this.debug = false,
    this.isDevMode = false,
  });
}

/// 应用路径管理（对应 marktext AppPaths / EnvPaths）
/// 管理用户数据、日志、配置文件等路径
class AppPaths {
  /// 用户数据根目录（对应 userDataPath）
  final String userDataPath;

  /// 日志目录（对应 logPath）
  late final String logPath;

  /// 配置文件目录（对应 preferencesPath）
  late final String preferencesPath;

  /// 编辑器缓冲区存储目录（对应 editorBufferStorePath）
  late final String editorBufferStorePath;

  /// 配置文件路径（对应 preferencesFilePath）
  late final String preferencesFilePath;

  AppPaths(this.userDataPath) {
    final now = DateTime.now();
    final monthStr = '${now.year}${now.month}';

    logPath = p.join(userDataPath, 'logs', monthStr);
    preferencesPath = userDataPath;
    editorBufferStorePath = p.join(userDataPath, 'editorStates');
    preferencesFilePath = p.join(preferencesPath, 'preference.json');
  }
}

/// 初始化应用环境（对应 marktext setupEnvironment）
Future<AppEnvironment> setupEnvironment({bool debug = false}) async {
  // 获取平台对应的应用数据目录
  final appDocDir = await getApplicationDocumentsDirectory();
  final userDataPath = p.join(appDocDir.path, 'FlutterMarkdownEditor');

  final paths = AppPaths(userDataPath);

  // 确保必要的目录存在（对应 marktext ensureAppDirectoriesSync）
  await _ensureAppDirectories(paths);

  return AppEnvironment(
    paths: paths,
    debug: debug,
    isDevMode: debug,
  );
}

/// 确保应用所需目录存在（对应 marktext ensureAppDirectoriesSync）
Future<void> _ensureAppDirectories(AppPaths paths) async {
  final dirs = [
    paths.userDataPath,
    paths.logPath,
    paths.editorBufferStorePath,
  ];

  for (final dir in dirs) {
    final directory = Directory(dir);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
  }
}
