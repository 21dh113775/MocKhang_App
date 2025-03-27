import 'dart:async';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockhang_app/admin/data/models/user_model.dart';
import 'package:mockhang_app/admin/data/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  UserModel? _currentUser;
  List<UserModel> _allUsers = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;

  UserModel? get currentUser => _currentUser;
  List<UserModel> get allUsers => _allUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _auth.currentUser != null;
  bool get isProfileComplete => _currentUser?.isProfileCompleted ?? false;
  bool get isAdmin => _currentUser?.role == 'admin';

  void _safeNotifyListeners() {
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          notifyListeners();
        } catch (e) {
          print('UserProvider: Error during notifyListeners: $e');
        }
      });
    } else {
      Future.microtask(() {
        try {
          notifyListeners();
        } catch (e) {
          print('UserProvider: Error during notifyListeners: $e');
        }
      });
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _safeNotifyListeners();
    }
  }

  void _setError(String? error) {
    _errorMessage = error;
    _safeNotifyListeners();
  }

  UserProvider();

  Future<void> initialize() async {
    print('UserProvider: Bắt đầu khởi tạo');
    _setLoading(true);

    try {
      if (_initialized) {
        print('UserProvider: Đã khởi tạo trước đó');
        _setLoading(false);
        return;
      }

      _setupAuthListener();
      print('UserProvider: Đã thiết lập Auth Listener');

      final User? currentUser = _auth.currentUser;
      print(
        'UserProvider: FirebaseAuth.currentUser = ${currentUser?.uid ?? "null"}',
      );

      if (currentUser != null) {
        await _loadUserData();
        print(
          'UserProvider: Đã tải dữ liệu người dùng: ${_currentUser?.fullName}',
        );
      } else {
        print('UserProvider: Chưa đăng nhập, bỏ qua tải dữ liệu người dùng');
      }

      _initialized = true;
      print('UserProvider: Khởi tạo hoàn tất');
    } catch (e) {
      print('UserProvider: Lỗi khi khởi tạo: $e');
      _setError('Không thể khởi tạo: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserData() async {
    if (_auth.currentUser == null) {
      print('UserProvider: _loadUserData - không có người dùng đăng nhập');
      return;
    }

    print(
      'UserProvider: Bắt đầu tải dữ liệu cho người dùng: ${_auth.currentUser!.uid}',
    );

    try {
      _setLoading(true);
      _setError(null);

      final currentUserDoc =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .get();

      if (currentUserDoc.exists) {
        _currentUser = UserModel.fromMap(
          _auth.currentUser!.uid,
          currentUserDoc.data() ?? {},
        );
        print('UserProvider: Đã lấy được thông tin người dùng từ Firestore');
      } else {
        print('UserProvider: Không tìm thấy thông tin người dùng, tạo mới');
        await _createNewUserRecord();

        final newUserDoc =
            await _firestore
                .collection('users')
                .doc(_auth.currentUser!.uid)
                .get();
        if (newUserDoc.exists) {
          _currentUser = UserModel.fromMap(
            _auth.currentUser!.uid,
            newUserDoc.data() ?? {},
          );
        }
      }

      print('UserProvider: Tải danh sách người dùng');
      await _loadAllUsers();
      _safeNotifyListeners();
    } catch (e) {
      _setError('Không thể lấy thông tin người dùng: ${e.toString()}');
      print('UserProvider: Lỗi trong _loadUserData(): $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadAllUsers() async {
    try {
      print('UserProvider: Bắt đầu tải danh sách tất cả người dùng');
      final QuerySnapshot snapshot = await _firestore.collection('users').get();

      print(
        'UserProvider: Số lượng người dùng từ Firestore: ${snapshot.docs.length}',
      );

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
      _setError('Không thể tải danh sách người dùng: ${e.toString()}');
    }
  }

  void _setupAuthListener() {
    _authSubscription?.cancel();

    _authSubscription = _auth.authStateChanges().listen((User? user) async {
      print('UserProvider: Auth state changed. User: ${user?.uid ?? "null"}');

      if (user == null) {
        print('UserProvider: Người dùng đã đăng xuất');
        clearUserData();
      } else {
        print('UserProvider: Người dùng đã đăng nhập: ${user.uid}');
        await _loadUserData();
      }
    });
  }

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
        final newUser = {
          'email': firebaseUser.email ?? '',
          'fullName': firebaseUser.displayName ?? 'Người dùng mới',
          'role': 'user', // Mặc định là người dùng
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
        await docRef.update({'lastLogin': FieldValue.serverTimestamp()});
        print('UserProvider: Đã cập nhật thời gian đăng nhập');
      }
    } catch (e) {
      print('UserProvider: Lỗi khi tạo bản ghi người dùng mới: $e');
    }
  }

  // Phương thức getAllUsersWithoutCheck để lấy danh sách tất cả người dùng
  Future<List<UserModel>> getAllUsersWithoutCheck() async {
    print(
      'UserProvider: Bắt đầu lấy tất cả người dùng mà không kiểm tra quyền',
    );

    try {
      final snapshot = await _firestore.collection('users').get();
      final users =
          snapshot.docs.map((doc) {
            return UserModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();

      print('UserProvider: Đã lấy ${users.length} người dùng');
      return users;
    } catch (e) {
      print('UserProvider: Lỗi trong getAllUsersWithoutCheck: $e');
      _setError('Không thể lấy danh sách người dùng: ${e.toString()}');
      return [];
    }
  }

  Future<bool> updateUserProfile({
    String? fullName,
    String? phoneNumber,
    String? address,
    File? avatarFile,
  }) async {
    if (_auth.currentUser == null) return false;

    _setLoading(true);
    _setError(null);

    try {
      String userId = _auth.currentUser!.uid;
      print('UserProvider: Cập nhật hồ sơ cho người dùng $userId');

      String? avatarUrl;
      if (avatarFile != null) {
        avatarUrl = await _userRepository.uploadUserAvatar(userId, avatarFile);
        print('UserProvider: Đã tải lên ảnh đại diện: $avatarUrl');
      }

      final Map<String, dynamic> updateData = {};
      if (fullName != null) updateData['fullName'] = fullName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (address != null) updateData['address'] = address;
      if (avatarUrl != null) updateData['avatarUrl'] = avatarUrl;

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
        print('UserProvider: Hồ sơ đủ thông tin để đánh dấu hoàn thành');
      }

      await _firestore.collection('users').doc(userId).update(updateData);
      print('UserProvider: Đã cập nhật hồ sơ người dùng thành công');
      await refreshUserData();
      return true;
    } catch (e) {
      _setError('Lỗi khi cập nhật hồ sơ: ${e.toString()}');
      print('UserProvider: Lỗi trong updateUserProfile(): $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Phương thức làm mới dữ liệu người dùng
  Future<void> refreshUserData() async {
    print('UserProvider: Bắt đầu làm mới dữ liệu người dùng');
    _setLoading(true); // Đặt trạng thái đang tải
    _setError(null); // Reset lỗi

    try {
      // Kiểm tra xem người dùng đã đăng nhập chưa
      if (_auth.currentUser == null) {
        print('UserProvider: Không thể làm mới dữ liệu - chưa đăng nhập');
        return;
      }

      // Lấy lại thông tin người dùng từ Firestore
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

      // Làm mới danh sách người dùng
      print('UserProvider: Làm mới danh sách người dùng');
      await _loadAllUsers();
    } catch (e) {
      _setError('Không thể làm mới dữ liệu: ${e.toString()}');
      print('UserProvider: Lỗi trong refreshUserData(): $e');
    } finally {
      _setLoading(false); // Kết thúc trạng thái tải
    }
  }

  void clearUserData() {
    print('UserProvider: Xóa dữ liệu người dùng');
    _currentUser = null;
    _allUsers = [];
    _safeNotifyListeners();
  }

  // Trong UserProvider
  Future<bool> completeUserProfile({
    required String fullName,
    required String phoneNumber,
    required String address,
    File? avatarFile, // Chỉ cần nhận hình ảnh nếu người dùng chọn ảnh mới
    bool isDefaultAddress = false, // Đặt mặc định cho địa chỉ
  }) async {
    if (_auth.currentUser == null) return false;

    _setLoading(true);
    _setError(null);

    try {
      String userId = _auth.currentUser!.uid;
      print('UserProvider: Hoàn thành hồ sơ cho người dùng $userId');

      // Nếu có ảnh đại diện, upload và lấy URL
      String? avatarUrl;
      if (avatarFile != null) {
        avatarUrl = await _userRepository.uploadUserAvatar(userId, avatarFile);
        print('UserProvider: Đã tải lên ảnh đại diện: $avatarUrl');
      }

      // Tạo map dữ liệu cần cập nhật
      final Map<String, dynamic> updateData = {};
      updateData['fullName'] = fullName;
      updateData['phoneNumber'] = phoneNumber;
      updateData['address'] = address;
      if (avatarUrl != null) updateData['avatarUrl'] = avatarUrl;
      updateData['isProfileCompleted'] = true;

      // Cập nhật dữ liệu vào Firestore
      await _firestore.collection('users').doc(userId).update(updateData);
      print('UserProvider: Đã cập nhật hồ sơ người dùng thành công');

      // Làm mới dữ liệu người dùng sau khi cập nhật
      await refreshUserData();
      return true;
    } catch (e) {
      _setError('Lỗi khi hoàn thành hồ sơ: ${e.toString()}');
      print('UserProvider: Lỗi trong completeUserProfile(): $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteUser(String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      // Gọi đến UserRepository để xóa dữ liệu người dùng
      bool success = await _userRepository.deleteUser(userId);

      if (success) {
        // Nếu bạn đã thiết lập Cloud Function, gọi nó để xóa Authentication
        try {
          final functions = FirebaseFunctions.instance;
          final callable = functions.httpsCallable('deleteUser');
          final result = await callable.call({'uid': userId});

          if (result.data['success'] == true) {
            print('Đã xóa tài khoản Authentication thành công');
          }
        } catch (e) {
          print('Lỗi khi xóa tài khoản Authentication: $e');
          // Tiếp tục mặc dù có lỗi, vì dữ liệu người dùng đã bị xóa
        }

        // Làm mới danh sách người dùng
        await _loadAllUsers();
        _safeNotifyListeners();
      } else {
        _setError('Không thể xóa người dùng.');
      }
    } catch (e) {
      _setError('Lỗi khi xóa người dùng: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    print('UserProvider: Dispose');
    _authSubscription?.cancel();
    super.dispose();
  }
}
