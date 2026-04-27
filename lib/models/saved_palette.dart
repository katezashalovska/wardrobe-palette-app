import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaletteEntry {
  final String name;
  final Color color;
  final bool isFixed;

  PaletteEntry({
    required this.name,
    required this.color,
    this.isFixed = false,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'color': color.value,
        'isFixed': isFixed,
      };

  factory PaletteEntry.fromMap(Map<String, dynamic> map) {
    return PaletteEntry(
      name: map['name'] as String? ?? '',
      color: Color(map['color'] as int? ?? 0xFFAAAAAA),
      isFixed: map['isFixed'] as bool? ?? false,
    );
  }
}

class SavedPalette {
  final String id;
  final List<PaletteEntry> entries;
  final DateTime createdAt;

  SavedPalette({
    required this.id,
    required this.entries,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'palette': entries.map((e) => e.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory SavedPalette.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawPalette = data['palette'] as List<dynamic>? ?? [];
    return SavedPalette(
      id: doc.id,
      entries: rawPalette
          .map((e) => PaletteEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
