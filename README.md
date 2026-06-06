# MarkFlowy
**一个基于 Flutter 的跨平台 Markdown 编辑器**
灵感来自 [MarkText](https://github.com/marktext/marktext)，使用 [AppFlowy Editor](https://github.com/AppFlowy-IO/appflowy-editor) 构建
[
]([https://github.com/xumyuan/MarkFlowy/actions/workflows/ci.yml](https://github.com/xumyuan/MarkFlowy/actions/workflows/ci.yml))
[
]([https://github.com/xumyuan/MarkFlowy/actions/workflows/release.yml](https://github.com/xumyuan/MarkFlowy/actions/workflows/release.yml))
[
](LICENSE)
## [English](README_EN.md) | 中文
## 功能特性
* **所见即所得编辑** — 基于 AppFlowy Editor 的富文本编辑，支持粗体、斜体、标题、列表、引用、代码块等
* **三种编辑模式** — WYSIWYG / 源码模式 / 分屏预览，随时切换
* **文件管理** — 文件树浏览、多标签编辑、文件监视、拖拽排序
* **6 套主题** — Cadmium Light/Dark、Graphite Light、Material Dark、One Dark、Ulysses Light
* **快捷键** — macOS/Windows 平台自适应快捷键，支持自定义
* **搜索替换** — 支持正则表达式、大小写敏感、全词匹配
* **命令面板** — `Cmd/Ctrl+Shift+P` 快速执行命令
* **导出** — 支持导出为 HTML 和 PDF
* **跨平台** — macOS、Windows、iOS、Android
## 快速开始
### 下载安装
前往 [Releases](https://github.com/xumyuan/MarkFlowy/releases) 页面下载最新版本：
|平台|下载|
|-|-|
|macOS|`MarkFlowy-macOS.zip`|
|Windows|`MarkFlowy-Windows.zip`|
### 从源码构建
## 开发环境配置
### 前置要求
|工具|版本|
|-|-|
|Flutter|>= 3.11.5 (stable)|
|Dart|>= 3.11.5|
|Xcode|>= 15.0（macOS 开发）|
|Visual Studio|>= 2022（Windows 开发）|
|CocoaPods|最新版（macOS 开发）|
### 环境搭建
### 常用命令
## 项目结构
## 技术栈
|类别|技术|
|-|-|
|框架|Flutter 3.11+|
|编辑器|[AppFlowy Editor](https://github.com/AppFlowy-IO/appflowy-editor)|
|状态管理|[Riverpod](https://riverpod.dev/)|
|路由|[GoRouter](https://pub.dev/packages/go_router)|
|桌面窗口|[window_manager](https://pub.dev/packages/window_manager)|
|PDF 导出|[pdf](https://pub.dev/packages/pdf) + [printing](https://pub.dev/packages/printing)|
|主题|自定义 ThemeData（参考 MarkText 原始 CSS）|
## 贡献
欢迎贡献！请遵循以下步骤：
1. Fork 本仓库
1. 创建特性分支 (`git checkout -b feature/amazing-feature`)
1. 提交更改 (`git commit -m 'feat: 添加某个功能'`)
1. 推送到分支 (`git push origin feature/amazing-feature`)
1. 创建 Pull Request
### 提交规范
使用 [Conventional Commits](https://www.conventionalcommits.org/)：
* `feat:` 新功能
* `fix:` 修复 Bug
* `docs:` 文档更新
* `chore:` 构建/工具变更
## 许可证
[MIT License](LICENSE)
## 致谢
* [MarkText](https://github.com/marktext/marktext) — 本项目的灵感来源和功能参考
* [AppFlowy Editor](https://github.com/AppFlowy-IO/appflowy-editor) — 核心富文本编辑器引擎
* [Flutter](https://flutter.dev/) — 跨平台 UI 框架
