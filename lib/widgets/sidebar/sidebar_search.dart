/// 侧边栏搜索面板
/// 参考: marktext/src/renderer/src/components/sideBar/search.vue
///
/// 功能:
/// - 在当前项目文件夹中搜索文本
/// - 搜索结果列表（文件名+行号+上下文）
/// - 支持大小写敏感、全词匹配、正则表达式
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/file_provider.dart';
import '../../services/file_service.dart';

/// 单条搜索匹配结果
class SearchMatch {
  /// 匹配所在行号
  final int lineNumber;

  /// 匹配行的内容（上下文）
  final String lineContent;

  /// 匹配起始位置
  final int matchStart;

  /// 匹配长度
  final int matchLength;

  const SearchMatch({
    required this.lineNumber,
    required this.lineContent,
    required this.matchStart,
    required this.matchLength,
  });
}

/// 单个文件的搜索结果
class FileSearchResult {
  /// 文件路径
  final String filePath;

  /// 文件名
  final String fileName;

  /// 匹配项列表
  final List<SearchMatch> matches;

  const FileSearchResult({
    required this.filePath,
    required this.fileName,
    required this.matches,
  });
}

/// 搜索状态
class SearchState {
  final String keyword;
  final List<FileSearchResult> results;
  final bool isSearching;
  final bool isCaseSensitive;
  final bool isWholeWord;
  final bool isRegexp;
  final String? errorMessage;

  const SearchState({
    this.keyword = '',
    this.results = const [],
    this.isSearching = false,
    this.isCaseSensitive = false,
    this.isWholeWord = false,
    this.isRegexp = false,
    this.errorMessage,
  });

  /// 总匹配数
  int get totalMatches => results.fold(0, (sum, r) => sum + r.matches.length);

  SearchState copyWith({
    String? keyword,
    List<FileSearchResult>? results,
    bool? isSearching,
    bool? isCaseSensitive,
    bool? isWholeWord,
    bool? isRegexp,
    String? Function()? errorMessage,
  }) {
    return SearchState(
      keyword: keyword ?? this.keyword,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      isCaseSensitive: isCaseSensitive ?? this.isCaseSensitive,
      isWholeWord: isWholeWord ?? this.isWholeWord,
      isRegexp: isRegexp ?? this.isRegexp,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

/// 搜索状态 Notifier
class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounceTimer;

  @override
  SearchState build() => const SearchState();

  /// 更新搜索关键词并触发搜索（带去抖）
  void setKeyword(String keyword) {
    state = state.copyWith(keyword: keyword);
    _debounceTimer?.cancel();
    if (keyword.isEmpty) {
      state = state.copyWith(results: [], isSearching: false);
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  /// 切换大小写敏感
  void toggleCaseSensitive() {
    state = state.copyWith(isCaseSensitive: !state.isCaseSensitive);
    if (state.keyword.isNotEmpty) _performSearch();
  }

  /// 切换全词匹配
  void toggleWholeWord() {
    state = state.copyWith(isWholeWord: !state.isWholeWord);
    if (state.keyword.isNotEmpty) _performSearch();
  }

  /// 切换正则表达式
  void toggleRegexp() {
    state = state.copyWith(isRegexp: !state.isRegexp);
    if (state.keyword.isNotEmpty) _performSearch();
  }

  /// 执行搜索
  Future<void> _performSearch() async {
    final fileState = ref.read(fileProvider);
    final projectPath = fileState.projectPath;
    if (projectPath == null || state.keyword.isEmpty) {
      state = state.copyWith(results: [], isSearching: false);
      return;
    }

    state = state.copyWith(isSearching: true, errorMessage: () => null);

    try {
      // 构建正则表达式
      RegExp pattern;
      try {
        String patternStr = state.keyword;
        if (!state.isRegexp) {
          patternStr = RegExp.escape(patternStr);
        }
        if (state.isWholeWord) {
          patternStr = '\\b$patternStr\\b';
        }
        pattern = RegExp(patternStr, caseSensitive: state.isCaseSensitive);
      } catch (e) {
        state = state.copyWith(
          isSearching: false,
          errorMessage: () => '无效的正则表达式',
        );
        return;
      }

      final results = <FileSearchResult>[];
      int fileCount = 0;

      // 递归搜索项目目录中的 Markdown 文件
      await _searchDirectory(Directory(projectPath), pattern, results, fileCount);

      state = state.copyWith(
        results: results,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        errorMessage: () => '搜索出错: $e',
      );
    }
  }

  /// 递归搜索目录
  Future<void> _searchDirectory(
    Directory dir,
    RegExp pattern,
    List<FileSearchResult> results,
    int fileCount,
  ) async {
    // 限制最大搜索文件数
    if (fileCount > 100) return;

    try {
      await for (final entity in dir.list()) {
        if (fileCount > 100) break;
        final name = entity.path.split('/').last;
        // 跳过隐藏文件和 node_modules
        if (name.startsWith('.') || name == 'node_modules') continue;

        if (entity is Directory) {
          await _searchDirectory(entity, pattern, results, fileCount);
        } else if (entity is File && isMarkdownFile(entity.path)) {
          fileCount++;
          final fileResult = await _searchInFile(entity, pattern);
          if (fileResult != null) {
            results.add(fileResult);
          }
        }
      }
    } catch (_) {
      // 忽略权限错误等
    }
  }

  /// 在单个文件中搜索
  Future<FileSearchResult?> _searchInFile(File file, RegExp pattern) async {
    try {
      final content = await file.readAsString();
      final lines = content.split('\n');
      final matches = <SearchMatch>[];

      for (int i = 0; i < lines.length; i++) {
        final lineMatches = pattern.allMatches(lines[i]);
        for (final match in lineMatches) {
          matches.add(SearchMatch(
            lineNumber: i + 1,
            lineContent: lines[i].trim(),
            matchStart: match.start,
            matchLength: match.end - match.start,
          ));
        }
      }

      if (matches.isEmpty) return null;
      return FileSearchResult(
        filePath: file.path,
        fileName: file.path.split('/').last,
        matches: matches,
      );
    } catch (_) {
      return null;
    }
  }
}

/// 搜索 Provider
final searchProvider =
    NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);

/// 侧边栏搜索面板组件（对应 marktext search.vue）
class SidebarSearchPanel extends ConsumerStatefulWidget {
  /// 点击搜索结果时的回调
  final void Function(String filePath, int lineNumber)? onResultTap;

  const SidebarSearchPanel({super.key, this.onResultTap});

  @override
  ConsumerState<SidebarSearchPanel> createState() => _SidebarSearchPanelState();
}

class _SidebarSearchPanelState extends ConsumerState<SidebarSearchPanel> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final fileState = ref.watch(fileProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        // 搜索输入区域（对应 marktext search-wrapper）
        _buildSearchInput(searchState, theme),

        // 搜索选项信息
        if (searchState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              searchState.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),

        // 搜索结果信息
        if (searchState.results.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              '${searchState.totalMatches} 个匹配，${searchState.results.length} 个文件',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ),

        // 搜索中指示器
        if (searchState.isSearching)
          const Padding(
            padding: EdgeInsets.all(8),
            child: LinearProgressIndicator(minHeight: 2),
          ),

        // 搜索结果或空状态
        Expanded(
          child: searchState.results.isNotEmpty
              ? _buildSearchResults(searchState, theme)
              : _buildEmptyState(searchState, fileState, theme),
        ),
      ],
    );
  }

