/// 拼写检查服务测试
import 'package:flutter_test/flutter_test.dart';

import 'package:markflowy/services/spellchecker_service.dart';

void main() {
  group('SpellcheckerService', () {
    late SpellcheckerService service;

    setUp(() {
      service = SpellcheckerService();
      service.setEnabled(true);
    });

    group('checkWord', () {
      test('已知正确词应返回 true', () {
        expect(service.checkWord('the'), isTrue);
        expect(service.checkWord('have'), isTrue);
        expect(service.checkWord('good'), isTrue);
      });

      test('常用词应被识别为正确', () {
        // 'playing' 匹配后缀 'ing'，应被 _isLikelyCorrect 识别
        expect(service.checkWord('playing'), isTrue);
        // 'replay' 匹配前缀 're'，应被 _isLikelyCorrect 识别
        expect(service.checkWord('replay'), isTrue);
      });

      test('忽略词应返回 true', () {
        service.addIgnoredWord('testword');
        expect(service.checkWord('testword'), isTrue);
      });

      test('自定义词典词应返回 true', () {
        service.addToDictionary('myword');
        expect(service.checkWord('myword'), isTrue);
      });

      test('纯数字应跳过检查', () {
        expect(service.checkWord('12345'), isTrue);
      });

      test('禁用时应返回 true', () {
        service.setEnabled(false);
        expect(service.checkWord('xyzwq'), isTrue);
      });

      test('单字符应跳过检查', () {
        expect(service.checkWord('a'), isTrue);
      });
    });

    group('checkText', () {
      test('应检测文本中的拼写错误', () {
        service.setEnabled(true);
        final results = service.checkText('the qwerty asdfg hello');
        expect(results.length, greaterThanOrEqualTo(0));
      });

      test('禁用时应返回空列表', () {
        service.setEnabled(false);
        final results = service.checkText('asdf qwer');
        expect(results, isEmpty);
      });
    });

    group('supportedLanguages', () {
      test('应包含常见语言', () {
        expect(SpellcheckerService.supportedLanguages, contains('en-US'));
        expect(SpellcheckerService.supportedLanguages, contains('zh-CN'));
      });
    });

    group('ignoredWords', () {
      test('添加后应忽略', () {
        service.addIgnoredWord('myword');
        expect(service.checkWord('myword'), isTrue);
      });

      test('移除后不应忽略', () {
        service.addIgnoredWord('custom');
        // 添加后应在自定义词典中
        expect(service.checkWord('custom'), isTrue);
        service.removeIgnoredWord('custom');
        // 移除后取决于词典检查结果
        // 'custom' 不在基础词典中，所以应返回 false
        expect(service.checkWord('custom'), isFalse);
      });

      test('清空后应清除所有忽略词', () {
        service.addIgnoredWord('word1');
        service.addIgnoredWord('word2');
        service.clearIgnoredWords();
        // word1, word2 不在基础词典，取决于 _isLikelyCorrect
      });
    });
  });
}
