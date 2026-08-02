import 'package:pinpic/services/synonym_engine.dart';

/// Parsed "what I remember" query: fillers stripped, digits kept, tokens ready.
class MemoryQuery {
  const MemoryQuery({
    required this.raw,
    required this.cleaned,
    required this.tokens,
    required this.digitTokens,
    required this.meaningfulTokens,
  });

  final String raw;
  final String cleaned;
  final Set<String> tokens;
  final Set<String> digitTokens;

  /// Tokens that should drive search (stop-words removed). Falls back to
  /// [tokens] when the user only typed fillers + one keyword.
  final Set<String> meaningfulTokens;

  bool get isEmpty => meaningfulTokens.isEmpty && digitTokens.isEmpty;
}

/// Turns colloquial memory phrases into searchable tokens.
///
/// Examples:
/// - «найди где тот чек из икеи» → {чек, икеи} (+ synonym expand later)
/// - «примерно 4990» → digits {4990}
/// - «паспрот» stays as token for fuzzy
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
  };

  MemoryQuery parse(String raw) {
    final normalized = _synonyms.normalize(raw.trim());
    // «4 990» → «4990» so amount memory works without exact OCR spacing.
    final collapsedAmounts = normalized.replaceAllMapped(
      RegExp(r'(\d{1,3}(?:\s\d{3})+)'),
      (match) => match.group(0)!.replaceAll(RegExp(r'\s+'), ''),
    );
    final digitTokens = {
      for (final match in _digits.allMatches(collapsedAmounts)) match.group(0)!,
    };

    final allTokens = <String>{};
    for (final rawToken in collapsedAmounts.toLowerCase().split(_split)) {
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
    );
  }
}
