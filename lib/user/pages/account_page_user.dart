import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/user_model.dart';
import 'package:mockhang_app/admin/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class AccountPageUser extends StatefulWidget {
  const AccountPageUser({Key? key}) : super(key: key);

  @override
  State<AccountPageUser> createState() => _AccountPageUserState();
}

class _AccountPageUserState extends State<AccountPageUser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  File? _selectedImage;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    await userProvider.refreshUserData();
    //await userProvider.checkProfileStatus();

    final user = userProvider.currentUser;
    if (user != null) {
      _fullNameController.text = user.fullName;
      _phoneNumberController.text = user.phoneNumber ?? '';
      _addressController.text = user.address ?? '';
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final bool success = await userProvider.completeUserProfile(
        fullName: _fullNameController.text,
        phoneNumber: _phoneNumberController.text,
        address: _addressController.text,
        avatarFile: _selectedImage,
      );

      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thông tin thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userProvider.errorMessage ?? 'Cập nhật thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản của tôi'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.currentUser;

          if (_isLoading || user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!user.isProfileCompleted) _buildProfileCompletionMessage(),

                _buildUserInfoSection(user, userProvider),
              ],
            ),
          );
        },
      ),
      floatingActionButton:
          _isEditing
              ? FloatingActionButton.extended(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('Lưu thông tin'),
              )
              : null,
    );
  }

  Widget _buildProfileCompletionMessage() {
    return Card(
      color: Colors.amber[100],
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  'Cập nhật thông tin cá nhân',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng cập nhật đầy đủ thông tin cá nhân để có thể sử dụng tất cả tính năng của ứng dụng. Thông tin của bạn sẽ được bảo mật và chỉ sử dụng để phục vụ quá trình mua hàng.',
            ),
            const SizedBox(height: 12),
            if (!_isEditing)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                child: const Text('Cập nhật ngay'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(UserModel user, UserProvider userProvider) {
    return _isEditing ? _buildEditForm() : _buildUserInfoDisplay(user);
  }

  Widget _buildUserInfoDisplay(UserModel user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child:
                  user.avatarUrl == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const Divider(height: 32),
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
            _buildInfoItem(
              Icons.verified_user,
              'Trạng thái hồ sơ',
              user.isProfileCompleted ? 'Đã hoàn thành' : 'Chưa hoàn thành',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    final user = Provider.of<UserProvider>(context).currentUser;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (user?.avatarUrl != null
                              ? NetworkImage(user!.avatarUrl!)
                              : null),
                  child:
                      _selectedImage == null && user?.avatarUrl == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập họ tên';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneNumberController,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập số điện thoại';
              }
              if (value.length < 10) {
                return 'Số điện thoại không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Địa chỉ',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập địa chỉ';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
