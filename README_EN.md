# MarkFlowy
## **A cross-platform Markdown editor built with Flutter**
Inspired by [MarkText](https://github.com/marktext/marktext), powered by [AppFlowy Editor](https://github.com/AppFlowy-IO/appflowy-editor)
[
](%5Bhttps://github.com/xumyuan/MarkFlowy/actions/workflows/ci.yml%5D(https://github.com/xumyuan/MarkFlowy/actions/workflows/ci.yml))
[
](%5Bhttps://github.com/xumyuan/MarkFlowy/actions/workflows/release.yml%5D(https://github.com/xumyuan/MarkFlowy/actions/workflows/release.yml))
[
](LICENSE)
中文 | [English](README_EN.md)
## Features
* **WYSIWYG Editing** — Rich text editing powered by AppFlowy Editor, supporting bold, italic, headings, lists, blockquotes, code blocks, and more
* **Three Editing Modes** — WYSIWYG / Source Code / Split View, switch anytime
* **File Management** — File tree browsing, multi-tab editing, file watching, drag-to-reorder
* **6 Themes** — Cadmium Light/Dark, Graphite Light, Material Dark, One Dark, Ulysses Light
* **Keyboard Shortcuts** — Platform-adaptive shortcuts (macOS/Windows), customizable
* **Find & Replace** — Regex, case-sensitive, and whole-word matching
* **Command Palette** — `Cmd/Ctrl+Shift+P` to quickly execute commands
* **Export** — Export to HTML and PDF
* **Cross-platform** — macOS, Windows, iOS, Android
## Quick Start
### Download
Head to the [Releases](https://github.com/xumyuan/MarkFlowy/releases) page for the latest version:
|Platform|Download|
|-|-|
|macOS|`MarkFlowy-macOS.zip`|
|Windows|`MarkFlowy-Windows.zip`|
### Build from Source
## Development Setup
### Prerequisites
|Tool|Version|
|-|-|
|Flutter|>= 3.11.5 (stable)|
|Dart|>= 3.11.5|
|Xcode|>= 15.0 (for macOS development)|
|Visual Studio|>= 2022 (for Windows development)|
|CocoaPods|Latest (for macOS development)|
### Getting Started
### Common Commands
## Project Structure
## Tech Stack
|Category|Technology|
|-|-|
|Framework|Flutter 3.11+|
|Editor|[AppFlowy Editor](https://github.com/AppFlowy-IO/appflowy-editor)|
|State Management|[Riverpod](https://riverpod.dev/)|
|Routing|[GoRouter](https://pub.dev/packages/go_router)|
|Desktop Window|[window_manager](https://pub.dev/packages/window_manager)|
|PDF Export|[pdf](https://pub.dev/packages/pdf) + [printing](https://pub.dev/packages/printing)|
|Theming|Custom ThemeData (based on MarkText CSS)|
## Contributing
Contributions are welcome! Please follow these steps:
1. Fork this repository
1. Create a feature branch (`git checkout -b feature/amazing-feature`)
1. Commit your changes (`git commit -m 'feat: add amazing feature'`)
1. Push to the branch (`git push origin feature/amazing-feature`)
1. Open a Pull Request
### Commit Convention
We use [Conventional Commits](https://www.conventionalcommits.org/):
* `feat:` New feature
* `fix:` Bug fix
* `docs:` Documentation update
* `chore:` Build/tooling changes
## License
[MIT License](LICENSE)
## Acknowledgements
* [MarkText](https://github.com/marktext/marktext) — The inspiration and feature reference for this project
* [AppFlowy Editor](https://github.com/AppFlowy-IO/appflowy-editor) — Core rich text editor engine
* [Flutter](https://flutter.dev/) — Cross-platform UI framework
