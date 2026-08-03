import 'package:pinpic/core/constants/app_constants.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/fuzzy_matcher.dart';
import 'package:pinpic/services/memory_query_parser.dart';
import 'package:pinpic/services/ranking_engine.dart';
import 'package:pinpic/services/synonym_engine.dart';
import 'package:pinpic/services/vector_search_service.dart';
import 'package:pinpic/shared/models/photo_entity.dart';
import 'package:pinpic/shared/repositories/photo_repository.dart';
import 'package:pinpic/shared/repositories/search_history_repository.dart';

class SearchHit {
  const SearchHit({
    required this.photo,
    required this.score,
    required this.reason,
    required this.confidence,
    this.evidence = const [],
    this.isSimilar = false,
  });

  final PhotoEntity photo;
  final double score;
  final String reason;
  final int confidence;
  final List<String> evidence;
  final bool isSimilar;
}

class SearchPage {
  const SearchPage({
    required this.items,
    required this.nextOffset,
    required this.hasMore,
    required this.total,
    required this.isSimilarFallback,
  });

  final List<SearchHit> items;
  final int nextOffset;
  final bool hasMore;
  final int total;
  final bool isSimilarFallback;
}

class _CacheEntry<T> {
  const _CacheEntry(this.value, this.createdAt);

  final T value;
  final DateTime createdAt;

  bool get isFresh =>
      DateTime.now().difference(createdAt) < const Duration(minutes: 2);
}

class SearchService {
  SearchService({
    required PhotoRepository photoRepository,
    required SearchHistoryRepository historyRepository,
    SynonymEngine? synonymEngine,
    FuzzyMatcher? fuzzyMatcher,
    RankingEngine? rankingEngine,
    VectorSearchService? vectorSearchService,
    MemoryQueryParser? queryParser,
  }) : _photos = photoRepository,
       _history = historyRepository,
       _synonyms = synonymEngine ?? SynonymEngine(),
       _fuzzy = fuzzyMatcher ?? FuzzyMatcher(),
       _ranking = rankingEngine ?? RankingEngine(),
       _vectors =
           vectorSearchService ??
           VectorSearchService(photoRepository: photoRepository),
       _parser =
           queryParser ??
           MemoryQueryParser(synonymEngine: synonymEngine ?? SynonymEngine());

  final PhotoRepository _photos;
  final SearchHistoryRepository _history;
  final SynonymEngine _synonyms;
  final FuzzyMatcher _fuzzy;
  final RankingEngine _ranking;
  final MemoryQueryParser _parser;
  final VectorSearchService _vectors;
  final Map<String, _CacheEntry<List<SearchHit>>> _resultCache = {};
  final Map<String, _CacheEntry<List<String>>> _suggestionCache = {};
  _CacheEntry<Set<String>>? _vocabularyCache;

  Future<List<SearchHit>> search(
    String rawQuery, {
    String? category,
    bool favoritesOnly = false,
    int limit = AppConstants.searchPageSize,
  }) async {
    final page = await searchPage(
      rawQuery,
      category: category,
      favoritesOnly: favoritesOnly,
      limit: limit,
    );
    return page.items;
  }

  Future<SearchPage> searchPage(
    String rawQuery, {
    String? category,
    bool favoritesOnly = false,
    int offset = 0,
    int limit = AppConstants.searchPageSize,
  }) async {
    final query = rawQuery.trim();
    if (query.isEmpty && category == null && !favoritesOnly) {
      return const SearchPage(
        items: [],
        nextOffset: 0,
        hasMore: false,
        total: 0,
        isSimilarFallback: false,
      );
    }

    final memoryQuery = _parser.parse(query);
    final cacheKey =
        '${memoryQuery.cleaned}|${memoryQuery.dateFrom}|${memoryQuery.dateTo}|'
        '${category ?? ''}|$favoritesOnly';
    var cached = _resultCache[cacheKey];
    if (cached == null || !cached.isFresh) {
      final ranked = await _buildRankedResults(
        memoryQuery,
        category: category,
        favoritesOnly: favoritesOnly,
      );
      cached = _CacheEntry(ranked, DateTime.now());
      _resultCache[cacheKey] = cached;
    }

    final hits = cached.value;
    final safeOffset = offset.clamp(0, hits.length);
    final end = (safeOffset + limit).clamp(0, hits.length);
    final items = hits.sublist(safeOffset, end);
    final similarFallback =
        hits.isNotEmpty && hits.every((hit) => hit.isSimilar);
    return SearchPage(
      items: items,
      nextOffset: end,
      hasMore: end < hits.length,
      total: hits.length,
      isSimilarFallback: similarFallback,
    );
  }

