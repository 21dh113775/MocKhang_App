import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadCategoryImage(File imageFile) async {
    try {
      // Tạo đường dẫn duy nhất cho ảnh
      String fileName =
          'category_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';

      // Tham chiếu đến vị trí lưu trữ
      Reference storageReference = _storage.ref().child(
        'category_images/$fileName',
      );

      // Tải ảnh lên
      UploadTask uploadTask = storageReference.putFile(imageFile);

      // Đợi upload hoàn tất
      TaskSnapshot snapshot = await uploadTask;

      // Lấy URL của ảnh
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Lỗi upload ảnh: $e');
      return null;
    }
  }
}
