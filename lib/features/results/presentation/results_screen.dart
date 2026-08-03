import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinpic/core/providers/core_providers.dart';
import 'package:pinpic/routes/route_paths.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/search_service.dart';
import 'package:pinpic/shared/models/index_progress.dart';
import 'package:pinpic/theme/app_colors.dart';
import 'package:pinpic/widgets/app_scaffold.dart';
import 'package:pinpic/widgets/async_state_view.dart';
import 'package:pinpic/widgets/fact_memory_tile.dart';

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
      return _EmptyResults(
        query: widget.query,
        category: widget.category,
        favoritesOnly: widget.favoritesOnly,
        indexing: ref.watch(indexProgressProvider),
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
      sliver: SliverList.separated(
        itemCount: hits.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final hit = hits[index];
          return FactMemoryTile(
            photo: hit.photo,
            confidence: hit.confidence,
            evidence: hit.evidence.take(2).toList(growable: false),
            onTap: () =>
                context.push(RoutePaths.photoDetailsPath(hit.photo.mediaId)),
          );
        },
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

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({
    required this.query,
    required this.category,
    required this.favoritesOnly,
    required this.indexing,
  });

  final String query;
  final String? category;
  final bool favoritesOnly;
  final IndexProgress indexing;

  static const _categoryIcons = <String, IconData>{
    CategoryEngine.receipts: Icons.receipt_long_outlined,
    CategoryEngine.tickets: Icons.confirmation_number_outlined,
    CategoryEngine.passports: Icons.badge_outlined,
    CategoryEngine.passwords: Icons.wifi_password_rounded,
    CategoryEngine.qr: Icons.qr_code_2_rounded,
    CategoryEngine.warranties: Icons.verified_outlined,
    CategoryEngine.businessCards: Icons.contact_page_outlined,
    CategoryEngine.documents: Icons.description_outlined,
  };

  static const _tips = <String>[
    'чек вчера',
    'пароль вайфай',
    'билет',
    'паспорт',
    'QR',
  ];

  @override
  Widget build(BuildContext context) {
    final isCategoryOnly = query.trim().isEmpty && category != null;
    final indexingBusy = indexing.isRunning;
    final icon = favoritesOnly
        ? Icons.favorite_border_rounded
        : (_categoryIcons[category] ?? Icons.search_off_rounded);

    final String title;
    final String description;
    if (favoritesOnly) {
      title = 'В избранном пусто';
      description =
          'Отметьте чек, пароль или документ — где важен текст или код.';
    } else if (indexingBusy && isCategoryOnly) {
      title = 'Пока пусто';
      description =
          'Память ещё собирается. $category появятся здесь, '
          'когда PinPic прочитает текст на фото. '
          'Это не поиск пейзажей и котов.';
    } else if (isCategoryOnly) {
      title = 'Пока нет «$category»';
      description =
          'PinPic ищет важное с текстом и кодами в галерее — '
          'не все фото подряд. Если документ есть, подождите обновления '
          'памяти или попробуйте поиск как помните.';
    } else {
      title = 'Ничего не найдено';
      description =
          indexingBusy
          ? 'По запросу «$query» пока пусто. Память ещё собирается — '
                'попробуйте сумму, дату («вчера») или другое слово.'
          : 'По запросу «$query» в памяти ничего нет. '
                'PinPic помнит чеки, пароли, билеты и коды — '
                'не «найди кота». Попробуйте иначе или откройте коллекцию.';
    }

    return AppEmptyState(
      icon: icon,
      title: title,
      description: description,
      suggestions: favoritesOnly || isCategoryOnly ? const [] : _tips,
      onSuggestion: favoritesOnly || isCategoryOnly
          ? null
          : (tip) {
              context.pushReplacement(
                '${RoutePaths.results}?q=${Uri.encodeQueryComponent(tip)}',
              );
            },
      primaryLabel: isCategoryOnly || favoritesOnly
          ? 'На главную'
          : 'Изменить запрос',
      onPrimary: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(RoutePaths.home);
        }
      },
    );
  }
}
