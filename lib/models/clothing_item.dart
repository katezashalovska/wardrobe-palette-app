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
  final Color? mainColor;
  final DateTime dateAdded;

  ClothingItem({
    required this.id,
    required this.imageUrl,
    required this.category,
    required this.dominantColors,
    this.mainColor,
    required this.dateAdded,
  });

  ClothingItem copyWith({
    String? id,
    String? imageUrl,
    ClothingCategory? category,
    List<Color>? dominantColors,
    Color? mainColor,
    DateTime? dateAdded,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      dominantColors: dominantColors ?? this.dominantColors,
      mainColor: mainColor ?? this.mainColor,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'category': category.name,
      'dominantColors': dominantColors.map((c) => c.value).toList(),
      'mainColor': mainColor?.value,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map, String docId) {
    return ClothingItem(
      id: docId,
      imageUrl: map['imageUrl'] ?? '',
      category: ClothingCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ClothingCategory.tops,
      ),
      dominantColors: (map['dominantColors'] as List<dynamic>?)
              ?.map((c) => Color(c as int))
              .toList() ??
          [],
      mainColor: map['mainColor'] != null ? Color(map['mainColor'] as int) : null,
      dateAdded: map['dateAdded'] != null
          ? DateTime.parse(map['dateAdded'])
          : DateTime.now(),
    );
  }
}
