/// 编码服务测试
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:markflowy/services/encoding_service.dart';

void main() {
  group('EncodingService', () {
    late EncodingService service;

    setUp(() {
      service = EncodingService();
    });

    group('detectByBom', () {
      test('应检测 UTF-8 BOM', () {
        final bytes = [0xEF, 0xBB, 0xBF, 0x48, 0x65, 0x6C, 0x6C, 0x6F];
        final result = service.detectByBom(bytes);
        expect(result, 'utf8');
      });

      test('应检测 UTF-16 BE BOM', () {
        final bytes = [0xFE, 0xFF, 0x00, 0x48];
        final result = service.detectByBom(bytes);
        expect(result, 'utf16-be');
      });

      test('应检测 UTF-16 LE BOM', () {
        final bytes = [0xFF, 0xFE, 0x48, 0x00];
        final result = service.detectByBom(bytes);
        expect(result, 'utf16-le');
      });

      test('无 BOM 应返回 null', () {
        final bytes = [0x48, 0x65, 0x6C, 0x6C, 0x6F];
        final result = service.detectByBom(bytes);
        expect(result, isNull);
      });
    });

    group('detectEncoding', () {
      test('UTF-8 纯英文文本', () {
        final text = 'Hello World';
        final bytes = utf8.encode(text);
        final result = service.detectEncoding(bytes);
        expect(result.text, text);
        expect(result.encoding, 'utf8');
        expect(result.confidence, greaterThan(0.8));
      });

      test('UTF-8 中文文本', () {
        final text = '你好世界';
        final bytes = utf8.encode(text);
        final result = service.detectEncoding(bytes);
        expect(result.text, text);
        expect(result.encoding, 'utf8');
      });

      test('UTF-8 BOM 文本', () {
        final text = 'Hello';
        final bytes = [0xEF, 0xBB, 0xBF, ...utf8.encode(text)];
        final result = service.detectEncoding(bytes);
        expect(result.text, text);
        expect(result.encoding, 'utf8');
        expect(result.confidence, 1.0);
      });

      test('Latin-1 兜底编码', () {
        // 使用不是有效 UTF-8 且不含 BOM 的字节序列
        final bytes = [0x80, 0x81, 0x82, 0x48, 0x65, 0x6C, 0x6C, 0x6F];
        final result = service.detectEncoding(bytes);
        expect(result.encoding, isNotEmpty);
        expect(result.text, isNotEmpty);
      });

      test('空字节数组', () {
        final bytes = <int>[];
        final result = service.detectEncoding(bytes);
        expect(result.text, isEmpty);
      });
    });

    group('supportedEncodings', () {
      test('应包含常见编码', () {
        expect(
          EncodingService.supportedEncodings,
          containsAll(['utf8', 'gbk', 'big5', 'latin1']),
        );
      });
    });
  });
}
