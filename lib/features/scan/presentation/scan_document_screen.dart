import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinpic/core/providers/core_providers.dart';
import 'package:pinpic/routes/route_paths.dart';
import 'package:pinpic/services/document_scan_service.dart';
import 'package:pinpic/theme/app_colors.dart';

final documentScanServiceProvider = Provider<DocumentScanService>((ref) {
  return DocumentScanService(
    photoRepository: ref.watch(photoRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
  );
});

class ScanDocumentScreen extends ConsumerStatefulWidget {
  const ScanDocumentScreen({super.key});

  @override
  ConsumerState<ScanDocumentScreen> createState() => _ScanDocumentScreenState();
}

class _ScanDocumentScreenState extends ConsumerState<ScanDocumentScreen> {
  final _picker = ImagePicker();
  bool _busy = false;
  String? _previewPath;
  String? _ocrPreview;
  String? _category;
  String? _error;

  Future<void> _capture(ImageSource source) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 92,
        maxWidth: 2400,
      );
      if (file == null) {
        setState(() => _busy = false);
        return;
      }
      final result = await ref
          .read(documentScanServiceProvider)
          .ingestFile(file.path);
      if (!mounted) return;
      setState(() {
        _previewPath = result.photo.path;
        _ocrPreview = result.ocrText.isEmpty
            ? 'Текст пока не распознан. Можно повторить съёмку.'
            : result.ocrText;
        _category = result.category;
        _busy = false;
      });
      ref.invalidate(searchServiceProvider);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Не удалось обработать документ: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Сканировать важное'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Сфотографируйте билет, паспорт, чек или договор. PinPic сразу распознает текст и добавит его в локальный поиск.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  height: 1.4,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF12121A),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0x22FFFFFF)),
                  ),
                  child: _previewPath == null
                      ? const Center(
                          child: Text(
                            'Кадр документа появится здесь',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(
                            File(_previewPath!),
                            fit: BoxFit.contain,
                          ),
                        ),
                ),
              ),
              if (_ocrPreview != null) ...[
                const SizedBox(height: 16),
                Text(
                  _category == null
                      ? 'Распознанный текст'
                      : 'Категория: $_category',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _ocrPreview!,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Color(0xFFFF6B8A))),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _capture(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Галерея'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _capture(ImageSource.camera),
                      icon: _busy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.photo_camera_outlined),
                      label: Text(_busy ? 'Читаем…' : 'Камера'),
                    ),
                  ),
                ],
              ),
              if (_ocrPreview != null &&
                  _ocrPreview!.trim().isNotEmpty &&
                  !_ocrPreview!.startsWith('Текст пока')) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    final query = _ocrPreview!
                        .split(RegExp(r'\s+'))
                        .where((part) => part.trim().length >= 3)
                        .take(2)
                        .join(' ');
                    context.push(
                      '${RoutePaths.results}?q=${Uri.encodeQueryComponent(query)}',
                    );
                  },
                  child: const Text('Найти по распознанному тексту'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
