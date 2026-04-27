import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/wardrobe_provider.dart';
import '../../services/outfit_service.dart';
import '../../theme/app_colors.dart';
import '../../models/clothing_item.dart';
import 'package:google_fonts/google_fonts.dart';

class OutfitGenerationScreen extends ConsumerStatefulWidget {
  const OutfitGenerationScreen({super.key});

  @override
  ConsumerState<OutfitGenerationScreen> createState() => _OutfitGenerationScreenState();
}

class _OutfitGenerationScreenState extends ConsumerState<OutfitGenerationScreen> {
  List<OutfitSuggestion> _suggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generate();
    });
  }

  void _generate() {
    setState(() => _isLoading = true);
    final wardrobe = ref.read(wardrobeProvider).items;
    
    // Simulate some AI processing feel
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _suggestions = OutfitService.suggestMultipleOutfits(wardrobe, count: 5);
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Look Generator', 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold)
        ),
        actions: [
          IconButton(
            onPressed: _generate,
            icon: const Icon(Icons.refresh),
            tooltip: 'Regenerate',
          ),
        ],
      ),
      body: _isLoading 
        ? _buildLoadingState()
        : _suggestions.isEmpty 
          ? _buildEmptyState()
          : _buildResultsList(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Analyzing your style...',
            style: GoogleFonts.outfit(
              fontSize: 18,
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.style_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Not enough items to generate looks.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: AppColors.textHeading),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adding more clothes to your wardrobe first.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textBody),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return _buildOutfitCard(suggestion, index);
      },
    );
  }

  Widget _buildOutfitCard(OutfitSuggestion suggestion, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LOOK #${index + 1}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Complementary',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 180,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: suggestion.items.length,
              itemBuilder: (context, iIndex) {
                final item = suggestion.items[iIndex];
                return _buildItemMiniature(item);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              suggestion.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textBody,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemMiniature(ClothingItem item) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 140,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: (kIsWeb 
                ? NetworkImage(item.imageUrl) 
                : FileImage(io.File(item.imageUrl))) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.category.name.toUpperCase(),
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ],
    );
  }
}
