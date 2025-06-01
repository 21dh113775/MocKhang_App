import 'package:flutter/material.dart';
import 'package:mockhang_app/user/pages/AccountUser/app_theme.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildSettingsSection('Tài khoản', [
          _buildSettingItem(
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            onTap: () {
              // Chuyển đến màn hình đổi mật khẩu
            },
          ),
          _buildSettingItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Quyền riêng tư',
            onTap: () {
              // Chuyển đến màn hình cài đặt quyền riêng tư
            },
          ),
        ]),
        _buildSettingsSection('Giao diện', [
          _buildSettingSwitch(
            icon: Icons.dark_mode,
            title: 'Chế độ tối',
            onChanged: (bool value) {
              // Thay đổi chế độ giao diện
            },
          ),
        ]),
        _buildSettingsSection('Khác', [
          _buildSettingItem(
            icon: Icons.logout,
            title: 'Đăng xuất',
            onTap: () {
              // Xử lý đăng xuất
            },
            color: Colors.red,
          ),
        ]),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.primaryColor),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSettingSwitch({
    required IconData icon,
    required String title,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      value: false, // Trạng thái hiện tại của switch
      onChanged: onChanged,
    );
  }
}
