import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Xác định màu chủ đạo
  final Color primaryColor = Color(0xFF2C3E50);
  final Color accentColor = Color(0xFF3498DB);
  final Color backgroundColor = Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;

  bool _showCenterMessage = false;

  @override
  void initState() {
    super.initState();
    // Hiển thị thông báo ở giữa sau khi widget được build hoàn toàn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _showCenterMessage = true;
      });

      // Tự động ẩn thông báo sau 5 giây
      Future.delayed(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showCenterMessage = false;
          });
        }
      });
    });
  }

  void _showComingSoonMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Chức năng này sẽ được hoàn thiện trong thời gian tới!",
          style: TextStyle(fontSize: 14),
        ),
        duration: Duration(seconds: 3),
        backgroundColor: accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cài đặt hệ thống",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showComingSoonMessage,
          ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: _showComingSoonMessage,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: backgroundColor,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildSectionHeader(context, "Cấu hình chung"),
                SizedBox(height: 8),
                _buildSettingCard(
                  context,
                  icon: Icons.language,
                  title: "Ngôn ngữ hệ thống",
                  subtitle: "Tiếng Việt",
                  onTap: _showComingSoonMessage,
                ),
                _buildSettingCard(
                  context,
                  icon: Icons.color_lens,
                  title: "Giao diện",
                  subtitle: "Sáng",
                  onTap: _showComingSoonMessage,
                ),
                _buildSettingCard(
                  context,
                  icon: Icons.notifications,
                  title: "Thông báo",
                  subtitle: "Bật",
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      _showComingSoonMessage();
                    },
                    activeColor: accentColor,
                  ),
                  onTap: _showComingSoonMessage,
                ),

                SizedBox(height: 24),
                _buildSectionHeader(context, "Bảo mật"),
                SizedBox(height: 8),
                _buildSettingCard(
                  context,
                  icon: Icons.lock,
                  title: "Mật khẩu",
                  subtitle: "Thay đổi mật khẩu đăng nhập",
                  onTap: _showComingSoonMessage,
                ),
                _buildSettingCard(
                  context,
                  icon: Icons.verified_user,
                  title: "Xác thực hai yếu tố",
                  subtitle: "Tắt",
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      _showComingSoonMessage();
                    },
                    activeColor: accentColor,
                  ),
                  onTap: _showComingSoonMessage,
                ),

                SizedBox(height: 24),
                _buildSectionHeader(context, "Quản lý dữ liệu"),
                SizedBox(height: 8),
                _buildSettingCard(
                  context,
                  icon: Icons.backup,
                  title: "Sao lưu dữ liệu",
                  subtitle: "Sao lưu tự động: Hàng tuần",
                  onTap: _showComingSoonMessage,
                ),
                _buildSettingCard(
                  context,
                  icon: Icons.restore,
                  title: "Khôi phục dữ liệu",
                  subtitle: "Sao lưu gần nhất: 24/03/2025",
                  onTap: _showComingSoonMessage,
                ),
                _buildSettingCard(
                  context,
                  icon: Icons.storage,
                  title: "Dung lượng lưu trữ",
                  subtitle: "Đã sử dụng: 2.4GB / 10GB",
                  onTap: _showComingSoonMessage,
                ),

                SizedBox(height: 24),
                _buildSectionHeader(context, "Nâng cao"),
                SizedBox(height: 8),
                _buildSettingCard(
                  context,
                  icon: Icons.admin_panel_settings,
                  title: "Phân quyền người dùng",
                  subtitle: "Quản lý vai trò và quyền truy cập",
                  onTap: _showComingSoonMessage,
                ),
                _buildSettingCard(
                  context,
                  icon: Icons.api,
                  title: "API Settings",
                  subtitle: "Quản lý key và kết nối",
                  onTap: _showComingSoonMessage,
                ),
                _buildSettingCard(
                  context,
                  icon: Icons.system_update,
                  title: "Cập nhật hệ thống",
                  subtitle: "Phiên bản hiện tại: 2.1.4",
                  onTap: _showComingSoonMessage,
                ),

                SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _showComingSoonMessage,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        "Khôi phục cài đặt gốc",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),

          // Thông báo ở giữa màn hình
          if (_showCenterMessage)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Trang cài đặt đang được phát triển. Một số chức năng sẽ được hoàn thiện sau.",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showCenterMessage = false;
                        });
                      },
                      child: Text(
                        "Đóng",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        title,
        style: TextStyle(
          color: primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryColor),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
        ),
        trailing:
            trailing ??
            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