  Future<List<String>> suggestions(String rawPrefix) async {
    final memory = _parser.parse(rawPrefix);
    final prefix = memory.cleaned.isNotEmpty
        ? memory.cleaned
        : _synonyms.normalize(rawPrefix);
    if (prefix.isEmpty) {
      final recent = await _history.getRecent(limit: 6);
      return recent.map((e) => e.query).toList(growable: false);
    }

    final cached = _suggestionCache[prefix];
    if (cached != null && cached.isFresh) return cached.value;

    final fromKeywords = await _photos.suggestKeywords(
      prefix,
      limit: AppConstants.suggestionsLimit,
    );
    final recent = await _history.getRecent(limit: 12);
    final merged = <String>{};

    for (final item in recent) {
      final recentClean = _parser.parse(item.query).cleaned;
      if (item.query.toLowerCase().startsWith(prefix) ||
          recentClean.startsWith(prefix)) {
        merged.add(item.query);
      }
    }
    for (final keyword in fromKeywords) {
      merged.add(keyword);
    }

    if (merged.length < AppConstants.suggestionsLimit && prefix.length >= 3) {
      final vocabulary = await _vocabulary();
      for (final keyword in vocabulary) {
        if (_fuzzy.isMatch(prefix, keyword)) merged.add(keyword);
        if (merged.length >= AppConstants.suggestionsLimit) break;
      }
    }

    final result = merged
        .take(AppConstants.suggestionsLimit)
        .toList(growable: false);
    _suggestionCache[prefix] = _CacheEntry(result, DateTime.now());
    return result;
  }

  Future<void> remember(String query, {int resultCount = 0}) {
    return _history.add(query: query, resultCount: resultCount);
  }

  void invalidateCaches() {
    _resultCache.clear();
    _suggestionCache.clear();
    _vocabularyCache = null;
  }

