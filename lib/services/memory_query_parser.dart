import 'package:pinpic/services/synonym_engine.dart';

/// Parsed "what I remember" query: fillers stripped, digits kept, tokens ready.
class MemoryQuery {
  const MemoryQuery({
    required this.raw,
    required this.cleaned,
    required this.tokens,
    required this.digitTokens,
    required this.meaningfulTokens,
    this.dateFrom,
    this.dateTo,
  });

  final String raw;
  final String cleaned;
  final Set<String> tokens;
  final Set<String> digitTokens;

  /// Tokens that should drive search (stop-words removed). Falls back to
  /// [tokens] when the user only typed fillers + one keyword.
  final Set<String> meaningfulTokens;

  /// Inclusive calendar range from phrases like «вчера», «в январе».
  final DateTime? dateFrom;
  final DateTime? dateTo;

  bool get isEmpty => meaningfulTokens.isEmpty && digitTokens.isEmpty;

  bool get hasDateHint => dateFrom != null || dateTo != null;
}

/// Turns colloquial memory phrases into searchable tokens.
///
/// Examples:
/// - «найди где тот чек из икеи» → {чек, икеи} (+ synonym expand later)
/// - «примерно 4990» / «чек на 2.4к» → digits {4990} / {2400}
/// - «паспрот» stays as token for fuzzy
/// - «вчера», «прошлой зимой» → [dateFrom, dateTo]
class MemoryQueryParser {
  MemoryQueryParser({SynonymEngine? synonymEngine})
    : _synonyms = synonymEngine ?? SynonymEngine();

  final SynonymEngine _synonyms;

  static final _split = RegExp(r'[^a-zA-Zа-яА-ЯёЁ0-9+@._-]+');
  static final _digits = RegExp(r'\d{3,}');

  /// Conversational fillers people type around the real memory.
  static const stopWords = <String>{
    'найди',
    'найти',
    'искать',
    'поиск',
    'где',
    'куда',
    'покажи',
    'открой',
    'дай',
    'мне',
    'пожалуйста',
    'плиз',
    'этот',
    'эта',
    'это',
    'эти',
    'тот',
    'та',
    'те',
    'там',
    'тут',
    'здесь',
    'был',
    'была',
    'было',
    'были',
    'есть',
    'какой',
    'какая',
    'какие',
    'какое',
    'который',
    'которая',
    'примерно',
    'типа',
    'вроде',
    'что',
    'ли',
    'нужен',
    'нужна',
    'нужно',
    'хочу',
    'можешь',
    'можно',
    'надо',
    'ну',
    'как',
    'бы',
    'же',
    'уже',
    'ещё',
    'еще',
    'из',
    'от',
    'для',
    'про',
    'под',
    'над',
    'без',
    'при',
    'фото',
    'фотку',
    'фотка',
    'картинку',
    'снимок',
    'скрин',
    'скриншот',
    'на',
    'find',
    'where',
    'show',
    'open',
    'please',
    'the',
    'a',
    'an',
    'my',
    'from',
    'with',
    'for',
    'and',
    'or',
    'that',
    'this',
    // Date words are stripped after range extraction.
    'вчера',
    'сегодня',
    'позавчера',
    'неделе',
    'неделя',
    'неделю',
    'прошлой',
    'прошлый',
    'прошлая',
    'прошлом',
    'этой',
    'этом',
    'этим',
    'зимой',
    'зима',
    'летом',
    'лето',
    'весной',
    'весна',
    'осенью',
    'осень',
    'январе',
    'феврале',
    'марте',
    'апреле',
    'мае',
    'июне',
    'июле',
    'августе',
    'сентябре',
    'октябре',
    'ноябре',
    'декабре',
    'января',
    'февраля',
    'марта',
    'апреля',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
    'тыс',
    'тысяч',
    'тысячи',
    'тысячу',
  };

  static const _months = <String, int>{
    'январ': 1,
    'феврал': 2,
    'март': 3,
    'апрел': 4,
    'мае': 5,
    'май': 5,
    'мая': 5,
    'июн': 6,
    'июл': 7,
    'август': 8,
    'сентябр': 9,
    'октябр': 10,
    'ноябр': 11,
    'декабр': 12,
  };

