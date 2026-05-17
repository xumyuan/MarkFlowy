/// 文件状态管理 Provider
/// 参考: marktext/src/renderer/src/store/project.js + editor.js (Pinia stores)
///
/// 管理:
/// - 当前打开的项目/文件夹路径
/// - 打开的文件列表
/// - 当前活动文件
/// - 文件树节点数据
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/document.dart';
import '../services/file_service.dart';

/// 文件状态（对应 marktext project store + editor store 中的文件相关状态）
class FileState {
  /// 当前打开的项目文件夹路径（对应 marktext projectTree.pathname）
  final String? projectPath;

  /// 文件树根节点
  final FileTreeNode? projectTree;

  /// 打开的文件列表（与 TabBarState.tabs 同步）
  final List<Document> openedFiles;

  /// 当前活动文件路径
  final String? activeFilePath;

  /// 最近打开的文件列表
  final List<String> recentFiles;

  /// 是否正在加载目录
  final bool isLoading;

  const FileState({
    this.projectPath,
    this.projectTree,
    this.openedFiles = const [],
    this.activeFilePath,
    this.recentFiles = const [],
    this.isLoading = false,
  });

  FileState copyWith({
    String? Function()? projectPath,
    FileTreeNode? Function()? projectTree,
    List<Document>? openedFiles,
    String? Function()? activeFilePath,
    List<String>? recentFiles,
    bool? isLoading,
  }) {
    return FileState(
      projectPath: projectPath != null ? projectPath() : this.projectPath,
      projectTree: projectTree != null ? projectTree() : this.projectTree,
      openedFiles: openedFiles ?? this.openedFiles,
      activeFilePath:
          activeFilePath != null ? activeFilePath() : this.activeFilePath,
      recentFiles: recentFiles ?? this.recentFiles,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 文件状态 Notifier（对应 marktext useProjectStore + useEditorStore 中的文件 actions）
class FileNotifier extends Notifier<FileState> {
  late final FileService _fileService;

  @override
  FileState build() {
    _fileService = ref.read(fileServiceProvider);
    return const FileState();
  }

  /// 打开文件夹（对应 marktext ASK_FOR_OPEN_PROJECT）
  Future<void> openFolder([String? folderPath]) async {
    final path = folderPath ?? await _fileService.openFolderDialog();
    if (path == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final tree = await _fileService.readDirectory(path);
      _fileService.watchDirectory(path);

      state = state.copyWith(
        projectPath: () => path,
        projectTree: () => tree,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 刷新文件树
  Future<void> refreshTree() async {
    final path = state.projectPath;
    if (path == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final tree = await _fileService.readDirectory(path);
      state = state.copyWith(
        projectTree: () => tree,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 展开文件夹节点（对应 marktext folder click 展开）
  Future<FileTreeNode?> expandFolder(String dirPath) async {
    try {
      return await _fileService.expandFolder(dirPath);
    } catch (e) {
      return null;
    }
  }

  /// 关闭项目文件夹
  void closeFolder() {
    if (state.projectPath != null) {
      _fileService.unwatchDirectory(state.projectPath!);
    }
    state = state.copyWith(
      projectPath: () => null,
      projectTree: () => null,
    );
  }

  /// 打开文件（对应 marktext mt::open-file）
  Future<Document?> openFile([String? filePath]) async {
    String? path = filePath;
    if (path == null) {
      final paths = await _fileService.openFileDialog();
      if (paths.isEmpty) return null;
      path = paths.first;
    }

    // 检查是否已打开
    final existing = state.openedFiles.where((f) => f.filePath == path).firstOrNull;
    if (existing != null) {
      state = state.copyWith(activeFilePath: () => path);
      return existing;
    }

    try {
      final result = await _fileService.loadFile(path);
      final doc = Document(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filePath: result.pathname,
        filename: result.filename,
        content: result.content,
        isSaved: true,
        encoding: result.encoding,
        lineEnding: result.lineEnding,
        createdAt: DateTime.now(),
        lastModifiedAt: DateTime.now(),
      );

      // 监视文件
      _fileService.watchFile(path);

      state = state.copyWith(
        openedFiles: [...state.openedFiles, doc],
        activeFilePath: () => path,
      );

      // 添加到最近文件
      _addRecentFile(path);

      return doc;
    } catch (e) {
      return null;
    }
  }

  /// 保存文件（对应 marktext saveFile）
  Future<bool> saveFile(Document doc) async {
    if (doc.filePath.isEmpty) {
      return saveFileAs(doc);
    }

    try {
      await _fileService.saveFile(
        doc.filePath,
        doc.content,
        lineEnding: doc.lineEnding,
      );

      // 更新文档状态为已保存
      final updatedFiles = state.openedFiles.map((f) {
        if (f.id == doc.id) {
          return f.copyWith(isSaved: true, lastModifiedAt: DateTime.now());
        }
        return f;
      }).toList();

      state = state.copyWith(openedFiles: updatedFiles);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 另存为（对应 marktext save-as）
  Future<bool> saveFileAs(Document doc) async {
    final path = await _fileService.saveAsDialog(
      defaultFileName: doc.filename,
    );
    if (path == null) return false;

    try {
      await _fileService.saveFile(path, doc.content, lineEnding: doc.lineEnding);

      // 更新文档路径和保存状态
      final updatedFiles = state.openedFiles.map((f) {
        if (f.id == doc.id) {
          return f.copyWith(
            filePath: path,
            filename: path.split('/').last,
            isSaved: true,
            lastModifiedAt: DateTime.now(),
          );
        }
        return f;
      }).toList();

      state = state.copyWith(
        openedFiles: updatedFiles,
        activeFilePath: () => path,
      );

      _addRecentFile(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 关闭文件
  void closeFile(String docId) {
    final doc = state.openedFiles.where((f) => f.id == docId).firstOrNull;
    if (doc != null && doc.filePath.isNotEmpty) {
      _fileService.unwatchFile(doc.filePath);
    }

    final updatedFiles = state.openedFiles.where((f) => f.id != docId).toList();
    String? newActivePath = state.activeFilePath;

    if (doc?.filePath == state.activeFilePath) {
      newActivePath = updatedFiles.isNotEmpty ? updatedFiles.last.filePath : null;
    }

    state = state.copyWith(
      openedFiles: updatedFiles,
      activeFilePath: () => newActivePath,
    );
  }

  /// 更新文档内容（标记为未保存）
  void updateDocumentContent(String docId, String content) {
    final updatedFiles = state.openedFiles.map((f) {
      if (f.id == docId) {
        return f.copyWith(content: content, isSaved: false);
      }
      return f;
    }).toList();
    state = state.copyWith(openedFiles: updatedFiles);
  }

  /// 设置活动文件
  void setActiveFile(String? filePath) {
    state = state.copyWith(activeFilePath: () => filePath);
  }

  /// 创建新文件（在项目目录中）
  Future<void> createFileInProject(String dirPath, String filename) async {
    try {
      await _fileService.createFile(dirPath, filename);
      // 刷新文件树
      await refreshTree();
    } catch (e) {
      // 文件已存在或其他错误
    }
  }

  /// 重命名文件/目录
  Future<void> renameItem(String oldPath, String newName) async {
    try {
      await _fileService.rename(oldPath, newName);
      await refreshTree();
    } catch (e) {
      // 重命名失败
    }
  }

  /// 删除文件/目录
  Future<void> deleteItem(String pathname) async {
    try {
      await _fileService.delete(pathname);
      await refreshTree();
    } catch (e) {
      // 删除失败
    }
  }

  /// 设置最近文件列表
  void setRecentFiles(List<String> files) {
    state = state.copyWith(recentFiles: files);
  }

  void _addRecentFile(String path) {
    final files = List<String>.from(state.recentFiles);
    files.remove(path);
    files.insert(0, path);
    if (files.length > 20) {
      files.removeRange(20, files.length);
    }
    state = state.copyWith(recentFiles: files);
  }
}

/// FileService Provider
final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});

/// 文件状态 Provider
final fileProvider =
    NotifierProvider<FileNotifier, FileState>(FileNotifier.new);
