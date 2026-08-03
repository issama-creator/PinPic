/// Simple document validity badge. Reminders live in [ExpiryReminderService].
enum DocumentValidity { valid, expiringSoon, expired }

class DocumentExpiryStatus {
  const DocumentExpiryStatus({
    required this.validity,
    required this.label,
    required this.expiresAt,
    this.daysLeft,
  });

  final DocumentValidity validity;
  final String label;
  final DateTime expiresAt;
  final int? daysLeft;

/// Yellow band matches the product note («через 15 дней»).
  static DocumentExpiryStatus? fromDate(
    DateTime? expiresAt, {
    DateTime? now,
    int warnWithinDays = 15,
  }) {
    if (expiresAt == null) return null;
    final today = _dateOnly(now ?? DateTime.now());
    final end = _dateOnly(expiresAt);
    final days = end.difference(today).inDays;

    if (days < 0) {
      return DocumentExpiryStatus(
        validity: DocumentValidity.expired,
        label: 'Просрочен',
        expiresAt: end,
        daysLeft: days,
      );
    }
    if (days <= warnWithinDays) {
      final when = days == 0
          ? 'Истекает сегодня'
          : days == 1
          ? 'Истекает завтра'
          : 'Истекает через $days ${_dayWord(days)}';
      return DocumentExpiryStatus(
        validity: DocumentValidity.expiringSoon,
        label: when,
        expiresAt: end,
        daysLeft: days,
      );
    }
    return DocumentExpiryStatus(
      validity: DocumentValidity.valid,
      label: 'Действителен',
      expiresAt: end,
      daysLeft: days,
    );
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static String _dayWord(int days) {
    final mod10 = days % 10;
    final mod100 = days % 100;
    if (mod10 == 1 && mod100 != 11) return 'день';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'дня';
    }
    return 'дней';
  }
}
