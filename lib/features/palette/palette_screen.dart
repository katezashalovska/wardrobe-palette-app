import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/clothing_item.dart';
import '../../providers/wardrobe_provider.dart';
import '../../theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class PaletteScreen extends ConsumerStatefulWidget {
  const PaletteScreen({super.key});

  @override
  ConsumerState<PaletteScreen> createState() => _PaletteScreenState();
}

class _PaletteScreenState extends ConsumerState<PaletteScreen> {
  bool _isGenerated = false;
  List<PaletteComponent> _generatedPalette = [];

  // ── Color-theory helpers ──────────────────────────────────────────────────

  /// Extract the HSL representation of a [Color].
  HSLColor _toHsl(Color c) => HSLColor.fromColor(c);

  /// Build a color from HSL, clamping values to valid ranges.
  Color _fromHsl(double h, double s, double l) {
    return HSLColor.fromAHSL(
      1.0,
      h % 360.0,
      s.clamp(0.0, 1.0),
      l.clamp(0.15, 0.92),
    ).toColor();
  }

  /// Complementary hue (opposite on the wheel).
  Color _complementary(HSLColor hsl) =>
      _fromHsl(hsl.hue + 180, hsl.saturation * 0.9, hsl.lightness * 0.85);

  /// Analogous hue shifted by [deg] degrees.
  Color _analogous(HSLColor hsl, double deg) =>
      _fromHsl(hsl.hue + deg, hsl.saturation, hsl.lightness);

  /// Triadic hue (120° steps).
  Color _triadic(HSLColor hsl, {bool second = false}) =>
      _fromHsl(hsl.hue + (second ? 240 : 120), hsl.saturation * 0.85, hsl.lightness);

  /// Light tint of the base color (good for cosmetics / nails).
  Color _tint(HSLColor hsl) =>
      _fromHsl(hsl.hue, hsl.saturation * 0.6, (hsl.lightness + 0.25).clamp(0.0, 0.92));

  // ── Slot definitions ─────────────────────────────────────────────────────

  static const _slots = [
    'Outerwear',
    'Top',
    'Bottom',
    'Accessories',
    'Manicure',
    'Cosmetics',
  ];

  // ── Palette generation ───────────────────────────────────────────────────

