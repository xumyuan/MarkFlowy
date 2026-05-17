<div align="center">

# MarkFlowy

**A cross-platform Markdown editor built with Flutter**

Inspired by [MarkText](https://github.com/marktext/marktext), powered by [AppFlowy Editor](https://github.com/AppFlowy-IO/appflowy-editor)

[![CI](https://github.com/xumyuan/MarkFlowy/actions/workflows/ci.yml/badge.svg)](https://github.com/xumyuan/MarkFlowy/actions/workflows/ci.yml)
[![Release](https://github.com/xumyuan/MarkFlowy/actions/workflows/release.yml/badge.svg)](https://github.com/xumyuan/MarkFlowy/actions/workflows/release.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

中文 | [English](README_EN.md)

</div>

---

## Features

- **WYSIWYG Editing** — Rich text editing powered by AppFlowy Editor, supporting bold, italic, headings, lists, blockquotes, code blocks, and more
- **Three Editing Modes** — WYSIWYG / Source Code / Split View, switch anytime
- **File Management** — File tree browsing, multi-tab editing, file watching, drag-to-reorder
- **6 Themes** — Cadmium Light/Dark, Graphite Light, Material Dark, One Dark, Ulysses Light
- **Keyboard Shortcuts** — Platform-adaptive shortcuts (macOS/Windows), customizable
- **Find & Replace** — Regex, case-sensitive, and whole-word matching
- **Command Palette** — `Cmd/Ctrl+Shift+P` to quickly execute commands
- **Export** — Export to HTML and PDF
- **Cross-platform** — macOS, Windows, iOS, Android

## Quick Start

### Download

Head to the [Releases](https://github.com/xumyuan/MarkFlowy/releases) page for the latest version:

| Platform | Download |
|----------|----------|
| macOS | `MarkFlowy-macOS.zip` |
| Windows | `MarkFlowy-Windows.zip` |

### Build from Source

```bash
# Clone the repository
git clone https://github.com/xumyuan/MarkFlowy.git
cd MarkFlowy

# Install dependencies
flutter pub get

# Run in debug mode
flutter run -d macos    # macOS
flutter run -d windows  # Windows

# Build for release
flutter build macos --release
flutter build windows --release
```

## Development Setup

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter | >= 3.11.5 (stable) |
| Dart | >= 3.11.5 |
| Xcode | >= 15.0 (for macOS development) |
| Visual Studio | >= 2022 (for Windows development) |
| CocoaPods | Latest (for macOS development) |

### Getting Started

```bash
# 1. Install Flutter if you haven't already
# https://docs.flutter.dev/get-started/install

# 2. Verify your environment
flutter doctor

# 3. Additional steps for macOS
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
brew install cocoapods

# 4. Clone and run
git clone https://github.com/xumyuan/MarkFlowy.git
cd MarkFlowy
flutter pub get
flutter run -d macos
```

### Common Commands

```bash
flutter analyze          # Static analysis
flutter test             # Run tests
flutter run -d macos     # Debug on macOS
flutter run -d windows   # Debug on Windows
flutter run -d chrome    # Debug on Web
flutter build macos      # Release build for macOS
flutter build windows    # Release build for Windows
```

## Project Structure

```
lib/
├── main.dart                        # App entry point
├── app.dart                         # Router configuration
├── models/                          # Data models
│   ├── app_settings.dart            #   App settings
│   └── document.dart                #   Document model
├── providers/                       # Riverpod state management
│   ├── editor_provider.dart         #   Editor state
│   ├── file_provider.dart           #   File state
│   ├── search_provider.dart         #   Search state
│   ├── settings_provider.dart       #   Settings state
│   └── theme_provider.dart          #   Theme state
├── services/                        # Service layer
│   ├── file_service.dart            #   File I/O
│   ├── export_service.dart          #   HTML/PDF export
│   ├── menu_service.dart            #   Native menus
│   ├── search_service.dart          #   Find & replace
│   ├── settings_service.dart        #   Settings persistence
│   └── shortcut_service.dart        #   Shortcut management
├── screens/                         # Pages
│   ├── editor_screen.dart           #   Main editor layout
│   ├── settings_screen.dart         #   Settings page
│   └── welcome_screen.dart          #   Welcome page
├── themes/                          # Theme definitions (6 themes)
├── widgets/
│   ├── editor/                      #   Editor widgets (WYSIWYG/source/split/toolbar)
│   ├── titlebar/                    #   Title bar (macOS/Windows adaptive)
│   ├── sidebar/                     #   Sidebar (file tree/search/TOC)
│   ├── tabs/                        #   Tab bar
│   ├── settings/                    #   Settings panels (6 panels)
│   ├── search/                      #   Find & replace bar
│   └── common/                      #   Common widgets
└── utils/                           # Utilities
```

## Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.11+ |
| Editor | [AppFlowy Editor](https://github.com/AppFlowy-IO/appflowy-editor) |
| State Management | [Riverpod](https://riverpod.dev/) |
| Routing | [GoRouter](https://pub.dev/packages/go_router) |
| Desktop Window | [window_manager](https://pub.dev/packages/window_manager) |
| PDF Export | [pdf](https://pub.dev/packages/pdf) + [printing](https://pub.dev/packages/printing) |
| Theming | Custom ThemeData (based on MarkText CSS) |

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation update
- `chore:` Build/tooling changes

## License

[MIT License](LICENSE)

## Acknowledgements

- [MarkText](https://github.com/marktext/marktext) — The inspiration and feature reference for this project
- [AppFlowy Editor](https://github.com/AppFlowy-IO/appflowy-editor) — Core rich text editor engine
- [Flutter](https://flutter.dev/) — Cross-platform UI framework
