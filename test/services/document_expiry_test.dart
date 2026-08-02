import 'package:flutter_test/flutter_test.dart';
import 'package:pinpic/services/document_expiry.dart';

void main() {
  final now = DateTime(2026, 8, 2);

  test('valid when more than 15 days left', () {
    final status = DocumentExpiryStatus.fromDate(
      DateTime(2026, 9, 1),
      now: now,
    );
    expect(status?.validity, DocumentValidity.valid);
    expect(status?.label, 'Действителен');
  });

  test('expiring soon shows days left', () {
    final status = DocumentExpiryStatus.fromDate(
      DateTime(2026, 8, 17),
      now: now,
    );
    expect(status?.validity, DocumentValidity.expiringSoon);
    expect(status?.label, 'Истекает через 15 дней');
  });

  test('expired', () {
    final status = DocumentExpiryStatus.fromDate(
      DateTime(2026, 7, 1),
      now: now,
    );
    expect(status?.validity, DocumentValidity.expired);
    expect(status?.label, 'Просрочен');
  });

  test('null when no date', () {
    expect(DocumentExpiryStatus.fromDate(null), isNull);
  });
}
