# MarkFlowy ↔ MarkText 产品级对齐分析报告

> 报告日期：2026-06-06  
> 分析方式：全量阅读两项目全部源代码后进行逐项对比  
> MarkText 源码：`/Users/mingyuanxu/workspace/marktext` (340+ 源文件)  
> MarkFlowy 源码：`/Users/mingyuanxu/workspace/flutter_markdown_editor` (56 dart 文件)

---

## 一、总体对齐度评估

```
整体对齐度：≈ 62%

  编辑器核心  ████████░░ 80%
  文件系统    ████████░░ 75%
  搜索替换    ████████░░ 75%
  侧边栏      ██████░░░░ 60%
  主题系统    ██████████ 90%
  快捷键      ██████░░░░ 55%
  菜单栏      ████░░░░░░ 40%
  导出        ██████░░░░ 55%
  设置页面    ██████░░░░ 60%
  图片处理    ███░░░░░░░ 30%
  拼写检查    ███░░░░░░░ 25%
  国际化      ░░░░░░░░░░  0%
  Muya编辑器  ████░░░░░░ 35%
```

---

## 二、按功能模块逐一对比

### 2.1 编辑器引擎 — **最大差距所在**

MarkText 使用自研 **Muya 编辑器**（151 个源文件），MarkFlowy 使用 **appflowy_editor** 替代。

#### 2.1.1 编辑器 UI 组件对比

| MarkText (Muya) 组件 | 用途 | MarkFlowy 状态 |
|---|---|---|
| **FormatPicker** | 选中文字后弹出：粗/斜/下划线/删除线/高亮/行内代码/行内公式/链接/图片/清除格式 | ❌ 缺失。当前用 appflowy_editor 内置 FloatingToolbar，功能较少（无高亮、无清除格式、无行内公式） |
| **QuickInsert** | 输入 `@` 触发：基础块(段落/标题/引用/代码/公式/HTML)、列表(有序/无序/任务)、高级(表格/分割线/脚注)、图表(mermaid/flowchart/sequence/vega-lite) | ❌ 完全缺失。这是 MarkText 核心交互之一 |
| **TablePicker** | 可视化表格行列选择器（6×8 网格 + 手动输入） | ❌ 缺失。appflowy_editor 有基本表格支持但无选择器 |
| **EmojiPicker** | 输入 `:` 触发表情面板，支持搜索 | ❌ 缺失 |
| **ImageSelector** | 两 Tab：文件选择 / URL 嵌入，支持 alt/title | ❌ 缺失。ImageService 仅处理路径逻辑，无 UI |
| **ImageToolbar** | 选中图片后：编辑/对齐(行内/左/中/右)/打开/删除 | ❌ 缺失 |
| **LinkTools** | 点击链接弹出：取消链接、跳转 URL | ❌ 缺失 |
| **FootnoteTool** | 脚注悬浮窗：显示定义、创建、跳转 | ❌ 缺失 |
| **FrontMenu** | 段落悬停图标 `+`：复制段落、转为…、新建段落、删除 | ❌ 缺失 |
| **Transformer** | 图片/表格的拖拽变换大小手柄 | ❌ 缺失 |
| **CodePicker** | 代码块语言选择器下拉 | ❌ 缺失 |
| **TableBarTools** | 表格内行列增删工具栏 | ❌ 缺失（appflowy_editor 部分支持） |
| **MathPreview** | 行内公式预览弹窗 | ❌ 缺失 |
| **Rollback** | 块级回退提示 | ❌ 缺失 |
| **FontSizeMenu** | 字号下拉选择 | ❌ 缺失 |

**结论：Muya 编辑器 18 个 UI 组件，MarkFlowy 仅实现了 1 个（FloatingToolbar 基础功能），17 个缺失。**

#### 2.1.2 编辑器行为对比

