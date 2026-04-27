import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
import 'package:path_provider/path_provider.dart';

class SegmentationService {
  static Future<String?> removeBackground(String imagePath) async {
    if (kIsWeb) return imagePath;

    final segmenter = SubjectSegmenter(
      options: SubjectSegmenterOptions(
        enableForegroundBitmap: true,
        enableForegroundConfidenceMask: false,
        enableMultipleSubjects: SubjectResultOptions(
          enableConfidenceMask: false,
          enableSubjectBitmap: false,
        ),
      ),
    );

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final SubjectSegmentationResult result = await segmenter.processImage(inputImage);
      
      if (result.foregroundBitmap != null) {
        final Uint8List bytes = result.foregroundBitmap!;
        final dir = await getTemporaryDirectory();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_segmented.png';
        final newPath = '${dir.path}/$fileName';
        
        final File file = File(newPath);
        await file.writeAsBytes(bytes);
        
        segmenter.close();
        return newPath;
      }
    } catch (e) {
      debugPrint('Error removing background: $e');
    }
    
    segmenter.close();
    return null; // Return null if failed, the caller should fallback to original
  }
}
