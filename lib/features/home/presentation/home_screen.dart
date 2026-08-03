import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pinpic/core/constants/app_constants.dart';
import 'package:pinpic/core/providers/core_providers.dart';
import 'package:pinpic/core/utils/hash_utils.dart';
import 'package:pinpic/features/settings/presentation/settings_screen.dart';
import 'package:pinpic/routes/route_paths.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/document_expiry.dart';
import 'package:pinpic/shared/models/app_settings_entity.dart';
import 'package:pinpic/shared/models/index_progress.dart';
import 'package:pinpic/shared/models/photo_entity.dart';
import 'package:pinpic/widgets/async_state_view.dart';
import 'package:pinpic/widgets/photo_thumbnail.dart';

/// A completed library is left untouched on app entry until the visible media
/// count or the index rules change. Per-file fingerprints still protect the
/// actual sync when a photo is added or removed.
bool shouldStartStartupIndex(AppSettingsEntity settings, int deviceCount) {
  return !settings.initialScanCompleted ||
      settings.totalIndexed != deviceCount ||
      settings.indexedPipelineVersion != HashUtils.indexPipelineVersion;
}

final class _HomeStyle {
  const _HomeStyle({
    required this.bg,
    required this.card,
    required this.searchFill,
    required this.muted,
    required this.label,
    required this.accent,
    required this.text,
    required this.border,
    required this.washColors,
  });

  final Color bg;
  final Color card;
  final Color searchFill;
  final Color muted;
  final Color label;
  final Color accent;
  final Color text;
  final Color border;
  final List<Color> washColors;

  static const dark = _HomeStyle(
    bg: Color(0xFF050510),
    card: Color(0xFF1C1C1E),
    searchFill: Color(0xFF1C1C1E),
    muted: Color(0xFF8E8E93),
    label: Color(0xFFAEAEB2),
    accent: Color(0xFFA855F7),
    text: Colors.white,
    border: Color(0x14FFFFFF),
    washColors: [Color(0x242A1250), Color(0x100E0820), Color(0x00050510)],
  );

  static const light = _HomeStyle(
    bg: Color(0xFFF6F7FB),
    card: Color(0xFFFFFFFF),
    searchFill: Color(0xFFE8EAF2),
    muted: Color(0xFF5C5C6A),
    label: Color(0xFF3A3A48),
    accent: Color(0xFF9333EA),
    text: Color(0xFF12121A),
    border: Color(0x221A1A22),
    washColors: [Color(0x22C4B5FD), Color(0x10EDE9FE), Color(0x00F6F7FB)],
  );

  static _HomeStyle of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? light : dark;
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  int _tab = 0;