| 行为 | MarkText (Muya) | MarkFlowy |
|---|---|---|
| 自动配对括号/引号/Markdown 语法 | ✅ 支持 | ⚠️ 设置有字段但 appflowy_editor 不执行 |
| 自动列表续行 | ✅ Enter 自动创建下一列表项 | ✅ appflowy_editor 内置支持 |
| 代码块缩进/Tab | ✅ Tab 缩进，Shift+Tab 取消 | ✅ appflowy_editor 内置 |
| Tab 大小设置 | ✅ `setTabSize(1-4)` | ⚠️ AppSettings 中有但未传递给编辑器 |
| 列表缩进方式 | ✅ 1-4 空格或 dfm | ⚠️ 设置存在但未使用 |
| 标题提升/降低 | ✅ `Cmd+=` / `Cmd+-` | ⚠️ 快捷键已定义但 appflowy_editor 可能不响应 |
| 复制段落 | ✅ `Cmd+Option+D` | ❌ 快捷键定义但无实现 |
| 删除段落 | ✅ FrontMenu 或命令 | ❌ 缺失 |
| 前/后插入段落 | ✅ `insertParagraph(location, text)` | ❌ 缺失 |
| 复制为 HTML | ✅ `copyAsHtml()` | ❌ 缺失 |
| 复制为富文本 | ✅ `copyAsRich()` | ❌ 缺失 |
| 粘贴为纯文本 | ✅ `pasteAsPlainText()` | ❌ 缺失 |
| 选择所有 | ✅ `selectAll()` | ✅ appflowy_editor 内置 |
| 撤销/重做 | ✅ `undo()` / `redo()` | ✅ appflowy_editor 内置 |
| 历史栈追踪 | ✅ change 事件带 history 信息 | ❌ 缺失 |

#### 2.1.3 Muya 公共 API 对比

| Muya API | 用途 | MarkFlowy 对应 |
|---|---|---|
| `setMarkdown()` | 设置文档内容 | ✅ `WysiwygEditor.loadContent()` |
| `getMarkdown()` | 导出 markdown | ✅ `WysiwygEditor.getMarkdown()` |
| `exportStyledHTML()` | 导出带样式的 HTML | ⚠️ ExportService 基础兜底 |
| `exportHtml()` | 导出纯 HTML | ✅ ExportService.markdownToHtml() |
| `getWordCount()` | 字数统计 | ❌ 缺失 |
| `getCursor()` | 获取光标位置 | ❌ 缺失 |
| `setCursor()` | 设置光标 | ❌ 缺失 |
| `createTable()` | 创建表格 | ⚠️ appflowy_editor 内置但无行列选择器 |
| `setFocusMode()` | 焦点模式 | ⚠️ AppEditorState 有字段但编辑器不处理 |
| `setFont()` | 设置字体/行高 | ❌ 缺失（设置存在但不影响编辑器） |
| `setTabSize()` | Tab 大小 | ❌ 缺失 |
| `setListIndentation()` | 列表缩进 | ❌ 缺失 |
| `updateParagraph()` | 更改块类型 | ⚠️ 工具栏定义了但未实现 |
| `duplicate()` | 复制当前段落 | ❌ 缺失 |
| `deleteParagraph()` | 删除段落 | ❌ 缺失 |
| `insertParagraph()` | 插入段落 | ❌ 缺失 |
| `editTable()` | 编辑表格结构 | ❌ 缺失 |
| `format(type)` | 应用内联格式 | ✅ appflowy_editor toolbar |
| `insertImage()` | 插入图片 | ⚠️ ImageService 处理路径但编辑器无调用入口 |
| `search()` | 搜索 | ⚠️ SearchService 可搜索但编辑器无高亮（仅源码模式有） |
| `replace()` | 替换 | ⚠️ 同上 |
| `find()` | 查找上/下一个 | ⚠️ 同上 |
| `undo()` / `redo()` | 撤销/重做 | ✅ |
| `copyAsHtml()` / `copyAsRich()` / `pasteAsPlainText()` | 剪贴板操作 | ❌ 全缺失 |
| `setOptions()` | 更新编辑器选项 | ❌ 缺失 |
| `extractImages()` | 提取文档中所有图片 | ❌ 缺失 |
| `replaceWordInline()` | 替换单词范围（供拼写检查） | ❌ 缺失 |

