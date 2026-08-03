import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/document_expiry.dart';
import 'package:pinpic/services/entity_extraction_service.dart';
import 'package:pinpic/shared/models/photo_entity.dart';
import 'package:pinpic/theme/app_colors.dart';
import 'package:pinpic/widgets/photo_thumbnail.dart';

/// Fact-first search hit: password / amount / title primary, photo as proof.
class FactMemoryTile extends StatelessWidget {
  const FactMemoryTile({
    super.key,
    required this.photo,
    required this.onTap,
    this.confidence,
    this.evidence = const [],
  });

  final PhotoEntity photo;
  final VoidCallback onTap;
  final int? confidence;
  final List<String> evidence;

  @override
  Widget build(BuildContext context) {
    final entities = EntityExtractionService().extract(
      ocrText: photo.ocrText,
      category: photo.category,
      dateTaken: photo.dateTaken,
      qrPayload: photo.qrPayload,
    );
    final title =
        photo.cardTitle?.trim().isNotEmpty == true
        ? photo.cardTitle!
        : (entities.cardHeadline ??
              photo.category ??
              photo.displayName ??
              'Документ');
    final fact = _primaryFact(photo, entities);
    final subtitle = _subtitle(photo, entities, fact);
    final expiry = DocumentExpiryStatus.fromDate(
      photo.expiresAt ?? entities.expiresAt,
    );

    return Material(
      color: const Color(0xFF16161F),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (fact != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            fact.value,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: fact.isSecret ? 20 : 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                              letterSpacing: fact.isSecret ? 0.2 : -0.2,
                            ),
                          ),
                        ],
                        if (subtitle != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.3,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                        if (expiry != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            expiry.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: expiry.validity == DocumentValidity.expired
                                  ? const Color(0xFFFF8A80)
                                  : const Color(0xFFFFC857),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: PhotoThumbnail(
                        mediaId: photo.mediaId,
                        filePath: photo.path,
                        width: 144,
                        height: 144,
                      ),
                    ),
                  ),
                ],
              ),
              if (fact != null || evidence.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (fact != null)
                      _CopyChip(
                        label: fact.copyLabel,
                        value: fact.value,
                      ),
                    if (confidence != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF242430),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '$confidence%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    for (final chip in evidence.take(2))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF242430),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          chip,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static _Fact? _primaryFact(PhotoEntity photo, ExtractedEntities entities) {
    if (entities.wifiPassword != null) {
      return _Fact(
        value: entities.wifiPassword!,
        copyLabel: 'Скопировать пароль',
        isSecret: true,
      );
    }
    if (photo.category == CategoryEngine.passwords &&
        (photo.ocrText?.trim().isNotEmpty ?? false)) {
      final line = photo.ocrText!
          .split(RegExp(r'[\n\r]+'))
          .map((l) => l.trim())
          .firstWhere(
            (l) => l.length >= 6 && !l.toLowerCase().contains('password'),
            orElse: () => photo.ocrText!.trim(),
          );
      if (line.isNotEmpty) {
        return _Fact(
          value: line.length > 42 ? '${line.substring(0, 42)}…' : line,
          copyLabel: 'Скопировать',
          isSecret: true,
        );
      }
    }
    if (entities.amount != null) {
      return _Fact(
        value: entities.amount!,
        copyLabel: 'Скопировать сумму',
      );
    }
    if (entities.docNumber != null) {
      return _Fact(
        value: entities.docNumber!,
        copyLabel: 'Скопировать номер',
      );
    }
    if (entities.phone != null) {
      return _Fact(
        value: entities.phone!,
        copyLabel: 'Скопировать телефон',
      );
    }
    if (photo.hasQr && (photo.qrPayload?.trim().isNotEmpty ?? false)) {
      final payload = photo.qrPayload!.trim();
      return _Fact(
        value: payload.length > 48 ? '${payload.substring(0, 48)}…' : payload,
        copyLabel: 'Скопировать QR',
      );
    }
    return null;
  }

  static String? _subtitle(
    PhotoEntity photo,
    ExtractedEntities entities,
    _Fact? fact,
  ) {
    final parts = <String>[];
    if (photo.category != null) parts.add(photo.category!);
    if (entities.amount != null && fact?.value != entities.amount) {
      parts.add(entities.amount!);
    }
    if (photo.dateTaken != null) {
      final d = photo.dateTaken!;
      parts.add('${d.day.toString().padLeft(2, '0')}.'
          '${d.month.toString().padLeft(2, '0')}.'
          '${d.year}');
    }
    if (parts.isEmpty && photo.summary != null) return photo.summary;
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }
}

class _Fact {
  const _Fact({
    required this.value,
    required this.copyLabel,
    this.isSecret = false,
  });

  final String value;
  final String copyLabel;
  final bool isSecret;
}

class _CopyChip extends StatelessWidget {
  const _CopyChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.copy_rounded, size: 16, color: Colors.white),
      label: Text(label),
      backgroundColor: AppColors.purple.withValues(alpha: 0.85),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: value));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Скопировано: $value')),
        );
      },
    );
  }
}
