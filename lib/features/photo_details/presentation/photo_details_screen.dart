import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:pinpic/core/providers/core_providers.dart';
import 'package:pinpic/shared/models/photo_entity.dart';
import 'package:pinpic/theme/app_colors.dart';
import 'package:pinpic/widgets/app_scaffold.dart';
import 'package:pinpic/widgets/async_state_view.dart';
import 'package:pinpic/widgets/photo_thumbnail.dart';
import 'package:pinpic/widgets/smart_memory_card.dart';
import 'package:share_plus/share_plus.dart';

final _photoByIdProvider = FutureProvider.autoDispose
    .family<PhotoEntity?, String>((ref, mediaId) async {
      await ref.watch(appBootstrapProvider.future);
      return ref.watch(photoRepositoryProvider).findByMediaId(mediaId);
    });

class PhotoDetailsScreen extends ConsumerStatefulWidget {
  const PhotoDetailsScreen({super.key, required this.mediaId});

  final String mediaId;

  @override
  ConsumerState<PhotoDetailsScreen> createState() => _PhotoDetailsScreenState();
}

class _PhotoDetailsScreenState extends ConsumerState<PhotoDetailsScreen> {
  bool _rereading = false;

  Future<void> _reread() async {
    if (_rereading) return;
    setState(() => _rereading = true);
    try {
      final updated = await ref
          .read(photoTextRefreshServiceProvider)
          .refresh(widget.mediaId);
      ref.invalidate(_photoByIdProvider(widget.mediaId));
      ref.invalidate(photoStatsProvider);
      ref.invalidate(categoryCountsProvider);
      ref.read(searchServiceProvider).invalidateCaches();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated?.ocrText?.trim().isNotEmpty == true
                ? 'Текст обновлён'
                : 'Текст на фото не найден',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось перечитать: $error')),
      );
    } finally {
      if (mounted) setState(() => _rereading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoAsync = ref.watch(_photoByIdProvider(widget.mediaId));
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Фото'),
        actions: [
          photoAsync.maybeWhen(
            data: (photo) {
              if (photo == null) return const SizedBox.shrink();
              return IconButton(
                onPressed: () async {
                  await ref
                      .read(photoRepositoryProvider)
                      .setFavorite(widget.mediaId, !photo.isFavorite);
                  ref.invalidate(_photoByIdProvider(widget.mediaId));
                  ref.invalidate(favoritesProvider);
                  ref.read(searchServiceProvider).invalidateCaches();
                },
                icon: Icon(
                  photo.isFavorite
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: photo.isFavorite ? AppColors.purple : null,
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: photoAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => AppRetryState(
            message: 'Не удалось загрузить данные фото',
            onRetry: () =>
                ref.invalidate(_photoByIdProvider(widget.mediaId)),
          ),
          data: (photo) {
            if (photo == null) {
              return const Center(child: Text('Фото не найдено в индексе'));
            }

            final text = photo.ocrText?.trim() ?? '';

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PhotoThumbnail(
                      mediaId: widget.mediaId,
                      filePath: photo.path,
                      width: 1200,
                      height: 1200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SmartMemoryCard(photo: photo, showActions: true),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16161F),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x22FFFFFF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Текст на фото',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _rereading ? null : _reread,
                            icon: _rereading
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(
                              _rereading ? 'Читаем…' : 'Перечитать',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        text.isEmpty
                            ? 'Пока пусто. Нажмите «Перечитать» — PinPic ещё раз прочитает это фото.'
                            : text,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: text.isEmpty
                              ? AppColors.textMuted
                              : Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Подробности',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 10),
                  _InfoRow(label: 'Категория', value: photo.category ?? '—'),
                  _InfoRow(
                    label: 'Дата',
                    value: photo.dateTaken != null
                        ? dateFormat.format(photo.dateTaken!)
                        : '—',
                  ),
                  if (photo.hasQr)
                    _InfoRow(
                      label: 'QR',
                      value: photo.qrPayload ?? 'обнаружен',
                    ),
                  if (kDebugMode) ...[
                    _InfoRow(
                      label: 'OCR токены',
                      value: photo.ocrKeywords.isEmpty
                          ? '—'
                          : photo.ocrKeywords.take(12).join(', '),
                    ),
                    _InfoRow(
                      label: 'Сущности',
                      value: photo.entityTokens.isEmpty
                          ? '—'
                          : photo.entityTokens.take(12).join(', '),
                    ),
                  ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final file = File(photo.path);
                          if (!await file.exists()) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Файл недоступен'),
                              ),
                            );
                            return;
                          }
                          await SharePlus.instance.share(
                            ShareParams(files: [XFile(photo.path)]),
                          );
                        },
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Поделиться'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final next = !photo.isFavorite;
                          await ref
                              .read(photoRepositoryProvider)
                              .setFavorite(widget.mediaId, next);
                          ref.invalidate(
                            _photoByIdProvider(widget.mediaId),
                          );
                          ref.invalidate(favoritesProvider);
                          ref.read(searchServiceProvider).invalidateCaches();
                        },
                        icon: Icon(
                          photo.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                        ),
                        label: Text(
                          photo.isFavorite ? 'В избранном' : 'В избранное',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final asset =
                              await AssetEntity.fromId(widget.mediaId);
                          await asset?.file;
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                asset == null
                                    ? 'Не удалось открыть оригинал'
                                    : 'Оригинал: ${photo.path}',
                              ),
                            ),
                          );
                        },
                        child: const Text('Открыть оригинал'),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Удалить из индекса?'),
                              content: const Text(
                                'Фото останется в галерее телефона, но исчезнет из PinPic.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => context.pop(false),
                                  child: const Text('Отмена'),
                                ),
                                TextButton(
                                  onPressed: () => context.pop(true),
                                  child: const Text('Удалить'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed != true) return;
                          await ref
                              .read(photoRepositoryProvider)
                              .deleteByMediaId(widget.mediaId);
                          ref
                              .read(thumbnailCacheProvider)
                              .invalidate(widget.mediaId);
                          ref.read(searchServiceProvider).invalidateCaches();
                          ref.invalidate(favoritesProvider);
                          ref.invalidate(photoStatsProvider);
                          if (!context.mounted) return;
                          context.pop();
                        },
                        child: const Text(
                          'Удалить',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
