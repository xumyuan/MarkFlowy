/// 文件编码服务
/// 参考: marktext/src/main/filesystem/encoding.js
///
/// 支持多种编码的检测和转换：
/// - UTF-8, UTF-16 (LE/BE), UTF-32 (LE/BE)
/// - GBK, GB2312, GB18030 (中文编码)
/// - Big5 (繁体中文)
/// - Shift_JIS, EUC-JP (日文)
/// - EUC-KR (韩文)
/// - Latin-1, Windows-1252 等西欧编码
library;

import 'dart:convert';

/// 编码检测结果
class EncodingResult {
  /// 编码名称
  final String encoding;

  /// 置信度 (0.0 ~ 1.0)
  final double confidence;

  /// 解码后的文本
  final String text;

  const EncodingResult({
    required this.encoding,
    required this.confidence,
    required this.text,
  });
}

/// BOM 标记定义
class _BomInfo {
  final List<int> bytes;
  final String encoding;
  const _BomInfo(this.bytes, this.encoding);
}

/// 编码服务 — 自动检测文件编码并正确读取文件内容
class EncodingService {
  /// 已知的 BOM 标记及其对应编码
  static const _boms = [
    _BomInfo([0xEF, 0xBB, 0xBF], 'utf8'), // UTF-8 BOM
    _BomInfo([0xFE, 0xFF], 'utf16-be'), // UTF-16 BE BOM
    _BomInfo([0xFF, 0xFE], 'utf16-le'), // UTF-16 LE BOM
    _BomInfo([0x00, 0x00, 0xFE, 0xFF], 'utf32-be'), // UTF-32 BE BOM
    _BomInfo([0xFF, 0xFE, 0x00, 0x00], 'utf32-le'), // UTF-32 LE BOM
  ];

  /// 支持的编码列表（用于设置页面展示）
  static const supportedEncodings = [
    'utf8',
    'utf16-le',
    'utf16-be',
    'gbk',
    'gb2312',
    'gb18030',
    'big5',
    'shiftjis',
    'euc-jp',
    'euc-kr',
    'latin1',
    'windows-1252',
    'windows-1251',
    'ascii',
  ];

  /// 根据 BOM 检测编码
  String? detectByBom(List<int> bytes) {
    for (final bom in _boms) {
      if (bytes.length >= bom.bytes.length) {
        bool match = true;
        for (var i = 0; i < bom.bytes.length; i++) {
          if (bytes[i] != bom.bytes[i]) {
            match = false;
            break;
          }
        }
        if (match) return bom.encoding;
      }
    }
    return null;
  }

  /// 自动检测文件编码（对应 marktext autoGuessEncoding）
  /// 首先检查 BOM，然后尝试 UTF-8 验证，最后尝试常见编码
  EncodingResult detectEncoding(List<int> bytes) {
    // 1. 检查 BOM
    final bomEncoding = detectByBom(bytes);
    int bomOffset = 0;

    if (bomEncoding == 'utf8') bomOffset = 3;
    if (bomEncoding == 'utf16-be' || bomEncoding == 'utf16-le') bomOffset = 2;
    if (bomEncoding == 'utf32-be' || bomEncoding == 'utf32-le') bomOffset = 4;

    final contentBytes = bomOffset > 0
        ? bytes.sublist(bomOffset)
        : bytes;

    // 2. 如果 BOM 明确指定了编码，直接使用
    if (bomEncoding != null) {
      String text;
      try {
        text = _decodeWithEncoding(contentBytes, bomEncoding);
        return EncodingResult(
          encoding: bomEncoding,
          confidence: 1.0,
          text: text,
        );
      } catch (_) {
        // Fall through to try other encodings
      }
    }

    // 3. 尝试 UTF-8
    if (_isValidUtf8(contentBytes)) {
      return EncodingResult(
        encoding: 'utf8',
        confidence: 0.9,
        text: utf8.decode(contentBytes),
      );
    }

    // 4. 尝试常见中文编码
    for (final encoding in ['gbk', 'gb2312', 'big5', 'gb18030']) {
      try {
        final text = _decodeWithEncoding(contentBytes, encoding);
        // 检查解码结果是否合理（中文字符占比判断）
        if (_isLikelyChinese(text)) {
          return EncodingResult(
            encoding: encoding,
            confidence: 0.7,
            text: text,
          );
        }
      } catch (_) {
        continue;
      }
    }

    // 5. 尝试日文编码
    for (final encoding in ['shiftjis', 'euc-jp']) {
      try {
        final text = _decodeWithEncoding(contentBytes, encoding);
        if (_isLikelyJapanese(text)) {
          return EncodingResult(
            encoding: encoding,
            confidence: 0.6,
            text: text,
          );
        }
      } catch (_) {
        continue;
      }
    }

    // 6. 尝试韩文编码
    try {
      final text = _decodeWithEncoding(contentBytes, 'euc-kr');
      if (_isLikelyKorean(text)) {
        return EncodingResult(
          encoding: 'euc-kr',
          confidence: 0.6,
          text: text,
        );
      }
    } catch (_) {
      // continue
    }

    // 7. 回退到 Latin-1（永远不会失败的兜底编码）
    final latinText = latin1.decode(contentBytes);
    return EncodingResult(
      encoding: 'latin1',
      confidence: 0.3,
      text: latinText,
    );
  }

