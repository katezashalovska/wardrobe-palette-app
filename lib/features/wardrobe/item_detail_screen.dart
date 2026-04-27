import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../models/clothing_item.dart';
import '../../theme/app_colors.dart';

class ItemDetailScreen extends StatelessWidget {
  final ClothingItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          _categoryLabel(item.category),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Full-screen photo ─────────────────────────────────────────────
          Positioned.fill(
            child: item.imageUrl.startsWith('http')
                ? Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
                  )
                : kIsWeb
                    ? Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
                      )
                    : Image.file(
                        io.File(item.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
                      ),
          ),

          // ── Gradient overlay at bottom ────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 310,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
            ),
          ),

          // ── Pantone swatches row at the bottom ────────────────────────────
          if (item.dominantColors.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: item.dominantColors
                      .take(6)
                      .map((color) => _PantoneSwatch(color: color))
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _categoryLabel(ClothingCategory cat) {
    const names = {
      ClothingCategory.tops: 'Top',
      ClothingCategory.bottoms: 'Bottom',
      ClothingCategory.dresses: 'Dress',
      ClothingCategory.outerwear: 'Outerwear',
      ClothingCategory.shoes: 'Shoes',
      ClothingCategory.bags: 'Bag',
      ClothingCategory.accessories: 'Accessories',
      ClothingCategory.cosmetics: 'Cosmetics',
      ClothingCategory.sets: 'Set',
    };
    return names[cat] ?? cat.name;
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Image not found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ── Pantone vertical chip (landscape-friendly) ───────────────────────────────

class _PantoneSwatch extends StatelessWidget {
  final Color color;
  const _PantoneSwatch({required this.color});

  @override
  Widget build(BuildContext context) {
    final hex = color.value.toRadixString(16).substring(2).toUpperCase();
    final pantoneCode = '19-${hex.substring(hex.length >= 4 ? hex.length - 4 : 0)} TCX';

    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: '#$hex'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied #$hex'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      child: Container(
        width: 76,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color block
            Container(
              height: 96,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
            ),
            // Labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text(
                        'PANTONE',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.1,
                          color: Colors.black,
                        ),
                      ),
                      Text('®', style: TextStyle(fontSize: 5, color: Colors.black)),
                    ],
                  ),
                  Text(
                    pantoneCode,
                    style: const TextStyle(fontSize: 7, color: Colors.black54, height: 1.2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#$hex',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
