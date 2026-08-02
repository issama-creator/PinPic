import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinpic/core/providers/core_providers.dart';
import 'package:pinpic/routes/route_paths.dart';
import 'package:pinpic/services/search_service.dart';
import 'package:pinpic/theme/app_colors.dart';
import 'package:pinpic/widgets/app_scaffold.dart';
import 'package:pinpic/widgets/async_state_view.dart';
import 'package:pinpic/widgets/photo_thumbnail.dart';
import 'package:pinpic/widgets/smart_memory_card.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({
    super.key,
    required this.query,
    this.category,
    this.favoritesOnly = false,
  });

  final String query;
  final String? category;
  final bool favoritesOnly;

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  final _scrollController = ScrollController();
  final _hits = <SearchHit>[];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  bool _similarFallback = false;
  int _nextOffset = 0;
  int _total = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(reset: true));
  }

  @override
  void didUpdateWidget(covariant ResultsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query ||
        oldWidget.category != widget.category ||
        oldWidget.favoritesOnly != widget.favoritesOnly) {
      _load(reset: true);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 600 &&
        _hasMore &&
        !_loadingMore &&
        !_loading) {
      _load();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _loadingMore = false;
        _errorMessage = null;
        _hits.clear();
        _nextOffset = 0;
      });
    } else {
      setState(() => _loadingMore = true);
    }

    try {
      await ref.read(appBootstrapProvider.future);
      final page = await ref
          .read(searchServiceProvider)
          .searchPage(
            widget.query,
            category: widget.category,
            favoritesOnly: widget.favoritesOnly,
            offset: reset ? 0 : _nextOffset,
          );
      if (!mounted) return;
      setState(() {
        _hits.addAll(page.items);
        _nextOffset = page.nextOffset;
        _hasMore = page.hasMore;
        _total = page.total;
        _similarFallback = page.isSimilarFallback;
        _loading = false;
        _loadingMore = false;
      });
      if (reset && widget.query.trim().isNotEmpty) {
        await ref
            .read(searchServiceProvider)
            .remember(widget.query, resultCount: page.total);
        ref.invalidate(recentSearchesProvider);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _errorMessage = 'Не удалось выполнить поиск';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.query.isNotEmpty
        ? widget.query
        : (widget.category ?? 'Результаты');
    return AppScaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () async {
              final applied = await context.push<Map<String, dynamic>>(
                RoutePaths.filters,
              );
              if (applied == null || !context.mounted) return;
              final nextCategory = applied['category'] as String?;
              final nextFav = applied['favoritesOnly'] as bool? ?? false;
              context.pushReplacement(
                '${RoutePaths.results}?q=${Uri.encodeQueryComponent(widget.query)}'
                '${nextCategory != null ? '&category=${Uri.encodeQueryComponent(nextCategory)}' : ''}'
                '${nextFav ? '&fav=1' : ''}',
              );
            },
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return AppRetryState(
        message: _errorMessage!,
        onRetry: () => _load(reset: true),
      );
    }
    if (_hits.isEmpty) {
      final isCategoryOnly =
          widget.query.trim().isEmpty && widget.category != null;
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ничего не найдено',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              isCategoryOnly
                  ? 'В этой категории пока нет проиндексированных фото'
                  : 'Попробуйте: документ, чек, паспорт, QR',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _similarFallback
                  ? 'Похожие результаты'
                  : '$_total результат${_plural(_total)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),
        Expanded(child: _buildResultSections(context)),
      ],
    );
  }

  Widget _buildResultSections(BuildContext context) {
    final direct = _hits.where((hit) => !hit.isSimilar).toList();
    final similar = _hits.where((hit) => hit.isSimilar).toList();
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        if (direct.isNotEmpty) _resultGrid(context, direct),
        if (similar.isNotEmpty) ...[
          if (direct.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  'Похожие результаты',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          _resultGrid(context, similar),
        ],
        if (_loadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Widget _resultGrid(BuildContext context, List<SearchHit> hits) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final hit = hits[index];
          return _ResultCard(
            hit: hit,
            onTap: () =>
                context.push(RoutePaths.photoDetailsPath(hit.photo.mediaId)),
          );
        }, childCount: hits.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.55,
        ),
      ),
    );
  }

  String _plural(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod10 == 1 && mod100 != 11) return '';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'а';
    }
    return 'ов';
  }
}

String _friendlyEvidence(String value) => value;

class _ResultCard extends ConsumerWidget {
  const _ResultCard({required this.hit, required this.onTap});

  final SearchHit hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chips = hit.evidence.isEmpty
        ? <String>[hit.reason]
        : hit.evidence.map(_friendlyEvidence).take(3).toList(growable: false);

    return Material(
      color: const Color(0xFF16161F),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PhotoThumbnail(
                      mediaId: hit.photo.mediaId,
                      filePath: hit.photo.path,
                      width: 240,
                      height: 240,
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '${hit.confidence}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SmartMemoryCard(photo: hit.photo, compact: true),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final chip in chips)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF242430),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            chip,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hit.photo.dateTaken == null
                              ? 'Дата неизвестна'
                              : MaterialLocalizations.of(
                                  context,
                                ).formatShortDate(hit.photo.dateTaken!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: hit.photo.isFavorite
                            ? 'Убрать из избранного'
                            : 'В избранное',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 26,
                          height: 26,
                        ),
                        onPressed: () async {
                          await ref
                              .read(photoRepositoryProvider)
                              .setFavorite(
                                hit.photo.mediaId,
                                !hit.photo.isFavorite,
                              );
                          ref.invalidate(favoritesProvider);
                          ref.read(searchServiceProvider).invalidateCaches();
                        },
                        icon: Icon(
                          hit.photo.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: hit.photo.isFavorite
                              ? AppColors.purple
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
