import 'package:flutter/material.dart';
import 'package:pinpic/theme/app_colors.dart';

class AppRetryState extends StatelessWidget {
  const AppRetryState({
    super.key,
    required this.message,
    required this.onRetry,
    this.textColor,
  });

  final String message;
  final VoidCallback onRetry;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.search_off_rounded,
    this.primaryLabel,
    this.onPrimary,
    this.suggestions = const [],
    this.onSuggestion,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final List<String> suggestions;
  final ValueChanged<String>? onSuggestion;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final muted = isLight ? const Color(0xFF5C5C6A) : AppColors.textMuted;
    final text = isLight ? const Color(0xFF12121A) : Colors.white;
    final card = isLight ? const Color(0xFFE8EAF2) : const Color(0xFF1C1C1E);
    final accent = isLight ? const Color(0xFF9333EA) : const Color(0xFFA855F7);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: card,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(icon, size: 40, color: accent),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.15,
                  color: text,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                  color: muted,
                ),
              ),
              if (suggestions.isNotEmpty && onSuggestion != null) ...[
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Попробуйте найти',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: muted,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final tip in suggestions)
                      ActionChip(
                        label: Text(tip),
                        onPressed: () => onSuggestion!(tip),
                        backgroundColor: card,
                        side: BorderSide(
                          color: text.withValues(alpha: 0.08),
                        ),
                        labelStyle: TextStyle(
                          color: text,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ],
              if (primaryLabel != null && onPrimary != null) ...[
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: onPrimary,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      primaryLabel!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