  void _generatePalette() {
    final wardrobeState = ref.read(wardrobeProvider);
    final wardrobe = wardrobeState.items;
    final random = Random();

    // 1. Pick a random harmony for this generation
    final harmony = _ColorHarmony.values[random.nextInt(_ColorHarmony.values.length)];

    // 2. Identify available colors from wardrobe to use as anchors
    final List<Color> wardrobeColors = [];
    for (final item in wardrobe) {
      if (item.dominantColors.isNotEmpty) {
        wardrobeColors.addAll(item.dominantColors);
      }
    }
    final uniqueWardrobeColors = wardrobeColors.toSet().toList();

    // 3. Define the base (anchor) HSL
    HSLColor anchor;
    if (uniqueWardrobeColors.isNotEmpty) {
      anchor = HSLColor.fromColor(uniqueWardrobeColors[random.nextInt(uniqueWardrobeColors.length)]);
    } else {
      // Generate a "wearable" random base
      anchor = HSLColor.fromAHSL(
        1.0,
        random.nextDouble() * 360,
        (0.25 + random.nextDouble() * 0.25), // 25-50% saturation
        (0.3 + random.nextDouble() * 0.4),  // 30-70% lightness
      );
    }

    // slots to categories mapping
    final Map<String, List<ClothingCategory>> slotToCategories = {
      'Outerwear': [ClothingCategory.outerwear],
      'Top': [ClothingCategory.tops, ClothingCategory.dresses, ClothingCategory.sets],
      'Bottom': [ClothingCategory.bottoms],
      'Accessories': [ClothingCategory.accessories, ClothingCategory.shoes, ClothingCategory.bags],
      'Cosmetics': [ClothingCategory.cosmetics],
      'Manicure': [ClothingCategory.cosmetics],
    };

    final List<PaletteComponent> newPalette = [];

    // 4. Generate colors based on harmony and role
    for (int i = 0; i < _slots.length; i++) {
      final slot = _slots[i];
      final categories = slotToCategories[slot];
      
      // Determine role based on index/slot
      // Base (Outerwear, Bottom): 60% vibe (Neutral/Anchor)
      // Secondary (Top): 30% vibe (Main color)
      // Accent (Accessories, Nails, Cosmetics): 10% vibe (Pop)
      final bool isBase = slot == 'Outerwear' || slot == 'Bottom';
      final bool isAccent = slot == 'Accessories' || slot == 'Manicure' || slot == 'Cosmetics';

      // Pick hue based on harmony
      double hue;
      switch (harmony) {
        case _ColorHarmony.analogous:
          // H, H+30, H-30, H+60, H-60
          final offsets = [0, 30, -30, 60, -60, 15];
          hue = (anchor.hue + offsets[i % offsets.length]) % 360;
          break;
        case _ColorHarmony.complementary:
          // H, H+180, H+15, H+195
          final offsets = [0, 180, 15, 195, -15, 165];
          hue = (anchor.hue + offsets[i % offsets.length]) % 360;
          break;
        case _ColorHarmony.triadic:
          // H, H+120, H+240
          final offsets = [0, 120, 240, 15, 135, 255];
          hue = (anchor.hue + offsets[i % offsets.length]) % 360;
          break;
      }

      // Check if user has items and if they only have one color
      final List<Color> itemColors = [];
      if (categories != null) {
        for (final cat in categories) {
          final items = wardrobe.where((item) => item.category == cat).toList();
          for (final item in items) {
            itemColors.addAll(item.dominantColors);
          }
        }
      }
      final uniqueItemColors = itemColors.toSet().toList();

      Color finalColor;
      bool isFixed = false;

      if (uniqueItemColors.length == 1) {
        finalColor = uniqueItemColors.first;
        isFixed = true;
      } else if (uniqueItemColors.length > 1) {
        finalColor = uniqueItemColors[random.nextInt(uniqueItemColors.length)];
      } else {
        // Generate wearable color
        double h = hue;
        double s, l;

        switch (slot) {
          case 'Outerwear':
            s = 0.05 + random.nextDouble() * 0.15; // 5-20% (Very neutral)
            l = 0.25 + random.nextDouble() * 0.20; // 25-45% (Darker/Grounding)
            break;
          case 'Top':
            s = 0.15 + random.nextDouble() * 0.20; // 15-35% (Soft)
            l = 0.70 + random.nextDouble() * 0.18; // 70-88% (Light/Pastel)
            break;
          case 'Bottom':
            s = 0.10 + random.nextDouble() * 0.20; // 10-30%
            l = 0.40 + random.nextDouble() * 0.20; // 40-60%
            break;
          case 'Accessories':
            s = 0.30 + random.nextDouble() * 0.25; // 30-55% (Rich but muted)
            l = 0.25 + random.nextDouble() * 0.25; // 25-50% (Deeper accent)
            break;
          case 'Manicure':
            // Warm beauty tones (Red/Orange/Peach/Rose)
            if (random.nextBool()) {
              h = (random.nextDouble() * 40); // 0-40 (Warm)
            } else {
              h = (330 + random.nextDouble() * 30) % 360; // 330-360 (Rose)
            }
            s = 0.20 + random.nextDouble() * 0.25;
            l = 0.45 + random.nextDouble() * 0.20;
            break;
          case 'Cosmetics':
            // Soft beauty (Mauve/Peach)
            if (random.nextBool()) {
              h = (random.nextDouble() * 30); // Peach
            } else {
              h = (300 + random.nextDouble() * 40) % 360; // Mauve/Pink
            }
            s = 0.15 + random.nextDouble() * 0.20;
            l = 0.55 + random.nextDouble() * 0.20;
            break;
          default:
            s = 0.20;
            l = 0.50;
        }

        finalColor = HSLColor.fromAHSL(1.0, h, s.clamp(0.05, 0.6), l.clamp(0.15, 0.9)).toColor();
      }

      newPalette.add(PaletteComponent(
        name: slot,
        color: finalColor,
        isFixed: isFixed,
      ));
    }

    setState(() {
      _generatedPalette = newPalette;
      _isGenerated = true;
    });
  }

  void _useFashionPalette() {
    final List<PaletteComponent> fashionPalette = [
      PaletteComponent(name: 'Outerwear', color: AppColors.fashionOuterwear),
      PaletteComponent(name: 'Top', color: AppColors.fashionTop),
      PaletteComponent(name: 'Bottom', color: AppColors.fashionBottom),
      PaletteComponent(name: 'Accessories', color: AppColors.fashionAccessories),
      PaletteComponent(name: 'Manicure', color: AppColors.fashionManicure),
      PaletteComponent(name: 'Cosmetics', color: AppColors.fashionCosmetics),
    ];

    setState(() {
      _generatedPalette = fashionPalette;
      _isGenerated = true;
    });
  }

