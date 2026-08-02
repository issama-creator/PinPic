class CategoryEngine {
  static const documents = 'Документы';
  static const receipts = 'Чеки';
  static const passwords = 'Пароли';
  static const tickets = 'Билеты';
  static const passports = 'Паспорта';
  static const licenses = 'Права';
  static const contracts = 'Договоры';
  static const warranties = 'Гарантии';
  static const prescriptions = 'Рецепты';
  static const businessCards = 'Визитки';
  static const qr = 'QR';
  static const animals = 'Животные';
  static const plants = 'Растения';
  static const screenshots = 'Скриншоты';
  static const cars = 'Машины';
  static const food = 'Еда';
  static const people = 'Люди';

  /// All assignable categories — used to infer a category filter from a
  /// free-text query (e.g. "билет" → «Билеты») so photos already tagged
  /// by category still surface even when OCR keywords are thin.
  static const all = <String>[
    documents,
    receipts,
    passwords,
    tickets,
    passports,
    licenses,
    contracts,
    warranties,
    prescriptions,
    businessCards,
    qr,
    animals,
    plants,
    screenshots,
    cars,
    food,
    people,
  ];

  /// Document-first collections shown on the home screen with live counts.
  static const memoryCollections = <String>[
    documents,
    passports,
    licenses,
    contracts,
    receipts,
    tickets,
    warranties,
    prescriptions,
    businessCards,
    passwords,
    qr,
  ];

  /// Search-only umbrella. These remain distinct stored categories so a user
  /// can still open «Чеки» or «Билеты», while a broad «документ» query brings
  /// back every document-like photo.
  static const documentFamily = <String>{
    documents,
    receipts,
    passwords,
    tickets,
    passports,
    licenses,
    contracts,
    warranties,
    prescriptions,
    businessCards,
  };

  static const _documentIntentTokens = {
    'документ',
    'документы',
    'document',
    'paperwork',
    'certificate',
    'бумага',
    'справка',
  };

  static final _tokenSplit = RegExp(r'[^a-zA-Zа-яА-ЯёЁ0-9]+');

  /// If expanded search tokens include a category name (or its lowercase
  /// form from synonym expansion), return that category label.
  static String? inferFromTokens(Iterable<String> tokens) {
    final categories = inferCategoriesFromTokens(tokens);
    return categories.isEmpty ? null : categories.first;
  }

  /// Singular / synonym forms that should open a specific collection.
  static const _categoryAliases = <String, String>{
    'паспорт': passports,
    'загранпаспорт': passports,
    'права': licenses,
    'водительские': licenses,
    'водительское': licenses,
    'license': licenses,
    'licence': licenses,
    'договор': contracts,
    'контракт': contracts,
    'гарантия': warranties,
    'гарантии': warranties,
    'warranty': warranties,
    'рецепт': prescriptions,
    'рецепты': prescriptions,
    'prescription': prescriptions,
    'чек': receipts,
    'чеки': receipts,
    'receipt': receipts,
    'билет': tickets,
    'билеты': tickets,
    'ticket': tickets,
    'визитка': businessCards,
    'визитки': businessCards,
    'пароль': passwords,
    'пароли': passwords,
    'password': passwords,
  };

  /// Returns every indexed category a query is allowed to broaden into.
  /// «Документ» is intentionally an umbrella; specific intents stay narrow.
  static List<String> inferCategoriesFromTokens(Iterable<String> tokens) {
    final normalized = {
      for (final token in tokens)
        token.trim().toLowerCase().replaceAll('ё', 'е'),
    };
    if (normalized.any(_documentIntentTokens.contains)) {
      return documentFamily.toList(growable: false);
    }
    for (final category in all) {
      final key = category.toLowerCase().replaceAll('ё', 'е');
      if (normalized.contains(key)) return [category];
    }
    for (final token in normalized) {
      final alias = _categoryAliases[token];
      if (alias != null) return [alias];
    }
    return const [];
  }

  /// Priority order matters: the most specific content signal always wins
  /// over a broader/technical one. A boarding pass or a receipt often also
  /// carries a QR code, but "Билеты"/"Чеки" is the more useful category than
  /// the generic "QR" — so QR is only assigned when nothing more specific
  /// matched. Likewise a password/OTP screenshot is still a screenshot
  /// technically, but "Пароли" is far more useful for search.
  String? classify({
    required String? ocrText,
    required List<String> objects,
    required bool hasQr,
    String? displayName,
    String? mimeType,
  }) {
    // Intentionally ignore [displayName]: Unsplash-style filenames
    // ("theangryteddy-keyboard-…", "vacation-trip") leak false category
    // signals. Filenames still feed [KeywordEngine] for search.
    final blob = [ocrText ?? '', ...objects].join(' ').toLowerCase();
    final tokens = blob
        .split(_tokenSplit)
        .where((token) => token.isNotEmpty)
        .toSet();
    // OCR can contain arbitrary hallucinated words on textured images
    // (for example, bead strings read as "tree"). Broad visual categories
    // must therefore be based on the image models' labels/objects only.
    final visualBlob = objects.join(' ').toLowerCase();
    final visualTokens = visualBlob
        .split(_tokenSplit)
        .where((token) => token.isNotEmpty)
        .toSet();

    if (_matches(
      blob,
      tokens,
      const ['password', 'пароль', 'логин', 'login', 'otp', 'двухфакторн'],
      phrases: const [
        'pin code',
        'pin-код',
        'verification code',
        'confirm code',
        'secret code',
        'код подтверждения',
        'одноразовый код',
        'смс-код',
      ],
    )) {
      return passwords;
    }

    if (_matches(blob, tokens, const [
      'ikea',
      'receipt',
      'чек',
      'касс',
      'total',
      'итого',
      'ндс',
      'vat',
      'магазин',
    ])) {
      return receipts;
    }

    if (_matches(
      blob,
      tokens,
      const [
        'ticket',
        'билет',
        'boarding',
        'посадочный',
        'рейс',
        'концерт',
        'кинотеатр',
      ],
      phrases: const ['flight number', 'seat number', 'boarding pass'],
    )) {
      return tickets;
    }

    // A ticket can also have a generic Document label, but its explicit
    // boarding/concert signal is more useful and must win.
    if (_matches(
      blob,
      tokens,
      const ['passport', 'паспорт', 'снилс'],
      phrases: const ['russian federation'],
    )) {
      return passports;
    }

    if (_matches(
      blob,
      tokens,
      const ['водительск', 'права', 'driver', 'license', 'удостоверен'],
      phrases: const ['driver license', 'driving licence', 'водительское удостоверение'],
    )) {
      return licenses;
    }

    if (_matches(blob, tokens, const [
      'warranty',
      'гарант',
      'гарантий',
    ])) {
      return warranties;
    }

    if (_matches(blob, tokens, const [
      'prescription',
      'рецепт',
      'аптек',
      'pharmacy',
      'лекарств',
    ])) {
      return prescriptions;
    }

    if (_matches(blob, tokens, const [
      'contract',
      'договор',
      'соглашен',
      'agreement',
    ])) {
      return contracts;
    }

    if (_matches(blob, tokens, const [
      'document',
      'документ',
      'invoice',
      'справка',
      'certificate',
      'инструкц',
    ])) {
      return documents;
    }

    if (_matches(
      blob,
      tokens,
      const ['визитк', 'businesscard'],
      phrases: const ['business card'],
    )) {
      return businessCards;
    }

    if (hasQr) return qr;

    if (_matches(blob, tokens, const [
          'screenshot',
          'screen shot',
          'скриншот',
          'снимок экрана',
        ]) ||
        (mimeType?.contains('png') == true &&
            _matches(blob, tokens, const ['screen', 'screenshot']))) {
      return screenshots;
    }

    if (_matches(visualBlob, visualTokens, const [
      'dog',
      'cat',
      'pet',
      'bird',
      'собак',
      'кошк',
      'животн',
      'птиц',
      'puppy',
      'kitten',
    ])) {
      return animals;
    }

    if (_matches(visualBlob, visualTokens, const [
      'plant',
      'flower',
      'tree',
      'растени',
      'цвет',
      'дерев',
      'flora',
      'succulent',
    ])) {
      return plants;
    }

    if (_matches(visualBlob, visualTokens, const [
      'car',
      'vehicle',
      'automobile',
      'машин',
      'авто',
      'truck',
      'motorcycle',
    ])) {
      return cars;
    }

    if (_matches(visualBlob, visualTokens, const [
      'food',
      'meal',
      'restaurant',
      'еда',
      'пицц',
      'кофе',
      'coffee',
      'cake',
      'sushi',
      'burger',
    ])) {
      return food;
    }

    if (_matches(visualBlob, visualTokens, const [
      'person',
      'people',
      'human',
      'face',
      'portrait',
      'man',
      'woman',
      'boy',
      'girl',
      'selfie',
      'человек',
      'люди',
      'лицо',
      'портрет',
      'мужчина',
      'женщина',
    ])) {
      return people;
    }

    return null;
  }

  /// Word-safe matching: naive `blob.contains(needle)` let short needles
  /// like "car" or "cat" false-positive on unrelated words that merely
  /// contain them as a substring (e.g. "carving" -> Cars, "vacation" ->
  /// Животные, "победа" -> Еда). Single-word needles must match a whole
  /// token exactly, or — for longer stems (>=4 chars) — be a token prefix
  /// so Russian declensions still match (e.g. "документ" -> "документы").
  /// `phrases` are checked as raw substrings since they intentionally span
  /// token boundaries (e.g. "business card").
  bool _matches(
    String blob,
    Set<String> tokens,
    List<String> needles, {
    List<String> phrases = const [],
  }) {
    for (final phrase in phrases) {
      if (blob.contains(phrase)) return true;
    }
    for (final needle in needles) {
      if (needle.contains(' ')) {
        if (blob.contains(needle)) return true;
        continue;
      }
      if (tokens.contains(needle)) return true;
      if (needle.length >= 4 && tokens.any((t) => t.startsWith(needle))) {
        return true;
      }
    }
    return false;
  }
}
