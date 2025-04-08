import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/user_model.dart';

class ProfileDataService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload hình ảnh lên Firebase Storage
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      // Tạo đường dẫn lưu trữ duy nhất cho mỗi hình ảnh
      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference reference = _storage
          .ref()
          .child('profile_images')
          .child(fileName);

      // Tải file lên
      final UploadTask uploadTask = reference.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;

      // Lấy URL download
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Không thể tải hình ảnh lên, vui lòng thử lại');
    }
  }

  Future<int> getCompletedOrderCount() async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 300));
    return 5; // Demo data
  }

  Future<int> getFavoriteCount() async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 300));
    return 12; // Demo data
  }

  Future<double> getRewardPoints() async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 300));
    return 250.0; // Demo data
  }
}
