/// Structured facts extracted from OCR — no network / LLM.
class ExtractedEntities {
  const ExtractedEntities({
    this.brand,
    this.title,
    this.amount,
    this.amountDigits,
    this.date,
    this.docNumber,
    this.phone,
    this.email,
    this.url,
    this.cardTail,
    this.wifiPassword,
    this.vin,
    this.plate,
    this.person,
  });

  final String? brand;
  final String? title;
  final String? amount;
  final String? amountDigits;
  final String? date;
  final String? docNumber;
  final String? phone;
  final String? email;
  final String? url;
  final String? cardTail;
  final String? wifiPassword;
  final String? vin;
  final String? plate;
  final String? person;

  bool get isEmpty =>
      brand == null &&
      title == null &&
      amount == null &&
      date == null &&
      docNumber == null &&
      phone == null &&
      email == null &&
      url == null &&
      cardTail == null &&
      wifiPassword == null &&
      vin == null &&
      plate == null &&
      person == null;

  /// Compact one-line summary for grids.
  String? get summaryLine {
    final parts = <String>[
      if (brand != null) brand!,
      if (title != null &&
          (brand == null ||
              !title!.toLowerCase().contains(brand!.toLowerCase())))
        title!,
      if (person != null) person!,
      if (amount != null) amount!,
      if (docNumber != null) docNumber!,
      if (wifiPassword != null) 'Wi‑Fi · $wifiPassword',
      if (cardTail != null) cardTail!,
      if (phone != null) phone!,
      if (email != null) email!,
      if (date != null) date!,
    ];
    final unique = <String>[];
    for (final part in parts) {
      if (unique.any((u) => u.toLowerCase() == part.toLowerCase())) continue;
      unique.add(part);
      if (unique.length >= 4) break;
    }
    if (unique.isEmpty) return null;
    return unique.join(' · ');
  }

  /// Multi-line smart card body (title separate).
  List<String> get cardRows {
    final rows = <String>[
      if (person != null) person!,
      if (amount != null) amount!,
      if (docNumber != null) docNumber!,
      if (date != null) date!,
      if (cardTail != null) cardTail!,
      if (wifiPassword != null) wifiPassword!,
      if (phone != null) phone!,
      if (email != null) email!,
      if (url != null) url!,
      if (vin != null) 'VIN $vin',
      if (plate != null) plate!,
    ];
    final unique = <String>[];
    for (final row in rows) {
      if (unique.any((u) => u.toLowerCase() == row.toLowerCase())) continue;
      unique.add(row);
      if (unique.length >= 5) break;
    }
    return unique;
  }

  String? get cardHeadline {
    if (brand != null) return brand;
    if (title != null) return title;
    if (person != null) return person;
    return null;
  }

  /// Tokens used for exact search: 4990, phones, emails, contract numbers…
  List<String> get searchTokens {
    final tokens = <String>{};
    void add(String? value) {
      if (value == null) return;
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;
      tokens.add(trimmed.toLowerCase());
      for (final part in trimmed.toLowerCase().split(RegExp(r'[^a-z0-9а-яё+@.]+'))) {
        if (part.length >= 3) tokens.add(part);
      }
    }

    add(brand);
    add(title);
    add(amount);
    add(amountDigits);
    add(date);
    add(docNumber);
    add(phone);
    add(email);
    add(url);
    add(cardTail?.replaceAll('•', '').replaceAll(' ', ''));
    add(wifiPassword);
    add(vin);
    add(plate);
    add(person);

    if (phone != null) {
      final digits = phone!.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 10) {
        tokens.add(digits);
        if (digits.length == 11 && digits.startsWith('8')) {
          tokens.add('7${digits.substring(1)}');
        }
      }
    }
    return tokens.toList()..sort();
  }
}

