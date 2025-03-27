// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:mockhang_app/auth/db/database_helper.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// // Định nghĩa interface Repository
// abstract class AuthRepositoryInterface {
//   // Properties
//   User? get currentUser;
//   Stream<User?> get authStateChanges;
//   bool get isLocalAdminLoggedIn;
//   String? get localAdminName;
//   DatabaseHelper get dbHelper;

//   // Database operations
//   Future<void> initializeDatabase();
  
//   // Authentication operations
//   Future<bool> isCurrentUserAdmin();
//   Future<bool> signInAsLocalAdmin(String email, String password);
//   Future<UserCredential?> signInWithEmailAndPassword(String email, String password);
//   Future<UserCredential> registerWithEmailAndPassword(String email, String password, String fullName);
//   Future<void> sendEmailVerification();
//   Future<void> resetPassword(String email);
//   Future<void> signOut();
//   Future<UserCredential?> signInWithGoogle();
// }

// // Concrete implementation của Repository
// class AuthRepository implements AuthRepositoryInterface {
//   // Singleton pattern để đảm bảo chỉ có một instance của repository
//   static final AuthRepository _instance = AuthRepository._internal();
  
//   factory AuthRepository() {
//     return _instance;
//   }
  
//   AuthRepository._internal();
  
//   // Dependencies
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
//     serverClientId: '495594370579-g9nq4cj5o77lp9t67e4l72nmi5ce7lfu.apps.googleusercontent.com',
//   );

//   // Configuration
//   final String _adminEmail = 'admin@gmail.com';

//   // State
//   bool _isLocalAdminLoggedIn = false;
//   String? _localAdminName;
  
//   // Getters implementation
//   @override
//   DatabaseHelper get dbHelper => _dbHelper;
  
//   @override
//   bool get isLocalAdminLoggedIn => _isLocalAdminLoggedIn;
  
//   @override
//   String? get localAdminName => _localAdminName;
  
//   @override
//   User? get currentUser => _auth.currentUser;
  
//   @override
//   Stream<User?> get authStateChanges => _auth.authStateChanges();
  
//   // Database initialization
//   @override
//   Future<void> initializeDatabase() async {
//     try {
//       // Khởi tạo database
//       await _dbHelper.database;
      
//       // Debug: kiểm tra danh sách admin
//       List<Map<String, dynamic>> admins = await _dbHelper.getAllAdmins();
//       debugPrint('Admin accounts available: $admins');
      
//       return;
//     } catch (e) {
//       debugPrint('Error initializing database: $e');
//       throw Exception('Không thể khởi tạo cơ sở dữ liệu: $e');
//     }
//   }

//   // Implementation của các phương thức authentication
//   @override
//   Future<bool> isCurrentUserAdmin() async {
//     // Strategy pattern: Kiểm tra admin theo nhiều cách khác nhau
//     if (_isLocalAdminLoggedIn) {
//       return true;
//     }

//     final user = _auth.currentUser;
//     if (user == null) return false;

//     try {
//       final userDoc = await _firestore.collection('users').doc(user.uid).get();
//       final role = userDoc.data()?['role'] as String? ?? 'user';
//       return role == 'admin';
//     } catch (e) {
//       debugPrint('Lỗi kiểm tra quyền admin: $e');
//       return false;
//     }
//   }

//   @override
//   Future<bool> signInAsLocalAdmin(String email, String password) async {
//     try {
//       debugPrint('Trying to sign in as local admin with: $email');

//       // Debug - kiểm tra danh sách admin trong DB
//       List<Map<String, dynamic>> allAdmins = await _dbHelper.getAllAdmins();
//       debugPrint('All admin accounts in DB: $allAdmins');

//       // Adapter pattern: Chuyển đổi giữa local authentication và điều khiển state
//       bool isValidAdmin = await _dbHelper.validateAdmin(email, password);
//       debugPrint('Admin validation result: $isValidAdmin');

//       if (isValidAdmin) {
//         _isLocalAdminLoggedIn = true;
//         _localAdminName = 'Admin';
//         debugPrint('Local admin login successful');
//         return true;
//       }

//       debugPrint('Local admin login failed - invalid credentials');
//       return false;
//     } catch (e) {
//       debugPrint('Error in local admin login: $e');
//       return false;
//     }
//   }

//   @override
//   Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
//     try {
//       debugPrint('Đang đăng nhập với email: $email');

//       // Chain of Responsibility pattern: Xử lý theo chuỗi các handler
//       // Handler 1: Kiểm tra admin trước
//       if (email.trim() == _adminEmail) {
//         bool isLocalAdmin = await signInAsLocalAdmin(email, password);
//         if (isLocalAdmin) {
//           return null; // Trả về null vì admin không dùng Firebase
//         }
//       }

//       // Handler 2: Nếu không phải admin hoặc đăng nhập admin thất bại, sử dụng Firebase
//       final userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       // Observer pattern: Cập nhật trạng thái user sau khi đăng nhập
//       await _firestore
//           .collection('users')
//           .doc(userCredential.user!.uid)
//           .update({'lastLogin': FieldValue.serverTimestamp()})
//           .catchError((e) => debugPrint('Lỗi cập nhật lastLogin: $e'));

