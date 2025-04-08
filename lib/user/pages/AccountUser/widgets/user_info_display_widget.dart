import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/user_model.dart';

class UserInfoDisplay extends StatelessWidget {
  final UserModel user;
  final Function(String) onSettingTapped;

  const UserInfoDisplay({
    Key? key,
    required this.user,
    required this.onSettingTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Thông tin cá nhân',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _buildPersonalInfoCard(),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Cài đặt tài khoản',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _buildSettingsCard(),
      ],
    );
  }

  Widget _buildPersonalInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    user.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.isProfileCompleted ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.isProfileCompleted ? 'Đã xác thực' : 'Chưa xác thực',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const Divider(height: 24),
            _buildInfoItem(
              Icons.phone,
              'Số điện thoại',
              user.phoneNumber ?? 'Chưa cập nhật',
            ),
            _buildInfoItem(
              Icons.location_on,
              'Địa chỉ',
              user.address ?? 'Chưa cập nhật',
            ),
            _buildInfoItem(
              Icons.calendar_today,
              'Ngày tạo tài khoản',
              '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
            ),
            if (user.lastLogin != null)
              _buildInfoItem(
                Icons.access_time,
                'Đăng nhập gần nhất',
                '${user.lastLogin!.day}/${user.lastLogin!.month}/${user.lastLogin!.year}',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.lock,
            title: 'Thay đổi mật khẩu',
            onTap: () => onSettingTapped('password'),
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Cài đặt thông báo',
            onTap: () => onSettingTapped('notifications'),
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingItem(
            icon: Icons.language,
            title: 'Ngôn ngữ',
            value: 'Tiếng Việt',
            onTap: () => onSettingTapped('language'),
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: 'Quyền riêng tư',
            onTap: () => onSettingTapped('privacy'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.brown.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.brown, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.brown.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.brown, size: 20),
      ),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }
}
