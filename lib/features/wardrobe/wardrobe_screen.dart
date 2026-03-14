import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/clothing_item.dart';
import '../../providers/wardrobe_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_colors.dart';
import 'category_details_screen.dart';

class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wardrobeState = ref.watch(wardrobeProvider);
    final items = wardrobeState.items;
    final colors = wardrobeState.categoryColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wardrobe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(wardrobeProvider.notifier).refreshColors(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        children: ClothingCategory.values.map((cat) {
          final categoryItems = items.where((i) => i.category == cat).toList();
          return _buildCategoryCard(context, cat, categoryItems.length, colors[cat] ?? Colors.grey);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(navigationProvider.notifier).state = 2,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, ClothingCategory cat, int count, Color categoryColor) {
    final iconMap = {
      ClothingCategory.tops: Icons.checkroom,
      ClothingCategory.bottoms: Icons.layers,
      ClothingCategory.dresses: Icons.woman,
      ClothingCategory.outerwear: Icons.cloud_outlined,
      ClothingCategory.shoes: Icons.directions_walk,
      ClothingCategory.bags: Icons.shopping_bag_outlined,
      ClothingCategory.accessories: Icons.watch_outlined,
      ClothingCategory.cosmetics: Icons.face_retouching_natural,
      ClothingCategory.sets: Icons.style_outlined,
    };

    final nameMap = {
      ClothingCategory.tops: 'Tops',
      ClothingCategory.bottoms: 'Bottoms',
      ClothingCategory.dresses: 'Dresses',
      ClothingCategory.outerwear: 'Outerwear',
      ClothingCategory.shoes: 'Shoes',
      ClothingCategory.bags: 'Bags',
      ClothingCategory.accessories: 'Accessories',
      ClothingCategory.cosmetics: 'Cosmetics',
      ClothingCategory.sets: 'Sets',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppColors.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(iconMap[cat], color: categoryColor),
        ),
        title: Text(
          nameMap[cat] ?? cat.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$count items'),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailsScreen(category: cat),
            ),
          );
        },
      ),
    );
  }


}