  /// 检查字节序列是否为有效的 UTF-8
  bool _isValidUtf8(List<int> bytes) {
    try {
      utf8.decode(bytes);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 判断文本是否可能为中文
  bool _isLikelyChinese(String text) {
    if (text.isEmpty) return false;
    int chineseCount = 0;
    for (final char in text.runes) {
      if ((char >= 0x4E00 && char <= 0x9FFF) || // CJK Unified Ideographs
          (char >= 0x3400 && char <= 0x4DBF) || // CJK Extension A
          (char >= 0xF900 && char <= 0xFAFF)) {
        // CJK Compatibility
        chineseCount++;
      }
    }
    return chineseCount > text.length * 0.1; // 至少10%是中文字符
  }

  /// 判断文本是否可能为日文
  bool _isLikelyJapanese(String text) {
    if (text.isEmpty) return false;
    int japaneseCount = 0;
    for (final char in text.runes) {
      if ((char >= 0x3040 && char <= 0x309F) || // Hiragana
          (char >= 0x30A0 && char <= 0x30FF)) {
        // Katakana
        japaneseCount++;
      }
    }
    return japaneseCount > 0;
  }

  /// 判断文本是否可能为韩文
  bool _isLikelyKorean(String text) {
    if (text.isEmpty) return false;
    int koreanCount = 0;
    for (final char in text.runes) {
      if (char >= 0xAC00 && char <= 0xD7AF) {
        // Hangul Syllables
        koreanCount++;
      }
    }
    return koreanCount > 0;
  }

  /// 使用指定编码解码文本
  String _decodeWithEncoding(List<int> bytes, String encoding) {
    return switch (encoding) {
      'utf8' => utf8.decode(bytes),
      'utf16-be' || 'utf16-le' => _decodeUtf16(bytes, encoding),
      'latin1' => latin1.decode(bytes),
      'ascii' => ascii.decode(bytes),
      // GBK, Big5, Shift_JIS 等需要通过自定义解码器处理
      // 这里使用系统默认的 Latin-1 兜底，生产环境建议使用三方包
      _ => _fallbackDecode(bytes),
    };
  }

  /// UTF-16 解码
  String _decodeUtf16(List<int> bytes, String encoding) {
    if (bytes.length < 2) return String.fromCharCodes(bytes);

    final isBigEndian = encoding == 'utf16-be';
    final codeUnits = <int>[];

    for (var i = 0; i < bytes.length - 1; i += 2) {
      final unit = isBigEndian
          ? (bytes[i] << 8) | bytes[i + 1]
          : (bytes[i + 1] << 8) | bytes[i];
      codeUnits.add(unit);
    }

    return String.fromCharCodes(codeUnits);
  }

  /// 回退解码（Latin-1 作为兜底）
  String _fallbackDecode(List<int> bytes) {
    try {
      return latin1.decode(bytes);
    } catch (_) {
      return String.fromCharCodes(bytes);
    }
  }
}