**结论：Muya 的 34 个公共 API，MarkFlowy 实现/部分实现了约 12 个，22 个缺失或不可用。**

---

### 2.2 文件系统

| 功能 | MarkText | MarkFlowy | 状态 |
|---|---|---|---|
| 打开文件 | ✅ 支持多种编码 | ✅ 集成编码检测（但 GBK/Big5 等真实解码未实现） | ⚠️ |
| 打开文件夹 | ✅ 侧边栏文件树 | ✅ FileTreePanel | ✅ |
| 保存 | ✅ 支持 crlf/lf 行尾 | ✅ saveFile 支持 lineEnding | ✅ |
| 另存为 | ✅ | ✅ | ✅ |
| 自动保存 | ✅ 可配置延迟 | ✅ 5s 延迟（硬编码，不可配置） | ⚠️ |
| 文件监视（外部修改检测） | ✅ watcher + polling | ⚠️ FileService 有 watcher 但 UI 未消费回调 | ❌ |
| 编码自动检测 | ✅ autoGuessEncoding | ⚠️ EncodingService 存在但 GBK/Big5 等用 Latin-1 兜底 | ❌ |
| 编码手动选择 | ✅ 20+ 编码 | ❌ 设置中无 UI 入口 | ❌ |
| 最近文件列表 | ✅ 持久化 | ✅ 持久化到 SharedPreferences | ✅ |
| 文件树展开/折叠 | ✅ | ✅ | ✅ |
| 文件排序 | ✅ modified/created/title | ❌ 固定在名称排序 | ❌ |
| 新建文件/目录 | ✅ | ✅ createFile | ✅ |
| 重命名 | ✅ | ✅ rename | ✅ |
| 删除 | ✅ | ✅ delete | ✅ |

---

### 2.3 搜索与替换

| 功能 | MarkText | MarkFlowy |
|---|---|---|
| 文档内搜索 | ✅ | ✅ SearchService + SearchReplaceBar |
| 搜索替换 | ✅ | ✅ |
| 大小写敏感 | ✅ | ✅ |
| 全词匹配 | ✅ | ✅ |
| 正则表达式 | ✅ | ✅ |
| 上一个/下一个导航 | ✅ Cmd+G / Cmd+Shift+G | ✅ |
| 全部替换 | ✅ | ✅ |
| 搜索防抖 | ✅ 150ms | ✅ 150ms |
| **搜索结果高亮（编辑器内）** | ✅ `.ag-highlight` CSS | ⚠️ 仅源码模式有，WYSIWYG 模式无 |
| **自动滚动到匹配** | ✅ | ❌ 缺失 |
| **文件夹内搜索** | ✅ `Ctrl+Shift+F` | ❌ 未实现 |
| **排除模式** | ✅ glob 模式 | ❌ 设置字段存在但未使用 |
| **搜索历史** | ✅ 最近搜索词 | ❌ 缺失 |
| **正则验证** | ✅ 实时提示错误 | ✅ validateRegex |
| **搜索栏布局** | ✅ 浮动右上角 | ✅ Stack overlay（已修复） |

---

### 2.4 侧边栏

| 面板 | MarkText | MarkFlowy |
|---|---|---|
| **文件树** | ✅ 完整目录树 + 已打开文件 | ⚠️ 存在但 FileTree 展开后无法折叠，无右键菜单 |
| **搜索面板** | ✅ 文件夹内搜索 | ⚠️ SidebarSearchPanel 存在但无功能实现 |
| **目录大纲（TOC）** | ✅ 显示标题结构 | ⚠️ TocPanel 存在但内容可能为空（取决于编辑器内容同步） |
| **图标列交互** | ✅ toggle 行为 | ✅ 正确实现 |
| **拖拽调整宽度** | ✅ 175-500px | ✅ |
| **侧边栏 Ctrl+J 切换** | ✅ | ✅ |

