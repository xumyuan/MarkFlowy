列出所有可用的 skills。

扫描 `skills/*/SKILL.md`，读取每个文件的 frontmatter（前几行的 `---` 块），提取 name 和 description。

以表格形式展示：
| Skill | 描述 | 路径 |
|-------|------|------|

如果 skills/ 目录不存在或为空，提示用户尚未安装任何 skill。
