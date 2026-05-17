/// 文件服务单元测试
/// 测试文件读写和路径处理
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_markdown_editor/services/file_service.dart';

void main() {
  late FileService fileService;
  late Directory tempDir;

  setUp(() {
    fileService = FileService();
    tempDir = Directory.systemTemp.createTempSync('file_service_test_');
  });

  tearDown(() {
    fileService.unwatchAll();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('FileService', () {
    group('loadFile', () {
      test('应正确读取 UTF-8 文件', () async {
        final file = File('${tempDir.path}/test.md');
        await file.writeAsString('# Hello\nWorld');

        final result = await fileService.loadFile(file.path);
        expect(result.content, '# Hello\nWorld');
        expect(result.filename, 'test.md');
        expect(result.encoding, 'utf8');
      });

      test('应检测 LF 行尾', () async {
        final file = File('${tempDir.path}/lf.md');
        await file.writeAsString('line1\nline2\n');

        final result = await fileService.loadFile(file.path);
        expect(result.lineEnding, 'lf');
      });

      test('应检测 CRLF 行尾', () async {
        final file = File('${tempDir.path}/crlf.md');
        await file.writeAsString('line1\r\nline2\r\n');

        final result = await fileService.loadFile(file.path);
        expect(result.lineEnding, 'crlf');
        // 内容应统一为 LF
        expect(result.content, 'line1\nline2\n');
      });

      test('读取不存在的文件应抛出异常', () async {
        expect(
          () => fileService.loadFile('${tempDir.path}/nonexistent.md'),
          throwsA(isA<FileSystemException>()),
        );
      });
    });

    group('saveFile', () {
      test('应正确写入文件', () async {
        final filePath = '${tempDir.path}/output.md';
        await fileService.saveFile(filePath, '# Test Content');

        final file = File(filePath);
        expect(await file.exists(), isTrue);
        expect(await file.readAsString(), '# Test Content');
      });

      test('应使用 CRLF 行尾写入', () async {
        final filePath = '${tempDir.path}/crlf_out.md';
        await fileService.saveFile(filePath, 'line1\nline2', lineEnding: 'crlf');

        final file = File(filePath);
        final content = await file.readAsString();
        expect(content, 'line1\r\nline2');
      });

      test('应自动创建父目录', () async {
        final filePath = '${tempDir.path}/sub/dir/file.md';
        await fileService.saveFile(filePath, 'nested');

        expect(await File(filePath).exists(), isTrue);
      });
    });

    group('readDirectory', () {
      test('应正确读取目录结构', () async {
        // 创建测试文件和目录
        await File('${tempDir.path}/file1.md').writeAsString('');
        await File('${tempDir.path}/file2.txt').writeAsString('');
        await Directory('${tempDir.path}/subdir').create();

        final tree = await fileService.readDirectory(tempDir.path);
        expect(tree.isDirectory, isTrue);
        expect(tree.folders.length, 1);
        expect(tree.files.length, 2);
      });

      test('应跳过隐藏文件', () async {
        await File('${tempDir.path}/.hidden').writeAsString('');
        await File('${tempDir.path}/visible.md').writeAsString('');

        final tree = await fileService.readDirectory(tempDir.path);
        expect(tree.files.length, 1);
        expect(tree.files.first.name, 'visible.md');
      });

      test('读取不存在的目录应抛出异常', () async {
        expect(
          () => fileService.readDirectory('${tempDir.path}/nonexistent'),
          throwsA(isA<FileSystemException>()),
        );
      });
    });

    group('createFile', () {
      test('应创建新文件', () async {
        final path = await fileService.createFile(tempDir.path, 'new.md');
        expect(await File(path).exists(), isTrue);
      });

      test('创建已存在的文件应抛出异常', () async {
        await File('${tempDir.path}/existing.md').writeAsString('');
        expect(
          () => fileService.createFile(tempDir.path, 'existing.md'),
          throwsA(isA<FileSystemException>()),
        );
      });
    });

    group('isMarkdownFile', () {
      test('.md 应识别为 Markdown', () {
        expect(isMarkdownFile('test.md'), isTrue);
      });

      test('.markdown 应识别为 Markdown', () {
        expect(isMarkdownFile('file.markdown'), isTrue);
      });

      test('.txt 应识别为 Markdown', () {
        expect(isMarkdownFile('notes.txt'), isTrue);
      });

      test('.dart 不应识别为 Markdown', () {
        expect(isMarkdownFile('main.dart'), isFalse);
      });

      test('.pdf 不应识别为 Markdown', () {
        expect(isMarkdownFile('doc.pdf'), isFalse);
      });
    });

    group('exists', () {
      test('存在的文件应返回 true', () async {
        await File('${tempDir.path}/exists.md').writeAsString('');
        expect(await fileService.exists('${tempDir.path}/exists.md'), isTrue);
      });

      test('不存在的文件应返回 false', () async {
        expect(
          await fileService.exists('${tempDir.path}/nope.md'),
          isFalse,
        );
      });
    });
  });
}
