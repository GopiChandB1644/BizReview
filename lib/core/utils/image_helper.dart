import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Picks an image from the gallery and returns it as a Base64 encoded string.
  static Future<String?> pickImageAsBase64({
    ImageSource source = ImageSource.gallery,
    double maxWidth = 800,
    double maxHeight = 800,
    int imageQuality = 70,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image == null) return null;

      final Uint8List bytes = await image.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Decodes a base64 string to Uint8List for display with MemoryImage.
  static Uint8List? bytesFromBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      debugPrint('Error decoding base64: $e');
      return null;
    }
  }
}
