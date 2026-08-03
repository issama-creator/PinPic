import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/entity_extraction_service.dart';
import 'package:pinpic/shared/models/photo_entity.dart';

/// Resolves the display title: user rename wins, then auto facts.
String resolveMemoryCardTitle(
  PhotoEntity photo, {
  ExtractedEntities? entities,
  String fallback = 'Документ',
}) {
  final custom = photo.customTitle?.trim();
  if (custom != null && custom.isNotEmpty) return custom;

  final extracted =
      entities ??
      EntityExtractionService().extract(
        ocrText: photo.ocrText,
        category: photo.category,
        dateTaken: photo.dateTaken,
        qrPayload: photo.qrPayload,
      );

  final live = extracted.cardHeadline?.trim();
  if (live != null &&
      live.isNotEmpty &&
      !_isBareCollectionLabel(live, photo.category)) {
    return live;
  }

  // Passwords / Wi‑Fi: never leave a bare «Пароли» as the hero title.
  if (photo.category == CategoryEngine.passwords ||
      extracted.wifiPassword != null ||
      extracted.wifiSsid != null) {
    if (extracted.wifiSsid != null && extracted.wifiSsid!.trim().isNotEmpty) {
      return extracted.wifiSsid!.trim();
    }
    final hay = '${photo.ocrText ?? ''} ${photo.summary ?? ''}'.toLowerCase();
    if (hay.contains('wifi') ||
        hay.contains('wi-fi') ||
        hay.contains('вайфай') ||
        hay.contains('ssid')) {
      return 'Wi‑Fi';
    }
    return 'Пароль';
  }

  if (extracted.amount != null) return 'Чек';

  final stored = photo.cardTitle?.trim();
  if (stored != null &&
      stored.isNotEmpty &&
      !_isBareCollectionLabel(stored, photo.category)) {
    return stored;
  }

  if (live != null && live.isNotEmpty) return live;
  if (stored != null && stored.isNotEmpty) return stored;

  return photo.category?.trim().isNotEmpty == true
      ? photo.category!
      : (photo.displayName?.trim().isNotEmpty == true
            ? photo.displayName!
            : fallback);
}

bool _isBareCollectionLabel(String value, String? category) {
  final lower = value.toLowerCase().trim();
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
  if (bare.contains(lower)) return true;
  final cat = category?.toLowerCase().trim();
  return cat != null && cat == lower;
}