  Future<List<SearchHit>> _buildRankedResults(
    MemoryQuery memoryQuery, {
    String? category,
    required bool favoritesOnly,
  }) async {
    final originalTokens = memoryQuery.meaningfulTokens;
    final expandedTokens = {
      ..._synonyms.expand(originalTokens),
      ...memoryQuery.digitTokens,
    };
    final inferredCategories = category == null
        ? CategoryEngine.inferCategoriesFromTokens(expandedTokens)
        : [category];
    final semanticFuture = originalTokens.isEmpty
        ? Future.value(const <SemanticCandidate>[])
        : _vectors.search(originalTokens);

    var candidates = await _photos.searchCandidatesForTokens(
      tokens: expandedTokens,
      category: category,
      favoritesOnly: favoritesOnly,
    );
    final fuzzyCandidateIds = <String>{};
    final semanticScores = <String, double>{};

    if (category == null && inferredCategories.isNotEmpty) {
      final merged = <String, PhotoEntity>{
        for (final photo in candidates) photo.mediaId: photo,
      };
      for (final inferredCategory in inferredCategories) {
        final byCategory = await _photos.searchCandidatesForTokens(
          tokens: const {},
          category: inferredCategory,
          favoritesOnly: favoritesOnly,
        );
        for (final photo in byCategory) {
          merged[photo.mediaId] = photo;
        }
      }
      candidates = merged.values.toList(growable: false);
    }

    // QR intent: also pull every photo where a code was actually decoded,
    // even if category was overwritten (e.g. ticket + QR → Билеты).
    final wantsQr = expandedTokens.any(
      (token) =>
          token == 'qr' ||
          token.startsWith('qr') ||
          token.contains('qrкод') ||
          token.contains('qr-код') ||
          token == 'barcode' ||
          token == 'штрихкод',
    );
    if (wantsQr && category == null) {
      final withQr = await _photos.getWithQr(limit: 200);
      final merged = <String, PhotoEntity>{
        for (final photo in candidates) photo.mediaId: photo,
      };
      for (final photo in withQr) {
        if (favoritesOnly && !photo.isFavorite) continue;
        merged[photo.mediaId] = photo;
      }
      candidates = merged.values.toList(growable: false);
    }

    // Fuzzy recall when empty or thin — user typed from imperfect memory.
    final needsFuzzy =
        originalTokens.isNotEmpty &&
        (candidates.isEmpty || candidates.length < 8);
    if (needsFuzzy) {
      final vocabulary = await _vocabulary();
      final fuzzyTokens = <String>{};
      for (final token in originalTokens) {
        if (token.length < 3) continue;
        for (final keyword in vocabulary) {
          if (_fuzzy.isMatch(token, keyword)) fuzzyTokens.add(keyword);
          if (fuzzyTokens.length >= 40) break;
        }
        if (fuzzyTokens.length >= 40) break;
      }
      if (fuzzyTokens.isNotEmpty) {
        final fuzzyHits = await _photos.searchCandidatesForTokens(
          tokens: fuzzyTokens,
          category: category,
          favoritesOnly: favoritesOnly,
        );
        final merged = <String, PhotoEntity>{
          for (final photo in candidates) photo.mediaId: photo,
        };
        for (final photo in fuzzyHits) {
          if (!merged.containsKey(photo.mediaId)) {
            fuzzyCandidateIds.add(photo.mediaId);
          }
          merged[photo.mediaId] = photo;
        }
        candidates = merged.values.toList(growable: false);
        expandedTokens.addAll(fuzzyTokens);
      }
    }

    if (originalTokens.isNotEmpty && candidates.isEmpty) {
      final semantic = await semanticFuture;
      final merged = <String, PhotoEntity>{};
      for (final candidate in semantic) {
        final photo = candidate.photo;
        if (favoritesOnly && !photo.isFavorite) continue;
        if (category != null && photo.category != category) continue;
        semanticScores[photo.mediaId] = candidate.similarity;
        merged[photo.mediaId] = photo;
      }
      candidates = merged.values.toList(growable: false);
    }

    // Soft date filter: keep dated hits inside the remembered window.
    if (memoryQuery.hasDateHint) {
      final from = memoryQuery.dateFrom;
      final to = memoryQuery.dateTo;
      final dated = <PhotoEntity>[];
      final undated = <PhotoEntity>[];
      for (final photo in candidates) {
        final taken = photo.dateTaken;
        if (taken == null) {
          undated.add(photo);
          continue;
        }
        final inRange =
            (from == null || !taken.isBefore(from)) &&
            (to == null || taken.isBefore(to));
        if (inRange) {
          dated.add(photo);
        }
      }
      // Prefer dated matches; keep a few undated only if nothing dated hit.
      candidates = dated.isNotEmpty
          ? dated
          : undated.take(12).toList(growable: false);
    }

    final hits = <SearchHit>[];
    final rankingQuery = memoryQuery.cleaned.isNotEmpty
        ? memoryQuery.cleaned
        : memoryQuery.raw.toLowerCase().replaceAll('ё', 'е');
    for (final photo in candidates) {
      final rank = _ranking.rank(
        photo: photo,
        normalizedQuery: rankingQuery,
        originalTokens: originalTokens,
        expandedTokens: expandedTokens,
        similarFallback: fuzzyCandidateIds.contains(photo.mediaId),
        categoryFilter: inferredCategories.contains(photo.category)
            ? photo.category
            : null,
        semanticSimilarity: semanticScores[photo.mediaId] ?? 0,
      );
      if (rank.score <= 0 && originalTokens.isNotEmpty) {
        continue;
      }
      var score = rank.score;
      // Amount memory: boost when query digits appear in entity/OCR signals.
      if (memoryQuery.digitTokens.isNotEmpty) {
        final hay = [
          ...photo.entityTokens,
          ...photo.ocrKeywords,
          photo.ocrText ?? '',
          photo.cardBody ?? '',
        ].join(' ').replaceAll(RegExp(r'\s+'), '');
        for (final digit in memoryQuery.digitTokens) {
          if (hay.contains(digit)) {
            score += 8;
            break;
          }
        }
      }
      hits.add(
        SearchHit(
          photo: photo,
          score: score,
          confidence: rank.confidence,
          reason: rank.reason,
          evidence: rank.evidence,
          isSimilar: rank.isSimilar,
        ),
      );
    }
    hits.sort((a, b) {
      final byPin = (b.photo.isPinned ? 1 : 0).compareTo(
        a.photo.isPinned ? 1 : 0,
      );
      if (byPin != 0) return byPin;
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final aDate = a.photo.dateTaken ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.photo.dateTaken ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    // Never leave a free-text search empty if memory already has something.
    if (hits.isEmpty &&
        originalTokens.isNotEmpty &&
        !favoritesOnly) {
      return _antiEmptyRescue(
        category: category,
        inferredCategories: inferredCategories,
      );
    }
    return hits;
  }

  /// Approximate / recent / category neighbours — better than a blank screen.
  Future<List<SearchHit>> _antiEmptyRescue({
    String? category,
    required List<String> inferredCategories,
  }) async {
    final merged = <String, PhotoEntity>{};

    Future<void> take(List<PhotoEntity> photos) async {
      for (final photo in photos) {
        merged.putIfAbsent(photo.mediaId, () => photo);
        if (merged.length >= 24) return;
      }
    }

    if (category != null) {
      await take(
        await _photos.searchCandidatesForTokens(
          tokens: const {},
          category: category,
          favoritesOnly: false,
        ),
      );
    }
    for (final inferred in inferredCategories) {
      if (merged.length >= 24) break;
      await take(
        await _photos.searchCandidatesForTokens(
          tokens: const {},
          category: inferred,
          favoritesOnly: false,
        ),
      );
    }
    if (merged.length < 12) {
      await take(await _photos.getRecentDocuments(limit: 24));
    }
    if (merged.length < 8) {
      await take(await _photos.getPinned(limit: 16));
    }
    if (merged.isEmpty) {
      await take(await _photos.semanticCandidatePool(limit: 24));
    }

    final rescued = merged.values.toList(growable: false)
      ..sort((a, b) {
        final byPin = (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0);
        if (byPin != 0) return byPin;
        final aDate = a.dateTaken ?? a.indexedAt;
        final bDate = b.dateTaken ?? b.indexedAt;
        return bDate.compareTo(aDate);
      });

    return [
      for (final photo in rescued.take(20))
        SearchHit(
          photo: photo,
          score: 1,
          confidence: 32,
          reason: 'Близко',
          evidence: const ['не точное совпадение'],
          isSimilar: true,
        ),
    ];
  }

  Future<Set<String>> _vocabulary() async {
    final cached = _vocabularyCache;
    if (cached != null && cached.isFresh) return cached.value;
    final vocabulary = await _photos.keywordVocabulary();
    final entityPool = await _photos.semanticCandidatePool(limit: 800);
    final enriched = {
      ...vocabulary,
      for (final photo in entityPool)
        for (final token in photo.entityTokens)
          if (token.trim().length >= 3) token.toLowerCase(),
    };
    _vocabularyCache = _CacheEntry(enriched, DateTime.now());
    return enriched;
  }
}