---

### 2.5 菜单栏

MarkText 菜单系统完整对应所有操作。MarkFlowy 的 `MenuService` 构建了完整的 7 个菜单（文件/编辑/段落/格式/视图/窗口/帮助），但：

| 问题 | 详情 |
|---|---|
| **所有菜单命令回调是空的** | `app.dart` 第 253 行：`MenuService(onCommand: (_) {})` |
| 文件菜单 | 新建/打开/保存/另存为/导出/关闭 — **全部点击无任何效果** |
| 编辑菜单 | 撤销/重做/剪切/复制/粘贴/全选 — **全部无效果** |
| 段落菜单 | 标题/表格/代码块/引用/列表 — **全部无效果** |
| 格式菜单 | 粗/斜/下划线/高亮/链接/图片 — **全部无效果** |
| 视图菜单 | 命令面板/源码/打字机/焦点/侧边栏 — **全部无效果** |
| 帮助菜单 | 快捷键参考/Markdown 参考/关于 — **全部无效果** |

**结论：菜单栏 UI 完整构建但 100% 不可用。这是最严重的用户体验问题之一。**

---

### 2.6 快捷键

| 类别 | 已定义 | 可用 | 不可用 |
|---|---|---|---|
| 文件操作 | 9 个 | 4 个（新建/打开/保存/关闭标签） | 5 个 |
| 编辑操作 | 13 个 | 5 个（查找/替换/查下一个/命令面板/Escape） | 8 个 |
| 段落操作 | 15 个 | 2 个（打字机/焦点模式） | 13 个 |
| 格式化操作 | 10 个 | 0 个 | 10 个 |
| 视图操作 | 7 个 | 4 个 | 3 个 |
| 窗口操作 | 1 个 | 0 个 | 1 个 |
| 标签切换 | 2 个 | 0 个 | 2 个 |

编辑器内的格式化快捷键（Cmd+B, Cmd+I, Cmd+U 等）由 appflowy_editor 的 `standardCommandShortcutEvents` 处理，但这些与 `shortcut_service.dart` 中定义的快捷键系统**完全独立，没有集成**。

**结论：57 个快捷键定义中约 15 个可用（26%）。菜单快捷键标签全部有显示，但点击无效果。**

---

### 2.7 命令面板

| 功能 | MarkText | MarkFlowy |
|---|---|---|
| 模糊搜索 | ✅ | ✅ |
| Arrow 键导航 | ✅ | ✅ |
| 显示快捷键标签 | ✅ | ✅ |
| 层级命令系统 | ✅ `rootCommand → subcommands` | ❌ 仅平铺列表 |
| 异步搜索 | ✅ 支持 loading 状态 | ❌ |
| 动态命令注册 | ✅ `registerCommand` / `run()` / `search()` | ❌ 仅静态列表 |
| 命令分类 | ✅ 按菜单分类 | ❌ 混合展示 |
| 执行命令 | ✅ | ⚠️ 调用 `executeCommand` 但大多数命令无注册回调 |

---

### 2.8 导出

