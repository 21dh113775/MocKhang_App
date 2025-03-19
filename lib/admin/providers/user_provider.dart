import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockhang_app/admin/data/models/user_model.dart';
import 'package:mockhang_app/admin/data/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  // Khởi tạo các đối tượng cần thiết
  final UserRepository _userRepository = UserRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Trạng thái khởi tạo
  bool get isInitialized => _initialized;

  // Các biến trạng thái
  UserModel? _currentUser; // Người dùng hiện tại
  List<UserModel> _allUsers = []; // Danh sách tất cả người dùng (cho admin)
  bool _isLoading = false; // Đang tải dữ liệu
  String? _errorMessage; // Thông báo lỗi
  bool _initialized = false; // Đã khởi tạo chưa
  StreamSubscription<User?>? _authSubscription; // Theo dõi thay đổi xác thực

  // Getters
  UserModel? get currentUser => _currentUser;
  List<UserModel> get allUsers => _allUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _auth.currentUser != null;
  bool get isProfileComplete => _currentUser?.isProfileCompleted ?? false;
  bool get isAdmin => _currentUser?.role == 'admin';

  // Constructor
  UserProvider() {
    // Không làm gì trong constructor để tránh gọi hàm async
  }

  // Phương thức khởi tạo an toàn
  Future<void> initialize() async {
    // Thêm log để theo dõi tiến trình khởi tạo
    print('UserProvider: Bắt đầu khởi tạo');

    // Đặt trạng thái đang tải
    _isLoading = true;
    _safeNotifyListeners();

    try {
      // Kiểm tra xem đã khởi tạo chưa để tránh khởi tạo nhiều lần
      if (_initialized) {
        print('UserProvider: Đã khởi tạo trước đó');
        _isLoading = false;
        _safeNotifyListeners();
        return;
      }

      // Thiết lập auth listener để theo dõi thay đổi đăng nhập
      _setupAuthListener();
      print('UserProvider: Đã thiết lập Auth Listener');

      // Kiểm tra người dùng hiện tại
      final User? currentUser = _auth.currentUser;
      print(
        'UserProvider: FirebaseAuth.currentUser = ${currentUser?.uid ?? "null"}',
      );

      // Khởi tạo dữ liệu người dùng nếu đã đăng nhập
      if (currentUser != null) {
        await _loadUserData();
        print(
          'UserProvider: Đã tải dữ liệu người dùng: ${_currentUser?.fullName}',
        );

        // Log vai trò người dùng
        print(
          'UserProvider: Vai trò người dùng hiện tại: ${_currentUser?.role}',
        );
      } else {
        print('UserProvider: Chưa đăng nhập, bỏ qua tải dữ liệu người dùng');
      }

      _initialized = true;
      print('UserProvider: Khởi tạo hoàn tất');
    } catch (e) {
      print('UserProvider: Lỗi khi khởi tạo: $e');
      _errorMessage = 'Không thể khởi tạo: ${e.toString()}';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Thông báo thay đổi an toàn (tránh gọi trong build phase)
  void _safeNotifyListeners() {
    try {
      // Sử dụng addPostFrameCallback để đảm bảo notifyListeners được gọi sau khi build kết thúc
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      print('UserProvider: Lỗi khi gọi notifyListeners: $e');
    }
  }

  // Tải dữ liệu người dùng
  Future<void> _loadUserData() async {
    if (_auth.currentUser == null) {
      print('UserProvider: _loadUserData - không có người dùng đăng nhập');
      return;
    }

    print(
      'UserProvider: Bắt đầu tải dữ liệu cho người dùng: ${_auth.currentUser!.uid}',
    );

    try {
      // Đặt trạng thái đang tải
      _isLoading = true;
      _errorMessage = null;
      _safeNotifyListeners();

      // Lấy thông tin người dùng hiện tại từ Firestore
      final currentUserDoc =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .get();

      if (currentUserDoc.exists) {
        // Chuyển đổi dữ liệu từ Firestore thành đối tượng UserModel
        _currentUser = UserModel.fromMap(
          _auth.currentUser!.uid,
          currentUserDoc.data() ?? {},
        );
        print('UserProvider: Đã lấy được thông tin người dùng từ Firestore');
        print(
          'UserProvider: Thông tin người dùng - Tên: ${_currentUser!.fullName}, Vai trò: ${_currentUser!.role}',
        );
      } else {
        print('UserProvider: Không tìm thấy thông tin người dùng, tạo mới');
        await _createNewUserRecord();

        // Lấy lại thông tin sau khi tạo mới
        final newUserDoc =
            await _firestore
                .collection('users')
                .doc(_auth.currentUser!.uid)
                .get();
        _currentUser = UserModel.fromMap(
          _auth.currentUser!.uid,
          newUserDoc.data() ?? {},
        );
      }

      // Luôn tải danh sách người dùng bất kể vai trò
      print('UserProvider: Tải danh sách người dùng');
      await _loadAllUsers();
    } catch (e) {
      _errorMessage = 'Không thể lấy thông tin người dùng: ${e.toString()}';
      print('UserProvider: Lỗi trong _loadUserData(): $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Tải danh sách tất cả người dùng (không kiểm tra quyền)
  Future<void> _loadAllUsers() async {
    try {
      print('UserProvider: Bắt đầu tải danh sách tất cả người dùng');

      // Truy vấn trực tiếp từ Firestore
      final QuerySnapshot snapshot = await _firestore.collection('users').get();

      // Kiểm tra và log số lượng tài liệu nhận được
      print(
        'UserProvider: Số lượng người dùng từ Firestore: ${snapshot.docs.length}',
      );

      // Chuyển đổi thành danh sách UserModel
      _allUsers =
          snapshot.docs.map((doc) {
            return UserModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();

      print('UserProvider: Đã tải thành công ${_allUsers.length} người dùng');
    } catch (e) {
      print('UserProvider: Lỗi khi tải danh sách người dùng: $e');
      _errorMessage = 'Không thể tải danh sách người dùng: ${e.toString()}';
    }
  }

  // Đăng ký listener cho thay đổi trạng thái xác thực
  void _setupAuthListener() {
    // Hủy subscription cũ nếu có
    _authSubscription?.cancel();

    // Đăng ký mới
    _authSubscription = _auth.authStateChanges().listen((User? user) async {
      print('UserProvider: Auth state changed. User: ${user?.uid ?? "null"}');

      if (user == null) {
        // Người dùng đã đăng xuất
        print('UserProvider: Người dùng đã đăng xuất');
        clearUserData();
      } else {
        // Người dùng đã đăng nhập
        print('UserProvider: Người dùng đã đăng nhập: ${user.uid}');
        await _loadUserData();
      }
    });
  }

  // Tạo bản ghi người dùng mới nếu chưa tồn tại
  Future<void> _createNewUserRecord() async {
    try {
      final User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        print(
          'UserProvider: Không thể tạo bản ghi mới vì không có người dùng đăng nhập',
        );
        return;
      }

      print(
        'UserProvider: Đang tạo bản ghi mới cho người dùng: ${firebaseUser.uid}',
      );

      final docRef = _firestore.collection('users').doc(firebaseUser.uid);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        // Tạo bản ghi mới
        final newUser = {
          'email': firebaseUser.email ?? '',
          'fullName': firebaseUser.displayName ?? 'Người dùng mới',
          'role': 'user', // Mặc định là người dùng thường
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'isProfileCompleted': false,
          'avatarUrl': firebaseUser.photoURL,
          'phoneNumber': null,
          'address': null,
        };

        await docRef.set(newUser);
        print('UserProvider: Đã tạo bản ghi người dùng mới thành công');
      } else {
        // Cập nhật thời gian đăng nhập
        await docRef.update({'lastLogin': FieldValue.serverTimestamp()});
        print('UserProvider: Đã cập nhật thời gian đăng nhập');
      }
    } catch (e) {
      print('UserProvider: Lỗi khi tạo bản ghi người dùng mới: $e');
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    print('UserProvider: Bắt đầu getAllUsers()');

    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      // Đảm bảo Provider đã được khởi tạo
      if (!_initialized) {
        print('UserProvider: Provider chưa được khởi tạo, đang khởi tạo...');
        await initialize();
      }

      // Đảm bảo dữ liệu người dùng đã được tải
      if (_currentUser == null) {
        print('UserProvider: currentUser là null, đang tải dữ liệu người dùng');
        await _loadUserData();
      }

      // Truy vấn trực tiếp Firestore để tránh sự cố cache
      print('UserProvider: Đang truy vấn danh sách người dùng từ Firestore');
      final QuerySnapshot snapshot = await _firestore.collection('users').get();

      print(
        'UserProvider: Số lượng người dùng từ Firestore: ${snapshot.docs.length}',
      );

      // Chuyển đổi kết quả thành danh sách UserModel
      _allUsers =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return UserModel.fromMap(doc.id, data);
          }).toList();

      print('UserProvider: Đã tải ${_allUsers.length} người dùng thành công');
      return _allUsers;
    } catch (e) {
      _errorMessage = 'Không thể lấy danh sách người dùng: ${e.toString()}';
      print('UserProvider: Lỗi trong getAllUsers(): $e');
      return [];
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Làm mới dữ liệu người dùng
  Future<void> refreshUserData() async {
    print('UserProvider: Bắt đầu làm mới dữ liệu người dùng');
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      // Kiểm tra xem người dùng đã đăng nhập chưa
      if (_auth.currentUser == null) {
        print('UserProvider: Không thể làm mới dữ liệu - chưa đăng nhập');
        return;
      }

      // Tải lại dữ liệu người dùng
      final userDoc =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .get();

      if (userDoc.exists) {
        _currentUser = UserModel.fromMap(
          _auth.currentUser!.uid,
          userDoc.data() ?? {},
        );
        print(
          'UserProvider: Đã làm mới dữ liệu người dùng. Vai trò: ${_currentUser?.role}',
        );
      } else {
        print('UserProvider: Không tìm thấy dữ liệu người dùng');
      }

      // Luôn tải lại danh sách người dùng (không kiểm tra quyền)
      print('UserProvider: Làm mới danh sách người dùng');
      await _loadAllUsers();
    } catch (e) {
      _errorMessage = 'Không thể làm mới dữ liệu: ${e.toString()}';
      print('UserProvider: Lỗi trong refreshUserData(): $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Cập nhật hồ sơ người dùng
  Future<bool> updateUserProfile({
    String? fullName,
    String? phoneNumber,
    String? address,
    File? avatarFile,
  }) async {
    if (_auth.currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      String userId = _auth.currentUser!.uid;
      print('UserProvider: Cập nhật hồ sơ cho người dùng $userId');

      // Tải lên ảnh đại diện nếu có
      String? avatarUrl;
      if (avatarFile != null) {
        avatarUrl = await _userRepository.uploadUserAvatar(userId, avatarFile);
        print('UserProvider: Đã tải lên ảnh đại diện: $avatarUrl');
      }

      // Tạo map dữ liệu cần cập nhật
      final Map<String, dynamic> updateData = {};
      if (fullName != null) updateData['fullName'] = fullName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (address != null) updateData['address'] = address;
      if (avatarUrl != null) updateData['avatarUrl'] = avatarUrl;

      // Kiểm tra xem có đủ thông tin để đánh dấu hồ sơ đã hoàn thành chưa
      bool canCompleteProfile = true;
      if (_currentUser != null) {
        final String checkName = fullName ?? _currentUser!.fullName;
        final String? checkPhone = phoneNumber ?? _currentUser!.phoneNumber;
        final String? checkAddress = address ?? _currentUser!.address;

        canCompleteProfile =
            checkName.isNotEmpty &&
            checkPhone != null &&
            checkPhone.isNotEmpty &&
            checkAddress != null &&
            checkAddress.isNotEmpty;
      }

      if (canCompleteProfile) {
        updateData['isProfileCompleted'] = true;
        print('UserProvider: Hồ sơ đã đủ thông tin để đánh dấu hoàn thành');
      }

      // Cập nhật dữ liệu vào Firestore
      await _firestore.collection('users').doc(userId).update(updateData);
      print('UserProvider: Đã cập nhật hồ sơ người dùng thành công');

      // Tải lại dữ liệu người dùng
      await refreshUserData();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi khi cập nhật hồ sơ: ${e.toString()}';
      print('UserProvider: Lỗi trong updateUserProfile(): $e');
      return false;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Hoàn thành hồ sơ người dùng
  Future<bool> completeUserProfile({
    required String fullName,
    required String phoneNumber,
    required String address,
    File? avatarFile,
  }) async {
    if (_auth.currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      String userId = _auth.currentUser!.uid;
      print('UserProvider: Hoàn thành hồ sơ cho người dùng $userId');

      // Cập nhật thông tin hồ sơ thông qua repository
      bool success = await _userRepository.completeUserProfile(
        userId: userId,
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
        avatarFile: avatarFile,
      );

      if (success) {
        print('UserProvider: Hoàn thành hồ sơ thành công');
        await refreshUserData();
      } else {
        print('UserProvider: Không thể hoàn thành hồ sơ');
      }

      return success;
    } catch (e) {
      _errorMessage = 'Lỗi khi hoàn thành hồ sơ: ${e.toString()}';
      print('UserProvider: Lỗi trong completeUserProfile(): $e');
      return false;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Cập nhật vai trò người dùng (bỏ kiểm tra quyền admin)
  Future<bool> updateUserRole(String userId, String newRole) async {
    print(
      'UserProvider: Cập nhật vai trò cho người dùng $userId thành $newRole',
    );

    _isLoading = true;
    _safeNotifyListeners();

    try {
      // Cập nhật trực tiếp trong Firestore
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
      });

      print('UserProvider: Đã cập nhật vai trò thành công');

      // Cập nhật danh sách người dùng
      await refreshUserData();
      return true;
    } catch (e) {
      _errorMessage = 'Không thể cập nhật vai trò: ${e.toString()}';
      print('UserProvider: Lỗi trong updateUserRole(): $e');
      return false;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Xử lý khi đăng xuất
  void clearUserData() {
    print('UserProvider: Xóa dữ liệu người dùng');
    _currentUser = null;
    _allUsers = [];
    _safeNotifyListeners();
  }

  // Xóa người dùng (bỏ kiểm tra quyền admin)
  Future<bool> deleteUser(String userId) async {
    print('UserProvider: Yêu cầu xóa người dùng $userId');

    _isLoading = true;
    _safeNotifyListeners();

    try {
      // Xóa người dùng từ Firestore
      await _firestore.collection('users').doc(userId).delete();
      print('UserProvider: Đã xóa người dùng khỏi Firestore');

      // Cập nhật danh sách người dùng
      await refreshUserData();
      return true;
    } catch (e) {
      _errorMessage = 'Không thể xóa người dùng: ${e.toString()}';
      print('UserProvider: Lỗi trong deleteUser(): $e');
      return false;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Kiểm tra trạng thái kết nối Firebase
  Future<bool> testFirebaseConnection() async {
    try {
      print('UserProvider: Kiểm tra kết nối Firebase');
      final QuerySnapshot snapshot =
          await _firestore.collection('users').limit(1).get();
      print(
        'UserProvider: Kết nối Firebase thành công. Số tài liệu: ${snapshot.docs.length}',
      );
      return true;
    } catch (e) {
      print('UserProvider: Kết nối Firebase thất bại: $e');
      _errorMessage = 'Không thể kết nối tới Firebase: ${e.toString()}';
      _safeNotifyListeners();
      return false;
    }
  }

  // Thêm vào UserProvider - đã cập nhật không kiểm tra quyền
  Future<List<UserModel>> getAllUsersWithoutCheck() async {
    print('UserProvider: Bắt đầu getAllUsersWithoutCheck()');

    try {
      // Chỉ đảm bảo người dùng đã đăng nhập
      if (_auth.currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Lấy danh sách người dùng không kiểm tra quyền
      final users = await getAllUsers();
      print('UserProvider: Users fetched: ${users.length}');
      return users;
    } catch (e) {
      print('UserProvider: Lỗi khi thực hiện getAllUsersWithoutCheck: $e');
      _errorMessage = 'Không thể lấy danh sách người dùng: ${e.toString()}';
      notifyListeners();
      return []; // Return an empty list if there is an error
    }
  }

  // Dọn dẹp tài nguyên khi provider bị hủy
  @override
  void dispose() {
    print('UserProvider: Dispose');
    _authSubscription?.cancel();
    super.dispose();
  }
}
