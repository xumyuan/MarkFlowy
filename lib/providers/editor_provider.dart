/// 编辑器状态管理 Provider
/// 参考: marktext/src/renderer/src/store/editor.js (Pinia store)
///
/// 管理:
/// - 当前编辑模式（WYSIWYG / 源码 / 分屏）
/// - 当前活动文档的编辑器状态
/// - 文档修改状态追踪
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 编辑模式枚举（对应 marktext 的 sourceCode/typewriter/focus 模式切换）
enum EditorMode {
  /// 所见即所得模式（对应 marktext 默认的 Muya 编辑器）
  wysiwyg,

  /// 源码模式（对应 marktext sourceCode.vue / CodeMirror）
  sourceCode,

  /// 分屏模式（左源码右预览，marktext 未直接实现但属于常见需求）
  splitView,
}

/// 编辑器状态
class AppEditorState {
  /// 当前编辑模式
  final EditorMode mode;

  /// 当前活动文档 ID（与 TabBarState.activeTabId 对应）
  final String? activeDocumentId;

  /// 文档是否被修改（未保存）
  final bool isModified;

  /// 是否处于焦点模式（对应 marktext focus mode）
  final bool isFocusMode;

  /// 是否处于打字机模式（对应 marktext typewriter mode）
  final bool isTypewriterMode;

  /// 当前文档的 markdown 内容
  final String markdown;

  const AppEditorState({
    this.mode = EditorMode.wysiwyg,
    this.activeDocumentId,
    this.isModified = false,
    this.isFocusMode = false,
    this.isTypewriterMode = false,
    this.markdown = '',
  });

  AppEditorState copyWith({
    EditorMode? mode,
    String? Function()? activeDocumentId,
    bool? isModified,
    bool? isFocusMode,
    bool? isTypewriterMode,
    String? markdown,
  }) {
    return AppEditorState(
      mode: mode ?? this.mode,
      activeDocumentId: activeDocumentId != null
          ? activeDocumentId()
          : this.activeDocumentId,
      isModified: isModified ?? this.isModified,
      isFocusMode: isFocusMode ?? this.isFocusMode,
      isTypewriterMode: isTypewriterMode ?? this.isTypewriterMode,
      markdown: markdown ?? this.markdown,
    );
  }
}

/// 编辑器状态 Notifier
/// 对应 marktext useEditorStore 中的 actions
class EditorNotifier extends Notifier<AppEditorState> {
  @override
  AppEditorState build() {
    return const AppEditorState();
  }

  /// 切换编辑模式
  void setMode(EditorMode mode) {
    state = state.copyWith(mode: mode);
  }

  /// 循环切换模式: WYSIWYG → 源码 → 分屏 → WYSIWYG
  void cycleMode() {
    final nextMode = switch (state.mode) {
      EditorMode.wysiwyg => EditorMode.sourceCode,
      EditorMode.sourceCode => EditorMode.splitView,
      EditorMode.splitView => EditorMode.wysiwyg,
    };
    state = state.copyWith(mode: nextMode);
  }

  /// 设置当前活动文档
  void setActiveDocument(String? documentId) {
    state = state.copyWith(activeDocumentId: () => documentId);
  }

  /// 更新 markdown 内容（编辑器内容变化时调用）
  /// [markDirtyOnly] 为 true 时只标记修改状态，不更新 markdown 文本
  /// （避免 WYSIWYG 模式下 state 变化导致编辑器重建的死循环）
  void updateMarkdown(String markdown, {bool markDirtyOnly = false}) {
    if (markDirtyOnly) {
      if (!state.isModified) {
        state = state.copyWith(isModified: true);
      }
    } else {
      state = state.copyWith(markdown: markdown, isModified: true);
    }
  }

  /// 同步内容到 provider 并标记已修改（不会导致编辑器重建，因为 WYSIWYG 使用 GlobalKey 读取）
  void syncContent(String markdown) {
    state = state.copyWith(markdown: markdown, isModified: true);
  }

  /// 加载文档内容（打开文件或切换标签时）
  void loadDocument(String docId, String markdown) {
    state = state.copyWith(
      activeDocumentId: () => docId,
      markdown: markdown,
      isModified: false,
    );
  }

  /// 标记文档已修改
  void markModified() {
    state = state.copyWith(isModified: true);
  }

  /// 标记文档已保存
  void markSaved() {
    state = state.copyWith(isModified: false);
  }

  /// 切换焦点模式（对应 marktext View → Focus Mode）
  void toggleFocusMode() {
    state = state.copyWith(isFocusMode: !state.isFocusMode);
  }

  /// 切换打字机模式（对应 marktext View → Typewriter Mode）
  void toggleTypewriterMode() {
    state = state.copyWith(isTypewriterMode: !state.isTypewriterMode);
  }
}

/// 编辑器 Provider
final editorProvider =
    NotifierProvider<EditorNotifier, AppEditorState>(EditorNotifier.new);
