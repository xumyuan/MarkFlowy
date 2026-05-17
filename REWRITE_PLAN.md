# MarkText → Flutter 翻译还原计划

## 项目概况

将 MarkText（Electron + Vue，340 个源文件）翻译还原为 Flutter 跨平台应用。优先做好 win 和 mac 端，建立本地 git 仓库，分阶段做提交。

**源码位置**: `/Users/mingyuanxu/workspace/marktext`
**目标位置**: `/Users/mingyuanxu/workspace/flutter_markdown_editor`
**目标平台**: macOS, Windows, iOS, Android

---

## 源码规模与模块划分

| 模块 | 源文件数 | 路径 | 职责 |
|------|---------|------|------|
| **Main Process** | 63 js | `src/main/` | 窗口管理、文件 I/O、菜单、快捷键、偏好设置 |
| **Renderer (Vue)** | 117 vue/js | `src/renderer/` | UI 组件、状态管理(Pinia)、页面路由 |
| **Muya Editor** | 151 js | `src/muya/` | WYSIWYG 编辑器引擎（最复杂） |
| **Common** | 8 js | `src/common/` | 共享常量、文件系统工具、快捷键定义 |
| **总计** | **339** | | |

---

## 翻译策略

采用 **"由外到内、逐层还原"** 策略：先搭 Shell 跑起来，再逐模块填充功能。

**核心决策**：Muya 编辑器不逐行翻译（工程量太大），用 `appflowy_editor` 替代，只还原 Muya 的功能特性。其余模块（Main、Renderer）逐文件对照翻译。

---

## 6 个 Agent 分工

### Agent 1: 项目骨架与基础设施

**对应源码**:
- `src/main/index.js` — 应用入口
- `src/main/app/` — 应用生命周期、环境、路径
- `src/main/config.js` — 全局配置
- `src/common/` — 共享常量和工具

**产出**:
```
flutter create 项目初始化
lib/main.dart                    ← src/main/index.js
lib/app.dart                     ← src/renderer/src/main.js + router
lib/models/app_settings.dart     ← src/main/config.js
lib/models/document.dart         ← src/main/editorBufferStore/
lib/utils/platform_utils.dart    ← src/main/app/env.js + paths.js
lib/utils/constants.dart         ← src/common/
pubspec.yaml                     (所有依赖)
```

**关键依赖**: `flutter_riverpod`, `go_router`, `window_manager`

---

### Agent 2: 窗口框架与布局 Shell

**对应源码**:
- `src/main/windows/` — 窗口创建与管理 (base.js, editor.js, setting.js)
- `src/renderer/src/pages/app.vue` — 主布局
- `src/renderer/src/components/titleBar/` — 标题栏
- `src/renderer/src/components/sideBar/index.vue` — 侧边栏容器
- `src/renderer/src/components/editorWithTabs/tabs.vue` — 标签栏

**产出**:
```
lib/screens/editor_screen.dart   ← app.vue (主布局：标题栏+侧边栏+标签+编辑区)
lib/widgets/titlebar/
  ├── macos_title_bar.dart       ← titleBar/index.vue (macOS 部分)
  ├── windows_title_bar.dart     ← titleBar/index.vue (Windows 部分)
  └── title_bar.dart             ← titleBar/index.vue (Linux 通用)
lib/widgets/sidebar/
  └── sidebar.dart               ← sideBar/index.vue + icon.vue
lib/widgets/tabs/
  └── tab_bar.dart               ← editorWithTabs/tabs.vue
lib/widgets/common/
  ├── platform_adaptive.dart     ← 平台自适应组件
  └── responsive_layout.dart     ← 响应式布局
```

---

### Agent 3: 核心编辑器（Muya → appflowy_editor）

**对应源码** (功能对照，非逐行翻译):
- `src/muya/lib/contentState/` — 29 个控制器 → appflowy_editor 插件/快捷键
- `src/muya/lib/parser/` — Markdown 解析 → `markdown` 包
- `src/muya/lib/ui/` — 浮动工具栏 → appflowy_editor toolbar
- `src/renderer/src/components/editorWithTabs/editor.vue` — 编辑器容器
- `src/renderer/src/components/editorWithTabs/sourceCode.vue` — 源码模式

**Muya contentState 功能映射**:

