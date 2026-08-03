/// Structured facts extracted from OCR — no network / LLM.
class ExtractedEntities {
  const ExtractedEntities({
    this.brand,
    this.title,
    this.amount,
    this.amountDigits,
    this.date,
    this.expiresAt,
    this.docNumber,
    this.phone,
    this.email,
    this.url,
    this.cardTail,
    this.wifiPassword,
    this.wifiSsid,
    this.vin,
    this.plate,
    this.person,
  });

  final String? brand;
  final String? title;
  final String? amount;
  final String? amountDigits;
  final String? date;
  /// Parsed valid-until / expiry date when OCR has an explicit cue.
  final DateTime? expiresAt;
  final String? docNumber;
  final String? phone;
  final String? email;
  final String? url;
  final String? cardTail;
  final String? wifiPassword;
  final String? wifiSsid;
  final String? vin;
  final String? plate;
  final String? person;

  bool get isEmpty =>
      brand == null &&
      title == null &&
      amount == null &&
      date == null &&
      expiresAt == null &&
      docNumber == null &&
      phone == null &&
      email == null &&
      url == null &&
      cardTail == null &&
      wifiPassword == null &&
      wifiSsid == null &&
      vin == null &&
      plate == null &&
      person == null;

  /// Compact one-line summary for grids.
  String? get summaryLine {
    final urlLabel = EntityExtractionService.prettyUrlLabel(url);
    final parts = <String>[
      if (cardHeadline != null) cardHeadline!,
      if (person != null) person!,
      if (amount != null) amount!,
      if (docNumber != null) docNumber!,
      if (wifiSsid != null && cardHeadline != wifiSsid) wifiSsid!,
      if (wifiPassword != null) wifiPassword!,
      if (cardTail != null) cardTail!,
      if (phone != null) phone!,
      if (email != null) email!,
      if (urlLabel != null && cardHeadline != urlLabel) urlLabel,
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
    final urlLabel = EntityExtractionService.prettyUrlLabel(url);
    final rows = <String>[
      if (person != null) person!,
      if (amount != null) amount!,
      if (docNumber != null) docNumber!,
      if (date != null) date!,
      if (cardTail != null) cardTail!,
      if (wifiSsid != null) wifiSsid!,
      if (wifiPassword != null) wifiPassword!,
      if (phone != null) phone!,
      if (email != null) email!,
      if (urlLabel != null) urlLabel,
      if (url != null && urlLabel == null) url!,
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

  /// Short confident title for cards — never invents, only formats facts.
  String? get cardHeadline {
    final brandLabel = brand?.trim();
    final isWifiBrand =
        brandLabel != null &&
        (brandLabel.toLowerCase() == 'wi-fi' ||
            brandLabel.toLowerCase() == 'wifi');

    if (wifiSsid != null && wifiSsid!.trim().isNotEmpty) {
      return wifiSsid!.trim();
    }
    if (brandLabel != null && brandLabel.isNotEmpty && !isWifiBrand) {
      return brandLabel;
    }
    if (wifiPassword != null) return 'Wi‑Fi';

    final urlLabel = EntityExtractionService.prettyUrlLabel(url);
    if (urlLabel != null) return urlLabel;

    if (person != null && person!.trim().isNotEmpty) return person!.trim();

    final titleLabel = title?.trim();
    if (titleLabel != null &&
        titleLabel.isNotEmpty &&
        !_isBareCategoryLabel(titleLabel)) {
      return titleLabel;
    }
    if (amount != null) return 'Чек';
    if (titleLabel != null && titleLabel.isNotEmpty) return titleLabel;
    return null;
  }

  static bool _isBareCategoryLabel(String value) {
    const bare = {
      'qr',
      'чеки',
      'чек',
      'пароли',
      'пароль',
      'документы',
      'документ',
      'билеты',
      'билет',
      'паспорта',
      'паспорт',
      'гарантии',
      'визитки',
      'скриншоты',
    };
    return bare.contains(value.toLowerCase().trim());
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
    add(wifiSsid);
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
    final wifiQr = _wifiFromQr(qrPayload);
    final url = _url(text) ??
        _url(qrPayload) ??
        (wifiQr == null ? _urlFromLooseQr(qrPayload) : null);
    final wifi = _wifiPassword(text) ?? wifiQr?.password;
    final ssid = wifiQr?.ssid ?? _wifiSsid(text);
    final cardTail = _cardTail(text);
    final vin = _vin(text);
    final plate = _plate(text);

    return ExtractedEntities(
      brand: _brand(text),
      title: _titleHint(text, category, lines),
      amount: amountMatch?.display,
      amountDigits: amountMatch?.digits,
      date: _date(text) ?? _formatDate(dateTaken),
      expiresAt: _expiresAt(text),
      docNumber: _docNumber(text),
      phone: phone,
      email: email,
      url: url,
      cardTail: cardTail,
      wifiPassword: wifi,
      wifiSsid: ssid,
      vin: vin,
      plate: plate,
      person: _personName(text, lines, category),
    );
  }

  /// Confident display name from a URL host — no guessing beyond the host.
  static String? prettyUrlLabel(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final trimmed = rawUrl.trim();
    Uri? uri;
    try {
      uri = Uri.parse(
        trimmed.contains('://') ? trimmed : 'https://$trimmed',
      );
    } catch (_) {
      return null;
    }
    var host = uri.host.toLowerCase().trim();
    if (host.isEmpty) return null;
    host = host.replaceFirst(RegExp(r'^www\.'), '');
    // Strip common mobile / language prefixes: en.m.wikipedia.org → wikipedia.org
    while (true) {
      final next = host.replaceFirst(
        RegExp(r'^(m|mobile|www|en|ru|de|fr|es|it|pt|uk|zh)\.'),
        '',
      );
      if (next == host) break;
      host = next;
    }

    const known = <String, String>{
      'wikipedia.org': 'Wikipedia',
      'youtube.com': 'YouTube',
      'youtu.be': 'YouTube',
      'google.com': 'Google',
      'maps.google.com': 'Google Maps',
      'goo.gl': 'Google',
      't.me': 'Telegram',
      'telegram.me': 'Telegram',
      'wa.me': 'WhatsApp',
      'whatsapp.com': 'WhatsApp',
      'instagram.com': 'Instagram',
      'facebook.com': 'Facebook',
      'fb.com': 'Facebook',
      'vk.com': 'VK',
      'tiktok.com': 'TikTok',
      'github.com': 'GitHub',
      'apple.com': 'Apple',
      'microsoft.com': 'Microsoft',
      'amazon.com': 'Amazon',
      'ozon.ru': 'Ozon',
      'wildberries.ru': 'Wildberries',
      'avito.ru': 'Avito',
      'yandex.ru': 'Яндекс',
      'ya.ru': 'Яндекс',
    };
    for (final entry in known.entries) {
      if (host == entry.key || host.endsWith('.${entry.key}')) {
        return entry.value;
      }
    }

    final labels = host.split('.').where((p) => p.isNotEmpty).toList();
    if (labels.length < 2) return host;
    final name = labels[labels.length - 2];
    if (name.length < 2) return host;
    return '${name[0].toUpperCase()}${name.substring(1)}';
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
    if (lower.contains('страхов') || lower.contains('insurance')) {
      return 'Страховка';
    }
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
      r'https?://[^\s<>"{}|\\^`\[\]]+|www\.[^\s<>"{}|\\^`\[\]]+',
      caseSensitive: false,
    ).firstMatch(text);
    var value = match?.group(0);
    if (value == null) return null;
    // Trim trailing punctuation often glued by OCR.
    while (value!.isNotEmpty &&
        (value.endsWith(')') ||
            value.endsWith(',') ||
            value.endsWith('.') ||
            value.endsWith(']') ||
            value.endsWith('"'))) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }

  /// Bare domain / path QR payloads without scheme.
  String? _urlFromLooseQr(String? payload) {
    if (payload == null) return null;
    final text = payload.trim();
    if (text.isEmpty || text.toUpperCase().startsWith('WIFI:')) return null;
    if (_url(text) != null) return _url(text);
    if (RegExp(
      r'^[a-z0-9][a-z0-9.\-]*\.[a-z]{2,}(/[\S]*)?$',
      caseSensitive: false,
    ).hasMatch(text)) {
      return text.contains('://') ? text : 'https://$text';
    }
    return null;
  }

  ({String? ssid, String? password})? _wifiFromQr(String? payload) {
    if (payload == null) return null;
    final text = payload.trim();
    if (!text.toUpperCase().startsWith('WIFI:')) return null;
    String? field(String key) {
      final match = RegExp(
        '$key:([^;]*)',
        caseSensitive: false,
      ).firstMatch(text);
      final value = match?.group(1)?.trim();
      if (value == null || value.isEmpty) return null;
      return value;
    }

    return (ssid: field('S'), password: field('P'));
  }

  String? _wifiSsid(String text) {
    final match = RegExp(
      r'(?:ssid|сеть|network|имя сети)\s*[:\-–]?\s*([^\r\n]{2,40})',
      caseSensitive: false,
    ).firstMatch(text);
    final value = match?.group(1)?.trim();
    if (value == null || value.isEmpty) return null;
    return value.replaceAll(RegExp(r'[\"«»]'), '').trim();
  }

  String? _wifiPassword(String text) {
    final match = RegExp(
      r'(?:password|пароль|pass\s*code|пин|pass)\s*[:\-–]?\s*([^\s]{6,48})',
      caseSensitive: false,
    ).firstMatch(text);
    final value = match?.group(1)?.trim();
    if (value == null || value.isEmpty) return null;
    return value.replaceFirst(RegExp(r'[),.;]+$'), '');
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

  /// Prefer dates next to expiry / valid-until cues — not birth dates.
  DateTime? _expiresAt(String text) {
    final cue = RegExp(
      r'(?:действител(?:ен|ьна|ьно)\s+до|годен\s+до|годна\s+до|'
      r'срок\s+действия\s+до|действует\s+до|дата\s+окончания|'
      r'окончания\s+срока|valid\s+(?:until|thru|through|to)|'
      r'expir(?:y|es|ation)|exp\.?\s*date|date\s+of\s+expiry)',
      caseSensitive: false,
    );
    final cueMatch = cue.firstMatch(text);
    if (cueMatch == null) return null;
    return _parseFlexibleDate(text.substring(cueMatch.end));
  }

  DateTime? _parseFlexibleDate(String text) {
    final dmy = RegExp(
      r'(\d{1,2}[./\-]\d{1,2}[./\-]\d{2,4})',
    ).firstMatch(text);
    if (dmy != null) return _parseDayMonthYear(dmy.group(1)!);
    final iso = RegExp(r'(\d{4})-(\d{2})-(\d{2})').firstMatch(text);
    if (iso != null) {
      final y = int.tryParse(iso.group(1)!);
      final m = int.tryParse(iso.group(2)!);
      final d = int.tryParse(iso.group(3)!);
      if (y != null && m != null && d != null) {
        return DateTime(y, m, d);
      }
    }
    return null;
  }

  DateTime? _parseDayMonthYear(String raw) {
    final parts = raw.split(RegExp(r'[./\-]'));
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    var year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    if (year < 100) year += 2000;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return DateTime(year, month, day);
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
