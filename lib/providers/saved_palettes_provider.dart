import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/saved_palette.dart';

class SavedPalettesNotifier extends StateNotifier<AsyncValue<List<SavedPalette>>> {
  SavedPalettesNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  CollectionReference? _col() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('palettes');
  }

  Future<void> _load() async {
    try {
      final col = _col();
      if (col == null) {
        state = const AsyncValue.data([]);
        return;
      }
      final snap = await col.orderBy('createdAt', descending: true).get();
      final palettes =
          snap.docs.map((d) => SavedPalette.fromDoc(d)).toList();
      state = AsyncValue.data(palettes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();

  /// Returns the new document ID on success, null on failure.
  Future<String?> savePalette(List<PaletteEntry> entries) async {
    final col = _col();
    if (col == null || entries.isEmpty) return null;

    final data = {
      'palette': entries.map((e) => e.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    };
    final ref = await col.add(data);

    // Optimistic update
    final newItem = SavedPalette(
      id: ref.id,
      entries: entries,
      createdAt: DateTime.now(),
    );
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([newItem, ...current]);
    return ref.id;
  }

  Future<void> deletePalette(String id) async {
    final col = _col();
    if (col == null) return;
    await col.doc(id).delete();

    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(current.where((p) => p.id != id).toList());
  }
}

final savedPalettesProvider =
    StateNotifierProvider<SavedPalettesNotifier, AsyncValue<List<SavedPalette>>>(
        (ref) => SavedPalettesNotifier());
