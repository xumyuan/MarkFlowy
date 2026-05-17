marktext 源码参考助手。marktext 项目路径: /Users/mingyuanxu/workspace/marktext

根据用户的参数 $ARGUMENTS 执行以下操作：

## 无参数 / "overview" / "结构"
浏览 marktext 项目目录结构，给出源码架构概览：
- 列出 src/ 下的目录结构（2层深度）
- 读取 package.json 了解技术栈和依赖
- 读取 CLAUDE.md（如有）了解项目约定
- 给出简洁的架构总结

## 有搜索关键词（如 "search X" / "搜索 X" / 直接输入关键词）
在 marktext 源码中搜索相关代码：
- 在 /Users/mingyuanxu/workspace/marktext/src 目录下 grep 搜索关键词
- 展示匹配的文件和代码片段
- 如果关键词像是文件名，也用 find 查找匹配的文件

## "参考 X" / "ref X" / "how X"
查找 marktext 中某个功能的实现方式：
- 搜索相关代码
- 读取关键文件
- 总结实现思路和代码模式，供当前项目参考
