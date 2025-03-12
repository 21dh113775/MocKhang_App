import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockhang_app/auth/db/database_helper.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
    serverClientId:
        '495594370579-g9nq4cj5o77lp9t67e4l72nmi5ce7lfu.apps.googleusercontent.com',
  );

  final String _adminEmail = 'admin@gmail.com';

  // Local admin authentication state
  bool _isLocalAdminLoggedIn = false;
  String? _localAdminName;
  // Thêm vào AuthService
  DatabaseHelper get dbHelper => _dbHelper;
  bool get isLocalAdminLoggedIn => _isLocalAdminLoggedIn;
  String? get localAdminName => _localAdminName;

  // Lấy user hiện tại (từ Firebase)
  User? get currentUser => _auth.currentUser;

  // Stream để theo dõi trạng thái đăng nhập
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Kiểm tra xem người dùng hiện tại có phải là admin không
  Future<bool> isCurrentUserAdmin() async {
    if (_isLocalAdminLoggedIn) {
      return true;
    }

    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final role = userDoc.data()?['role'] as String? ?? 'user';
      return role == 'admin';
    } catch (e) {
      debugPrint('Lỗi kiểm tra quyền admin: $e');
      return false;
    }
  }

  // Đăng nhập như admin từ SQLite
  Future<bool> signInAsLocalAdmin(String email, String password) async {
    try {
      debugPrint('Trying to sign in as local admin with: $email');

      // Debug - kiểm tra danh sách admin trong DB
      List<Map<String, dynamic>> allAdmins = await _dbHelper.getAllAdmins();
      debugPrint('All admin accounts in DB: $allAdmins');

      bool isValidAdmin = await _dbHelper.validateAdmin(email, password);
      debugPrint('Admin validation result: $isValidAdmin');

      if (isValidAdmin) {
        _isLocalAdminLoggedIn = true;
        _localAdminName = 'Admin';
        debugPrint('Local admin login successful');
        return true;
      }

      debugPrint('Local admin login failed - invalid credentials');
      return false;
    } catch (e) {
      debugPrint('Error in local admin login: $e');
      return false;
    }
  }

  // Đăng nhập bằng email và password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      debugPrint('Đang đăng nhập với email: $email');

      // Kiểm tra nếu là tài khoản admin
      if (email.trim() == _adminEmail) {
        bool isLocalAdmin = await signInAsLocalAdmin(email, password);
        if (isLocalAdmin) {
          return null; // Trả về null vì admin không dùng Firebase
        }
      }

      // Nếu không phải admin hoặc đăng nhập admin thất bại, sử dụng Firebase để đăng nhập
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cập nhật lastLogin cho người dùng Firebase
      _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .update({'lastLogin': FieldValue.serverTimestamp()})
          .catchError((e) => debugPrint('Lỗi cập nhật lastLogin: $e'));

      return userCredential;
    } catch (e) {
      debugPrint('Lỗi đăng nhập: $e');
      rethrow;
    }
  }

  // Đăng ký với email và password
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      debugPrint('Đang đăng ký tài khoản mới: $email');

      // Tạo tài khoản với Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Tạo bản ghi trong Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'fullName': fullName,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      debugPrint('Lỗi đăng ký: $e');
      rethrow;
    }
  }

  // Gửi email xác thực
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        debugPrint('Đã gửi email xác thực đến ${user.email}');
      }
    } catch (e) {
      debugPrint('Lỗi gửi email xác thực: $e');
      rethrow;
    }
  }

  // Đặt lại mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('Đã gửi email đặt lại mật khẩu đến $email');
    } catch (e) {
      debugPrint('Lỗi gửi email đặt lại mật khẩu: $e');
      rethrow;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      if (_isLocalAdminLoggedIn) {
        _isLocalAdminLoggedIn = false;
        _localAdminName = null;
        return;
      }
      await _auth.signOut();
    } catch (e) {
      debugPrint('Lỗi đăng xuất: $e');
    }
  }

  // Đăng nhập với Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      debugPrint('Đang đăng nhập với Google');

      // Bắt đầu quá trình đăng nhập Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Nếu người dùng hủy quá trình đăng nhập
      if (googleUser == null) {
        debugPrint('Đăng nhập Google bị hủy bởi người dùng');
        return null;
      }

      // Lấy thông tin xác thực từ yêu cầu
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Tạo credential mới với thông tin từ Google
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập với Firebase bằng credential từ Google
      final userCredential = await _auth.signInWithCredential(credential);

      // Cập nhật hoặc tạo thông tin người dùng trong Firestore
      final userDoc = _firestore
          .collection('users')
          .doc(userCredential.user!.uid);
      final userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Cập nhật lastLogin nếu đã tồn tại
        await userDoc.update({'lastLogin': FieldValue.serverTimestamp()});
      } else {
        // Tạo mới nếu chưa tồn tại
        await userDoc.set({
          'email': userCredential.user!.email,
          'fullName': userCredential.user!.displayName ?? 'Google User',
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'provider': 'google',
        });
      }

      return userCredential;
    } catch (e) {
      debugPrint('Lỗi đăng nhập Google: $e');
      rethrow;
    }
  }
}
