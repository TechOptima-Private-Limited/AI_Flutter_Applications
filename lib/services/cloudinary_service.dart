import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static final _cloudinary = CloudinaryPublic(
    'diwftm6np',           // your cloud name
    'medibud',     // new UNSIGNED preset name
    cache: false,
  );

  static Future<String?> uploadFile({
    required File file,
    required String folder,
  }) async {
    try {
      print('Starting Cloudinary upload: ${file.path}');
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

  static Future<String?> uploadImage(File imageFile) async {
    return uploadFile(file: imageFile, folder: 'medical_reports');
  }

  static Future<String?> uploadPDF(File pdfFile) async {
    return uploadFile(file: pdfFile, folder: 'medical_pdfs');
  }
}
