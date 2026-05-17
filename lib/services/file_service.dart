/// 文件系统服务
/// 参考: marktext/src/main/filesystem/index.js, markdown.js, watcher.js, encoding.js
///
/// 功能:
/// - 文件读写（支持 UTF-8）
/// - 打开文件对话框
/// - 保存/另存为
/// - 新建文件
/// - 文件监视（外部修改检测）
/// - 读取目录结构
/// - 最近文件记录
library;

import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

/// 文件树节点数据模型
class FileTreeNode {
  /// 文件/文件夹的完整路径
  final String pathname;

  /// 名称
  final String name;

  /// 是否为目录
  final bool isDirectory;

  /// 是否为 Markdown 文件
  final bool isMarkdown;

  /// 子文件夹列表
  final List<FileTreeNode> folders;

  /// 子文件列表
  final List<FileTreeNode> files;

  /// 是否折叠（仅对文件夹有意义）
  bool isCollapsed;

  FileTreeNode({
    required this.pathname,
    required this.name,
    required this.isDirectory,
    this.isMarkdown = false,
    this.folders = const [],
    this.files = const [],
    this.isCollapsed = true,
  });

  FileTreeNode copyWith({
    String? pathname,
    String? name,
    bool? isDirectory,
    bool? isMarkdown,
    List<FileTreeNode>? folders,
    List<FileTreeNode>? files,
    bool? isCollapsed,
  }) {
    return FileTreeNode(
      pathname: pathname ?? this.pathname,
      name: name ?? this.name,
      isDirectory: isDirectory ?? this.isDirectory,
      isMarkdown: isMarkdown ?? this.isMarkdown,
      folders: folders ?? this.folders,
      files: files ?? this.files,
      isCollapsed: isCollapsed ?? this.isCollapsed,
    );
  }
}

/// 读取文件的结果（对应 marktext loadMarkdownFile 返回值）
class LoadFileResult {
  /// Markdown 内容
  final String content;

  /// 文件名
  final String filename;

  /// 文件完整路径
  final String pathname;

  /// 检测到的行尾符类型
  final String lineEnding;

  /// 编码
  final String encoding;

  const LoadFileResult({
    required this.content,
    required this.filename,
    required this.pathname,
    this.lineEnding = 'lf',
    this.encoding = 'utf8',
  });
}

/// Markdown 文件扩展名列表
const _markdownExtensions = [
  '.md',
  '.markdown',
  '.mdown',
  '.mkdn',
  '.mkd',
  '.mdwn',
  '.mdtxt',
  '.mdtext',
  '.text',
  '.txt',
];

/// 判断文件是否为 Markdown 文件
bool isMarkdownFile(String pathname) {
  final ext = p.extension(pathname).toLowerCase();
  return _markdownExtensions.contains(ext);
}

/// 文件系统服务（对应 marktext src/main/filesystem/ 模块）
class FileService {
  /// 文件监视器映射: 路径 -> StreamSubscription
  final Map<String, StreamSubscription<FileSystemEvent>> _watchers = {};

  /// 文件修改回调
  void Function(String pathname)? onFileChanged;

  /// 文件删除回调
  void Function(String pathname)? onFileDeleted;

  /// 目录变化回调
  void Function(String dirPath)? onDirectoryChanged;

  // ============ 文件读取 ============

  /// 读取 Markdown 文件（对应 marktext loadMarkdownFile）
  Future<LoadFileResult> loadFile(String pathname) async {
    final file = File(pathname);
    if (!await file.exists()) {
      throw FileSystemException('文件不存在', pathname);
    }

    // 读取文件内容（UTF-8）
    final content = await file.readAsString();

    // 检测行尾符（对应 marktext 的行尾检测逻辑）
    final hasLf = content.contains('\n') &&
        !content.contains('\r\n');
    final hasCrlf = content.contains('\r\n');
    String lineEnding = 'lf';
    if (hasCrlf && !hasLf) {
      lineEnding = 'crlf';
    }

    // 统一转换为 LF（marktext 内部始终使用 LF）
    final normalizedContent = content.replaceAll('\r\n', '\n');

    return LoadFileResult(
      content: normalizedContent,
      filename: p.basename(pathname),
      pathname: pathname,
      lineEnding: lineEnding,
      encoding: 'utf8',
    );
  }

  // ============ 文件保存 ============

  /// 写入文件（对应 marktext writeMarkdownFile）
  Future<void> saveFile(String pathname, String content, {
    String lineEnding = 'lf',
  }) async {
    // 根据行尾设置转换内容
    String outputContent = content;
    if (lineEnding == 'crlf') {
      outputContent = content.replaceAll('\n', '\r\n');
    }

    final file = File(pathname);
    // 确保父目录存在
    await file.parent.create(recursive: true);

    // 写入前忽略自身触发的监视事件
    _ignoreNextChange(pathname);
    await file.writeAsString(outputContent);
  }

