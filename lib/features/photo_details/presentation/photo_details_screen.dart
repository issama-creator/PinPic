import 'dart:io';
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
import 'package:share_plus/share_plus.dart';

final _photoByIdProvider = FutureProvider.autoDispose
    .family<PhotoEntity?, String>((ref, mediaId) async {
      await ref.watch(appBootstrapProvider.future);
      return ref.watch(photoRepositoryProvider).findByMediaId(mediaId);
    });

class PhotoDetailsScreen extends ConsumerWidget {
  const PhotoDetailsScreen({super.key, required this.mediaId});

  final String mediaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoAsync = ref.watch(_photoByIdProvider(mediaId));
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
                      .setFavorite(mediaId, !photo.isFavorite);
                  ref.invalidate(_photoByIdProvider(mediaId));
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
            onRetry: () => ref.invalidate(_photoByIdProvider(mediaId)),
          ),
          data: (photo) {
            if (photo == null) {
              return const Center(child: Text('Фото не найдено в индексе'));
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: PhotoThumbnail(
                        mediaId: mediaId,
                        filePath: photo.path,
                        width: 1200,
                        height: 1200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Почему найдено',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    label: 'OCR',
                    value: photo.ocrText?.isNotEmpty == true
                        ? photo.ocrText!
                        : '—',
                  ),
                  _InfoRow(label: 'Категория', value: photo.category ?? '—'),
                  _InfoRow(
                    label: 'Объекты',
                    value: photo.objects.isEmpty
                        ? '—'
                        : photo.objects.take(6).join(', '),
                  ),
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
                                .setFavorite(mediaId, next);
                            ref.invalidate(_photoByIdProvider(mediaId));
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
                            final asset = await AssetEntity.fromId(mediaId);
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
                                .deleteByMediaId(mediaId);
                            ref
                                .read(thumbnailCacheProvider)
                                .invalidate(mediaId);
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
              ),
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
