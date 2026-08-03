import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/entity_extraction_service.dart';
import 'package:pinpic/services/memory_card_title.dart';
import 'package:pinpic/shared/models/photo_entity.dart';

/// Builds one successful "try this" query from already-indexed memory.
/// Prefers concrete facts (SSID, brand+amount, site) over bare categories.
String? buildSampleMemoryHint(Iterable<PhotoEntity> photos) {
  final extractor = EntityExtractionService();

  for (final photo in photos) {
    final entities = extractor.extract(
      ocrText: photo.ocrText,
      category: photo.category,
      dateTaken: photo.dateTaken,
      qrPayload: photo.qrPayload,
    );

    final ssid = entities.wifiSsid?.trim();
    if (ssid != null && ssid.isNotEmpty) return ssid;

    if (entities.wifiPassword != null) return 'вайфай';

    final brand = entities.brand?.trim();
    final amount = _amountToken(photo, entities.amountDigits);
    if (brand != null &&
        brand.isNotEmpty &&
        !_isWeakLabel(brand, photo.category) &&
        amount != null) {
      return '$brand $amount';
    }

    final urlLabel = EntityExtractionService.prettyUrlLabel(entities.url);
    if (urlLabel != null) return urlLabel;

    if (amount != null) return 'чек $amount';

    final title = resolveMemoryCardTitle(photo, entities: entities);
    if (!_isWeakLabel(title, photo.category) && !_looksLikeYear(title)) {
      return title;
    }

    final custom = photo.customTitle?.trim();
    if (custom != null && custom.isNotEmpty) return custom;
  }

  // Last resort: a real document category that already has items — not a year mashup.
  for (final photo in photos) {
    final category = photo.category?.trim();
    if (category == null || category.isEmpty) continue;
    if (category == CategoryEngine.passwords) return 'пароль';
    if (category == CategoryEngine.receipts) return 'чек';
    if (category == CategoryEngine.tickets) return 'билет';
    if (category == CategoryEngine.passports) return 'паспорт';
    if (category == CategoryEngine.qr) return 'QR';
  }
  return null;
}

String? _amountToken(PhotoEntity photo, String? amountDigits) {
  if (amountDigits != null &&
      amountDigits.isNotEmpty &&
      !_looksLikeYear(amountDigits)) {
    return amountDigits;
  }
  for (final token in photo.entityTokens) {
    final digits = token.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 3 &&
        digits.length <= 8 &&
        !_looksLikeYear(digits)) {
      return digits;
    }
  }
  return null;
}

bool _looksLikeYear(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 4) return false;
  final year = int.tryParse(digits);
  return year != null && year >= 1990 && year <= 2100;
}

bool _isWeakLabel(String value, String? category) {
  final lower = value.toLowerCase().trim();
  if (lower.isEmpty) return true;
  if (_looksLikeYear(lower)) return true;
  // «Пароли 2026» style mashups
  if (RegExp(r'^(пароли|чеки|документы|билеты|qr)\s+\d{4}$').hasMatch(lower)) {
    return true;
  }
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
    'wi-fi',
    'wifi',
    'wi‑fi',
  };
  if (bare.contains(lower)) return true;
  final cat = category?.toLowerCase().trim();
  return cat != null && cat == lower;
}