  static const _categories = <_QuickCategory>[
    _QuickCategory('Документы', Icons.description_outlined, Color(0xFF5B8CFF)),
    _QuickCategory('Чеки', Icons.receipt_long_outlined, Color(0xFF34C759)),
    _QuickCategory(
      'Билеты',
      Icons.confirmation_number_outlined,
      Color(0xFF34AADC),
    ),
    _QuickCategory('Гарантии', Icons.verified_outlined, Color(0xFF4CC9F0)),
    _QuickCategory('Визитки', Icons.contact_page_outlined, Color(0xFF00B8A9)),
    _QuickCategory('Пароли', Icons.wifi_password_rounded, Color(0xFFFF5C7A)),
    _QuickCategory('QR', Icons.qr_code_2_rounded, Color(0xFFA855F7)),
    _QuickCategory('Паспорта', Icons.badge_outlined, Color(0xFF7C9CFF)),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_resumeIndexing());
      unawaited(_maybeAskExpiryReminders());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_resumeIndexing());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      ref.read(indexProgressProvider.notifier).stop();
    }
  }

  Future<void> _resumeIndexing() async {
    final settings = await ref.read(settingsRepositoryProvider).getSettings();
    if (!settings.permissionGranted) return;
    if (ref.read(indexingServiceProvider).isRunning) return;
    final deviceCount = await ref
        .read(photoMediaServiceProvider)
        .countDevicePhotos();
    if (!shouldStartStartupIndex(settings, deviceCount)) {
      return;
    }
    unawaited(ref.read(indexProgressProvider.notifier).start());
  }

  Future<void> _maybeAskExpiryReminders() async {
    final settings = await ref.read(settingsRepositoryProvider).getSettings();
    if (settings.expiryReminderPromptShown || settings.expiryRemindersEnabled) {
      return;
    }
    final sample = await ref
        .read(photoRepositoryProvider)
        .getExpiringSoon(limit: 1);
    if (sample.isEmpty || !mounted) return;

    final enable = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Напоминать о сроках?'),
        content: const Text(
          'PinPic нашёл документ со сроком действия. '
          'Можно получать локальные напоминания на этом устройстве — '
          'без облака и аккаунта.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Не сейчас'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Включить'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (enable == true) {
      final granted = await ref
          .read(expiryReminderServiceProvider)
          .requestPermission();
      await ref
          .read(settingsRepositoryProvider)
          .setExpiryRemindersEnabled(granted);
      if (granted) {
        final photos = await ref
            .read(photoRepositoryProvider)
            .getWithExpiry(limit: 200);
        await ref.read(expiryReminderServiceProvider).syncPhotos(photos);
      }
    } else {
      await ref
          .read(settingsRepositoryProvider)
          .markExpiryReminderPromptShown();
    }
    ref.invalidate(appSettingsProvider);
  }

  void _openResults(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    context.push('${RoutePaths.results}?q=${Uri.encodeQueryComponent(q)}');
  }

  /// Quick category tiles must filter by the exact indexed `category` field
  /// rather than run a free-text keyword search — otherwise unmatched
  /// queries silently fall back to "similar results" (i.e. arbitrary recent
  /// photos), making every category look identical.
  ///
  /// «Документы» is the umbrella collection: open it as a document intent
  /// query so receipts, tickets, passports, etc. all appear together.
  void _openCategory(String category) {
    if (category == CategoryEngine.documents) {
      context.push(
        '${RoutePaths.results}?q=${Uri.encodeQueryComponent('документ')}',
      );
      return;
    }
    context.push(
      '${RoutePaths.results}?category=${Uri.encodeQueryComponent(category)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _HomeStyle.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: style.bg,
        systemNavigationBarIconBrightness: isLight
            ? Brightness.dark
            : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: style.bg,
        body: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -1.1),
                    radius: 1.15,
                    colors: style.washColors,
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: IndexedStack(
                index: _tab,
                children: [
                  _SearchTab(
                    categories: _categories,
                    onOpenResults: _openResults,
                    onOpenCategory: _openCategory,
                    onOpenFilters: () => context.push(RoutePaths.filters),
                    onOpenPhoto: (mediaId) =>
                        context.push(RoutePaths.photoDetailsPath(mediaId)),
                  ),
                  _FavoritesTab(
                    onOpenPhoto: (mediaId) =>
                        context.push(RoutePaths.photoDetailsPath(mediaId)),
                    onGoSearch: () => setState(() => _tab = 0),
                  ),
                  const SettingsScreen(embedded: true),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _HomeBottomNav(
          index: _tab,
          onChanged: (value) => setState(() => _tab = value),
        ),
      ),
    );
  }
}

class _SearchTab extends ConsumerStatefulWidget {
  const _SearchTab({
    required this.categories,
    required this.onOpenResults,
    required this.onOpenCategory,
    required this.onOpenFilters,
    required this.onOpenPhoto,
  });

  final List<_QuickCategory> categories;
  final ValueChanged<String> onOpenResults;
  final ValueChanged<String> onOpenCategory;
  final VoidCallback onOpenFilters;
  final ValueChanged<String> onOpenPhoto;