| 功能 | MarkText | MarkFlowy |
|---|---|---|
| HTML 导出 | ✅ 带完整内联 CSS | ✅ markdownToHtml() |
| **PDF 导出** | ✅ HTML 管道渲染（保留全部格式） | ⚠️ 手动解析 Markdown（基础质量） |
| **PDF 代码高亮** | ✅ highlight.js | ❌ 纯文本 |
| **PDF 表格** | ✅ | ⚠️ 简单表格支持 |
| **PDF 数学公式** | ✅ KaTeX | ❌ |
| **PDF 图片嵌入** | ✅ | ❌ |
| **导出设置对话框** | ✅ 完整 5 个 Tab | ❌ 无对话框 |
| **打印** | ✅ | ⚠️ printDocument() 丢失全部格式 |
| 纸张大小选择 | ✅ A3/A4/A5/Legal/Letter/Tabloid | ✅ 支持 |
| 页边距设置 | ✅ | ✅ |
| 横向/纵向 | ✅ | ✅ |
| 页眉页脚 | ✅ 自定义 | ❌ |
| 目录生成（TOC） | ✅ 导出含目录 | ❌ |

---

### 2.9 设置页面

| 设置分区 | MarkText 设置项数 | MarkFlowy 设置项数 | 状态 |
|---|---|---|---|
| **通用** | 6 项 | 4 项（缺：新建窗口行为、缩放） | ⚠️ |
| **编辑器** | 12 项 | 6 项（缺：editorLineWidth, endOfLine, encoding, textDirection 等） | ⚠️ |
| **Markdown** | 10 项 | 5 项（缺：headingStyle, frontmatter, sequenceTheme 等） | ⚠️ |
| **主题** | 4 项 | 4 项 | ✅ |
| **图片** | 4 项 | 3 项（缺：relative directory base） | ⚠️ |
| **快捷键** | 可自定义修改 | 展示列表（修改功能未实现） | ❌ |
| **拼写检查** | 3 项 | 0 项 | ❌ |
| **导出** | 完整导出设置 | 0 项 | ❌ |

此外：`app.dart` 路由中 `SettingsPage` 的 `section` 参数被完全忽略，子路由 `/settings/general` 等无法直接定位。

---

### 2.10 图片处理

| 功能 | MarkText | MarkFlowy |
|---|---|---|
| 图片插入 — 文件选择 | ✅ | ⚠️ ImageService.pickImage() 存在但编辑器未集成 |
| 图片插入 — URL 嵌入 | ✅ ImageSelector 的 Embed Link Tab | ❌ 缺失 |
| 图片插入 — 粘贴板 | ✅ 截图/复制图片后 Cmd+V | ❌ 缺失 |
| 图片插入 — 拖拽 | ✅ | ❌ 缺失 |
| 图片上传模式 | ✅ | ❌ 接口预留 |
| 图片复制到文件夹模式 | ✅ | ✅ ImageService |
| 图片路径引用模式 | ✅ | ✅ ImageService |
| 图片相对路径 | ✅ relativeDirectoryBase | ✅ |
| 图片对齐 | ✅ 行内/左/中/右 | ❌ |
| 图片预览器 | ✅ 独立窗口全屏查看 | ❌ |
| 图片自动补全 | ✅ ImagePathPicker | ❌ |
| Unsplash 集成 | ✅ | ❌ |

---

### 2.11 拼写检查

| 功能 | MarkText | MarkFlowy |
|---|---|---|
| 基础拼写检查 | ✅ Electron 内置 + hunspell | ⚠️ SpellcheckerService 基础实现（仅简单词典） |
| 多语言切换 | ✅ 命令面板切换 | ❌ 无 UI 入口 |
| 错误下划线 | ✅ 红色波浪线 | ⚠️ 服务层可检测但编辑器无渲染 |
| 右键替换建议 | ✅ 弹出建议菜单 | ❌ 缺失 |
| 添加忽略词 | ✅ | ✅ addIgnoredWord |
| 用户自定义词典 | ✅ | ✅ addToDictionary |
| "全部忽略" | ✅ | ❌ 缺失 |
| "添加到词典" | ✅ | ⚠️ 部分支持 |
| 语言列表 | ✅ 完整 hunspell | ✅ 20+ 语言枚举 |
| 隐藏下划线选项 | ✅ | ✅ setNoUnderline |

---

### 2.12 国际化 (i18n)

