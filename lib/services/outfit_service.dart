import 'dart:math';
import 'package:flutter/material.dart';
import '../models/clothing_item.dart';

class OutfitSuggestion {
  final List<ClothingItem> items;
  final String description;

  OutfitSuggestion({required this.items, required this.description});
}

class OutfitService {
  static final _random = Random();

  static List<OutfitSuggestion> suggestMultipleOutfits(List<ClothingItem> wardrobe, {int count = 3}) {
    if (wardrobe.isEmpty) return [];
    
    final suggestions = <OutfitSuggestion>[];
    for (int i = 0; i < count; i++) {
      final suggestion = suggestOutfit(wardrobe);
      if (suggestion != null) {
        suggestions.add(suggestion);
      }
    }
    
    // De-duplicate if necessary (simple check by items)
    return suggestions.toSet().toList();
  }

  static OutfitSuggestion? suggestOutfit(List<ClothingItem> wardrobe) {
    if (wardrobe.isEmpty) return null;

    final tops = wardrobe.where((i) => i.category == ClothingCategory.tops || i.category == ClothingCategory.outerwear).toList();
    final bottoms = wardrobe.where((i) => i.category == ClothingCategory.bottoms).toList();
    final shoes = wardrobe.where((i) => i.category == ClothingCategory.shoes).toList();
    final bags = wardrobe.where((i) => i.category == ClothingCategory.bags).toList();
    final accessories = wardrobe.where((i) => i.category == ClothingCategory.accessories).toList();

    if (tops.isEmpty && bottoms.isEmpty && wardrobe.isNotEmpty) {
      // If no tops or bottoms, just pick any random item to start a "look"
      wardrobe.shuffle(_random);
      final item = wardrobe.first;
      return OutfitSuggestion(
        items: [item],
        description: "A piece from your collection.",
      );
    }

    final List<ClothingItem> selectedItems = [];
    
    // Pick a base item (Top or Bottom)
    ClothingItem baseItem;
    if (tops.isNotEmpty && (_random.nextBool() || bottoms.isEmpty)) {
      tops.shuffle(_random);
      baseItem = tops.first;
      selectedItems.add(baseItem);
    } else if (bottoms.isNotEmpty) {
      bottoms.shuffle(_random);
      baseItem = bottoms.first;
      selectedItems.add(baseItem);
    } else {
       // Should not happen due to check above
       return null;
    }

    final Color baseColor = _getItemColor(baseItem);
    final HSLColor baseHsl = HSLColor.fromColor(baseColor);

    // Find matching bottom if we picked a top
    if ((baseItem.category == ClothingCategory.tops || baseItem.category == ClothingCategory.outerwear) && bottoms.isNotEmpty) {
      final bottom = _findComplementaryItem(bottoms, baseHsl);
      if (bottom != null) selectedItems.add(bottom);
    } 
    // Find matching top if we picked a bottom
    else if (baseItem.category == ClothingCategory.bottoms && tops.isNotEmpty) {
      final top = _findComplementaryItem(tops, baseHsl);
      if (top != null) selectedItems.add(top);
    }

    // Add shoes if available
    if (shoes.isNotEmpty) {
      final shoe = _findComplementaryItem(shoes, baseHsl);
      if (shoe != null) selectedItems.add(shoe);
    }

    // Add accessory or bag
    if (bags.isNotEmpty && _random.nextBool()) {
      final bag = _findComplementaryItem(bags, baseHsl);
      if (bag != null) selectedItems.add(bag);
    } else if (accessories.isNotEmpty && _random.nextBool()) {
      final acc = _findComplementaryItem(accessories, baseHsl);
      if (acc != null) selectedItems.add(acc);
    }

    if (selectedItems.isEmpty) return null;

    return OutfitSuggestion(
      items: selectedItems,
      description: _generateDescription(selectedItems),
    );
  }

  static Color _getItemColor(ClothingItem item) {
    return item.mainColor ?? (item.dominantColors.isNotEmpty ? item.dominantColors.first : Colors.grey);
  }

  static ClothingItem? _findComplementaryItem(List<ClothingItem> items, HSLColor targetHsl) {
    if (items.isEmpty) return null;
    
    items.shuffle(_random);
    ClothingItem? bestItem;
    double bestScore = -1;

    for (final item in items) {
      final color = _getItemColor(item);
      final hsl = HSLColor.fromColor(color);
      
      // Calculate complementary score (hue difference near 180)
      double hueDiff = (targetHsl.hue - hsl.hue).abs();
      if (hueDiff > 180) hueDiff = 360 - hueDiff;
      
      final diffFrom180 = (180 - hueDiff).abs();
      final score = 180 - diffFrom180; // Higher is more complementary

      // Also consider saturation and lightness similarity for a better look
      final satScore = 100 - (targetHsl.saturation - hsl.saturation).abs() * 100;
      final lightScore = 100 - (targetHsl.lightness - hsl.lightness).abs() * 100;
      
      final totalScore = score + (satScore * 0.2) + (lightScore * 0.2);

      if (totalScore > 200) { // Very good match
        return item;
      }

      if (totalScore > bestScore) {
        bestScore = totalScore;
        bestItem = item;
      }
    }

    return bestItem;
  }

  static String _generateDescription(List<ClothingItem> items) {
    if (items.length <= 1) return "A simple single-piece look.";
    if (items.length == 2) return "A balanced two-piece look with complementary colors.";
    return "A complete ensemble curated specifically for your style today.";
  }
}
