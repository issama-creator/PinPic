import 'package:flutter_test/flutter_test.dart';
import 'package:pinpic/services/local_semantic_embedding_service.dart';

void main() {
  final service = LocalSemanticEmbeddingService();

  test('keeps synonym-related query and visual labels semantically close', () {
    final photo = service.forPhoto(
      ocrTerms: const [],
      visionTerms: const ['golden retriever', 'dog'],
      categoryTerms: const ['Животные'],
      hasQr: false,
    );
    final dog = service.forQuery(const ['собака']);
    final ticket = service.forQuery(const ['билет']);

    expect(service.similarity(dog, photo), greaterThan(0.2));
    expect(
      service.similarity(dog, photo),
      greaterThan(service.similarity(ticket, photo)),
    );
  });

  test('returns normalized fixed-size vectors', () {
    final vector = service.forQuery(const ['чек', 'ikea']);
    expect(vector, hasLength(LocalSemanticEmbeddingService.dimensions));
    final length = vector.fold<double>(0, (sum, value) => sum + value * value);
    expect(length, closeTo(1, 0.0001));
  });
}
