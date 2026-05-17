/// 快捷键服务
/// 参考: marktext/src/main/keyboard/shortcutHandler.js
///
/// 管理全局快捷键的注册和命令映射。
/// 使用 Flutter 的 Shortcuts + Actions 系统实现。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/keyboard_shortcuts.dart';

/// 命令回调类型
typedef CommandCallback = void Function();

/// 快捷键服务 — 注册和管理全局快捷键
/// 对应 marktext 的 Keybindings 类
class ShortcutService {
  /// 命令回调注册表
  final Map<String, CommandCallback> _commands = {};

  /// 用户自定义快捷键覆盖（commandId → SingleActivator）
  final Map<String, SingleActivator> _userOverrides = {};

  /// 注册一个命令回调
  void registerCommand(String commandId, CommandCallback callback) {
    _commands[commandId] = callback;
  }

  /// 批量注册命令
  void registerCommands(Map<String, CommandCallback> commands) {
    _commands.addAll(commands);
  }

  /// 注销命令
  void unregisterCommand(String commandId) {
    _commands.remove(commandId);
  }

  /// 执行命令
  bool executeCommand(String commandId) {
    final callback = _commands[commandId];
    if (callback != null) {
      callback();
      return true;
    }
    return false;
  }

  /// 检查命令是否已注册
  bool hasCommand(String commandId) => _commands.containsKey(commandId);

  /// 获取所有已注册命令 ID
  List<String> get registeredCommands => _commands.keys.toList();

  /// 设置用户自定义快捷键
  void setUserKeybinding(String commandId, SingleActivator activator) {
    _userOverrides[commandId] = activator;
  }

  /// 移除用户自定义快捷键
  void removeUserKeybinding(String commandId) {
    _userOverrides.remove(commandId);
  }

  /// 获取命令对应的快捷键（优先使用用户自定义）
  SingleActivator? getActivator(String commandId) {
    // 优先用户自定义
    if (_userOverrides.containsKey(commandId)) {
      return _userOverrides[commandId];
    }
    // 回退到默认
    final binding = getShortcutByCommand(commandId);
    return binding?.activator;
  }

  /// 构建 Flutter Shortcuts widget 的 bindings map
  Map<ShortcutActivator, Intent> buildShortcutBindings() {
    final bindings = <ShortcutActivator, Intent>{};
    for (final shortcut in allShortcuts) {
      final commandId = shortcut.commandId;
      // 使用用户覆盖或默认值
      final activator = _userOverrides[commandId] ?? shortcut.activator;
      bindings[activator] = _CommandIntent(commandId);
    }
    return bindings;
  }

  /// 构建 Flutter Actions widget 的 actions map
  Map<Type, Action<Intent>> buildActions() {
    return {
      _CommandIntent: CallbackAction<_CommandIntent>(
        onInvoke: (intent) {
          executeCommand(intent.commandId);
          return null;
        },
      ),
    };
  }

  /// 获取所有命令及其快捷键绑定（用于命令面板展示）
  List<CommandEntry> getAllCommandEntries() {
    final entries = <CommandEntry>[];
    for (final shortcut in allShortcuts) {
      final activator = _userOverrides[shortcut.commandId] ?? shortcut.activator;
      entries.add(CommandEntry(
        commandId: shortcut.commandId,
        description: shortcut.description,
        activator: activator,
        shortcutLabel: getShortcutLabel(shortcut.commandId),
      ));
    }
    return entries;
  }
}

/// 命令 Intent，将快捷键绑定到具体命令
class _CommandIntent extends Intent {
  final String commandId;
  const _CommandIntent(this.commandId);
}

/// 命令面板展示用的命令条目
class CommandEntry {
  final String commandId;
  final String description;
  final SingleActivator activator;
  final String shortcutLabel;

  const CommandEntry({
    required this.commandId,
    required this.description,
    required this.activator,
    required this.shortcutLabel,
  });
}

/// 快捷键服务状态
class ShortcutServiceState {
  final ShortcutService service;

  ShortcutServiceState({required this.service});
}

/// 快捷键服务 Notifier
class ShortcutServiceNotifier extends Notifier<ShortcutServiceState> {
  @override
  ShortcutServiceState build() {
    return ShortcutServiceState(service: ShortcutService());
  }

  /// 注册命令
  void registerCommand(String commandId, CommandCallback callback) {
    state.service.registerCommand(commandId, callback);
  }

  /// 执行命令
  bool executeCommand(String commandId) {
    return state.service.executeCommand(commandId);
  }

  /// 设置用户自定义快捷键
  void setUserKeybinding(String commandId, SingleActivator activator) {
    state.service.setUserKeybinding(commandId, activator);
    // 触发重建
    state = ShortcutServiceState(service: state.service);
  }
}

/// 快捷键服务 Provider
final shortcutServiceProvider =
    NotifierProvider<ShortcutServiceNotifier, ShortcutServiceState>(
  ShortcutServiceNotifier.new,
);

/// 快捷键 Widget 包装器
/// 包裹在应用顶层，提供全局快捷键支持
class ShortcutServiceWidget extends ConsumerWidget {
  final Widget child;

  const ShortcutServiceWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceState = ref.watch(shortcutServiceProvider);
    final service = serviceState.service;

    return Shortcuts(
      shortcuts: service.buildShortcutBindings(),
      child: Actions(
        actions: service.buildActions(),
        child: child,
      ),
    );
  }
}
