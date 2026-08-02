import 'package:flutter_test/flutter_test.dart';
import 'package:pinpic/services/imagenet_label_mapper.dart';

void main() {
  group('ImagenetLabelMapper', () {
    test('maps dog breeds to Dog/Animal', () {
      final labels = ImagenetLabelMapper.expand('golden retriever');
      expect(labels, containsAll(['Dog', 'Animal', 'Pet']));
    });

    test('maps pizza to Food', () {
      final labels = ImagenetLabelMapper.expand('pizza');
      expect(labels, containsAll(['Food', 'Meal', 'Pizza']));
    });

    test('maps sports car to Car/Vehicle', () {
      final labels = ImagenetLabelMapper.expand('sports car');
      expect(labels, containsAll(['Car', 'Vehicle']));
    });

    test('maps daisy to Plant/Flower', () {
      final labels = ImagenetLabelMapper.expand('daisy');
      expect(labels, containsAll(['Plant', 'Flower']));
    });

    test('maps espresso to Coffee/Food', () {
      final labels = ImagenetLabelMapper.expand('espresso');
      expect(labels, containsAll(['Coffee', 'Food']));
    });

    test('stone/cliff never become Food', () {
      for (final raw in const ['cliff', 'stone wall', 'mountain']) {
        final labels = ImagenetLabelMapper.expand(raw);
        expect(labels, isNot(contains('Food')), reason: raw);
        expect(labels, contains('Stone'), reason: raw);
      }
    });

    test('ignores background', () {
      expect(ImagenetLabelMapper.expand('background'), isEmpty);
    });

    test('maps crane bird to Bird/Animal', () {
      final labels = ImagenetLabelMapper.expand('crane');
      expect(labels, containsAll(['Bird', 'Animal']));
    });

    test('teddy bear is a Toy, not live Animal', () {
      final labels = ImagenetLabelMapper.expand('teddy, teddy bear');
      expect(labels, containsAll(['Toy', 'Teddy']));
      expect(labels, isNot(contains('Animal')));
      expect(labels, isNot(contains('Bear')));
    });

    test('real bears still map to Animal', () {
      final labels = ImagenetLabelMapper.expand('brown bear');
      expect(labels, contains('Animal'));
    });

    test('maps reflex camera to Camera', () {
      final labels = ImagenetLabelMapper.expand('reflex camera');
      expect(labels, containsAll(['Camera', 'Photo']));
    });
  });
}
