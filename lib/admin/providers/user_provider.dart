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

  // Cache collection reference để tránh khởi tạo lại nhiều lần
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');

  bool _initialized = false;
  bool get isInitialized => _initialized;

  UserModel? _currentUser;
  List<UserModel> _allUsers = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  // Đệm cho danh sách người dùng - giảm truy vấn Firestore
  DateTime? _lastUserListFetch;
  final Duration _userListCacheDuration = Duration(minutes: 5);

  UserModel? get currentUser => _currentUser;
  List<UserModel> get allUsers => _allUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _auth.currentUser != null;
  bool get isProfileComplete => _currentUser?.isProfileCompleted ?? false;
  bool get isAdmin => _currentUser?.role == 'admin';

  // Nâng cấp _safeNotifyListeners với debounce
  Timer? _notifyDebounceTimer;
  void _safeNotifyListeners() {
    // Hủy timer trước đó nếu còn active
    _notifyDebounceTimer?.cancel();

    // Đặt timer mới để debounce nhiều lệnh gọi
    _notifyDebounceTimer = Timer(Duration(milliseconds: 100), () {
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
    });
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
    if (_initialized) {
      print('UserProvider: Đã khởi tạo trước đó');
      return;
    }

    _setLoading(true);

    try {
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
      _initialized = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserData() async {
    if (_auth.currentUser == null) {
      print('UserProvider: _loadUserData - không có người dùng đăng nhập');
      return;
    }

    String userId = _auth.currentUser!.uid;
    print('UserProvider: Bắt đầu tải dữ liệu cho người dùng: $userId');

    try {
      _setLoading(true);
      _setError(null);

      // Thiết lập subscription cho tài liệu người dùng để cập nhật real-time
      _setupUserDocListener(userId);

      // Truy vấn dữ liệu ngay lập tức
      final currentUserDoc = await _usersCollection.doc(userId).get();

      if (currentUserDoc.exists) {
        _currentUser = UserModel.fromMap(
          userId,
          currentUserDoc.data() as Map<String, dynamic>,
        );
        print('UserProvider: Đã lấy được thông tin người dùng từ Firestore');
      } else {
        print('UserProvider: Không tìm thấy thông tin người dùng, tạo mới');
        await _createNewUserRecord();

        final newUserDoc = await _usersCollection.doc(userId).get();
        if (newUserDoc.exists) {
          _currentUser = UserModel.fromMap(
            userId,
            newUserDoc.data() as Map<String, dynamic>,
          );
        }
      }

      // Chỉ tải danh sách người dùng nếu cần
      if (_allUsers.isEmpty ||
          _lastUserListFetch == null ||
          DateTime.now().difference(_lastUserListFetch!) >
              _userListCacheDuration) {
        print('UserProvider: Tải danh sách người dùng');
        await _loadAllUsers();
      } else {
        print('UserProvider: Sử dụng cache danh sách người dùng');
      }

      _safeNotifyListeners();
    } catch (e) {
      _setError('Không thể lấy thông tin người dùng: ${e.toString()}');
      print('UserProvider: Lỗi trong _loadUserData(): $e');
    } finally {
      _setLoading(false);
    }
  }

  // Thiết lập listener cho tài liệu người dùng để cập nhật real-time
  void _setupUserDocListener(String userId) {
    // Hủy listener cũ trước khi tạo mới
    _userDocSubscription?.cancel();

    _userDocSubscription = _usersCollection
        .doc(userId)
        .snapshots()
        .listen(
          (docSnapshot) {
            if (docSnapshot.exists) {
              _currentUser = UserModel.fromMap(
                userId,
                docSnapshot.data() as Map<String, dynamic>,
              );
              print('UserProvider: Cập nhật dữ liệu người dùng real-time');
              _safeNotifyListeners();
            }
          },
          onError: (error) {
            print(
              'UserProvider: Lỗi khi lắng nghe thay đổi dữ liệu người dùng: $error',
            );
          },
        );
  }

  Future<void> _loadAllUsers() async {
    try {
      print('UserProvider: Bắt đầu tải danh sách tất cả người dùng');

      // Sử dụng phân trang và giới hạn để cải thiện hiệu suất
      final QuerySnapshot snapshot =
          await _usersCollection
              .limit(100) // Giới hạn số lượng người dùng được tải một lúc
              .get();

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

      // Cập nhật thời gian lấy dữ liệu gần nhất
      _lastUserListFetch = DateTime.now();

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
        _userDocSubscription?.cancel();
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

      String userId = firebaseUser.uid;
      print('UserProvider: Đang tạo bản ghi mới cho người dùng: $userId');

      final docRef = _usersCollection.doc(userId);
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
        // Sử dụng transaction để đảm bảo atomic update
        await _firestore.runTransaction((transaction) async {
          transaction.update(docRef, {
            'lastLogin': FieldValue.serverTimestamp(),
          });
        });
        print('UserProvider: Đã cập nhật thời gian đăng nhập');
      }
    } catch (e) {
      print('UserProvider: Lỗi khi tạo bản ghi người dùng mới: $e');
    }
  }

  // Tối ưu phương thức lấy danh sách người dùng với pagination
  Future<List<UserModel>> getAllUsersWithoutCheck({
    int limit = 100,
    UserModel? lastUser,
  }) async {
    print('UserProvider: Bắt đầu lấy tất cả người dùng với phân trang');

    try {
      Query query = _usersCollection.limit(limit);

      // Áp dụng phân trang nếu có user cuối cùng
      if (lastUser != null) {
        query = query.startAfterDocument(
          await _usersCollection.doc(lastUser.id).get(),
        );
      }

      final snapshot = await query.get();
      final users =
          snapshot.docs.map((doc) {
            return UserModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();

      print('UserProvider: Đã lấy ${users.length} người dùng (trang mới)');
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

      // Tải lên ảnh đại diện một cách bất đồng bộ nếu có
      Future<String?>? avatarUploadFuture;
      if (avatarFile != null) {
        avatarUploadFuture = _userRepository.uploadUserAvatar(
          userId,
          avatarFile,
        );
      }

      final Map<String, dynamic> updateData = {};
      if (fullName != null) updateData['fullName'] = fullName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (address != null) updateData['address'] = address;

      // Chờ tải lên ảnh hoàn thành nếu có
      if (avatarUploadFuture != null) {
        final avatarUrl = await avatarUploadFuture;
        if (avatarUrl != null) {
          updateData['avatarUrl'] = avatarUrl;
          print('UserProvider: Đã tải lên ảnh đại diện: $avatarUrl');
        }
      }

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

      // Sử dụng transaction để update
      await _firestore.runTransaction((transaction) async {
        transaction.update(_usersCollection.doc(userId), updateData);
      });

      print('UserProvider: Đã cập nhật hồ sơ người dùng thành công');

      // Làm mới dữ liệu người dùng không cần thiết vì đã có listener
      return true;
    } catch (e) {
      _setError('Lỗi khi cập nhật hồ sơ: ${e.toString()}');
      print('UserProvider: Lỗi trong updateUserProfile(): $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Phương thức làm mới dữ liệu người dùng - với tối ưu cache
  Future<void> refreshUserData({bool forceRefresh = false}) async {
    print('UserProvider: Bắt đầu làm mới dữ liệu người dùng');

    // Nếu không có người dùng đăng nhập, không cần làm gì
    if (_auth.currentUser == null) {
      print('UserProvider: Không thể làm mới dữ liệu - chưa đăng nhập');
      return;
    }

    // Nếu buộc làm mới hoặc cần cập nhật cache danh sách người dùng
    if (forceRefresh ||
        _lastUserListFetch == null ||
        DateTime.now().difference(_lastUserListFetch!) >
            _userListCacheDuration) {
      _setLoading(true);

      try {
        await _loadAllUsers();
        print('UserProvider: Đã làm mới danh sách người dùng');
      } catch (e) {
        _setError('Không thể làm mới dữ liệu: ${e.toString()}');
        print('UserProvider: Lỗi trong refreshUserData(): $e');
      } finally {
        _setLoading(false);
      }
    } else {
      print('UserProvider: Bỏ qua làm mới danh sách người dùng (dùng cache)');
    }
  }

  void clearUserData() {
    print('UserProvider: Xóa dữ liệu người dùng');
    _currentUser = null;
    _allUsers = [];
    _lastUserListFetch = null;
    _safeNotifyListeners();
  }

  Future<bool> completeUserProfile({
    required String fullName,
    required String phoneNumber,
    required String address,
    File? avatarFile,
    bool isDefaultAddress = false,
  }) async {
    if (_auth.currentUser == null) return false;

    _setLoading(true);
    _setError(null);

    try {
      String userId = _auth.currentUser!.uid;
      print('UserProvider: Hoàn thành hồ sơ cho người dùng $userId');

      // Tải lên ảnh đại diện một cách bất đồng bộ nếu có
      Future<String?>? avatarUploadFuture;
      if (avatarFile != null) {
        avatarUploadFuture = _userRepository.uploadUserAvatar(
          userId,
          avatarFile,
        );
      }

      // Tạo map dữ liệu cần cập nhật
      final Map<String, dynamic> updateData = {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'address': address,
        'isProfileCompleted': true,
      };

      // Chờ tải lên ảnh hoàn thành nếu có
      if (avatarUploadFuture != null) {
        final avatarUrl = await avatarUploadFuture;
        if (avatarUrl != null) {
          updateData['avatarUrl'] = avatarUrl;
          print('UserProvider: Đã tải lên ảnh đại diện: $avatarUrl');
        }
      }

      // Sử dụng batch để cập nhật nhiều trường cùng một lúc
      final batch = _firestore.batch();
      batch.update(_usersCollection.doc(userId), updateData);
      await batch.commit();

      print('UserProvider: Đã cập nhật hồ sơ người dùng thành công');

      // Làm mới dữ liệu người dùng không cần thiết vì đã có listener
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

        // Chỉ làm mới danh sách người dùng nếu xóa thành công
        // Xóa người dùng đã xóa khỏi bộ nhớ cache
        _allUsers.removeWhere((user) => user.id == userId);
        _lastUserListFetch = DateTime.now(); // Cập nhật thời gian cập nhật

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
    _userDocSubscription?.cancel();
    _notifyDebounceTimer?.cancel();
    super.dispose();
  }
}