  @override
  ConsumerState<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<_SearchTab> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<String> _hot = const [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller
      ..removeListener(_onQueryChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    _debounce = Timer(AppConstants.searchDebounce, () async {
      final query = _controller.text.trim();
      final items = await ref.read(searchServiceProvider).suggestions(query);
      if (!mounted) return;
      setState(() => _hot = items);
    });
    setState(() {});
  }

  Future<void> _submit([String? value]) async {
    final query = (value ?? _controller.text).trim();
    if (query.isEmpty) return;
    widget.onOpenResults(query);
  }

  @override
  Widget build(BuildContext context) {
    final recentAsync = ref.watch(recentSearchesProvider);
    final statsAsync = ref.watch(photoStatsProvider);
    final countsAsync = ref.watch(categoryCountsProvider);
    final pinnedAsync = ref.watch(pinnedPhotosProvider);
    final settingsAsync = ref.watch(appSettingsProvider);
    final progress = ref.watch(indexProgressProvider);
    final formatter = NumberFormat.decimalPattern('ru');
    final typing = _controller.text.trim().isNotEmpty;
    final style = _HomeStyle.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              children: [
                const _HomeBrand(),
                const SizedBox(height: 22),
                _InlineSearchField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onFilters: widget.onOpenFilters,
                  onSubmitted: _submit,
                ),
              ],
            ),
          ),
        ),
        if (typing && _hot.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Горячий поиск',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: style.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in _hot)
                        ActionChip(
                          label: Text(item),
                          backgroundColor: style.card,
                          side: BorderSide(color: style.border),
                          labelStyle: TextStyle(
                            color: style.text,
                            fontWeight: FontWeight.w500,
                          ),
                          onPressed: () {
                            _controller.text = item;
                            _submit(item);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (!typing) ...[
          ref.watch(expiringSoonProvider).when(
            data: (expiring) {
              if (expiring.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _HabitRail(
                    title: 'Скоро истекает',
                    photos: expiring,
                    onOpenPhoto: widget.onOpenPhoto,
                  ),
                ),
              );
            },
            loading: () =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
          ref.watch(yesterdayDocumentsProvider).when(
            data: (yesterday) {
              if (yesterday.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _HabitRail(
                    title: 'Вчерашнее важное',
                    photos: yesterday,
                    onOpenPhoto: widget.onOpenPhoto,
                    trailingAction: (
                      label: 'Вчерашний чек',
                      onTap: () => widget.onOpenResults('чек вчера'),
                    ),
                  ),
                ),
              );
            },
            loading: () =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
          ref.watch(recentDocumentsProvider).when(
            data: (recent) {
              if (recent.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _HabitRail(
                    title: 'Недавно важное',
                    photos: recent,
                    onOpenPhoto: widget.onOpenPhoto,
                  ),
                ),
              );
            },
            loading: () =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
          pinnedAsync.when(
            data: (pinned) {
              if (pinned.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _HabitRail(
                    title: 'Закреплённые',
                    photos: pinned,
                    onOpenPhoto: widget.onOpenPhoto,
                  ),
                ),
              );
            },
            loading: () =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.push(RoutePaths.scanDocument),
                  icon: Icon(
                    Icons.add_a_photo_outlined,
                    color: style.accent,
                    size: 20,
                  ),
                  label: Text(
                    'Добавить важное фото',
                    style: TextStyle(
                      color: style.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Коллекции',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: style.text,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: countsAsync.when(
                loading: () => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final item = widget.categories[index];
                    return _CategoryTile(
                      item: item,
                      count: null,
                      onTap: () => widget.onOpenCategory(item.label),
                    );
                  },
                ),
                error: (_, __) => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final item = widget.categories[index];
                    return _CategoryTile(
                      item: item,
                      count: null,
                      onTap: () => widget.onOpenCategory(item.label),
                    );
                  },
                ),
                data: (counts) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, index) {
                      final item = widget.categories[index];
                      return _CategoryTile(
                        item: item,
                        count: _collectionCount(item.label, counts),
                        onTap: () => widget.onOpenCategory(item.label),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          ContainedSliver(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: statsAsync.when(
                loading: () => SizedBox(height: 148),
                error: (_, __) => AppRetryState(
                  message: 'Не удалось загрузить статистику',
                  textColor: _HomeStyle.of(context).label,
                  onRetry: () => ref.invalidate(photoStatsProvider),
                ),
                data: (stats) {
                  final permissionGranted =
                      settingsAsync.asData?.value.permissionGranted ?? true;
                  if (!permissionGranted) {
                    return _AccessCard(
                      onOpen: () => context.go(RoutePaths.permission),
                    );
                  }
                  final liveFraction = progress.stage == IndexingStage.deep
                      ? 1.0
                      : progress.total > 0
                      ? progress.fraction
                      : (stats.photos <= 0
                            ? 0.0
                            : (stats.indexed / stats.photos).clamp(0.0, 1.0));
                  final percent = (liveFraction * 100).round();
                  final indexedCount = stats.indexed > 0
                      ? stats.indexed
                      : progress.processed;
                  final counts = countsAsync.asData?.value ?? const <String, int>{};
                  var documents = 0;
                  for (final category in CategoryEngine.documentFamily) {
                    documents += counts[category] ?? 0;
                  }

                      final sampleHint =
                      ref.watch(sampleMemoryHintProvider).asData?.value;
                  return _MemoryStatusCard(
                    rememberedLabel: formatter.format(indexedCount),
                    withTextLabel: formatter.format(stats.withOcr),
                    documentsLabel: formatter.format(documents),
                    progress: liveFraction,
                    percent: percent,
                    isRunning: progress.isRunning,
                    status: progress.status,
                    stage: progress.stage,
                    errorMessage: progress.errorMessage,
                    sampleHint: sampleHint,
                    onTrySample: sampleHint == null
                        ? null
                        : () => widget.onOpenResults(sampleHint),
                    onResume: () =>
                        ref.read(indexProgressProvider.notifier).start(),
                  );
                },
              ),
            ),
          ),
          recentAsync.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (items) {
              if (items.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox(height: 28));
              }
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Последние поиски',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: style.text,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              await ref
                                  .read(searchHistoryRepositoryProvider)
                                  .clear();
                              ref.invalidate(recentSearchesProvider);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: _HomeStyle.of(context).accent,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Очистить',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final item in items)
                            _RecentChip(
                              label: item.query,
                              onTap: () => _submit(item.query),
                              onRemove: () async {
                                await ref
                                    .read(searchHistoryRepositoryProvider)
                                    .remove(item.id);
                                ref.invalidate(recentSearchesProvider);
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
      ],
    );
  }
}