| Muya 控制器 | Flutter 实现方式 |
|-------------|-----------------|
| `formatCtrl.js` (粗体/斜体/删除线等) | appflowy_editor 内置 toolbar commands |
| `paragraphCtrl.js` (标题/段落/引用) | appflowy_editor block types |
| `codeBlockCtrl.js` | appflowy_editor code block + flutter_highlight |
| `tableBlockCtrl.js` + `tableSelectCellsCtrl.js` + `tableDragBarCtrl.js` | appflowy_editor table plugin（需自定义） |
| `imageCtrl.js` | appflowy_editor image block |
| `linkCtrl.js` | appflowy_editor link 工具 |
| `searchCtrl.js` | 独立 SearchService |
| `history.js` (撤销/重做) | appflowy_editor 内置 undo/redo |
| `enterCtrl.js` / `backspaceCtrl.js` / `deleteCtrl.js` | appflowy_editor 内置键盘处理 |
| `copyCutCtrl.js` / `pasteCtrl.js` | appflowy_editor 内置剪贴板 |
| `emojiCtrl.js` | 自定义 emoji picker widget |
| `tocCtrl.js` | 自定义 TOC 生成服务 |
| `footnoteCtrl.js` | 自定义 block（后期） |

**Muya UI 浮动组件映射**:

| Muya UI | Flutter 实现 |
|---------|-------------|
| `formatPicker/` (选中文字弹出格式栏) | appflowy_editor selection toolbar |
| `quickInsert/` (输入 / 弹出块插入菜单) | appflowy_editor slash command |
| `tablePicker/` + `tableTools/` | 自定义 table toolbar |
| `codePicker/` (语言选择) | DropdownButton |
| `emojiPicker/` | 自定义 emoji picker |
| `imagePicker/` + `imageSelector/` + `imageToolbar/` | 自定义 image 工具栏 |
| `linkTools/` | 自定义 link 编辑浮层 |

**产出**:
```
lib/widgets/editor/
  ├── wysiwyg_editor.dart        ← Muya 整体功能 (appflowy_editor 封装)
  ├── source_editor.dart         ← sourceCode.vue
  ├── split_view.dart            ← 分屏模式
  ├── editor_toolbar.dart        ← muya/lib/ui/formatPicker/
  └── mode_switcher.dart         ← 模式切换
lib/providers/editor_provider.dart ← Pinia editor store
lib/utils/markdown_utils.dart    ← Markdown ↔ appflowy Document 转换
```

---

### Agent 4: 文件管理与侧边栏

**对应源码**:
- `src/main/filesystem/` — index.js, markdown.js, watcher.js, encoding.js
- `src/main/commands/file.js` — 文件命令
- `src/main/commands/tab.js` — 标签命令
- `src/renderer/src/components/sideBar/tree.vue` — 文件树
- `src/renderer/src/components/sideBar/treeFile.vue` — 文件节点
- `src/renderer/src/components/sideBar/treeFolder.vue` — 文件夹节点
- `src/renderer/src/components/sideBar/treeOpenedTab.vue` — 已打开文件
- `src/renderer/src/components/sideBar/toc.vue` — 目录大纲
- `src/renderer/src/components/sideBar/search.vue` — 侧边栏搜索
- `src/renderer/src/components/recent/index.vue` — 最近文件
- `src/main/preferences/index.js` — 偏好存储

**产出**:
```
lib/services/file_service.dart   ← src/main/filesystem/
lib/providers/file_provider.dart ← Pinia project store + editor store (文件部分)
lib/widgets/sidebar/
  ├── file_tree.dart             ← tree.vue + treeFile.vue + treeFolder.vue
  ├── opened_files.dart          ← treeOpenedTab.vue
  ├── toc_panel.dart             ← toc.vue
  └── sidebar_search.dart        ← search.vue + searchResultItem.vue
lib/screens/welcome_screen.dart  ← recent/index.vue
lib/services/settings_service.dart ← src/main/preferences/
```

---

### Agent 5: 菜单、快捷键、主题、搜索替换

**对应源码**:
- `src/main/menu/templates/` — 12 个菜单模板文件
- `src/main/menu/actions/` — 10 个菜单动作文件
- `src/main/keyboard/` — keybindingsDarwin.js, keybindingsWindows.js, keybindingsLinux.js, shortcutHandler.js
- `src/renderer/src/components/search/index.vue` — 搜索替换对话框
- `src/renderer/src/components/commandPalette/index.vue` — 命令面板
- `src/muya/themes/` — 主题 CSS
- `src/renderer/src/prefComponents/theme/` — 主题设置

