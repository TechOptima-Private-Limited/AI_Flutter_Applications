import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class StorageService {
  static final _cloudinary = CloudinaryPublic(
    'diwftm6np',      // Replace with your Cloudinary cloud name
    'medibud',       // Replace with your upload preset name
    cache: false,
  );

  static Future<String?> uploadFile({
    required File file,
    required String folder,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Auto,
        ),
      );

      print('Cloudinary upload success: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }
}
