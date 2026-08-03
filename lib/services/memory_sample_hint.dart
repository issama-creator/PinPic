import 'package:pinpic/shared/models/photo_entity.dart';

/// Builds one successful "try this" query from already-indexed memory.
String? buildSampleMemoryHint(Iterable<PhotoEntity> photos) {
  for (final photo in photos) {
    final title = photo.cardTitle?.trim();
    final amount = _amountToken(photo);
    if (title != null && title.isNotEmpty) {
      if (amount != null) return '$title $amount';
      // Avoid generic category-as-title noise when we have a stronger digit.
      if (title.length >= 3 && title.toLowerCase() != photo.category?.toLowerCase()) {
        return title;
      }
    }
    if (amount != null) {
      final category = photo.category;
      return category == null ? amount : 'чек $amount';
    }
    final wifi = _wifiish(photo);
    if (wifi != null) return wifi;
  }

  for (final photo in photos) {
    final category = photo.category?.trim();
    if (category != null && category.isNotEmpty) return category;
  }
  return null;
}

String? _amountToken(PhotoEntity photo) {
  for (final token in photo.entityTokens) {
    final digits = token.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 3 && digits.length <= 8) return digits;
  }
  final body = photo.cardBody ?? '';
  final match = RegExp(r'(\d[\d\s]{2,}\d)').firstMatch(body);
  if (match == null) return null;
  return match.group(1)!.replaceAll(RegExp(r'\s+'), '');
}

String? _wifiish(PhotoEntity photo) {
  final hay = [
    photo.cardTitle,
    photo.summary,
    photo.category,
    ...photo.keywords.take(6),
  ].whereType<String>().join(' ').toLowerCase();
  if (hay.contains('wifi') ||
      hay.contains('wi-fi') ||
      hay.contains('вайфай') ||
      hay.contains('парол')) {
    return 'вайфай';
  }
  return null;
}
