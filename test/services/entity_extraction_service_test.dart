import 'package:flutter_test/flutter_test.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/entity_extraction_service.dart';

void main() {
  final extractor = EntityExtractionService();

  test('extracts IKEA amount date and searchable digits', () {
    final entities = extractor.extract(
      ocrText: 'IKEA\nReceipt\nTotal 4 990 ₽\n15.07.2026\n**** 4821',
      category: CategoryEngine.receipts,
    );

    expect(entities.brand?.toUpperCase(), 'IKEA');
    expect(entities.amount, contains('4990'));
    expect(entities.amountDigits, '4990');
    expect(entities.date, '15.07.2026');
    expect(entities.cardTail, contains('4821'));
    expect(entities.searchTokens, contains('4990'));
    expect(entities.cardHeadline?.toUpperCase(), 'IKEA');
    expect(entities.cardRows, isNotEmpty);
  });

  test('extracts contract number phone and email', () {
    final entities = extractor.extract(
      ocrText:
          'Договор №45872\nТел +7 (900) 123-45-67\nmail@example.com\n15.03.2026',
      category: CategoryEngine.contracts,
    );

    expect(entities.docNumber, '№45872');
    expect(entities.phone, contains('900'));
    expect(entities.email, 'mail@example.com');
    expect(entities.searchTokens, contains('45872'));
  });

  test('extracts wifi password', () {
    final entities = extractor.extract(
      ocrText: 'Wi-Fi Password: HomeNet_42',
      category: CategoryEngine.passwords,
    );
    expect(entities.wifiPassword, 'HomeNet_42');
    expect(entities.searchTokens, contains('homenet_42'));
  });

  test('extracts passport expiry date', () {
    final entities = extractor.extract(
      ocrText:
          'ПАСПОРТ\nSurname IVANOV\nДействителен до 15.03.2027\nДата рождения 01.01.1990',
      category: CategoryEngine.passports,
    );
    expect(entities.expiresAt, DateTime(2027, 3, 15));
    expect(entities.title, 'Паспорт');
  });

  test('ignores plain dates without expiry cue', () {
    final entities = extractor.extract(
      ocrText: 'IKEA\nTotal 990 ₽\n15.07.2026',
      category: CategoryEngine.receipts,
    );
    expect(entities.expiresAt, isNull);
  });
}
