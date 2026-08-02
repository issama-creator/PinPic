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

  List<String> build({
    required String? ocrText,
    required List<String> objects,
    required String? category,
    String? displayName,
    String? qrPayload,
    bool hasQr = false,
    bool hasFace = false,
  }) {
    final tokens = <String>{};

    void addSource(String? source) {
      if (source == null || source.trim().isEmpty) return;
      for (final raw in source.toLowerCase().split(_tokenSplit)) {
        final token = raw.trim();
        if (token.length < 2) continue;
        if (_stopWords.contains(token)) continue;
        if (RegExp(r'^\d+$').hasMatch(token) && token.length < 3) continue;
        tokens.add(token);
      }
    }

    addSource(ocrText);
    addSource(displayName);
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
    }
    tokens.addAll(_synonyms.expand(tokens));

    final list = tokens.toList()..sort();
    if (list.length > 80) {
      return list.take(80).toList(growable: false);
    }
    return list;
  }
}
