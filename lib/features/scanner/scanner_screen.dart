import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../providers/subscription_provider.dart';
import '../../services/ai_service.dart';
import '../../services/segmentation_service.dart';
import '../../theme/app_colors.dart';
import 'color_picker_screen.dart';
class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({super.key});



  Future<void> _handleScan(BuildContext context, WidgetRef ref) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null && context.mounted) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop to Clothing',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop to Clothing',
          ),
        ],
      );

      if (croppedFile != null && context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        try {
          final segmented = await SegmentationService.removeBackground(croppedFile.path);
          final finalPath = segmented ?? croppedFile.path;

          final colors = await AiService.extractDominantColors(finalPath);
          
          if (context.mounted) {
            Navigator.of(context).pop(); // Dismiss progress dialog
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ColorPickerScreen(
                  imagePath: croppedFile.path, // Original cropped photo with background
                  segmentedPath: finalPath,    // For color picking logic only
                  allColors: colors,
                ),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.of(context).pop(); // Dismiss progress dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error analyzing image: $e')),
            );
          }
        }
      }
    }
  }

  Future<void> _handleUpload(BuildContext context, WidgetRef ref) async {
    // Temporarily disabled for testing
    /*
    final subState = ref.read(subscriptionProvider);
    if (!subState.isPremium) {
      ref.read(subscriptionProvider.notifier).presentPaywall();
      return;
    }
    */

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && context.mounted) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop to Clothing',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop to Clothing',
          ),
        ],
      );

      if (croppedFile != null && context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        try {
          final segmented = await SegmentationService.removeBackground(croppedFile.path);
          final finalPath = segmented ?? croppedFile.path;

          final colors = await AiService.extractDominantColors(finalPath);

          if (context.mounted) {
            Navigator.of(context).pop(); // Dismiss progress dialog
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ColorPickerScreen(
                  imagePath: croppedFile.path, // Original cropped photo with background
                  segmentedPath: finalPath,    // For color picking logic only
                  allColors: colors,
                ),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.of(context).pop(); // Dismiss progress dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error analyzing image: $e')),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan Clothing'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textHeading,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCameraPlaceholder(),
              const SizedBox(height: 48),
              const Text(
                'Add to Your Library',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeading,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Point your camera at a clothing item or upload from your gallery.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textBody,
                ),
              ),
              const SizedBox(height: 48),
              _buildActionButton(
                onPressed: () => _handleScan(context, ref),
                icon: Icons.camera_alt_outlined,
                label: 'Start Scanning',
                isPrimary: true,
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                onPressed: () => _handleUpload(context, ref),
                icon: Icons.image_outlined,
                label: 'Upload from Gallery',
                isPrimary: false,
              ),
              const SizedBox(height: 100), // Reserve space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: const Icon(
        Icons.document_scanner_outlined,
        size: 80,
        color: AppColors.accentPurple,
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: isPrimary ? AppColors.primaryGradient : null,
        borderRadius: BorderRadius.circular(20),
        border: isPrimary ? null : Border.all(color: AppColors.glassBorder),
        color: isPrimary ? null : AppColors.surface,
        boxShadow: isPrimary ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : AppColors.textHeading,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
