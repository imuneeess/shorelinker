import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ImageHandler {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> updateProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final fileUrl = pickedFile.path; // Remplace ceci par l'URL de l'image si tu télécharges l'image sur un serveur

      await storage.write(key: 'userProfileImageUrl', value: fileUrl);
    }
  }

  Future<String?> getProfileImageUrl() async {
    return await storage.read(key: 'userProfileImageUrl');
  }
}
