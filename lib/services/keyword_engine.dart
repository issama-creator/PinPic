import 'package:pinpic/services/synonym_engine.dart';

class KeywordEngine {
  KeywordEngine({SynonymEngine? synonymEngine})
    : _synonyms = synonymEngine ?? SynonymEngine();

  final SynonymEngine _synonyms;

  static final _tokenSplit = RegExp(r'[^a-zA-Zа-яА-ЯёЁ0-9]+');
  static final _stopWords = <String>{
    'и',
    'в',
    'на',
    'с',
    'по',
    'для',
    'из',
    'к',
    'о',
    'от',
    'the',
    'a',
    'an',
    'of',
    'to',
    'in',
    'on',
    'for',
    'with',
    'and',
    'or',
  };

  static const _categoryIntentTokens = <String, Set<String>>{
    'Документы': {'документ', 'бумага', 'справка'},
    'Чеки': {
      'чек',
      'квитанция',
      'receipt',
      'invoice',
      'магазин',
      'покупка',
      'документ',
    },
    'Пароли': {'пароль', 'password', 'логин', 'документ'},
    'Билеты': {'билет', 'ticket', 'посадочный', 'пропуск', 'документ'},
    'Паспорта': {
      'паспорт',
      'passport',
      'загранпаспорт',
      'снилс',
      'документ',
    },
    'Права': {
      'права',
      'водительские',
      'водительское',
      'license',
      'licence',
      'driving',
      'документ',
    },
    'Договоры': {'договор', 'contract', 'соглашение', 'документ'},
    'Гарантии': {
      'гарантия',
      'гарантии',
      'warranty',
      'гарантийный',
      'документ',
    },
    'Рецепты': {
      'рецепт',
      'рецепты',
      'prescription',
      'аптека',
      'лекарство',
      'документ',
    },
    'Визитки': {'визитка', 'businesscard', 'контакт', 'документ'},
  };

  List<String> build({
    required String? ocrText,
    required List<String> objects,
    required String? category,
    String? displayName,
    String? album,
    String? qrPayload,
    bool hasQr = false,
    bool hasFace = false,
  }) {
    final tokens = <String>{};

    void addSource(String? source) => tokens.addAll(tokenize(source));

    addSource(ocrText);
    addSource(displayName);
    addSource(album);
    addSource(category);
    addSource(qrPayload);
    for (final object in objects) {
      addSource(object);
    }
    if (hasQr) {
      tokens.add('qr');
      tokens.add('qr-код');
    }
    if (hasFace) {
      tokens.add('человек');
      tokens.add('люди');
      tokens.add('лицо');
      tokens.add('person');
      tokens.add('people');
      tokens.add('face');
    }
    if (category != null && category.isNotEmpty) {
      tokens.add(category.toLowerCase());
      tokens.addAll(_categoryIntentTokens[category] ?? const {});
    }
    tokens.addAll(_synonyms.expand(tokens));

    final list = tokens.toList()..sort();
    if (list.length > 80) {
      return list.take(80).toList(growable: false);
    }
    return list;
  }

  /// Produces the unexpanded terms for a single signal source. These are kept
  /// alongside generic keywords so ranking can distinguish OCR from vision.
  List<String> tokenize(String? source) {
    if (source == null || source.trim().isEmpty) return const [];
    final tokens = <String>{};
    for (final raw in source.toLowerCase().split(_tokenSplit)) {
      final token = raw.trim();
      if (token.length < 2 || _stopWords.contains(token)) continue;
      if (RegExp(r'^\d+$').hasMatch(token) && token.length < 3) continue;
      tokens.add(_synonyms.normalize(token));
    }
    return tokens.toList()..sort();
  }

  List<String> tokenizeAll(Iterable<String> sources) {
    final tokens = <String>{};
    for (final source in sources) {
      tokens.addAll(tokenize(source));
    }
    return tokens.toList()..sort();
  }
}
