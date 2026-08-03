import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/document_expiry.dart';
import 'package:pinpic/services/entity_extraction_service.dart';
import 'package:pinpic/services/memory_card_title.dart';
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
  });

  final PhotoEntity photo;
  final VoidCallback onTap;
  final int? confidence;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final card = isLight ? const Color(0xFFF2F3F7) : const Color(0xFF16161F);
    final text = isLight ? const Color(0xFF12121A) : Colors.white;
    final muted = isLight ? const Color(0xFF5C5C6A) : AppColors.textMuted;
    final chipBg = isLight ? const Color(0xFFE4E6EE) : const Color(0xFF242430);

    final entities = EntityExtractionService().extract(
      ocrText: photo.ocrText,
      category: photo.category,
      dateTaken: photo.dateTaken,
      qrPayload: photo.qrPayload,
    );
    final title = resolveMemoryCardTitle(photo, entities: entities);
    final fact = _primaryFact(photo, entities);
    final subtitle = _subtitle(photo, entities, fact, title);
    final expiry = DocumentExpiryStatus.fromDate(
      photo.expiresAt ?? entities.expiresAt,
    );
    // Only show confidence when the match is soft — strong hits don't need it.
    final meta = <String>[
      if (confidence != null && confidence! < 80) '$confidence%',
    ];

    return Material(
      color: card,
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: text,
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
                              color: text,
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
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.3,
                              color: muted,
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
              if (fact != null) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _copy(
                      context,
                      fact.copyValue ?? fact.value,
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: Text(fact.copyLabel),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
              if (meta.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final chip in meta)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          chip,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: muted,
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

  static Future<void> _copy(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Скопировано')),
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
      final label = EntityExtractionService.prettyUrlLabel(
            entities.url ?? payload,
          ) ??
          entities.url ??
          payload;
      final shown = label.length > 48 ? '${label.substring(0, 48)}…' : label;
      return _Fact(
        value: shown,
        copyValue: payload,
        copyLabel: 'Скопировать',
      );
    }
    return null;
  }

  static String? _subtitle(
    PhotoEntity photo,
    ExtractedEntities entities,
    _Fact? fact,
    String title,
  ) {
    final parts = <String>[];
    final category = photo.category?.trim();
    if (category != null &&
        category.toLowerCase() != title.toLowerCase() &&
        category != CategoryEngine.passwords) {
      parts.add(category);
    }
    if (entities.amount != null && fact?.value != entities.amount) {
      parts.add(entities.amount!);
    }
    if (photo.dateTaken != null) {
      final d = photo.dateTaken!;
      parts.add(
        '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.'
        '${d.year}',
      );
    }
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }
}

class _Fact {
  const _Fact({
    required this.value,
    required this.copyLabel,
    this.copyValue,
    this.isSecret = false,
  });

  final String value;
  final String copyLabel;
  final String? copyValue;
  final bool isSecret;
}
