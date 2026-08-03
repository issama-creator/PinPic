import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinpic/core/providers/core_providers.dart';
import 'package:pinpic/routes/route_paths.dart';
import 'package:pinpic/services/document_scan_service.dart';
import 'package:pinpic/theme/app_colors.dart';
import 'package:pinpic/widgets/gradient_button.dart';

final documentScanServiceProvider = Provider<DocumentScanService>((ref) {
  return DocumentScanService(
    photoRepository: ref.watch(photoRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
    onPhotoIndexed: (photo) {
      unawaited(ref.read(expiryReminderServiceProvider).syncPhoto(photo));
    },
  );
});

/// Optional one-shot ingest — not part of first-run; gallery indexing finds
/// important photos without the user knowing where they are.
class ScanDocumentScreen extends ConsumerStatefulWidget {
  const ScanDocumentScreen({super.key});

  @override
  ConsumerState<ScanDocumentScreen> createState() => _ScanDocumentScreenState();
}

class _ScanDocumentScreenState extends ConsumerState<ScanDocumentScreen> {
  var _busy = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 92,
        maxWidth: 4096,
        maxHeight: 4096,
      );
      if (picked == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      final result = await ref
          .read(documentScanServiceProvider)
          .ingestFile(picked.path);

      if (!mounted) return;
      context.go(RoutePaths.photoDetailsPath(result.photo.mediaId));
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Не удалось прочитать фото. Попробуйте ещё раз.';
        });
      }
      debugPrint('Scan ingest failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Добавить важное'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Если документ ещё не в галерее — сфотографируйте или выберите '
                'файл. Остальное PinPic находит сам при индексации.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  height: 1.45,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              GradientButton(
                label: _busy ? 'Читаем…' : 'Снять фото',
                onPressed: _busy ? null : () => _pick(ImageSource.camera),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _busy ? null : () => _pick(ImageSource.gallery),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0x55FFFFFF)),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Выбрать из галереи',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFFF8A80)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
