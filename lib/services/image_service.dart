/// 图片处理服务
/// 参考: marktext/src/muya/lib/contentState/imageCtrl.js
///       marktext/src/renderer/src/components/editorWithTabs/imageViewer.vue
///
/// 支持三种图片插入模式（对应 marktext imageInsertAction）:
/// - upload: 上传到云端（预留接口）
/// - folder: 复制到文档同级文件夹
/// - path: 仅引用路径
library;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../models/app_settings.dart';

/// 图片插入结果
class ImageInsertResult {
  /// 插入到 Markdown 中的路径/URL
  final String markdownPath;

  /// 图片的绝对路径（本地文件时）
  final String? absolutePath;

  /// 是否为相对路径
  final bool isRelative;

  const ImageInsertResult({
    required this.markdownPath,
    this.absolutePath,
    this.isRelative = false,
  });

  /// 生成 Markdown 图片语法
  String toMarkdown({String alt = 'image'}) {
    return '![$alt]($markdownPath)';
  }
}

/// 图片验证结果
class ImageValidationResult {
  final bool isValid;
  final String? errorMessage;
  final int? width;
  final int? height;
  final int? fileSize;

  const ImageValidationResult({
    this.isValid = true,
    this.errorMessage,
    this.width,
    this.height,
    this.fileSize,
  });
}

/// 图片服务 — 处理图片选择、验证、路径管理
class ImageService {
  /// 支持的图片格式
  static const supportedExtensions = [
    'png', 'jpg', 'jpeg', 'gif', 'bmp',
    'webp', 'svg', 'ico', 'tiff', 'tif',
  ];

  /// 最大文件大小（10MB）
  static const maxFileSize = 10 * 1024 * 1024;

  /// 通过文件选择器选择图片
  Future<ImageInsertResult?> pickImage({
    ImageInsertAction action = ImageInsertAction.path,
    String? documentPath,
    String? relativeDirName,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: supportedExtensions,
      withData: false,
      withReadStream: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final pickedPath = file.path;
    if (pickedPath == null) return null;

    // 验证图片
    final validation = await validateImage(pickedPath);
    if (!validation.isValid) return null;

    return _processImage(
      pickedPath,
      file.name,
      action: action,
      documentPath: documentPath,
      relativeDirName: relativeDirName,
    );
  }

  /// 从文件路径处理图片插入
  Future<ImageInsertResult> processImageFile(
    String imagePath, {
    ImageInsertAction action = ImageInsertAction.path,
    String? documentPath,
    String? relativeDirName,
  }) async {
    final fileName = p.basename(imagePath);
    return _processImage(
      imagePath,
      fileName,
      action: action,
      documentPath: documentPath,
      relativeDirName: relativeDirName,
    );
  }

  /// 核心图片处理逻辑
  Future<ImageInsertResult> _processImage(
    String sourcePath,
    String fileName, {
    ImageInsertAction action = ImageInsertAction.path,
    String? documentPath,
    String? relativeDirName,
  }) async {
    switch (action) {
      case ImageInsertAction.folder:
        return _copyToFolder(
          sourcePath,
          fileName,
          documentPath: documentPath,
          relativeDirName: relativeDirName,
        );

      case ImageInsertAction.path:
        return _useAsPath(
          sourcePath,
          documentPath: documentPath,
        );

      case ImageInsertAction.upload:
        // 上传功能预留，当前回退到 path 模式
        return _useAsPath(
          sourcePath,
          documentPath: documentPath,
        );
    }
  }

  /// 复制图片到文档同级文件夹
  Future<ImageInsertResult> _copyToFolder(
    String sourcePath,
    String fileName, {
    String? documentPath,
    String? relativeDirName,
  }) async {
    final dirName = relativeDirName ?? 'assets';

    if (documentPath != null) {
      // 在文档所在目录创建 assets 文件夹
      final docDir = p.dirname(documentPath);
      final targetDir = Directory(p.join(docDir, dirName));
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // 复制文件（处理重名）
      final targetPath = await _copyWithUniqueName(
        sourcePath,
        p.join(targetDir.path, fileName),
      );

      return ImageInsertResult(
        markdownPath: '$dirName/${p.basename(targetPath)}',
        absolutePath: targetPath,
        isRelative: true,
      );
    } else {
      // 无文档路径时，仅引用原路径
      return ImageInsertResult(
        markdownPath: sourcePath,
        absolutePath: sourcePath,
      );
    }
  }

  /// 使用路径引用模式（支持相对路径）
  ImageInsertResult _useAsPath(
    String sourcePath, {
    String? documentPath,
  }) {
    if (documentPath != null) {
      try {
        // 尝试生成相对于文档的路径
        final docDir = p.dirname(documentPath);
        final relativePath = p.relative(sourcePath, from: docDir);
        return ImageInsertResult(
          markdownPath: relativePath,
          absolutePath: sourcePath,
          isRelative: true,
        );
      } catch (_) {
        // 无法生成相对路径时使用绝对路径
      }
    }
    return ImageInsertResult(
      markdownPath: sourcePath,
      absolutePath: sourcePath,
    );
  }

  /// 复制文件并处理重名（添加数字后缀）
  Future<String> _copyWithUniqueName(
    String sourcePath,
    String targetPath,
  ) async {
    var finalPath = targetPath;
    var counter = 1;
    final ext = p.extension(targetPath);
    final baseName = p.basenameWithoutExtension(targetPath);
    final dir = p.dirname(targetPath);

    while (await File(finalPath).exists()) {
      finalPath = p.join(dir, '${baseName}_$counter$ext');
      counter++;
    }

    await File(sourcePath).copy(finalPath);
    return finalPath;
  }

  /// 验证图片文件
  Future<ImageValidationResult> validateImage(String imagePath) async {
    final file = File(imagePath);

    // 检查文件是否存在
    if (!await file.exists()) {
      return const ImageValidationResult(
        isValid: false,
        errorMessage: '图片文件不存在',
      );
    }

    // 检查文件大小
    final fileSize = await file.length();
    if (fileSize > maxFileSize) {
      return ImageValidationResult(
        isValid: false,
        errorMessage: '图片文件过大（最大 10MB）',
        fileSize: fileSize,
      );
    }

    // 检查扩展名
    final ext = p.extension(imagePath).replaceAll('.', '').toLowerCase();
    if (!supportedExtensions.contains(ext)) {
      return ImageValidationResult(
        isValid: false,
        errorMessage: '不支持的图片格式: .$ext',
        fileSize: fileSize,
      );
    }

    return ImageValidationResult(
      isValid: true,
      fileSize: fileSize,
    );
  }

  /// 判断是否为支持的图片文件
  static bool isImageFile(String filePath) {
    final ext = p.extension(filePath).replaceAll('.', '').toLowerCase();
    return supportedExtensions.contains(ext);
  }
}
