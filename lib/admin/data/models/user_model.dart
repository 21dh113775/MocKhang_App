import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  String? phoneNumber;
  String? address;
  String? avatarUrl;
  final String role;
  final DateTime createdAt;
  DateTime? lastLogin;
  bool isProfileCompleted;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.address,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
    this.lastLogin,
    this.isProfileCompleted = false,
  });

  // Tạo UserModel từ DocumentSnapshot từ Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;

    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      avatarUrl: data['avatarUrl'],
      role: data['role'] ?? 'user',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      isProfileCompleted: data['isProfileCompleted'] ?? false,
    );
  }

  // Thêm factory constructor fromMap để tương thích với UserProvider
  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      avatarUrl: data['avatarUrl'],
      role: data['role'] ?? 'user',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      isProfileCompleted: data['isProfileCompleted'] ?? false,
    );
  }

  // Chuyển đổi UserModel thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'avatarUrl': avatarUrl,
      'role': role,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'isProfileCompleted': isProfileCompleted,
    };
  }

  // Tạo bản sao với thông tin cập nhật
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? avatarUrl,
    String? role,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isProfileCompleted,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
    );
  }
}