//       return userCredential;
//     } catch (e) {
//       debugPrint('Lỗi đăng nhập: $e');
//       rethrow;
//     }
//   }

//   @override
//   Future<UserCredential> registerWithEmailAndPassword(String email, String password, String fullName) async {
//     try {
//       debugPrint('Đang đăng ký tài khoản mới: $email');

//       // Unit of Work pattern: Đảm bảo các thao tác xử lý như một transaction
//       // Bước 1: Tạo tài khoản với Firebase Auth
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       // Bước 2: Tạo bản ghi trong Firestore
//       await _firestore.collection('users').doc(userCredential.user!.uid).set({
//         'email': email,
//         'fullName': fullName,
//         'role': 'user',
//         'createdAt': FieldValue.serverTimestamp(),
//         'lastLogin': FieldValue.serverTimestamp(),
//       });

//       return userCredential;
//     } catch (e) {
//       debugPrint('Lỗi đăng ký: $e');
//       rethrow;
//     }
//   }

//   @override
//   Future<void> sendEmailVerification() async {
//     try {
//       final user = _auth.currentUser;
//       if (user != null && !user.emailVerified) {
//         await user.sendEmailVerification();
//         debugPrint('Đã gửi email xác thực đến ${user.email}');
//       }
//     } catch (e) {
//       debugPrint('Lỗi gửi email xác thực: $e');
//       rethrow;
//     }
//   }

//   @override
//   Future<void> resetPassword(String email) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email);
//       debugPrint('Đã gửi email đặt lại mật khẩu đến $email');
//     } catch (e) {
//       debugPrint('Lỗi gửi email đặt lại mật khẩu: $e');
//       rethrow;
//     }
//   }

//   @override
//   Future<void> signOut() async {
//     try {
//       // Template Method pattern: Các bước cụ thể để đăng xuất được xác định
//       if (_isLocalAdminLoggedIn) {
//         _isLocalAdminLoggedIn = false;
//         _localAdminName = null;
//         return;
//       }
      
//       // Đăng xuất khỏi Google nếu đã đăng nhập
//       if (await _googleSignIn.isSignedIn()) {
//         await _googleSignIn.signOut();
//       }
      
//       // Đăng xuất khỏi Firebase
//       await _auth.signOut();
//     } catch (e) {
//       debugPrint('Lỗi đăng xuất: $e');
//       throw Exception('Không thể đăng xuất: $e');
//     }
//   }

//   @override
//   Future<UserCredential?> signInWithGoogle() async {
//     try {
//       debugPrint('Đang đăng nhập với Google');

//       // State design pattern: Quản lý trạng thái đăng nhập Google
//       // Trạng thái 1: Khởi tạo quá trình đăng nhập
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

//       // Trạng thái 2: Người dùng hủy quá trình
//       if (googleUser == null) {
//         debugPrint('Đăng nhập Google bị hủy bởi người dùng');
//         return null;
//       }

//       // Trạng thái 3: Lấy thông tin xác thực
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//       // Trạng thái 4: Tạo credential và đăng nhập Firebase
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final userCredential = await _auth.signInWithCredential(credential);

//       // Trạng thái 5: Cập nhật dữ liệu người dùng
//       final userDoc = _firestore.collection('users').doc(userCredential.user!.uid);
//       final userSnapshot = await userDoc.get();

//       // Factory pattern: Tạo hoặc cập nhật user data dựa trên điều kiện
//       if (userSnapshot.exists) {
//         // Cập nhật lastLogin nếu đã tồn tại
//         await userDoc.update({'lastLogin': FieldValue.serverTimestamp()});
//       } else {
//         // Tạo mới nếu chưa tồn tại
//         await userDoc.set({
//           'email': userCredential.user!.email,
//           'fullName': userCredential.user!.displayName ?? 'Google User',
//           'role': 'user',
//           'createdAt': FieldValue.serverTimestamp(),
//           'lastLogin': FieldValue.serverTimestamp(),
//           'provider': 'google',
//         });
//       }

//       return userCredential;
//     } catch (e) {
//       debugPrint('Lỗi đăng nhập Google: $e');
//       rethrow;
//     }
//   }

//   // Bổ sung thêm các phương thức hỗ trợ khác nếu cần
//   Future<Map<String, dynamic>?> getUserData(String userId) async {
//     try {
//       final userDoc = await _firestore.collection('users').doc(userId).get();
//       return userDoc.data();
//     } catch (e) {
//       debugPrint('Lỗi lấy thông tin người dùng: $e');
//       return null;
//     }
//   }
  
//   Future<bool> updateUserProfile(String userId, Map<String, dynamic> data) async {
//     try {
//       await _firestore.collection('users').doc(userId).update(data);
//       return true;
//     } catch (e) {
//       debugPrint('Lỗi cập nhật thông tin người dùng: $e');
//       return false;
//     }
//   }
// }