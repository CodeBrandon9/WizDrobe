import 'package:flutter/foundation.dart';

enum WardrobeCategory { tops, bottoms, shoes, outerwear, accessories }

@immutable
class WardrobeItem {
  const WardrobeItem({
    required this.name,
    required this.imageBytes,
    required this.backgroundRemoved,
    required this.category,
  });

  final String name;
  final Uint8List imageBytes;
  final bool backgroundRemoved;
  final WardrobeCategory category;
}

String wardrobeCategoryLabel(WardrobeCategory category) {
  switch (category) {
    case WardrobeCategory.tops:
      return 'Tops';
    case WardrobeCategory.bottoms:
      return 'Bottoms';
    case WardrobeCategory.shoes:
      return 'Shoes';
    case WardrobeCategory.outerwear:
      return 'Outerwear';
    case WardrobeCategory.accessories:
      return 'Accessories';
  }
}

@immutable
class SavedOutfitEntry {
  const SavedOutfitEntry({
    required this.name,
    required this.previewBytes,
  });

  final String name;
  final Uint8List previewBytes;
}
