import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileAvatar extends StatelessWidget {
  final UserModel user;
  final File? selectedImage;
  final double radius;
  final VoidCallback? onTap;

  const ProfileAvatar({
    Key? key,
    required this.user,
    this.selectedImage,
    this.radius = 50,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'profile-image',
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: radius - 3,
            backgroundColor: Colors.grey[300],
            backgroundImage:
                selectedImage != null
                    ? FileImage(selectedImage!)
                    : (user.avatarUrl != null
                        ? CachedNetworkImageProvider(user.avatarUrl!)
                            as ImageProvider
                        : null),
            child:
                selectedImage == null && user.avatarUrl == null
                    ? Icon(Icons.person, size: radius, color: Colors.brown)
                    : null,
          ),
        ),
      ),
    );
  }
}

class ProfileHeaderBackground extends StatelessWidget {
  final UserModel user;
  final File? selectedImage;

  const ProfileHeaderBackground({
    Key? key,
    required this.user,
    this.selectedImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.brown.shade800, Colors.brown.shade400],
            ),
          ),
        ),
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Center(
            child: ProfileAvatar(user: user, selectedImage: selectedImage),
          ),
        ),
      ],
    );
  }
}

class ProfileCompletionMessage extends StatelessWidget {
  final VoidCallback onEditPressed;
  final bool isEditing;

  const ProfileCompletionMessage({
    Key? key,
    required this.onEditPressed,
    required this.isEditing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.amber.shade100, Colors.amber.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Cập nhật thông tin cá nhân',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Vui lòng cập nhật đầy đủ thông tin cá nhân để sử dụng tất cả tính năng của ứng dụng. Thông tin của bạn sẽ được bảo mật và chỉ sử dụng cho quá trình mua hàng.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 16),
            if (!isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onEditPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('CẬP NHẬT NGAY'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
