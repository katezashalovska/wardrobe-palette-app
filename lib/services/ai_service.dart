import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:io' as io;

class AiService {
  static Future<List<Color>> extractDominantColors(String imagePath) async {
    try {
      final ImageProvider imageProvider;
      if (kIsWeb) {
        imageProvider = NetworkImage(imagePath);
      } else {
        imageProvider = FileImage(io.File(imagePath));
      }
          
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 24, // Extract more colors to have options after filtering
      );

      List<Color> colors = [];
      
      // Helper to check if a color is a likely skin tone or very neutral background
      bool isLikelySkinOrBackground(Color color) {
        final hsl = HSLColor.fromColor(color);
        
        // Very dark or very bright colors (often backgrounds like white walls or dark shadows)
        if (hsl.lightness > 0.90 || hsl.lightness < 0.1) return true;
        
        // Very unsaturated colors (grays, faded backgrounds)
        if (hsl.saturation < 0.1) return true;

        // Skin tones typically fall into specific hue ranges (orange/brown/pinkish)
        // with moderate saturation and lightness. 
        // Hue 10-45 is typical for most human skin tones
        if (hsl.hue >= 10 && hsl.hue <= 45 && hsl.saturation > 0.2 && hsl.saturation < 0.8 && hsl.lightness > 0.3 && hsl.lightness < 0.85) {
            return true;
        }
        
        return false;
      }

      // 1. First Pass: Try to find vibrant/clothing colors (filtering out skin/bg)
      for (var paletteColor in paletteGenerator.paletteColors) {
        if (!isLikelySkinOrBackground(paletteColor.color)) {
           if (!colors.contains(paletteColor.color)) {
             colors.add(paletteColor.color);
           }
        }
        if (colors.length >= 3) break;
      }

      // 2. Fallback: If the clothing actually WAS black, white, gray, or brown (skin-like)
      // and we filtered everything out, just take the most dominant colors anyway.
      if (colors.isEmpty) {
        if (paletteGenerator.dominantColor != null) {
          colors.add(paletteGenerator.dominantColor!.color);
        }
        for (var paletteColor in paletteGenerator.paletteColors) {
          if (!colors.contains(paletteColor.color)) {
            colors.add(paletteColor.color);
          }
          if (colors.length >= 3) break;
        }
      }

      return colors;
    } catch (e) {
      debugPrint('Error extracting colors: $e');
      return [Colors.grey]; // Fallback
    }
  }
}
