/// macOS 文件打开事件服务
///
/// AppDelegate.swift 通过 MethodChannel 将文件路径发送到 Flutter，
/// 这里暂存路径供 EditorScreen 启动后消费。
library;

/// 待打开的文件路径
String? _pendingOpenFile;

/// 设置待打开文件（由 main.dart 的 MethodChannel handler 调用）
void setPendingOpenFile(String path) {
  _pendingOpenFile = path;
}

/// 获取并清除待打开的文件路径
String? consumePendingOpenFile() {
  final path = _pendingOpenFile;
  _pendingOpenFile = null;
  return path;
}