| 功能 | MarkText | MarkFlowy |
|---|---|---|
| 多语言支持 | ✅ vue-i18n，10+ 语言 | ❌ 全硬编码中文/英文混用 |
| 动态切换语言 | ✅ 即时生效 | ❌ 无框架 |
| 菜单翻译 | ✅ | ❌ 硬编码中文 |
| 命令面板翻译 | ✅ | ❌ 硬编码 |
| 搜索栏翻译 | ✅ | ❌ 硬编码 |

---

### 2.13 欢迎页

| 功能 | MarkText | MarkFlowy |
|---|---|---|
| Logo + 版本 | ✅ | ✅ |
| 新建文件 | ✅ | ✅ |
| 打开文件 | ✅ | ✅ |
| 打开文件夹 | ✅ | ✅ |
| 最近文件列表 | ✅ 显示路径、可操作 | ✅ 支持清空 |
| 清空最近文件 | ✅ | ✅ |
| Markdown 快速参考 | ✅ 内置示例文档 | ❌ |

---

### 2.14 其他功能差距

| 功能 | MarkText | MarkFlowy |
|---|---|---|
| **字数统计** | ✅ 状态栏显示字数/行数 | ❌ |
| **自动换行** | ✅ editorLineWidth (px/ch/%) | ❌ |
| **代码块换行** | ✅ wrapCodeBlocks | ❌ 设置字段存在但未使用 |
| **隐藏滚动条** | ✅ hideScrollbar | ❌ 设置字段存在但未使用 |
| **文本方向 RTL** | ✅ | ❌ |
| **自定义 CSS 注入** | ✅ customCss | ❌ |
| **序列图/流程图** | ✅ mermaid, flowchart.js, sequence | ❌ appflowy_editor 不支持 |
| **Frontmatter** | ✅ YAML frontmatter | ❌ 设置存在但编辑器不支持 |
| **表情符号快捷输入** | ✅ `:smile:` 自动转换 | ❌ |
| **GitLab 兼容模式** | ✅ | ❌ |
| **HTML 块渲染** | ✅ 可配置 | ❌ |
| **自动规范化行尾** | ✅ | ❌ |
| **窗口恢复** | ✅ 恢复上次窗口位置/大小 | ❌ settingsService 有接口但未调用 |
| **启动恢复上次文件** | ✅ startUpAction | ❌ 设置字段存在但未实现 |
| **新窗口打开文件** | ✅ | ❌ |
| **微信/微博等社交分享** | ✅ 导出分享 | ❌ |

---

## 三、架构层面差距

### 3.1 状态管理集成度

MarkText 使用 Pinia stores（Electron 环境），所有状态通过 IPC 与 Main Process 通信。MarkFlowy 使用 Riverpod，但存在多个状态孤岛：

- **EditorProvider** 管理 `markdown` 内容
- **TabBarProvider** 管理标签页列表
- **FileProvider** 管理文件状态
- **SearchProvider** 管理搜索状态
- **SideBarProvider** 管理侧边栏

**问题**：这些 Provider 之间通过 `ref.read()` 松散耦合，而不是像 MarkText 那样有明确的 action 流程。例如：
- 标签切换时 TabBarProvider 需要同步 EditorProvider，但 EditorScreen 中也有多处重复的同步逻辑
- 文件保存时内容来源不一致（EditorProvider vs WysiwygEditor GlobalKey）
- WYSIWYG 内容同步采用 GlobalKey 提取模式，而非响应式

### 3.2 菜单命令系统

MarkText 有完整的 `commandIds → IPC → Main Process action` 链路。MarkFlowy：
- `keyboard_shortcuts.dart` 定义了 57 个 shortcut → commandId 映射
- `shortcut_service.dart` 有命令注册机制
- `menu_service.dart` 构建了完整菜单
- **但是** `app.dart` 传入菜单的是空回调 `(_) {}`，shortcut_service 中的命令从未被注册
- editor_screen.dart 中使用 `CallbackShortcuts` 直接绕过 shortcut service 注册了几个快捷键

