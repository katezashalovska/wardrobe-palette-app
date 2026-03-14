import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFFA824E3); // Purple
  static const Color primaryDark = Color(0xFF7A15AD);
  
  // Neutral colors
  static const Color background = Color(0xFFFCF8FF); // Light pinkish
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color textBody = Color(0xFF94A3B8); // Slate 400
  static const Color textHeading = Color(0xFF1E1B4B); // Very dark violet/indigo
  
  // Accent colors
  static const Color accentPurple = Color(0xFFB137DF);
  static const Color accentBlue = Color(0xFF3B82F6);
  
  // Fashion Palette (Scandinavian Soft Luxury)
  static const Color fashionOuterwear = Color(0xFF2D3142); // Midnight Slate
  static const Color fashionTop = Color(0xFFDDC1BD);       // Peony Silk
  static const Color fashionBottom = Color(0xFF9A9B94);    // Silver Sage
  static const Color fashionAccessories = Color(0xFFB5835C); // Toffee Ember
  static const Color fashionManicure = Color(0xFFB2A4B1);   // Misty Mauve
  static const Color fashionCosmetics = Color(0xFF8E5D52);   // Rosewood Lustre
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B2AFF), Color(0xFFE00C88)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  // Glassmorphism helpers
  static Color glassBackground = Colors.white.withOpacity(0.05);
  static Color glassBorder = Colors.white.withOpacity(0.1);
}
