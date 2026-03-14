import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/clothing_item.dart';
import '../services/category_color_service.dart';

class WardrobeState {
  final List<ClothingItem> items;
  final Map<ClothingCategory, Color> categoryColors;

  WardrobeState({
    required this.items,
    required this.categoryColors,
  });

  WardrobeState copyWith({
    List<ClothingItem>? items,
    Map<ClothingCategory, Color>? categoryColors,
  }) {
    return WardrobeState(
      items: items ?? this.items,
      categoryColors: categoryColors ?? this.categoryColors,
    );
  }
}

class WardrobeNotifier extends StateNotifier<WardrobeState> {
  WardrobeNotifier() : super(WardrobeState(items: [], categoryColors: {}));

  void addItem(ClothingItem item) {
    final newItems = [...state.items, item];
    final newColors = CategoryColorService.generateCategoryColors(newItems);
    state = state.copyWith(items: newItems, categoryColors: newColors);
  }

  void removeItem(String id) {
    final newItems = state.items.where((item) => item.id != id).toList();
    final newColors = CategoryColorService.generateCategoryColors(newItems);
    state = state.copyWith(items: newItems, categoryColors: newColors);
  }

  void refreshColors() {
    final newColors = CategoryColorService.generateCategoryColors(state.items);
    state = state.copyWith(categoryColors: newColors);
  }
}

final wardrobeProvider = StateNotifierProvider<WardrobeNotifier, WardrobeState>((ref) {
  final notifier = WardrobeNotifier();
  // Initial colors if needed
  notifier.refreshColors();
  return notifier;
});
