import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/clothing_item.dart';
import '../../providers/wardrobe_provider.dart';
import '../../theme/app_colors.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  final String imagePath;
  final List<Color> dominantColors;

  const ResultsScreen({
    super.key,
    required this.imagePath,
    required this.dominantColors,
  });

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  ClothingCategory? _selectedCategory;
  Color? _selectedMainColor;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.dominantColors.isNotEmpty) {
      _selectedMainColor = widget.dominantColors.first;
    }
  }

  String _getCategoryName(ClothingCategory category) {
    switch (category) {
      case ClothingCategory.tops: return 'Tops';
      case ClothingCategory.bottoms: return 'Bottoms';
      case ClothingCategory.dresses: return 'Dresses';
      case ClothingCategory.outerwear: return 'Outerwear';
      case ClothingCategory.shoes: return 'Shoes';
      case ClothingCategory.bags: return 'Bags';
      case ClothingCategory.accessories: return 'Accessories';
      case ClothingCategory.cosmetics: return 'Cosmetics';
      case ClothingCategory.sets: return 'Sets';
    }
  }

  Future<void> _saveItem() async {
    if (_selectedCategory == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
      final String itemId = DateTime.now().millisecondsSinceEpoch.toString();
      String finalImageUrl = widget.imagePath;

      if (!kIsWeb) {
        // Зберігаємо локально у постійну пам'ять
        final file = io.File(widget.imagePath);
        final extension = widget.imagePath.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
        
        final directory = await getApplicationDocumentsDirectory();
        final String newPath = '${directory.path}/$itemId.$extension';
        
        final savedImage = await file.copy(newPath);
        finalImageUrl = savedImage.path;
      }

      final newItem = ClothingItem(
        id: itemId,
        imageUrl: finalImageUrl,
        category: _selectedCategory!,
        dominantColors: widget.dominantColors,
        mainColor: _selectedMainColor,
        dateAdded: DateTime.now(),
      );

      await ref.read(wardrobeProvider.notifier).addItem(newItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item successfully added to wardrobe!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving item: $e')),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Color Analysis',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textHeading,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.textHeading, size: 20),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: kIsWeb
                                      ? Image.network(
                                          widget.imagePath,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          io.File(widget.imagePath),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2DC36A),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'Scan completed successfully',
                              style: TextStyle(
                                color: AppColors.textBody,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Pantone Palette Section
                    if (widget.dominantColors.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Color Palette (Pantone)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textHeading,
                              ),
                            ),

                            const SizedBox(height: 16),
                            SizedBox(
                              height: 120, // Height for Pantone chips
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.dominantColors.length,
                                itemBuilder: (context, index) {
                                  final color = widget.dominantColors[index];
                                  return Container(
                                    width: 80,
                                    margin: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.black.withOpacity(0.05),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: color,
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                            ),
                                          ),
                                        ),
                                          Container(
                                            height: 36,
                                            alignment: Alignment.center,
                                            child: Text(
                                              '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textHeading,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                    
                    // Select Category Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Category',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textHeading,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 12,
                            children: ClothingCategory.values.map((category) {
                              final isSelected = _selectedCategory == category;
                              return ChoiceChip(
                                label: Text(_getCategoryName(category)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = selected ? category : null;
                                  });
                                },
                                backgroundColor: const Color(0xFFF2F2F2),
                                selectedColor: const Color(0xFFD1127B),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textHeading,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Colors.transparent),
                                ),
                                showCheckmark: false,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _selectedCategory != null ? const Color(0xFFD1127B) : AppColors.textBody.withOpacity(0.3),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: (_selectedCategory != null && !_isSaving) ? _saveItem : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _isSaving 
                          ? [
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Saving...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ]
                          : [
                              const Icon(
                                Icons.save_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedCategory != null 
                                    ? 'Save to ${_getCategoryName(_selectedCategory!)}' 
                                    : 'Select a category',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
