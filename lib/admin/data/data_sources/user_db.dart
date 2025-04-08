import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';

class UserDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String userCollection = 'users';

  // Lấy thông tin người dùng hiện tại từ Firestore
  Future<UserModel?> getCurrentUser() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      DocumentSnapshot doc =
          await _firestore
              .collection(userCollection)
              .doc(currentUser.uid)
              .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng hiện tại: $e');
      return null;
    }
  }

  // Lấy thông tin người dùng theo ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(userCollection).doc(userId).get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng theo ID: $e');
      return null;
    }
  }

  // Cập nhật thông tin người dùng
  Future<bool> updateUserProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (fullName != null && fullName.isNotEmpty) {
        updateData['fullName'] = fullName;
      }

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        updateData['phoneNumber'] = phoneNumber;
      }

      if (address != null && address.isNotEmpty) {
        updateData['address'] = address;
      }

      // Nếu cập nhật đủ thông tin cần thiết, đánh dấu là đã hoàn thành hồ sơ
      if (phoneNumber != null &&
          phoneNumber.isNotEmpty &&
          address != null &&
          address.isNotEmpty) {
        updateData['isProfileCompleted'] = true;
      }

      await _firestore
          .collection(userCollection)
          .doc(userId)
          .update(updateData);

      return true;
    } catch (e) {
      print('Lỗi khi cập nhật thông tin người dùng: $e');
      return false;
    }
  }

  // Tải lên avatar người dùng
  Future<String?> uploadUserAvatar(String userId, File imageFile) async {
    try {
      // Tạo reference đến vị trí lưu trữ
      final ref = _storage.ref().child('user_avatars/$userId.jpg');

      // Tải lên file
      await ref.putFile(imageFile);

      // Lấy URL download
      final downloadUrl = await ref.getDownloadURL();

      // Cập nhật URL trong Firestore
      await _firestore.collection(userCollection).doc(userId).update({
        'avatarUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      print('Lỗi khi tải lên avatar: $e');
      return null;
    }
  }

  Future<String?> getUserAvatarUrl(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(userCollection).doc(userId).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['avatarUrl'] as String?;
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy URL avatar: $e');
      return null;
    }
  }

  // Kiểm tra trạng thái hồ sơ người dùng
  Future<bool> isProfileComplete(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(userCollection).doc(userId).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['isProfileCompleted'] ?? false;
      }
      return false;
    } catch (e) {
      print('Lỗi khi kiểm tra trạng thái hồ sơ: $e');
      return false;
    }
  }

  // Lấy danh sách tất cả người dùng (chỉ dành cho admin)
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(userCollection).get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách người dùng: $e');
      return [];
    }
  }

  Future<List<UserModel>> getAllUsersWithoutCheck() async {
    try {
      final users = await getAllUsers(); // Make sure this fetches data
      print('UserProvider: Users fetched: ${users.length}');
      return users;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }
}
