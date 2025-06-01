import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/providers/user_provider.dart';
import 'package:provider/provider.dart';

class UpdateProfilePage extends StatefulWidget {
  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  File? _avatar;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Cập nhật thông tin cá nhân')),
      body:
          currentUser == null
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(labelText: 'Số điện thoại'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số điện thoại';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(labelText: 'Địa chỉ'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập địa chỉ';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Tải ảnh đại diện (tuỳ chọn)
                          _pickAvatar();
                        },
                        child: Text('Chọn ảnh đại diện'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            // Cập nhật thông tin người dùng
                            _updateProfile(context, currentUser);
                          }
                        },
                        child: Text('Lưu thông tin'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  // Chọn ảnh đại diện
  void _pickAvatar() async {
    // Thực hiện chọn ảnh từ thư viện hoặc máy ảnh
    // Chỉ demo ở đây, nên bạn có thể thay bằng picker của mình
  }

  // Cập nhật thông tin người dùng
  void _updateProfile(BuildContext context, currentUser) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool success = await userProvider.updateUserProfile(
      fullName: currentUser.fullName,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
    );

    if (success) {
      Navigator.pop(context); // Quay lại trang AccountPageUser
    } else {
      // Hiển thị lỗi nếu cập nhật không thành công
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cập nhật thất bại')));
    }
  }
}