/// Rule-based extractor for amounts, dates, phones, emails, doc numbers, etc.
class EntityExtractionService {
  ExtractedEntities extract({
    required String? ocrText,
    required String? category,
    DateTime? dateTaken,
    String? qrPayload,
  }) {
    final text = (ocrText ?? '').trim();
    final lines = text
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    final amountMatch = _moneyMatch(text);
    final phone = _phone(text);
    final email = _email(text);
    final url = _url(text) ?? _url(qrPayload);
    final wifi = _wifiPassword(text);
    final cardTail = _cardTail(text);
    final vin = _vin(text);
    final plate = _plate(text);

    return ExtractedEntities(
      brand: _brand(text),
      title: _titleHint(text, category, lines),
      amount: amountMatch?.display,
      amountDigits: amountMatch?.digits,
      date: _date(text) ?? _formatDate(dateTaken),
      docNumber: _docNumber(text),
      phone: phone,
      email: email,
      url: url,
      cardTail: cardTail,
      wifiPassword: wifi,
      vin: vin,
      plate: plate,
      person: _personName(text, lines, category),
    );
  }

  String? _brand(String text) {
    return _firstMatch(text, [
      RegExp(r'\bIKEA\b', caseSensitive: false),
      RegExp(r'\bDNS\b'),
      RegExp(r'\bM\.?Video\b', caseSensitive: false),
      RegExp(r'\bWildberries\b', caseSensitive: false),
      RegExp(r'\bOzon\b', caseSensitive: false),
      RegExp(r'\bАэрофлот\b', caseSensitive: false),
      RegExp(r'\bS7\b'),
      RegExp(r'\bLG\b'),
      RegExp(r'\bSamsung\b', caseSensitive: false),
      RegExp(r'\bApple\b', caseSensitive: false),
      RegExp(r'\bWi-?Fi\b', caseSensitive: false),
    ]);
  }

  String? _titleHint(String text, String? category, List<String> lines) {
    final lower = text.toLowerCase();
    if (lower.contains('билет') || lower.contains('ticket')) {
      if (lower.contains('концерт')) return 'Билет на концерт';
      if (lower.contains('boarding') || lower.contains('посадоч')) {
        return 'Посадочный талон';
      }
      return 'Билет';
    }
    if (lower.contains('паспорт') || lower.contains('passport')) return 'Паспорт';
    if (lower.contains('договор') || lower.contains('contract')) return 'Договор';
    if (lower.contains('гарант') || lower.contains('warranty')) return 'Гарантия';
    if (lower.contains('рецепт') || lower.contains('prescription')) {
      return 'Рецепт';
    }
    if (lower.contains('водительск') || lower.contains('driver')) return 'Права';
    if (lower.contains('визит') || lower.contains('business card')) {
      return 'Визитка';
    }
    if (wifiPassword(text) != null ||
        lower.contains('wi-fi') ||
        lower.contains('wifi')) {
      return 'Wi‑Fi';
    }
    if (category != null) return category;
    if (lines.isNotEmpty && lines.first.length <= 40) return lines.first;
    return null;
  }

  /// Public helper for title hint wifi check without recursion issues.
  String? wifiPassword(String text) => _wifiPassword(text);

  ({String display, String digits})? _moneyMatch(String text) {
    final match = RegExp(
      r'(\d{1,3}(?:[ \u00A0]\d{3})+|\d+)(?:[.,]\d{2})?\s*(₽|руб\.?|RUB|\$|USD|€|EUR)',
      caseSensitive: false,
    ).firstMatch(text);
    if (match == null) return null;
    final raw = match.group(1)!.replaceAll(RegExp(r'[\s\u00A0]'), '');
    final intPart = raw.split(RegExp(r'[.,]')).first;
    final currency = match.group(2)!;
    final display = (currency.contains('руб') ||
            currency.toUpperCase() == 'RUB' ||
            currency == '₽')
        ? '$intPart ₽'
        : '$intPart $currency';
    return (display: display, digits: intPart);
  }

