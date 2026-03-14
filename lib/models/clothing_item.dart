import 'package:flutter/material.dart';

enum ClothingCategory {
  tops,
  bottoms,
  dresses,
  outerwear,
  shoes,
  bags,
  accessories,
  cosmetics,
  sets,
}

class ClothingItem {
  final String id;
  final String imageUrl;
  final ClothingCategory category;
  final List<Color> dominantColors;
  final DateTime dateAdded;

  ClothingItem({
    required this.id,
    required this.imageUrl,
    required this.category,
    required this.dominantColors,
    required this.dateAdded,
  });

  ClothingItem copyWith({
    String? id,
    String? imageUrl,
    ClothingCategory? category,
    List<Color>? dominantColors,
    DateTime? dateAdded,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      dominantColors: dominantColors ?? this.dominantColors,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }
}
