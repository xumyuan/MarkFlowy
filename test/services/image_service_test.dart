/// 图片服务测试
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:markflowy/services/image_service.dart';

void main() {
  group('ImageService', () {
    late ImageService service;

    setUp(() {
      service = ImageService();
    });

    group('isImageFile', () {
      test('应识别 png 文件', () {
        expect(ImageService.isImageFile('image.png'), isTrue);
      });

      test('应识别 jpg 文件', () {
        expect(ImageService.isImageFile('photo.jpg'), isTrue);
        expect(ImageService.isImageFile('photo.jpeg'), isTrue);
      });

      test('应识别 gif 文件', () {
        expect(ImageService.isImageFile('animation.gif'), isTrue);
      });

      test('应识别 svg 文件', () {
        expect(ImageService.isImageFile('icon.svg'), isTrue);
      });

      test('应拒绝非图片文件', () {
        expect(ImageService.isImageFile('document.md'), isFalse);
        expect(ImageService.isImageFile('file.txt'), isFalse);
        expect(ImageService.isImageFile('code.dart'), isFalse);
      });
    });

    group('validateImage', () {
      test('不存在的文件应返回无效', () async {
        final result = await service.validateImage('/tmp/nonexistent_image.png');
        expect(result.isValid, isFalse);
        expect(result.errorMessage, isNotNull);
      });

      test('支持的扩展名应返回有效', () async {
        // 创建一个临时测试图片文件
        final tempFile = File('/tmp/test_image.png');
        await tempFile.writeAsBytes([0x89, 0x50, 0x4E, 0x47]); // PNG header
        try {
          final result = await service.validateImage(tempFile.path);
          expect(result.isValid, isTrue);
          expect(result.fileSize, greaterThan(0));
        } finally {
          await tempFile.delete();
        }
      });
    });

    group('ImageInsertResult', () {
      test('toMarkdown 应生成正确语法', () {
        const result = ImageInsertResult(markdownPath: 'images/photo.png');
        // 默认 alt 为 'image'
        expect(result.toMarkdown(), '![image](images/photo.png)');
      });

      test('toMarkdown 应包含 alt 文本', () {
        const result = ImageInsertResult(markdownPath: 'photo.jpg');
        expect(
          result.toMarkdown(alt: 'My Photo'),
          '![My Photo](photo.jpg)',
        );
      });

      test('应支持绝对路径', () {
        const result = ImageInsertResult(
          markdownPath: '/Users/user/images/photo.png',
          absolutePath: '/Users/user/images/photo.png',
        );
        expect(result.isRelative, isFalse);
        expect(result.markdownPath, startsWith('/'));
      });

      test('应支持相对路径', () {
        const result = ImageInsertResult(
          markdownPath: 'assets/photo.png',
          isRelative: true,
        );
        expect(result.isRelative, isTrue);
      });
    });

    group('supportedExtensions', () {
      test('应包含常见图片格式', () {
        expect(ImageService.supportedExtensions, contains('png'));
        expect(ImageService.supportedExtensions, contains('jpg'));
        expect(ImageService.supportedExtensions, contains('webp'));
        expect(ImageService.supportedExtensions, contains('svg'));
      });
    });
  });
}