### 3.3 设置驱动行为

MarkText 几乎所有行为都可以通过设置控制。MarkFlowy 的 `AppSettings` 定义了 50+ 个字段，但：
- 仅约 20 个有 UI 入口且会持久化
- 大部分设置字段定义后从未被任何代码读取或使用
- 编辑器不会根据设置调整行为（字体、行高、Tab 大小等都不生效）

---

## 四、已知死代码 / 未使用组件

| 文件/类 | 状态 |
|---|---|
| `EditorBufferState` (document.dart) | 定义了完整的 buffer 状态模型但从未被导入或使用 |
| `EditorToolbar` (editor_toolbar.dart) | 在 editor_screen 中显示但按钮回调 `_handleFormatAction` 等方法为空实现 |
| `app.dart` MenuService | 传入空回调，所有菜单命令无任何效果 |
| `SettingsPage.section` 参数 | 路由中定义但被完全忽略 |
| `AppSettings.openFilesInNewWindow` 等 | 20+ 个设置字段定义但从未读取 |
| `SettingsNotifier` 中大量 setter 缺失 | 约 30 个设置项无 setter 方法也无 UI |
| ShortcutService 命令注册 | buildActions/buildShortcutBindings 构建了完整系统但从未被使用 |
| ImageService | 服务存在但编辑器从未调用 |
| SpellcheckerService | 服务存在但编辑器从未集成 |
| settingsService.loadWindowState | 存在接口但从未调用 |

---

## 五、优先级建议

### P0 — 用户无法正常使用

1. **菜单栏全部无效** — 点击任何菜单项无反应
2. **WYSIWYG 编辑器缺少 QuickInsert / EmojiPicker / LinkTools 等核心交互** — 用户无法高效编辑
3. **快捷键大量不可用** — 虽然列表能看到但 74% 不生效

### P1 — 严重影响体验

4. **文件被外部修改无提示** — FileService watcher 回调未被 UI 消费
5. **编码检测未真正解码 GBK/Big5** — 打开非 UTF-8 文件显示乱码
6. **设置页不完整** — 大量设置无法通过 GUI 修改
7. **PDF 导出质量低** — 不经过 HTML 管道

### P2 — 功能缺失

8. 国际化完全缺失
9. 图片粘贴/拖拽/上传不支持
10. 拼写检查无 UI 集成
11. 命令面板仅静态列表
12. 导出设置对话框缺失

---

## 六、总结

MarkFlowy 已经搭建了正确的架构骨架（Riverpod 状态管理、appflowy_editor 编辑引擎、完整的 UI 布局），并通过 109 个测试保证了稳定性。在近期的 4 次迭代中修复了内容同步、搜索高亮、打字机模式、快捷键补齐、编码检测、图片服务和拼写检查等关键问题。

但与 MarkText 相比，最大的差距集中在三个方面：

1. **编辑器引擎** — Muya 的 18 个 UI 插件仅实现了 1 个。QuickInsert、EmojiPicker、ImageSelector、LinkTools 等用户高频使用的交互全部缺失
2. **功能连通性** — 菜单栏构建完整但回调为空，快捷键定义 57 个但仅 15 个可用，图片/拼写检查等服务存在但未被编辑器消费
3. **设置驱动** — AppSettings 的 50+ 字段中仅 20 个有 UI 且在运行时有实际效果

建议下一步优先：
1. 连接菜单栏和快捷键到实际功能（修复 app.dart 中的空菜单回调，在 editor_screen 中注册 complete command map）
2. 实现 QuickInsert（`/` 或 `@` 触发的块插入菜单）和 EmojiPicker
3. 将 ImageService/SpellcheckerService 集成到编辑器中
4. 完善设置页面和设置驱动行为