  /// 另存为对话框（对应 marktext 的 save-as 功能）
  Future<String?> saveAsDialog({String? defaultFileName}) async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: '另存为',
      fileName: defaultFileName ?? 'untitled.md',
      type: FileType.custom,
      allowedExtensions: ['md', 'markdown', 'txt'],
    );
    return result;
  }

  // ============ 文件打开 ============

  /// 打开文件对话框
  Future<List<String>> openFileDialog() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: '打开文件',
      type: FileType.custom,
      allowedExtensions: ['md', 'markdown', 'mdown', 'mkdn', 'txt'],
      allowMultiple: true,
    );
    if (result == null) return [];
    return result.files
        .where((f) => f.path != null)
        .map((f) => f.path!)
        .toList();
  }

  /// 打开文件夹对话框
  Future<String?> openFolderDialog() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '打开文件夹',
    );
    return result;
  }

  // ============ 目录读取 ============

  /// 读取目录结构为文件树（对应 marktext 的 project tree 数据）
  Future<FileTreeNode> readDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      throw FileSystemException('目录不存在', dirPath);
    }

    final folders = <FileTreeNode>[];
    final files = <FileTreeNode>[];

    await for (final entity in dir.list()) {
      final name = p.basename(entity.path);
      // 跳过隐藏文件/目录和 node_modules
      if (name.startsWith('.') || name == 'node_modules') continue;

      if (entity is Directory) {
        folders.add(FileTreeNode(
          pathname: entity.path,
          name: name,
          isDirectory: true,
          isCollapsed: true,
        ));
      } else if (entity is File) {
        files.add(FileTreeNode(
          pathname: entity.path,
          name: name,
          isDirectory: false,
          isMarkdown: isMarkdownFile(entity.path),
        ));
      }
    }

    // 排序：文件夹按名称，文件按名称
    folders.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    files.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return FileTreeNode(
      pathname: dirPath,
      name: p.basename(dirPath),
      isDirectory: true,
      folders: folders,
      files: files,
      isCollapsed: false,
    );
  }

  /// 展开子目录（懒加载子目录内容）
  Future<FileTreeNode> expandFolder(String dirPath) async {
    return readDirectory(dirPath);
  }

  // ============ 文件监视（对应 marktext watcher.js） ============

  /// 监视文件变化
  void watchFile(String pathname) {
    if (_watchers.containsKey(pathname)) return;

    final file = File(pathname);
    if (!file.existsSync()) return;

    final subscription = file.parent
        .watch(events: FileSystemEvent.all)
        .where((event) => event.path == pathname || p.normalize(event.path) == p.normalize(pathname))
        .listen((event) {
      if (_shouldIgnoreEvent(pathname)) return;

      if (event.type == FileSystemEvent.modify) {
        onFileChanged?.call(pathname);
      } else if (event.type == FileSystemEvent.delete) {
        onFileDeleted?.call(pathname);
      }
    });

    _watchers[pathname] = subscription;
  }

  /// 监视目录变化
  void watchDirectory(String dirPath) {
    if (_watchers.containsKey(dirPath)) return;

    final dir = Directory(dirPath);
    if (!dir.existsSync()) return;

    final subscription = dir
        .watch(events: FileSystemEvent.all, recursive: true)
        .listen((event) {
      onDirectoryChanged?.call(dirPath);
    });

    _watchers[dirPath] = subscription;
  }

  /// 取消监视文件
  void unwatchFile(String pathname) {
    _watchers[pathname]?.cancel();
    _watchers.remove(pathname);
  }

  /// 取消监视目录
  void unwatchDirectory(String dirPath) {
    _watchers[dirPath]?.cancel();
    _watchers.remove(dirPath);
  }

  /// 取消所有监视
  void unwatchAll() {
    for (final sub in _watchers.values) {
      sub.cancel();
    }
    _watchers.clear();
    _ignoreSet.clear();
  }

  // ============ 文件操作 ============

  /// 新建文件
  Future<String> createFile(String dirPath, String filename) async {
    final filePath = p.join(dirPath, filename);
    final file = File(filePath);
    if (await file.exists()) {
      throw FileSystemException('文件已存在', filePath);
    }
    await file.create(recursive: true);
    await file.writeAsString('');
    return filePath;
  }

  /// 重命名文件/目录
  Future<String> rename(String oldPath, String newName) async {
    final parent = p.dirname(oldPath);
    final newPath = p.join(parent, newName);
    final entity = FileSystemEntity.typeSync(oldPath) == FileSystemEntityType.directory
        ? Directory(oldPath)
        : File(oldPath) as FileSystemEntity;

    await (entity as dynamic).rename(newPath);
    return newPath;
  }

  /// 删除文件/目录
  Future<void> delete(String pathname) async {
    final type = FileSystemEntity.typeSync(pathname);
    if (type == FileSystemEntityType.directory) {
      await Directory(pathname).delete(recursive: true);
    } else if (type == FileSystemEntityType.file) {
      await File(pathname).delete();
    }
  }

  /// 判断路径是否存在
  Future<bool> exists(String pathname) async {
    return FileSystemEntity.type(pathname) != FileSystemEntityType.notFound;
  }

  // ============ 忽略自身写入触发的事件 ============

  final Set<String> _ignoreSet = {};

  void _ignoreNextChange(String pathname) {
    _ignoreSet.add(pathname);
    // 1.5 秒后移除忽略（对应 marktext WATCHER_STABILITY_THRESHOLD）
    Future.delayed(const Duration(milliseconds: 1500), () {
      _ignoreSet.remove(pathname);
    });
  }

  bool _shouldIgnoreEvent(String pathname) {
    if (_ignoreSet.contains(pathname)) {
      _ignoreSet.remove(pathname);
      return true;
    }
    return false;
  }
}