**产出**:
```
lib/services/shortcut_service.dart    ← src/main/keyboard/
lib/utils/keyboard_shortcuts.dart     ← keybindingsDarwin/Windows/Linux.js
lib/services/menu_service.dart        ← src/main/menu/ (原生菜单)
lib/widgets/search/
  └── search_replace_bar.dart         ← search/index.vue
lib/widgets/command_palette.dart      ← commandPalette/index.vue
lib/themes/
  ├── app_theme.dart                  ← 主题工厂
  ├── cadmium_light.dart              ← muya/themes/
  ├── cadmium_dark.dart
  ├── graphite_light.dart
  ├── material_dark.dart
  ├── one_dark.dart
  └── ulysses_light.dart
lib/providers/theme_provider.dart     ← Pinia layout store (主题部分)
lib/providers/search_provider.dart
lib/services/search_service.dart
```

---

### Agent 6: 导出、设置页、移动端适配、测试

**对应源码**:
- `src/renderer/src/components/exportSettings/index.vue` — 导出设置
- `src/renderer/src/pages/preference.vue` — 设置页面
- `src/renderer/src/prefComponents/` — 48 个设置子组件
  - `general/`, `editor/`, `markdown/`, `theme/`, `image/`, `keybindings/`, `spellchecker/`
- `src/main/spellchecker/` — 拼写检查
- `src/main/i18n.js` — 国际化

**产出**:
```
lib/services/export_service.dart      ← 导出逻辑
lib/screens/settings_screen.dart      ← preference.vue
lib/widgets/settings/
  ├── general_settings.dart           ← prefComponents/general/
  ├── editor_settings.dart            ← prefComponents/editor/
  ├── markdown_settings.dart          ← prefComponents/markdown/
  ├── theme_settings.dart             ← prefComponents/theme/
  ├── image_settings.dart             ← prefComponents/image/
  └── keybinding_settings.dart        ← prefComponents/keybindings/
lib/providers/settings_provider.dart
test/                                 (单元测试+Widget测试)
```

---

## 执行顺序与依赖关系

```
Agent 1 (骨架)
  ↓
Agent 2 (窗口 Shell)  ──→  Agent 4 (文件管理)
  ↓                            ↓
Agent 3 (编辑器)       ──→  Agent 5 (菜单/快捷键/主题/搜索)
                               ↓
                         Agent 6 (导出/设置/移动端/测试)
```

**建议执行方式**:
- Agent 1 → Agent 2 必须串行（先有骨架才能搭 Shell）
- Agent 2 完成后，Agent 3 和 Agent 4 可并行
- Agent 5 依赖 Agent 3 (编辑器) 和 Agent 4 (文件) 的基础接口
- Agent 6 最后执行，做集成和打磨

---

## 核心技术栈

```yaml
dependencies:
  # 编辑器
  appflowy_editor: ^6.1.0
  flutter_highlight: ^0.7.0
  flutter_markdown: ^0.7.6
  markdown: ^7.2.2

  # 状态管理与路由
  flutter_riverpod: ^3.3.1
  go_router: ^17.2.3

  # 桌面支持
  window_manager: ^0.5.0
  file_picker: ^8.0.0
  path_provider: ^2.1.1
  shared_preferences: ^2.2.2

  # 导出
  pdf: ^3.11.3
  printing: ^5.11.0

  # 数学公式
  flutter_math_fork: ^0.7.2

  # UI
  fluent_ui: ^4.8.0
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test: sdk
  mocktail: ^1.0.3
  integration_test: sdk
```

---

## 每个 Agent 的启动 Prompt 模板

启动新环境时，给 AI 的 prompt 格式：

```
你是 Agent N，负责 [模块名]。

源码参考: /Users/mingyuanxu/workspace/marktext/src/[路径]
目标项目: /Users/mingyuanxu/workspace/flutter_markdown_editor/

请参考以下源文件逐一翻译还原为 Flutter/Dart 代码:
- [文件1] → [目标文件1]
- [文件2] → [目标文件2]
...

技术要求:
- 使用 flutter_riverpod 管理状态
- 中文注释
- 平台自适应 (macOS/Windows/iOS/Android)
- [Agent 特定要求]

前置依赖: [Agent N-1 的产出文件列表]
```

---

## 验收标准

| 阶段 | 验收 |
|------|------|
| Agent 1 完成 | `flutter run -d macos` 白屏启动无报错 |
| Agent 2 完成 | 自定义标题栏 + 侧边栏骨架 + 空编辑区 |
| Agent 3 完成 | WYSIWYG / 源码 / 分屏三模式可切换编辑 |
| Agent 4 完成 | 新建/打开/保存文件，文件树浏览 |
| Agent 5 完成 | 菜单栏、快捷键、6 主题、搜索替换可用 |
| Agent 6 完成 | 导出 HTML/PDF、设置页、移动端可运行、测试通过 |
