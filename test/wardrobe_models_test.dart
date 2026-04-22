import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wizdrobe/wardrobe_models.dart';

void main() {
  group('wardrobeCategoryLabel', () {
    test('maps every category to a non-empty label', () {
      for (final c in WardrobeCategory.values) {
        final label = wardrobeCategoryLabel(c);
        expect(label, isNotEmpty);
        expect(label.length, greaterThanOrEqualTo(3));
      }
    });

    test('returns expected labels', () {
      expect(wardrobeCategoryLabel(WardrobeCategory.tops), 'Tops');
      expect(wardrobeCategoryLabel(WardrobeCategory.bottoms), 'Bottoms');
      expect(wardrobeCategoryLabel(WardrobeCategory.shoes), 'Shoes');
      expect(wardrobeCategoryLabel(WardrobeCategory.outerwear), 'Outerwear');
      expect(wardrobeCategoryLabel(WardrobeCategory.accessories), 'Accessories');
    });
  });

  group('WardrobeItem', () {
    test('holds fields', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final item = WardrobeItem(
        name: 'Jacket',
        imageBytes: bytes,
        backgroundRemoved: true,
        category: WardrobeCategory.outerwear,
      );
      expect(item.name, 'Jacket');
      expect(item.imageBytes, same(bytes));
      expect(item.backgroundRemoved, isTrue);
      expect(item.category, WardrobeCategory.outerwear);
    });
  });

  group('SavedOutfitEntry', () {
    test('holds name and preview bytes', () {
      final preview = Uint8List.fromList([10, 20]);
      final entry = SavedOutfitEntry(name: 'Casual', previewBytes: preview);
      expect(entry.name, 'Casual');
      expect(entry.previewBytes, same(preview));
    });
  });
}
