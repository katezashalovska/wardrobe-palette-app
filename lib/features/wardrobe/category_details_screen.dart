import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../models/clothing_item.dart';
import '../../providers/wardrobe_provider.dart';
import '../../theme/app_colors.dart';

class CategoryDetailsScreen extends ConsumerWidget {
  final ClothingCategory category;

  const CategoryDetailsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(wardrobeProvider).items.where((i) => i.category == category).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name.toUpperCase()),
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                'No items in this category yet.',
                style: TextStyle(color: AppColors.textBody),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildItemCard(item);
              },
            ),
    );
  }

  Widget _buildItemCard(ClothingItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Large photo at the top
          Expanded(
            flex: 3,
            child: SizedBox(
              width: double.infinity,
              child: kIsWeb
                  ? Image.network(item.imageUrl, fit: BoxFit.cover)
                  : Image.file(io.File(item.imageUrl), fit: BoxFit.cover),
            ),
          ),
          // Palette circles at the bottom
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: item.dominantColors.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: item.dominantColors.take(5).map((color) {
                        return Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.glassBorder, width: 1),
                          ),
                        );
                      }).toList(),
                    )
                  : Center(
                      child: Text(
                        'No palette',
                        style: TextStyle(
                           fontSize: 12,
                           color: AppColors.textBody,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
