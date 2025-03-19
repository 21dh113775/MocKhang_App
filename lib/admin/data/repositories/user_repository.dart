import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mockhang_app/admin/data/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection reference
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');

  // Lấy thông tin người dùng hiện tại
  Future<UserModel?> getCurrentUser() async {
    try {
      // Kiểm tra người dùng đã đăng nhập chưa
      final User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        print('Chưa đăng nhập: Không có người dùng hiện tại');
        return null;
      }

      // Lấy thông tin người dùng từ Firestore
      DocumentSnapshot userDoc =
          await _usersCollection.doc(firebaseUser.uid).get();

      // Kiểm tra tài liệu có tồn tại không
      if (!userDoc.exists) {
        print('Không tìm thấy tài liệu người dùng cho ID: ${firebaseUser.uid}');
        return null;
      }

      // Chuyển đổi dữ liệu thành đối tượng UserModel
      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng hiện tại: $e');
      return null;
    }
  }

  // Lấy danh sách tất cả người dùng (chỉ cho admin)
  Future<List<UserModel>> getAllUsers() async {
    try {
      // Kiểm tra người dùng hiện tại
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Chưa đăng nhập');
      }

      // Kiểm tra quyền admin
      DocumentSnapshot userDoc =
          await _usersCollection.doc(currentUser.uid).get();

      if (!userDoc.exists || userDoc.get('role') != 'admin') {
        throw Exception('Không có quyền admin');
      }

      // Lấy danh sách người dùng
      QuerySnapshot querySnapshot = await _usersCollection.get();

      // Chuyển đổi kết quả thành danh sách UserModel
      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách người dùng: $e');
      throw e; // Ném lại ngoại lệ để xử lý ở tầng cao hơn
    }
  }

  // Cập nhật thông tin hồ sơ người dùng
  Future<bool> updateUserProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      // Tạo map chứa dữ liệu cần cập nhật
      Map<String, dynamic> updateData = {};

      // Chỉ thêm các trường có giá trị vào map
      if (fullName != null && fullName.isNotEmpty) {
        updateData['fullName'] = fullName;
      }

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        updateData['phoneNumber'] = phoneNumber;
      }

      if (address != null && address.isNotEmpty) {
        updateData['address'] = address;
      }

      // Thêm thông tin cập nhật
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      // Thực hiện cập nhật
      await _usersCollection.doc(userId).update(updateData);

      return true;
    } catch (e) {
      print('Lỗi khi cập nhật hồ sơ người dùng: $e');
      return false;
    }
  }

  // Tải lên ảnh đại diện người dùng
  Future<String?> uploadUserAvatar(String userId, File avatarFile) async {
    try {
      // Tạo đường dẫn lưu trữ
      final storageRef = _storage.ref().child('user_avatars/$userId.jpg');

      // Tải lên tệp
      await storageRef.putFile(avatarFile);

      // Lấy URL tải xuống
      final downloadUrl = await storageRef.getDownloadURL();

      // Cập nhật URL trong hồ sơ người dùng
      await _usersCollection.doc(userId).update({
        'avatarUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      print('Lỗi khi tải lên ảnh đại diện: $e');
      return null;
    }
  }

  // Hoàn thành hồ sơ người dùng
  Future<bool> completeUserProfile({
    required String userId,
    required String fullName,
    required String phoneNumber,
    required String address,
    File? avatarFile,
  }) async {
    try {
      // Tạo map chứa dữ liệu cập nhật
      Map<String, dynamic> profileData = {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'address': address,
        'isProfileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Tải lên ảnh đại diện nếu có
      if (avatarFile != null) {
        String? avatarUrl = await uploadUserAvatar(userId, avatarFile);
        if (avatarUrl != null) {
          profileData['avatarUrl'] = avatarUrl;
        }
      }

      // Cập nhật thông tin hồ sơ
      await _usersCollection.doc(userId).update(profileData);

      return true;
    } catch (e) {
      print('Lỗi khi hoàn thành hồ sơ: $e');
      return false;
    }
  }

  // Kiểm tra hồ sơ đã hoàn thành chưa
  Future<bool> isProfileComplete(String userId) async {
    try {
      // Lấy tài liệu người dùng
      DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();

      // Kiểm tra trường isProfileCompleted
      return userDoc.exists &&
          (userDoc.data() as Map<String, dynamic>)['isProfileCompleted'] ==
              true;
    } catch (e) {
      print('Lỗi khi kiểm tra trạng thái hồ sơ: $e');
      return false;
    }
  }

  // Kiểm tra người dùng có quyền admin không
  Future<bool> isUserAdmin(String userId) async {
    try {
      // Lấy tài liệu người dùng
      DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();

      // Kiểm tra vai trò admin
      return userDoc.exists &&
          (userDoc.data() as Map<String, dynamic>)['role'] == 'admin';
    } catch (e) {
      print('Lỗi khi kiểm tra quyền admin: $e');
      return false;
    }
  }

  // Cập nhật vai trò người dùng (chỉ admin mới thực hiện được)
  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      // Kiểm tra người dùng hiện tại
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Chưa đăng nhập');
      }

      // Kiểm tra quyền admin
      bool isAdmin = await isUserAdmin(currentUser.uid);
      if (!isAdmin) {
        throw Exception('Không có quyền admin');
      }

      // Cập nhật vai trò
      await _usersCollection.doc(userId).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Lỗi khi cập nhật vai trò người dùng: $e');
      return false;
    }
  }

  // Xóa tài khoản người dùng (chỉ admin mới thực hiện được)
  Future<bool> deleteUser(String userId) async {
    try {
      // Kiểm tra người dùng hiện tại
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Chưa đăng nhập');
      }

      // Kiểm tra quyền admin
      bool isAdmin = await isUserAdmin(currentUser.uid);
      if (!isAdmin) {
        throw Exception('Không có quyền admin');
      }

      // Xóa tài liệu người dùng
      await _usersCollection.doc(userId).delete();

      // Lưu ý: Việc này chỉ xóa dữ liệu từ Firestore
      // Để xóa hoàn toàn tài khoản, cần sử dụng Firebase Admin SDK hoặc Functions

      return true;
    } catch (e) {
      print('Lỗi khi xóa người dùng: $e');
      return false;
    }
  }
}