/// Tiny helper so padding widgets stay SliverToBoxAdapter without noise.
class ContainedSliver extends StatelessWidget {
  const ContainedSliver({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(child: child);
}

class _HomeBrand extends StatelessWidget {
  const _HomeBrand();

  @override
  Widget build(BuildContext context) {
    final style = _HomeStyle.of(context);
    return Center(
      child: Text.rich(
        textAlign: TextAlign.center,
        TextSpan(
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -0.5,
          ),
          children: [
            TextSpan(
              text: 'Pin',
              style: TextStyle(color: style.text),
            ),
            TextSpan(
              text: 'Pic',
              style: TextStyle(color: style.accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineSearchField extends StatelessWidget {
  const _InlineSearchField({
    required this.controller,
    required this.focusNode,
    required this.onFilters,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onFilters;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final style = _HomeStyle.of(context);
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: style.searchFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.border, width: 1.2),
      ),
      alignment: Alignment.center,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final hasText = controller.text.isNotEmpty;
          return TextField(
            controller: controller,
            focusNode: focusNode,
            textInputAction: TextInputAction.search,
            onSubmitted: onSubmitted,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: style.text,
              letterSpacing: -0.2,
            ),
            cursorColor: style.accent,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.transparent,
              hintText: 'Что вы помните?',
              hintStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: style.muted,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: style.muted,
                size: 26,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasText)
                    IconButton(
                      tooltip: 'Очистить',
                      onPressed: controller.clear,
                      icon: Icon(
                        Icons.close_rounded,
                        color: style.muted,
                        size: 22,
                      ),
                    ),
                  IconButton(
                    onPressed: onFilters,
                    icon: Icon(
                      Icons.tune_rounded,
                      color: style.accent,
                      size: 24,
                    ),
                  ),
                ],
              ),
              suffixIconConstraints: BoxConstraints(
                minWidth: hasText ? 100 : 52,
                minHeight: 56,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 52,
                minHeight: 56,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 18,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuickCategory {
  const _QuickCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

int _collectionCount(String label, Map<String, int> counts) {
  if (label == 'Документы') {
    var total = 0;
    for (final category in CategoryEngine.documentFamily) {
      total += counts[category] ?? 0;
    }
    return total;
  }
  return counts[label] ?? 0;
}

class _PinnedTile extends StatelessWidget {
  const _PinnedTile({required this.photo, required this.onTap});

  final PhotoEntity photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _HomeStyle.of(context);
    final title =
        photo.cardTitle?.trim().isNotEmpty == true
        ? photo.cardTitle!
        : (photo.category ?? photo.displayName ?? 'Документ');
    final expiry = DocumentExpiryStatus.fromDate(photo.expiresAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 168,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: style.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: style.border),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 72,
                  child: PhotoThumbnail(
                    mediaId: photo.mediaId,
                    filePath: photo.path,
                    width: 120,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.push_pin_rounded,
                          size: 12,
                          color: style.accent,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: style.text,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (expiry != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${_expiryDot(expiry.validity)} ${expiry.label}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: style.muted,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _expiryDot(DocumentValidity validity) {
    return switch (validity) {
      DocumentValidity.valid => '🟢',
      DocumentValidity.expiringSoon => '🟡',
      DocumentValidity.expired => '🔴',
    };
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.item,
    required this.onTap,
    this.count,
  });

  final _QuickCategory item;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final style = _HomeStyle.of(context);
    final showCount = count != null && count! > 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: style.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: style.border),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(item.icon, color: item.color, size: 28),
                    ),
                    if (showCount)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: item.color,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.15,
                color: style.label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitRail extends StatelessWidget {
  const _HabitRail({
    required this.title,
    required this.photos,
    required this.onOpenPhoto,
    this.trailingAction,
  });

  final String title;
  final List<PhotoEntity> photos;
  final ValueChanged<String> onOpenPhoto;
  final ({String label, VoidCallback onTap})? trailingAction;

  @override
  Widget build(BuildContext context) {
    final style = _HomeStyle.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: style.text,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            if (trailingAction != null)
              TextButton(
                onPressed: trailingAction!.onTap,
                style: TextButton.styleFrom(
                  foregroundColor: style.accent,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  trailingAction!.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final photo = photos[index];
              return _PinnedTile(
                photo: photo,
                onTap: () => onOpenPhoto(photo.mediaId),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MemoryStatusCard extends StatelessWidget {
  const _MemoryStatusCard({
    required this.rememberedLabel,
    required this.withTextLabel,
    required this.documentsLabel,
    required this.progress,
    required this.percent,
    required this.status,
    required this.stage,
    required this.onResume,
    this.isRunning = false,
    this.errorMessage,
    this.sampleHint,
    this.onTrySample,
  });

  final String rememberedLabel;
  final String withTextLabel;
  final String documentsLabel;
  final double progress;
  final int percent;
  final bool isRunning;
  final IndexingStatus status;
  final IndexingStage stage;
  final String? errorMessage;
  final VoidCallback onResume;
  final String? sampleHint;
  final VoidCallback? onTrySample;

  @override
  Widget build(BuildContext context) {
    final style = _HomeStyle.of(context);
    final headline = switch (status) {
      IndexingStatus.running =>
        stage == IndexingStage.fast
            ? 'Память собирается…'
            : 'Память уже работает',
      IndexingStatus.paused => 'Память на паузе',
      IndexingStatus.failed => 'Не удалось обновить память',
      IndexingStatus.completed => 'Память готова',
      IndexingStatus.idle =>
        progress <= 0 ? 'Память ещё пустая' : 'Память готова',
    };

    final subtitle = switch (status) {
      IndexingStatus.running =>
        stage == IndexingStage.fast
            ? 'Сначала скрины и свежее — искать можно уже сейчас'
            : 'Уточняем текст в фоне',
      IndexingStatus.paused => 'Продолжите, когда удобно',
      IndexingStatus.failed => errorMessage ?? 'Нажмите, чтобы повторить',
      IndexingStatus.completed => 'Спросите то, что помните',
      IndexingStatus.idle =>
        progress <= 0
            ? 'Откройте доступ и начните'
            : 'Спросите то, что помните',
    };

    final ready = status == IndexingStatus.completed ||
        (status == IndexingStatus.idle && progress >= 1) ||
        (status == IndexingStatus.running && stage == IndexingStage.deep);
    final busy = status == IndexingStatus.running || isRunning;
    final needsAction =
        status == IndexingStatus.failed || status == IndexingStatus.paused;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            style.accent.withValues(alpha: style == _HomeStyle.dark ? 0.18 : 0.10),
            style.card,
            style.card,
          ],
          stops: const [0.0, 0.42, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: style.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  ready
                      ? Icons.push_pin_rounded
                      : Icons.hourglass_top_rounded,
                  color: style.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: style.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: style.label,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              if (needsAction)
                IconButton(
                  onPressed: onResume,
                  tooltip: 'Продолжить',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: style.accent,
                    size: 22,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MemoryMetric(
                  value: rememberedLabel,
                  label: 'в памяти',
                ),
              ),
              _MemoryMetricDivider(color: style.border),
              Expanded(
                child: _MemoryMetric(
                  value: withTextLabel,
                  label: 'с текстом',
                ),
              ),
              _MemoryMetricDivider(color: style.border),
              Expanded(
                child: _MemoryMetric(
                  value: documentsLabel,
                  label: 'документов',
                ),
              ),
            ],
          ),
          if (busy || needsAction || (!ready && progress > 0 && progress < 1)) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress <= 0 && busy
                          ? null
                          : progress.clamp(0, 1),
                      minHeight: 6,
                      backgroundColor: style.muted.withValues(alpha: 0.16),
                      valueColor: AlwaysStoppedAnimation<Color>(style.accent),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: style.muted,
                  ),
                ),
              ],
            ),
          ],
          if (sampleHint != null && onTrySample != null) ...[
            const SizedBox(height: 14),
            Text(
              busy ? 'Уже нашлось — попробуйте' : 'Попробуйте найти',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: style.muted,
              ),
            ),
            const SizedBox(height: 8),
            ActionChip(
              avatar: Icon(
                Icons.search_rounded,
                size: 18,
                color: style.accent,
              ),
              label: Text(sampleHint!),
              backgroundColor: style.accent.withValues(alpha: 0.12),
              side: BorderSide(color: style.accent.withValues(alpha: 0.35)),
              labelStyle: TextStyle(
                color: style.text,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              onPressed: onTrySample,
            ),
          ],
        ],
      ),
    );
  }
}

class _MemoryMetric extends StatelessWidget {
  const _MemoryMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final style = _HomeStyle.of(context);
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: style.text,
            height: 1.05,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: style.muted,
          ),
        ),
      ],
    );
  }
}