  Color _getRandomColor(List<Color> available, Random random) {
    if (available.isEmpty) {
      return Color((random.nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    }
    return available[random.nextInt(available.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event.logicalKey == LogicalKeyboardKey.space) {
              _generatePalette();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: _isGenerated 
            ? _buildResultView()
            : _buildInitialView(),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.palette_outlined, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Palette Generator',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHeading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Create color combinations from your wardrobe',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.palette,
                    size: 40,
                    color: AppColors.accentPurple,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Generate Your Palette',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHeading,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Create color palettes from your wardrobe items',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textBody,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _generatePalette,
                    icon: const Icon(Icons.autorenew, color: Colors.white),
                    label: const Text(
                      'Generate Palette',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _useFashionPalette,
                  icon: const Icon(Icons.style_outlined, color: AppColors.accentPurple),
                  label: const Text(
                    'Use Fashion Palette (Soft Luxury)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accentPurple,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
                const SizedBox(height: 100), // Reserve space for bottom navigation
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildResultView() {
    return Column(
      children: [
        _buildPaletteHeader(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9, 
            ),
            itemCount: _generatedPalette.length,
            itemBuilder: (context, index) {
              return _buildPantoneSwatch(_generatedPalette[index]);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 110), // Padding to stay above bottom nav
          child: _buildFloatingGenerateButton(),
        ),
      ],
    );
  }

  Widget _buildPaletteHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FASHION COLOR',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: AppColors.textBody,
            ),
          ),
          const Text(
            'combinations',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.0,
              color: AppColors.textHeading,
              letterSpacing: -1,
            ),
          ),
          Text(
            'you need to try',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
              color: AppColors.textHeading.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPantoneSwatch(PaletteComponent comp) {
    final String hexCode = comp.color.value.toRadixString(16).substring(2).toUpperCase();
    
    return GestureDetector(
      onTap: comp.isFixed ? null : () => _generateIndividualBar(comp),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color Block (Flexible)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: comp.color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                ),
                child: comp.isFixed 
                  ? const Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.lock, size: 12, color: Colors.white38),
                      ),
                    )
                  : null,
              ),
            ),
            // Information Section (FIXED HEIGHT to prevent overflow)
            Container(
              height: 48, // Absolute height to ensure it always fits
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Text(
                        'PANTONE',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        '®',
                        style: TextStyle(
                          fontSize: 4,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '19-${hexCode.substring(hexCode.length - 4)} TCX',
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    comp.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.1,
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

  void _generateIndividualBar(PaletteComponent comp) {
    final wardrobeState = ref.read(wardrobeProvider);
    final wardrobe = wardrobeState.items;
    final random = Random();

    // Find all categories for this slot
    final Map<String, List<ClothingCategory>> slotToCategories = {
      'Outerwear': [ClothingCategory.outerwear],
      'Top': [ClothingCategory.tops, ClothingCategory.dresses, ClothingCategory.sets],
      'Bottom': [ClothingCategory.bottoms],
      'Accessories': [ClothingCategory.accessories, ClothingCategory.shoes, ClothingCategory.bags],
      'Cosmetics': [ClothingCategory.cosmetics],
      'Manicure': [ClothingCategory.cosmetics],
    };

    final categories = slotToCategories[comp.name];
    Color? newColor;

    if (categories != null) {
      final List<Color> availableColors = [];
      for (final cat in categories) {
        final items = wardrobe.where((item) => item.category == cat).toList();
        for (final item in items) {
          availableColors.addAll(item.dominantColors);
        }
      }
      final uniqueColors = availableColors.toSet().toList();
      if (uniqueColors.length > 1) {
        newColor = uniqueColors[random.nextInt(uniqueColors.length)];
      }
    }

    if (newColor == null) {
      // Harmonic generation fallback using "wearable" rules
      final isBase = comp.name == 'Outerwear' || comp.name == 'Bottom';
      final isAccent = comp.name == 'Accessories' || comp.name == 'Manicure' || comp.name == 'Cosmetics';
      
      final currentHue = HSLColor.fromColor(comp.color).hue;
      // Slight shift for variation if tapped
      final newHue = (currentHue + (random.nextDouble() * 40 - 20)) % 360;
      
      double s, l;
      if (isBase) {
        s = (0.2 + random.nextDouble() * 0.2); 
        l = (0.3 + random.nextDouble() * 0.3);
      } else if (isAccent) {
        s = (0.4 + random.nextDouble() * 0.35);
        l = (0.4 + random.nextDouble() * 0.4);
      } else {
        s = (0.3 + random.nextDouble() * 0.35);
        l = (0.3 + random.nextDouble() * 0.45);
      }
      newColor = HSLColor.fromAHSL(1.0, newHue, s.clamp(0.2, 0.75), l.clamp(0.25, 0.85)).toColor();
    }

    setState(() {
      final index = _generatedPalette.indexOf(comp);
      if (index != -1) {
        _generatedPalette[index] = PaletteComponent(
          name: comp.name,
          color: newColor!,
          isFixed: comp.isFixed,
        );
      }
    });
  }

  Widget _buildFloatingGenerateButton() {
    return GestureDetector(
      onTap: _generatePalette,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85), // Darker, more contrasty for floating button
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.autorenew, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text(
              'Generate',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ColorHarmony { analogous, complementary, triadic }

class PaletteComponent {
  final String name;
  final Color color;
  final bool isFixed;

  PaletteComponent({
    required this.name,
    required this.color,
    this.isFixed = false,
  });
}