  String? _docNumber(String text) {
    final match = RegExp(
      r'(?:№|N[oо]\.?|number|#)\s*([A-ZА-Я0-9\-/]{3,})',
      caseSensitive: false,
    ).firstMatch(text);
    if (match == null) return null;
    return '№${match.group(1)}';
  }

  String? _phone(String text) {
    final match = RegExp(
      r'(\+7|8)[\s\-]?\(?\d{3}\)?[\s\-]?\d{3}[\s\-]?\d{2}[\s\-]?\d{2}',
    ).firstMatch(text);
    return match?.group(0)?.replaceAll(RegExp(r'\s+'), ' ');
  }

  String? _email(String text) {
    final match = RegExp(
      r'[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}',
      caseSensitive: false,
    ).firstMatch(text);
    return match?.group(0);
  }

  String? _url(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    final match = RegExp(
      r'https?://[^\s]+|www\.[^\s]+',
      caseSensitive: false,
    ).firstMatch(text);
    return match?.group(0);
  }

  String? _wifiPassword(String text) {
    final match = RegExp(
      r'(?:password|пароль|pass\s*code|пин)\s*[:\-–]?\s*([A-Za-z0-9\-_]{6,})',
      caseSensitive: false,
    ).firstMatch(text);
    return match?.group(1);
  }

  String? _cardTail(String text) {
    final masked = RegExp(
      r'(?:\*{2,}|•{2,}|x{2,})\s*(\d{4})\b',
      caseSensitive: false,
    ).firstMatch(text);
    if (masked != null) return '•••• ${masked.group(1)}';
    final spaced = RegExp(r'\b(?:\d{4}[\s\-]){3}(\d{4})\b').firstMatch(text);
    if (spaced != null) return '•••• ${spaced.group(1)}';
    return null;
  }

  String? _vin(String text) {
    final match = RegExp(
      r'\b([A-HJ-NPR-Z0-9]{17})\b',
      caseSensitive: false,
    ).firstMatch(text.toUpperCase());
    return match?.group(1);
  }

  String? _plate(String text) {
    final match = RegExp(
      r'\b([АВЕКМНОРСТУХABEKMHOPCTYX]\s?\d{3}\s?[АВЕКМНОРСТУХABEKMHOPCTYX]{2}\s?\d{2,3})\b',
      caseSensitive: false,
    ).firstMatch(text);
    return match?.group(1)?.toUpperCase();
  }

  String? _personName(String text, List<String> lines, String? category) {
    final surname = RegExp(
      r'(?:Surname|Фамилия)\s*[:\-]?\s*([A-ZА-ЯЁ][A-Za-zА-Яа-яёЁ\-]{2,})',
      caseSensitive: false,
    ).firstMatch(text);
    if (surname != null) {
      final name = RegExp(
        r'(?:Name|Имя)\s*[:\-]?\s*([A-ZА-ЯЁ][A-Za-zА-Яа-яёЁ\-]{2,})',
        caseSensitive: false,
      ).firstMatch(text);
      if (name != null) return '${surname.group(1)} ${name.group(1)}';
      return surname.group(1);
    }
    final isCard = category != null &&
        (category.contains('Визит') || category.contains('Паспорт'));
    if (!isCard) return null;
    for (final line in lines.take(4)) {
      final words = line.split(RegExp(r'\s+'));
      if (words.length == 2 &&
          words.every((w) => RegExp(r'^[A-ZА-ЯЁ][a-zа-яё]+$').hasMatch(w))) {
        return line;
      }
    }
    return null;
  }

  String? _date(String text) {
    final match = RegExp(
      r'\b(\d{1,2}[./]\d{1,2}[./]\d{2,4})\b',
    ).firstMatch(text);
    return match?.group(1);
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    const months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String? _firstMatch(String text, List<RegExp> patterns) {
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) return match.group(0);
    }
    return null;
  }
}