class _MemoryMetricDivider extends StatelessWidget {
  const _MemoryMetricDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: color,
    );
  }
}

class _AccessCard extends StatelessWidget {
  const _AccessCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final style = _HomeStyle.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: style.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: style.border),
      ),
      child: Row(
        children: [
          Icon(Icons.photo_library_outlined, color: style.accent, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Нужен доступ к фото',
                  style: TextStyle(
                    color: style.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Разрешите доступ, чтобы начать локальный поиск.',
                  style: TextStyle(color: style.muted, height: 1.35),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onOpen, child: const Text('Открыть')),
        ],
      ),
    );
  }
}

class _RecentChip extends StatelessWidget {
  const _RecentChip({
    required this.label,
    required this.onTap,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final style = _HomeStyle.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: style.searchFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: style.border),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: style.text,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onRemove,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: style.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeBottomNav extends StatelessWidget {
  const _HomeBottomNav({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final style = _HomeStyle.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.bg,
        border: Border(top: BorderSide(color: style.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.search_rounded,
                  label: 'Поиск',
                  selected: index == 0,
                  onTap: () => onChanged(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.star_outline_rounded,
                  label: 'Избранное',
                  selected: index == 1,
                  onTap: () => onChanged(1),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.settings_outlined,
                  label: 'Настройки',
                  selected: index == 2,
                  onTap: () => onChanged(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? _HomeStyle.of(context).accent
        : _HomeStyle.of(context).muted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesTab extends ConsumerStatefulWidget {
  const _FavoritesTab({
    required this.onOpenPhoto,
    required this.onGoSearch,
  });

  final ValueChanged<String> onOpenPhoto;
  final VoidCallback onGoSearch;

  @override
  ConsumerState<_FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends ConsumerState<_FavoritesTab> {
  static const _pageSize = 30;
  final _controller = ScrollController();
  final _items = <PhotoEntity>[];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(reset: true));
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_controller.position.extentAfter < 400 &&
        _hasMore &&
        !_loading &&
        !_loadingMore) {
      _load();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _items.clear();
      });
    } else {
      setState(() => _loadingMore = true);
    }
    try {
      final page = await ref
          .read(photoRepositoryProvider)
          .getFavorites(offset: reset ? 0 : _items.length, limit: _pageSize);
      if (!mounted) return;
      setState(() {
        _items.addAll(page);
        _hasMore = page.length == _pageSize;
        _loading = false;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = 'Не удалось загрузить избранное';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(favoritesProvider, (previous, next) {
      if (previous != null && next.hasValue) {
        _load(reset: true);
      }
    });

    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return AppRetryState(
        message: _error!,
        textColor: _HomeStyle.of(context).label,
        onRetry: () => _load(reset: true),
      );
    }
    if (_items.isEmpty) {
      return AppEmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'Избранное пусто',
        description:
            'Отметьте важное фото звёздочкой — оно появится здесь.',
        primaryLabel: 'К поиску',
        onPrimary: widget.onGoSearch,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: GridView.builder(
        controller: _controller,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: _items.length + (_loadingMore ? 3 : 0),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final photo = _items[index];
          return GestureDetector(
            onTap: () => widget.onOpenPhoto(photo.mediaId),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: PhotoThumbnail(
                mediaId: photo.mediaId,
                filePath: photo.path,
                width: 300,
                height: 300,
              ),
            ),
          );
        },
      ),
    );
  }
}
