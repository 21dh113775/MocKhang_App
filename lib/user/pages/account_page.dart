import 'package:flutter/material.dart';
import 'package:mockhang_app/auth/auth_service.dart'; // Giả sử bạn có dịch vụ xác thực ở đây
import 'package:mockhang_app/auth/login_screen.dart';
// Giả sử LoginScreen được định nghĩa trong file login_screen.dart

class AccountPage extends StatelessWidget {
  // Hàm đăng xuất
  void _logout(BuildContext context) async {
    // Xử lý đăng xuất ở đây, ví dụ gọi API hoặc dịch vụ AuthService
    await AuthService()
        .signOut(); // Giả sử AuthService là dịch vụ quản lý đăng nhập và đăng xuất

    // Sau khi đăng xuất, chuyển hướng về trang LoginScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tài Khoản")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Thông tin tài khoản người dùng"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: Text("Đăng xuất"),
            ),
          ],
        ),
      ),
    );
  }
}
