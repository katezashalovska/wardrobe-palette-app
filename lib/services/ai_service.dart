import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:io' as io;
import 'dart:ui' as ui;
import 'dart:async' as dart_async;

class AiService {
  static Future<List<Color>> extractDominantColors(String imagePath) async {
    try {
      final ImageProvider imageProvider;
      if (kIsWeb) {
        imageProvider = NetworkImage(imagePath);
      } else {
        imageProvider = FileImage(io.File(imagePath));
      }
          
      // Resolve the image to get its dimensions
      final ImageStream stream = imageProvider.resolve(const ImageConfiguration());
      final completer = dart_async.Completer<ui.Image>();
      ImageStreamListener? listener;
      listener = ImageStreamListener((ImageInfo info, bool syncCall) {
        completer.complete(info.image);
        stream.removeListener(listener!);
      }, onError: (dynamic exception, StackTrace? stackTrace) {
        completer.completeError(exception, stackTrace);
      });
      stream.addListener(listener);

      final ui.Image image = await completer.future;

      final double width = image.width.toDouble();
      final double height = image.height.toDouble();

      final paletteGenerator = await PaletteGenerator.fromImage(
        image,
        maximumColorCount: 40,
        region: Rect.fromLTRB(
          width * 0.15,
          height * 0.15,
          width * 0.85,
          height * 0.85,
        ),
      );

      // Helper to check if a color is a likely skin tone or very neutral background
      bool isLikelySkinOrBackground(Color color) {
        final hsl = HSLColor.fromColor(color);
        
        // Loosen background filtering: only skip EXTREMELY pure white or pitch black
        if (hsl.lightness > 0.98 || hsl.lightness < 0.02) return true;
        
        // Skin tones typically fall into specific hue ranges (Orange/Red/Yellow hues)
        if (hsl.hue >= 10 && hsl.hue <= 35 && hsl.saturation > 0.15 && hsl.saturation < 0.65 && hsl.lightness > 0.4 && hsl.lightness < 0.85) {
            return true;
        }
        
        return false;
      }

      final List<Color> potentialColors = [];
      
      // 1. Gather distinct target variants from PaletteGenerator
      final variants = [
        paletteGenerator.vibrantColor,
        paletteGenerator.darkVibrantColor,
        paletteGenerator.lightVibrantColor,
        paletteGenerator.mutedColor,
        paletteGenerator.darkMutedColor,
        paletteGenerator.lightMutedColor,
        paletteGenerator.dominantColor,
      ];

      for (var variant in variants) {
        if (variant != null && !isLikelySkinOrBackground(variant.color)) {
          potentialColors.add(variant.color);
        }
      }

      // 2. Add colors from the full palette to catch nuanced shades (like dark burgundy)
      // Sort them by population (how much of the image they cover)
      final sortedSwatches = List<PaletteColor>.from(paletteGenerator.paletteColors)
        ..sort((a, b) => b.population.compareTo(a.population));

      for (var swatch in sortedSwatches) {
        if (!isLikelySkinOrBackground(swatch.color)) {
          potentialColors.add(swatch.color);
        }
        if (potentialColors.length > 30) break;
      }

      // 3. Filter for uniqueness with tighter thresholds
      List<Color> colors = [];
      
      bool isDuplicate(Color color) {
        final hsl = HSLColor.fromColor(color);
        for (var existing in colors) {
          final existingHsl = HSLColor.fromColor(existing);
          final hueDiff = (hsl.hue - existingHsl.hue).abs();
          final satDiff = (hsl.saturation - existingHsl.saturation).abs();
          final lightDiff = (hsl.lightness - existingHsl.lightness).abs();
          
          // Burgundy/Brown distinction usually relies on Hue and Saturation
          if (hueDiff < 12 && satDiff < 0.12 && lightDiff < 0.12) return true;
        }
        return false;
      }

      for (var color in potentialColors) {
        if (!isDuplicate(color)) {
          colors.add(color);
        }
        if (colors.length >= 12) break;
      }

      if (colors.isEmpty && paletteGenerator.dominantColor != null) {
        colors.add(paletteGenerator.dominantColor!.color);
      }

      return colors;
    } catch (e) {
      debugPrint('Error extracting colors: $e');
      return [Colors.grey]; // Fallback
    }
  }
}
