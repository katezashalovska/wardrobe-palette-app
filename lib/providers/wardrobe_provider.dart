import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/clothing_item.dart';
import '../services/category_color_service.dart';

class WardrobeState {
  final List<ClothingItem> items;
  final Map<ClothingCategory, Color> categoryColors;
  final bool isLoading;

  WardrobeState({
    required this.items,
    required this.categoryColors,
    this.isLoading = false,
  });

  WardrobeState copyWith({
    List<ClothingItem>? items,
    Map<ClothingCategory, Color>? categoryColors,
    bool? isLoading,
  }) {
    return WardrobeState(
      items: items ?? this.items,
      categoryColors: categoryColors ?? this.categoryColors,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WardrobeNotifier extends StateNotifier<WardrobeState> {
  WardrobeNotifier() : super(WardrobeState(items: [], categoryColors: {}, isLoading: true)) {
    _init();
  }

  /// Subscribes to auth-state changes so wardrobe reloads on login/logout.
  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _loadItems(user.uid);
      } else {
        // Clear on logout
        state = WardrobeState(items: [], categoryColors: {});
      }
    });
  }

  Future<void> _loadItems(String uid) async {
    state = state.copyWith(isLoading: true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('wardrobe')
          .orderBy('dateAdded', descending: true)
          .get();

      final items =
          snapshot.docs.map((doc) => ClothingItem.fromMap(doc.data(), doc.id)).toList();
      final newColors = CategoryColorService.generateCategoryColors(items);
      state = state.copyWith(items: items, categoryColors: newColors, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> reload() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) await _loadItems(uid);
  }

  Future<void> addItem(ClothingItem item) async {
    final newItems = [item, ...state.items];
    final newColors = CategoryColorService.generateCategoryColors(newItems);
    state = state.copyWith(items: newItems, categoryColors: newColors);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('wardrobe')
          .doc(item.id)
          .set(item.toMap())
          .catchError((e) {
            debugPrint('Error saving to Firestore: $e');
          });
    }
  }

  Future<void> removeItem(String id) async {
    final newItems = state.items.where((item) => item.id != id).toList();
    final newColors = CategoryColorService.generateCategoryColors(newItems);
    state = state.copyWith(items: newItems, categoryColors: newColors);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('wardrobe')
          .doc(id)
          .delete()
          .catchError((e) {
            debugPrint('Error deleting from Firestore: $e');
          });
    }
  }

  void refreshColors() {
    final newColors = CategoryColorService.generateCategoryColors(state.items);
    state = state.copyWith(categoryColors: newColors);
  }
}

final wardrobeProvider =
    StateNotifierProvider<WardrobeNotifier, WardrobeState>((ref) {
  return WardrobeNotifier();
});
