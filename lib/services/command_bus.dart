/// 中心化命令总线
/// 参考: marktext/src/main/menu/actions/ — 所有菜单动作的调度中心
///
/// 菜单和快捷键都通过 CommandBus 路由到实际功能，
/// 解决了之前菜单全部空回调、快捷键分散注册的问题。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/keyboard_shortcuts.dart';
import 'shortcut_service.dart';

/// 命令回调
typedef CommandHandler = void Function(String commandId);

/// 命令总线状态
class CommandBusState {
  /// 命令 → 处理函数映射
  final Map<String, CommandHandler> handlers;

  const CommandBusState({this.handlers = const {}});

  CommandBusState copyWith({Map<String, CommandHandler>? handlers}) {
    return CommandBusState(handlers: handlers ?? this.handlers);
  }
}

/// 命令总线 Notifier
class CommandBusNotifier extends Notifier<CommandBusState> {
  @override
  CommandBusState build() => const CommandBusState();

  /// 注册一批命令处理器（合并到已有处理器）
  void registerHandlers(Map<String, CommandHandler> newHandlers) {
    final merged = Map<String, CommandHandler>.from(state.handlers);
    merged.addAll(newHandlers);
    state = CommandBusState(handlers: merged);
  }

  /// 注册单个命令处理器
  void register(String commandId, CommandHandler handler) {
    final merged = Map<String, CommandHandler>.from(state.handlers);
    merged[commandId] = handler;
    state = CommandBusState(handlers: merged);
  }

  /// 执行命令
  bool execute(String commandId) {
    final handler = state.handlers[commandId];
    if (handler != null) {
      handler(commandId);
      return true;
    }
    return false;
  }

  /// 获取命令的快捷键标签
  String getShortcutLabel(String commandId) {
    return getShortcutLabel(commandId);
  }

  /// 获取所有已注册命令
  List<CommandEntry> getAllCommandEntries() {
    final entries = <CommandEntry>[];
    for (final shortcut in allShortcuts) {
      if (state.handlers.containsKey(shortcut.commandId)) {
        entries.add(CommandEntry(
          commandId: shortcut.commandId,
          description: shortcut.description,
          activator: shortcut.activator,
          shortcutLabel: getShortcutLabel(shortcut.commandId),
        ));
      }
    }
    return entries;
  }
}

/// 命令总线 Provider
final commandBusProvider =
    NotifierProvider<CommandBusNotifier, CommandBusState>(
        CommandBusNotifier.new);

/// 命令 Intent（用于 Shortcuts + Actions 系统）
class _CommandIntent extends Intent {
  final String commandId;
  const _CommandIntent(this.commandId);
}

/// 命令总线 Widget — 包裹应用顶层，提供全局快捷键支持
/// 替代之前的 ShortcutServiceWidget
class CommandBusWidget extends ConsumerWidget {
  final Widget child;

  const CommandBusWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bus = ref.read(commandBusProvider.notifier);

    // 构建快捷键映射
    final shortcuts = <ShortcutActivator, Intent>{};
    for (final shortcut in allShortcuts) {
      shortcuts[shortcut.activator] = _CommandIntent(shortcut.commandId);
    }

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: {
          _CommandIntent: CallbackAction<_CommandIntent>(
            onInvoke: (intent) {
              bus.execute(intent.commandId);
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}
