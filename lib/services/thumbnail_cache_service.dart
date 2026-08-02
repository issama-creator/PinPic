import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';

class ThumbnailCacheService {
  ThumbnailCacheService({
    this.maxEntries = 160,
    this.maxBytes = 48 * 1024 * 1024,
  });

  final int maxEntries;
  final int maxBytes;
  final LinkedHashMap<String, Uint8List> _cache = LinkedHashMap();
  final Map<String, Future<Uint8List?>> _inFlight = {};
  int _currentBytes = 0;

  /// Prefer [fallbackPath] when present: for photos we already indexed the
  /// file path is known and a direct disk decode is much faster / more
  /// reliable than waiting on MediaStore thumbnails (especially on emulators
  /// and for files dropped into Download/).
  Future<Uint8List?> get(
    String mediaId, {
    required int width,
    required int height,
    String? fallbackPath,
  }) {
    final key = '$mediaId@$width×$height';
    final cached = _cache.remove(key);
    if (cached != null) {
      _cache[key] = cached;
      return Future<Uint8List?>.value(cached);
    }

    final pending = _inFlight[key];
    if (pending != null) return pending;

    final future = _load(
      mediaId,
      width,
      height,
      fallbackPath,
    ).whenComplete(() => _inFlight.remove(key));
    _inFlight[key] = future;
    return future;
  }

  Future<Uint8List?> _load(
    String mediaId,
    int width,
    int height,
    String? fallbackPath,
  ) async {
    if (fallbackPath != null && fallbackPath.isNotEmpty) {
      final fromDisk = await _decodeFromDisk(fallbackPath, width, height);
      if (fromDisk != null) {
        _store(key: '$mediaId@$width×$height', bytes: fromDisk);
        return fromDisk;
      }
    }

    try {
      final asset = await AssetEntity.fromId(mediaId);
      if (asset != null) {
        final bytes = await asset.thumbnailDataWithSize(
          ThumbnailSize(width, height),
          quality: 80,
        );
        if (bytes != null) {
          _store(key: '$mediaId@$width×$height', bytes: bytes);
          return bytes;
        }
      }
    } catch (error) {
      debugPrint('Thumbnail via AssetEntity failed for $mediaId: $error');
    }

    return null;
  }

  Future<Uint8List?> _decodeFromDisk(
    String path,
    int width,
    int height,
  ) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        debugPrint('Thumbnail disk miss (missing file): $path');
        return null;
      }
      return compute(_resizeJpegIsolate, <Object>[path, width, height]);
    } catch (error) {
      debugPrint('Thumbnail disk decode failed for $path: $error');
      return null;
    }
  }

  void _store({required String key, required Uint8List bytes}) {
    _cache[key] = bytes;
    _currentBytes += bytes.lengthInBytes;
    _trim();
  }

  void invalidate(String mediaId) {
    final keys = _cache.keys
        .where((key) => key.startsWith('$mediaId@'))
        .toList();
    for (final key in keys) {
      final bytes = _cache.remove(key);
      if (bytes != null) _currentBytes -= bytes.lengthInBytes;
    }
  }

  void clear() {
    _cache.clear();
    _inFlight.clear();
    _currentBytes = 0;
  }

  void _trim() {
    while (_cache.length > maxEntries || _currentBytes > maxBytes) {
      final oldestKey = _cache.keys.first;
      final removed = _cache.remove(oldestKey);
      if (removed != null) _currentBytes -= removed.lengthInBytes;
    }
  }
}

Uint8List? _resizeJpegIsolate(List<Object> args) {
  final path = args[0] as String;
  final width = args[1] as int;
  final height = args[2] as int;
  try {
    final raw = File(path).readAsBytesSync();
    final decoded = img.decodeImage(raw);
    if (decoded == null) return null;
    final resized = img.copyResize(
      decoded,
      width: width,
      height: height,
      interpolation: img.Interpolation.average,
    );
    return Uint8List.fromList(img.encodeJpg(resized, quality: 82));
  } catch (_) {
    return null;
  }
}
