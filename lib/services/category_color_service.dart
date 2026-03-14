import 'package:flutter/material.dart';
import 'dart:math';
import '../models/clothing_item.dart';

class CategoryColorService {
  static final Random _random = Random();

  /// Generates a map of categories to colors based on the current wardrobe.
  static Map<ClothingCategory, Color> generateCategoryColors(List<ClothingItem> wardrobe) {
    final Map<ClothingCategory, Color> result = {};
    final List<ClothingCategory> emptyCategories = [];
    final List<HSLColor> anchorHsls = [];

    // 1. Get colors for filled categories
    for (var category in ClothingCategory.values) {
      final items = wardrobe.where((i) => i.category == category).toList();
      if (items.isNotEmpty) {
        // Use the dominant color of the most recent item
        final color = items.last.dominantColors.first;
        result[category] = color;
        anchorHsls.add(HSLColor.fromColor(color));
      } else {
        emptyCategories.add(category);
      }
    }

    // 2. Generate colors for empty categories
    if (emptyCategories.isNotEmpty) {
      if (anchorHsls.isEmpty) {
        // No items at all -> Generate a fully random but harmonious set
        final baseHue = _random.nextDouble() * 360;
        final baseS = 0.5 + _random.nextDouble() * 0.3;
        final baseL = 0.4 + _random.nextDouble() * 0.2;
        
        for (int i = 0; i < emptyCategories.length; i++) {
          final hueOffset = (i * (360 / emptyCategories.length)) % 360;
          result[emptyCategories[i]] = HSLColor.fromAHSL(
            1.0, 
            (baseHue + hueOffset) % 360, 
            baseS, 
            baseL
          ).toColor();
        }
      } else {
        // Some items exist -> Generate colors complementary/analogous to anchors
        for (int i = 0; i < emptyCategories.length; i++) {
          final anchor = anchorHsls[i % anchorHsls.length];
          // Mix complementary (180) and triadic (120/240) for variety
          double hueOffset;
          if (i % 3 == 0) {
            hueOffset = 180; // Complementary
          } else if (i % 3 == 1) {
            hueOffset = 120; // Triadic 1
          } else {
            hueOffset = 240; // Triadic 2
          }
          
          // Add a bit of randomness to the offset
          hueOffset += (_random.nextDouble() * 30 - 15);

          result[emptyCategories[i]] = HSLColor.fromAHSL(
            1.0,
            (anchor.hue + hueOffset) % 360,
            anchor.saturation * 0.9,
            (anchor.lightness * 0.95).clamp(0.2, 0.8)
          ).toColor();
        }
      }
    }

    return result;
  }
}
