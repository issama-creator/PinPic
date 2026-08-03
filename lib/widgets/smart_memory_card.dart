import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinpic/services/document_expiry.dart';
import 'package:pinpic/services/entity_extraction_service.dart';
import 'package:pinpic/services/memory_card_title.dart';
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
    this.onRenameTitle,
  });

  final PhotoEntity photo;
  final bool compact;
  final bool showActions;
  final Future<void> Function(String? title)? onRenameTitle;

  ExtractedEntities get _entities => EntityExtractionService().extract(
    ocrText: photo.ocrText,
    category: photo.category,
    dateTaken: photo.dateTaken,
    qrPayload: photo.qrPayload,
  );

  @override
  Widget build(BuildContext context) {
    final entities = _entities;
    final title = resolveMemoryCardTitle(
      photo,
      entities: entities,
      fallback: 'Фото',
    );
    final rows = entities.cardRows.isNotEmpty
        ? entities.cardRows
        : (photo.cardBody?.trim().isNotEmpty == true
              ? photo.cardBody!.split('\n')
              : const <String>[]);
    final icon = _iconFor(photo.category, entities);
    final expiry = DocumentExpiryStatus.fromDate(
      photo.expiresAt ?? entities.expiresAt,
    );
    final primaryCopy = _primaryCopy(entities);

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
            if (showActions && onRenameTitle != null)
              IconButton(
                tooltip: 'Переименовать',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                onPressed: () => _editTitle(context, title),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ),
            if (photo.isPinned)
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 8),
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
          if (primaryCopy != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _copy(context, primaryCopy.value),
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: Text(primaryCopy.label),
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
          Builder(
            builder: (context) {
              final secondary = _secondaryActions(context, entities);
              if (secondary.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(top: primaryCopy == null ? 12 : 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: secondary,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Future<void> _editTitle(BuildContext context, String current) async {
    final onRename = onRenameTitle;
    if (onRename == null) return;
    final controller = TextEditingController(text: current);
    final next = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Название'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 80,
            decoration: const InputDecoration(
              hintText: 'Например: Wi‑Fi у бабушки',
            ),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ''),
              child: const Text('Сбросить'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (next == null) return;
    await onRename(next.trim().isEmpty ? null : next.trim());
  }

  ({String label, String value})? _primaryCopy(ExtractedEntities entities) {
    if (entities.wifiPassword != null) {
      return (label: 'Скопировать пароль', value: entities.wifiPassword!);
    }
    if (entities.amount != null) {
      return (label: 'Скопировать сумму', value: entities.amount!);
    }
    if (entities.docNumber != null) {
      return (label: 'Скопировать номер', value: entities.docNumber!);
    }
    if (entities.phone != null) {
      return (label: 'Скопировать телефон', value: entities.phone!);
    }
    if (entities.url != null ||
        (photo.hasQr && (photo.qrPayload?.trim().isNotEmpty ?? false))) {
      final value = entities.url ?? photo.qrPayload!;
      return (label: 'Скопировать', value: value);
    }
    return null;
  }

  List<Widget> _secondaryActions(
    BuildContext context,
    ExtractedEntities entities,
  ) {
    final chips = <Widget>[];
    void add(String label, IconData icon, VoidCallback onTap) {
      chips.add(_ActionChip(label: label, icon: icon, onTap: onTap));
    }

    if (entities.phone != null) {
      add(
        'Позвонить',
        Icons.phone_rounded,
        () => launchUrl(Uri(scheme: 'tel', path: entities.phone)),
      );
    }
    if (entities.email != null) {
      add(
        'Написать',
        Icons.mail_outline_rounded,
        () => launchUrl(Uri(scheme: 'mailto', path: entities.email)),
      );
      add(
        'Скопировать email',
        Icons.copy_rounded,
        () => _copy(context, entities.email!),
      );
    }
    if (entities.url != null ||
        (photo.hasQr && (photo.qrPayload?.startsWith('http') ?? false))) {
      add('Открыть ссылку', Icons.open_in_new_rounded, () {
        final raw = entities.url ?? photo.qrPayload!;
        final uri = Uri.tryParse(
          raw.startsWith('http') ? raw : 'https://$raw',
        );
        if (uri != null) {
          launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      });
    }
    return chips;
  }

  Future<void> _copy(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Скопировано')));
  }

  String _iconFor(String? category, ExtractedEntities entities) {
    if (entities.wifiPassword != null || entities.wifiSsid != null) return '📶';
    if (entities.url != null || photo.hasQr) return '🔗';
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
        return '🔗';
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