  /// 搜索输入框（对应 marktext search-wrapper）
  Widget _buildSearchInput(SearchState searchState, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        child: Row(
          children: [
            // 搜索输入框
            Expanded(
              child: TextField(
                controller: _searchController,
                style: theme.textTheme.bodySmall,
                decoration: const InputDecoration(
                  hintText: '在文件夹中搜索',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                ),
                onChanged: (value) {
                  ref.read(searchProvider.notifier).setKeyword(value);
                },
              ),
            ),
            // 搜索选项按钮
            _SearchOptionButton(
              icon: 'Aa',
              tooltip: '区分大小写',
              isActive: searchState.isCaseSensitive,
              onTap: () => ref.read(searchProvider.notifier).toggleCaseSensitive(),
            ),
            _SearchOptionButton(
              icon: 'W',
              tooltip: '全词匹配',
              isActive: searchState.isWholeWord,
              onTap: () => ref.read(searchProvider.notifier).toggleWholeWord(),
            ),
            _SearchOptionButton(
              icon: '.*',
              tooltip: '正则表达式',
              isActive: searchState.isRegexp,
              onTap: () => ref.read(searchProvider.notifier).toggleRegexp(),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  /// 搜索结果列表
  Widget _buildSearchResults(SearchState searchState, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        final fileResult = searchState.results[index];
        return _SearchResultFileGroup(
          result: fileResult,
          onMatchTap: (match) {
            widget.onResultTap?.call(fileResult.filePath, match.lineNumber);
          },
        );
      },
    );
  }

  /// 空状态
  Widget _buildEmptyState(SearchState searchState, FileState fileState, ThemeData theme) {
    if (fileState.projectPath == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '未打开文件夹',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => ref.read(fileProvider.notifier).openFolder(),
              child: const Text('打开文件夹'),
            ),
          ],
        ),
      );
    }

    if (searchState.keyword.isNotEmpty && !searchState.isSearching) {
      return Center(
        child: Text(
          '未找到匹配结果',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// 搜索选项按钮（对应 marktext search controls 中的 span）
class _SearchOptionButton extends StatelessWidget {
  final String icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  const _SearchOptionButton({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? theme.colorScheme.primaryContainer
                : Colors.transparent,
          ),
          child: Text(
            icon,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

/// 搜索结果文件分组（对应 marktext searchResultItem.vue）
class _SearchResultFileGroup extends StatefulWidget {
  final FileSearchResult result;
  final void Function(SearchMatch match) onMatchTap;

  const _SearchResultFileGroup({
    required this.result,
    required this.onMatchTap,
  });

  @override
  State<_SearchResultFileGroup> createState() => _SearchResultFileGroupState();
}

class _SearchResultFileGroupState extends State<_SearchResultFileGroup> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 文件名标题行
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  _isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.description,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.result.fileName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 匹配数
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Text(
                    '${widget.result.matches.length}',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 匹配项列表
        if (_isExpanded)
          ...widget.result.matches.map(
            (match) => _SearchMatchItem(
              match: match,
              onTap: () => widget.onMatchTap(match),
            ),
          ),
      ],
    );
  }
}

/// 单条匹配结果
class _SearchMatchItem extends StatefulWidget {
  final SearchMatch match;
  final VoidCallback onTap;

  const _SearchMatchItem({
    required this.match,
    required this.onTap,
  });

  @override
  State<_SearchMatchItem> createState() => _SearchMatchItemState();
}

class _SearchMatchItemState extends State<_SearchMatchItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.only(left: 32, right: 12, top: 3, bottom: 3),
          color: _isHovered
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : Colors.transparent,
          child: Row(
            children: [
              // 行号
              SizedBox(
                width: 32,
                child: Text(
                  '${widget.match.lineNumber}',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
              // 行内容
              Expanded(
                child: Text(
                  widget.match.lineContent,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
