import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinpic/services/document_expiry.dart';
import 'package:pinpic/services/entity_extraction_service.dart';
import 'package:pinpic/shared/models/photo_entity.dart';
import 'package:pinpic/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// Compact memory card: headline + extracted facts, not just a filename.
class SmartMemoryCard extends StatelessWidget {
  const SmartMemoryCard({
    super.key,
    required this.photo,
    this.compact = false,
    this.showActions = false,
  });

  final PhotoEntity photo;
  final bool compact;
  final bool showActions;

  ExtractedEntities get _entities => EntityExtractionService().extract(
    ocrText: photo.ocrText,
    category: photo.category,
    dateTaken: photo.dateTaken,
    qrPayload: photo.qrPayload,
  );

  @override
  Widget build(BuildContext context) {
    final entities = _entities;
    final title =
        photo.cardTitle?.trim().isNotEmpty == true
        ? photo.cardTitle!
        : (entities.cardHeadline ??
              photo.category ??
              photo.displayName ??
              'Фото');
    final rows = photo.cardBody?.trim().isNotEmpty == true
        ? photo.cardBody!.split('\n')
        : entities.cardRows;
    final icon = _iconFor(photo.category, entities);
    final expiry = DocumentExpiryStatus.fromDate(
      photo.expiresAt ?? entities.expiresAt,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: TextStyle(fontSize: compact ? 16 : 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 13 : 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
            if (photo.isPinned)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.push_pin_rounded,
                  size: compact ? 14 : 16,
                  color: AppColors.purple,
                ),
              ),
          ],
        ),
        if (expiry != null) ...[
          SizedBox(height: compact ? 6 : 8),
          _ExpiryBadge(status: expiry, compact: compact),
        ],
        if (rows.isNotEmpty) ...[
          SizedBox(height: compact ? 6 : 10),
          for (final row in rows.take(compact ? 3 : 5))
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                row,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 11 : 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                  height: 1.25,
                ),
              ),
            ),
        ] else if (photo.summary != null) ...[
          SizedBox(height: compact ? 4 : 8),
          Text(
            photo.summary!,
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 11 : 13,
              color: AppColors.textMuted,
              height: 1.3,
            ),
          ),
        ],
        if (showActions) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (entities.phone != null)
                _ActionChip(
                  label: 'Позвонить',
                  icon: Icons.phone_rounded,
                  onTap: () => launchUrl(Uri(scheme: 'tel', path: entities.phone)),
                ),
              if (entities.phone != null)
                _ActionChip(
                  label: 'Скопировать телефон',
                  icon: Icons.copy_rounded,
                  onTap: () => _copy(context, entities.phone!),
                ),
              if (entities.email != null)
                _ActionChip(
                  label: 'Написать',
                  icon: Icons.mail_outline_rounded,
                  onTap: () =>
                      launchUrl(Uri(scheme: 'mailto', path: entities.email)),
                ),
              if (entities.email != null)
                _ActionChip(
                  label: 'Скопировать email',
                  icon: Icons.copy_rounded,
                  onTap: () => _copy(context, entities.email!),
                ),
              if (entities.wifiPassword != null)
                _ActionChip(
                  label: 'Скопировать пароль',
                  icon: Icons.wifi_password_rounded,
                  onTap: () => _copy(context, entities.wifiPassword!),
                ),
              if (entities.url != null ||
                  (photo.hasQr && (photo.qrPayload?.startsWith('http') ?? false)))
                _ActionChip(
                  label: 'Открыть ссылку',
                  icon: Icons.open_in_new_rounded,
                  onTap: () {
                    final raw = entities.url ?? photo.qrPayload!;
                    final uri = Uri.tryParse(
                      raw.startsWith('http') ? raw : 'https://$raw',
                    );
                    if (uri != null) {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              if (entities.docNumber != null)
                _ActionChip(
                  label: 'Скопировать номер',
                  icon: Icons.tag_rounded,
                  onTap: () => _copy(context, entities.docNumber!),
                ),
              if (entities.amount != null)
                _ActionChip(
                  label: 'Скопировать сумму',
                  icon: Icons.payments_outlined,
                  onTap: () => _copy(context, entities.amount!),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _copy(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Скопировано: $value')));
  }

  String _iconFor(String? category, ExtractedEntities entities) {
    if (entities.wifiPassword != null) return '📶';
    if (entities.url != null || (photo.hasQr)) return '📱';
    switch (category) {
      case 'Чеки':
        return '🧾';
      case 'Билеты':
        return '✈️';
      case 'Гарантии':
        return '🛡️';
      case 'Визитки':
        return '📇';
      case 'Паспорта':
      case 'Права':
        return '🪪';
      case 'Договоры':
        return '📄';
      case 'Пароли':
        return '📶';
      case 'QR':
        return '📱';
      default:
        return '📄';
    }
  }
}

class _ExpiryBadge extends StatelessWidget {
  const _ExpiryBadge({required this.status, required this.compact});

  final DocumentExpiryStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (Color dot, Color bg, Color fg) = switch (status.validity) {
      DocumentValidity.valid => (
        const Color(0xFF34C759),
        const Color(0x1A34C759),
        const Color(0xFF34C759),
      ),
      DocumentValidity.expiringSoon => (
        const Color(0xFFFFCC00),
        const Color(0x1AFFCC00),
        const Color(0xFFE6B800),
      ),
      DocumentValidity.expired => (
        const Color(0xFFFF3B30),
        const Color(0x1AFF3B30),
        const Color(0xFFFF6B63),
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 7 : 8,
            height: compact ? 7 : 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: fg,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 16, color: AppColors.purple),
      label: Text(label),
      backgroundColor: const Color(0xFF242430),
      side: BorderSide.none,
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}