  MemoryQuery parse(String raw, {DateTime? now}) {
    final clock = now ?? DateTime.now();
    final normalized = _synonyms.normalize(raw.trim());
    final dateRange = _extractDateRange(normalized.toLowerCase(), clock);

    // «4 990» → «4990»; «2.4к» / «2,4к» → «2400»
    var collapsed = normalized.replaceAllMapped(
      RegExp(r'(\d{1,3}(?:\s\d{3})+)'),
      (match) => match.group(0)!.replaceAll(RegExp(r'\s+'), ''),
    );
    // Cyrillic «к» is not a \w char in Dart, so avoid \b after it.
    collapsed = collapsed.replaceAllMapped(
      RegExp(
        r'(\d+[.,]\d+)\s*[kк](?![a-zA-Zа-яА-ЯёЁ0-9])',
        caseSensitive: false,
      ),
      (match) {
        final n = double.tryParse(match.group(1)!.replaceAll(',', '.'));
        if (n == null) return match.group(0)!;
        return (n * 1000).round().toString();
      },
    );
    collapsed = collapsed.replaceAllMapped(
      RegExp(r'(\d+)\s*[kк](?![a-zA-Zа-яА-ЯёЁ0-9])', caseSensitive: false),
      (match) {
        final n = int.tryParse(match.group(1)!);
        if (n == null) return match.group(0)!;
        return (n * 1000).toString();
      },
    );
    // «5 тысяч» → keep digit expansion via nearby number × 1000
    collapsed = collapsed.replaceAllMapped(
      RegExp(
        r'(\d+)\s*(?:тыс|тысяч|тысячи|тысячу)(?![a-zA-Zа-яА-ЯёЁ])',
        caseSensitive: false,
      ),
      (match) {
        final n = int.tryParse(match.group(1)!);
        if (n == null) return match.group(0)!;
        return (n * 1000).toString();
      },
    );

    final digitTokens = {
      for (final match in _digits.allMatches(collapsed)) match.group(0)!,
    };

    final allTokens = <String>{};
    for (final rawToken in collapsed.toLowerCase().split(_split)) {
      final token = rawToken.trim().replaceAll('ё', 'е');
      if (token.length < 2) continue;
      if (RegExp(r'^\d+$').hasMatch(token) && token.length < 3) continue;
      allTokens.add(token);
    }

    final meaningful = allTokens
        .where((token) => !stopWords.contains(token))
        .toSet();

    final driving = meaningful.isNotEmpty ? meaningful : allTokens;

    return MemoryQuery(
      raw: raw,
      cleaned: driving.join(' '),
      tokens: allTokens,
      digitTokens: digitTokens,
      meaningfulTokens: {...driving, ...digitTokens},
      dateFrom: dateRange?.$1,
      dateTo: dateRange?.$2,
    );
  }

  (DateTime, DateTime)? _extractDateRange(String lower, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);

    if (lower.contains('сегодня')) {
      return (today, today.add(const Duration(days: 1)));
    }
    if (lower.contains('позавчера')) {
      final day = today.subtract(const Duration(days: 2));
      return (day, day.add(const Duration(days: 1)));
    }
    if (lower.contains('вчера')) {
      final day = today.subtract(const Duration(days: 1));
      return (day, day.add(const Duration(days: 1)));
    }
    if (lower.contains('прошлой недел') || lower.contains('прошлая недел')) {
      final weekday = today.weekday; // 1=Mon
      final startThisWeek = today.subtract(Duration(days: weekday - 1));
      final start = startThisWeek.subtract(const Duration(days: 7));
      return (start, startThisWeek);
    }
    if (lower.contains('этой недел') || lower.contains('эта недел')) {
      final weekday = today.weekday;
      final start = today.subtract(Duration(days: weekday - 1));
      return (start, today.add(const Duration(days: 1)));
    }

    // Seasons (word-safe stems — avoid matching «билет» via «лет»).
    final past = lower.contains('прошл');
    if (RegExp(r'зим').hasMatch(lower)) {
      final endYear = past
          ? (now.month <= 2 ? now.year - 1 : now.year)
          : (now.month <= 2 ? now.year : now.year + 1);
      return (DateTime(endYear - 1, 12, 1), DateTime(endYear, 3, 1));
    }
    if (RegExp(r'(?:^|[^а-яё])лет(?:ом|о|у|а|н)|летом|лето').hasMatch(lower)) {
      final year = past ? now.year - 1 : now.year;
      return (DateTime(year, 6, 1), DateTime(year, 9, 1));
    }
    if (RegExp(r'осен').hasMatch(lower)) {
      final year = past ? now.year - 1 : now.year;
      return (DateTime(year, 9, 1), DateTime(year, 12, 1));
    }
    if (RegExp(r'весн').hasMatch(lower)) {
      final year = past ? now.year - 1 : now.year;
      return (DateTime(year, 3, 1), DateTime(year, 6, 1));
    }

    for (final entry in _months.entries) {
      if (lower.contains(entry.key)) {
        final month = entry.value;
        var year = now.year;
        // If that month is still ahead this year, assume last year.
        if (month > now.month) year -= 1;
        if (lower.contains('прошл')) year = now.year - 1;
        final start = DateTime(year, month, 1);
        final end = month == 12
            ? DateTime(year + 1, 1, 1)
            : DateTime(year, month + 1, 1);
        return (start, end);
      }
    }
    return null;
  }
}
