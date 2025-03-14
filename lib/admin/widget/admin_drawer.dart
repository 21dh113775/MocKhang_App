import 'package:flutter/material.dart';
import 'package:mockhang_app/auth/auth_service.dart'; // Đảm bảo đã import AuthService
import 'package:mockhang_app/auth/login_screen.dart'; // Đảm bảo đã import LoginScreen

class AdminDrawer extends StatelessWidget {
  final Function(int) onMenuSelected;

  AdminDrawer({required this.onMenuSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.brown),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  "Admin Panel",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.dashboard, "Dashboard", 0),
          _buildDrawerItem(Icons.person, "Tài khoản", 1),
          _buildDrawerItem(Icons.category, "Danh mục", 2),
          _buildDrawerItem(Icons.shopping_bag, "Sản phẩm", 3),
          _buildDrawerItem(Icons.warehouse, "Kho", 4),
          _buildDrawerItem(Icons.shopping_cart, "Đơn hàng", 5),
          Divider(),
          _buildDrawerItem(Icons.settings, "Cài đặt hệ thống", 6),
          _buildDrawerItem(Icons.bar_chart, "Báo cáo & Thống kê", 7),
          _buildDrawerItem(Icons.support_agent, "Hỗ trợ khách hàng", 8),
          _buildDrawerItem(Icons.discount, "Khuyến mãi", 9),
          _buildDrawerItem(Icons.attach_money, "Thanh toán & Doanh thu", 10),
          _buildDrawerItem(Icons.delivery_dining, "Quản lý vận chuyển", 11),
          _buildDrawerItem(Icons.notifications, "Quản lý thông báo", 12),
          _buildDrawerItem(Icons.article, "Quản lý nội dung (CMS)", 13),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Đăng xuất", style: TextStyle(color: Colors.red)),
            onTap: () async {
              bool confirmLogout = await _showLogoutDialog(context);
              if (confirmLogout) {
                // Gọi hàm đăng xuất và chuyển đến LoginScreen
                await _logout(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => onMenuSelected(index),
    );
  }

  /// Hiển thị hộp thoại xác nhận khi đăng xuất
  Future<bool> _showLogoutDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text("Xác nhận đăng xuất"),
                content: Text("Bạn có chắc chắn muốn đăng xuất không?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("Hủy"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text("Đăng xuất"),
                  ),
                ],
              ),
        ) ??
        false;
  }

  /// Đăng xuất và chuyển về trang LoginScreen
  Future<void> _logout(BuildContext context) async {
    // Gọi phương thức đăng xuất từ AuthService
    await AuthService().signOut();

    // Sau khi đăng xuất, điều hướng đến LoginScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
