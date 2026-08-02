import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinpic/core/providers/core_providers.dart';

/// Grid/list photo preview.
///
/// Prefers a direct [Image.file] decode (Flutter resizes off the UI isolate
/// via [cacheWidth]/[cacheHeight]) when [filePath] is known — that is the
/// fast path for already-indexed photos. Falls back to [ThumbnailCacheService]
/// (disk JPEG cache / photo_manager) when the path is missing or unreadable.
class PhotoThumbnail extends ConsumerStatefulWidget {
  const PhotoThumbnail({
    super.key,
    required this.mediaId,
    required this.width,
    required this.height,
    this.filePath,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String mediaId;
  final int width;
  final int height;
  final String? filePath;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  ConsumerState<PhotoThumbnail> createState() => _PhotoThumbnailState();
}

class _PhotoThumbnailState extends ConsumerState<PhotoThumbnail> {
  Future<Uint8List?>? _fallbackFuture;
  bool _fileFailed = false;

  @override
  void initState() {
    super.initState();
    if (!_canUseFile) {
      _fallbackFuture = _loadFallback();
    }
  }

  @override
  void didUpdateWidget(covariant PhotoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaId != widget.mediaId ||
        oldWidget.width != widget.width ||
        oldWidget.height != widget.height ||
        oldWidget.filePath != widget.filePath) {
      _fileFailed = false;
      _fallbackFuture = _canUseFile ? null : _loadFallback();
    }
  }

  bool get _canUseFile {
    final path = widget.filePath;
    return path != null && path.isNotEmpty && !_fileFailed;
  }

  Future<Uint8List?> _loadFallback() {
    return ref.read(thumbnailCacheProvider).get(
      widget.mediaId,
      width: widget.width,
      height: widget.height,
      fallbackPath: widget.filePath,
    );
  }

  void _onFileError(Object error, StackTrace? stack) {
    if (_fileFailed || !mounted) return;
    setState(() {
      _fileFailed = true;
      _fallbackFuture = _loadFallback();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (_canUseFile) {
      child = Image.file(
        File(widget.filePath!),
        fit: widget.fit,
        gaplessPlayback: true,
        filterQuality: FilterQuality.low,
        // Device-pixel-aware decode size keeps memory low and load fast.
        cacheWidth: (widget.width * MediaQuery.devicePixelRatioOf(context))
            .round()
            .clamp(64, 720),
        cacheHeight: (widget.height * MediaQuery.devicePixelRatioOf(context))
            .round()
            .clamp(64, 720),
        errorBuilder: (context, error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _onFileError(error, stack);
          });
          return const _ThumbPlaceholder(loading: true);
        },
      );
    } else {
      child = FutureBuilder<Uint8List?>(
        future: _fallbackFuture,
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes != null) {
            return Image.memory(
              bytes,
              fit: widget.fit,
              gaplessPlayback: true,
              filterQuality: FilterQuality.low,
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const _ThumbPlaceholder(loading: true);
          }
          return const _ThumbPlaceholder(loading: false);
        },
      );
    }

    final radius = widget.borderRadius;
    if (radius == null) return child;
    return ClipRRect(borderRadius: radius, child: child);
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder({required this.loading});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0x3316161F),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.image_outlined, size: 28),
      ),
    );
  }
}
