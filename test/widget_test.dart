/// MarkFlowy 基础冒烟测试
import 'package:flutter_test/flutter_test.dart';
import 'package:markflowy/utils/constants.dart';

void main() {
  test('应用名称常量正确', () {
    expect(kAppName, 'MarkFlowy');
  });

  test('GitHub 仓库地址常量正确', () {
    expect(kGithubRepoUrl, contains('markflowy'));
  });
}
