import 'package:pinpic/core/constants/app_constants.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/fuzzy_matcher.dart';
import 'package:pinpic/services/ranking_engine.dart';
import 'package:pinpic/services/synonym_engine.dart';
import 'package:pinpic/shared/models/photo_entity.dart';
import 'package:pinpic/shared/repositories/photo_repository.dart';
import 'package:pinpic/shared/repositories/search_history_repository.dart';

class SearchHit {
  const SearchHit({
    required this.photo,
    required this.score,
    required this.reason,
    required this.confidence,
    this.isSimilar = false,
  });

  final PhotoEntity photo;
  final double score;
  final String reason;
  final int confidence;
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
  }) : _photos = photoRepository,
       _history = historyRepository,
       _synonyms = synonymEngine ?? SynonymEngine(),
       _fuzzy = fuzzyMatcher ?? FuzzyMatcher(),
       _ranking = rankingEngine ?? RankingEngine();

  final PhotoRepository _photos;
  final SearchHistoryRepository _history;
  final SynonymEngine _synonyms;
  final FuzzyMatcher _fuzzy;
  final RankingEngine _ranking;
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

    final normalizedQuery = _synonyms.normalize(query);
    final cacheKey = '$normalizedQuery|${category ?? ''}|$favoritesOnly';
    var cached = _resultCache[cacheKey];
    if (cached == null || !cached.isFresh) {
      final ranked = await _buildRankedResults(
        normalizedQuery,
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
    return SearchPage(
      items: items,
      nextOffset: end,
      hasMore: end < hits.length,
      total: hits.length,
      isSimilarFallback:
          items.isNotEmpty && items.every((hit) => hit.isSimilar),
    );
  }

  Future<List<String>> suggestions(String rawPrefix) async {
    final prefix = _synonyms.normalize(rawPrefix);
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
      if (item.query.toLowerCase().startsWith(prefix)) {
        merged.add(item.query);
      }
    }
    for (final keyword in fromKeywords) {
      merged.add(keyword);
    }

    if (merged.length < AppConstants.suggestionsLimit && prefix.length >= 4) {
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
    String normalizedQuery, {
    String? category,
    required bool favoritesOnly,
  }) async {
    final originalTokens = _tokenize(normalizedQuery);
    final expandedTokens = _synonyms.expand(originalTokens);
    // "билет" expands to include "билеты" → infer «Билеты» so category-tagged
    // photos still match even when OCR never stored the word itself.
    final inferredCategory =
        category ?? CategoryEngine.inferFromTokens(expandedTokens);

    var candidates = await _photos.searchCandidatesForTokens(
      tokens: expandedTokens,
      category: category,
      favoritesOnly: favoritesOnly,
    );
    var similarFallback = false;

    if (category == null && inferredCategory != null) {
      final byCategory = await _photos.searchCandidatesForTokens(
        tokens: const {},
        category: inferredCategory,
        favoritesOnly: favoritesOnly,
      );
      if (byCategory.isNotEmpty) {
        final merged = <String, PhotoEntity>{
          for (final photo in candidates) photo.mediaId: photo,
          for (final photo in byCategory) photo.mediaId: photo,
        };
        candidates = merged.values.toList(growable: false);
      }
    }

    if (candidates.isEmpty && originalTokens.isNotEmpty) {
      final vocabulary = await _vocabulary();
      final fuzzyTokens = <String>{};
      for (final token in originalTokens) {
        for (final keyword in vocabulary) {
          if (_fuzzy.isMatch(token, keyword)) fuzzyTokens.add(keyword);
          if (fuzzyTokens.length >= 20) break;
        }
      }
      if (fuzzyTokens.isNotEmpty) {
        candidates = await _photos.searchCandidatesForTokens(
          tokens: fuzzyTokens,
          category: category,
          favoritesOnly: favoritesOnly,
        );
        expandedTokens.addAll(fuzzyTokens);
        similarFallback = candidates.isNotEmpty;
      }
    }

    // Intentionally no "dump the whole gallery as similar" fallback.
    // Returning empty is better than a plant + lion labeled 35% for «билет».

    final hits = <SearchHit>[];
    for (final photo in candidates) {
      final rank = _ranking.rank(
        photo: photo,
        normalizedQuery: normalizedQuery,
        originalTokens: originalTokens,
        expandedTokens: expandedTokens,
        similarFallback: similarFallback,
        categoryFilter: inferredCategory,
      );
      // Drop noise that only got a similar-fallback participation trophy.
      if (similarFallback && rank.score < 30) continue;
      if (rank.score <= 0 && !similarFallback && originalTokens.isNotEmpty) {
        continue;
      }
      hits.add(
        SearchHit(
          photo: photo,
          score: rank.score,
          confidence: rank.confidence,
          reason: rank.reason,
          isSimilar: similarFallback,
        ),
      );
    }
    hits.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final aDate = a.photo.dateTaken ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.photo.dateTaken ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return hits;
  }

  Future<Set<String>> _vocabulary() async {
    final cached = _vocabularyCache;
    if (cached != null && cached.isFresh) return cached.value;
    final vocabulary = await _photos.keywordVocabulary();
    _vocabularyCache = _CacheEntry(vocabulary, DateTime.now());
    return vocabulary;
  }

  Set<String> _tokenize(String query) {
    return query
        .toLowerCase()
        .split(RegExp(r'[^a-zA-Zа-яА-ЯёЁ0-9]+'))
        .map((e) => e.trim())
        .where((e) => e.length >= 2)
        .toSet();
  }
}
