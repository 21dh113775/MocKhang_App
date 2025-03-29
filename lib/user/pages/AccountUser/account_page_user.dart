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
  final TextEditingController _streetAddressController =
      TextEditingController();
  final TextEditingController _wardController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  String? _selectedCity;
  bool _isDefaultAddress = false;

  File? _selectedImage; // Biến lưu trữ hình ảnh đã chọn
  bool _isEditing = false;
  bool _isLoading = false;

  final List<String> _cities = [
    'Hà Nội',
    'TP. Hồ Chí Minh',
    'Đà Nẵng',
    'Cần Thơ',
    'Hải Phòng',
    // ... thêm các tỉnh thành khác
  ]..sort();

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

    await userProvider.refreshUserData(); // Làm mới dữ liệu người dùng

    final user = userProvider.currentUser;
    if (user != null) {
      _fullNameController.text = user.fullName;
      _phoneNumberController.text = user.phoneNumber ?? '';
      _addressController.text = user.address ?? '';

      try {
        final addressParts =
            user.address?.split(',').map((e) => e.trim()).toList();
        if (addressParts != null) {
          _streetAddressController.text = addressParts[0];
          if (addressParts.length > 1) {
            _wardController.text = addressParts[1];
          }
          if (addressParts.length > 2) {
            _districtController.text = addressParts[2];
          }
          if (addressParts.length > 3) {
            _selectedCity = addressParts.last;
          }
        }
      } catch (e) {
        print("Error parsing address: $e");
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Hàm để chọn hình ảnh từ thư viện
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      print("PickImage result: ${pickedFile?.path ?? 'null'}");

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        print("Selected image file exists: ${file.existsSync()}");

        setState(() {
          _selectedImage = file;
        });
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể chọn ảnh: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hàm để lưu thông tin người dùng (bao gồm ảnh)
  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final List<String> addressParts = [];
      if (_streetAddressController.text.trim().isNotEmpty)
        addressParts.add(_streetAddressController.text.trim());
      if (_wardController.text.trim().isNotEmpty)
        addressParts.add(_wardController.text.trim());
      if (_districtController.text.trim().isNotEmpty)
        addressParts.add(_districtController.text.trim());
      if (_selectedCity != null && _selectedCity!.isNotEmpty)
        addressParts.add(_selectedCity!);

      final completeAddress = addressParts.join(', ');

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final bool success = await userProvider.completeUserProfile(
        fullName: _fullNameController.text,
        phoneNumber: _phoneNumberController.text,
        address: completeAddress,
        avatarFile: _selectedImage, // Truyền hình ảnh nếu người dùng đã chọn
        isDefaultAddress: _isDefaultAddress,
      );

      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.errorMessage ?? 'Cập nhật thất bại'),
            backgroundColor: Colors.red,
          ),
        );
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
                _buildUserInfoSection(user),
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

  // Hiển thị thông điệp yêu cầu người dùng cập nhật hồ sơ
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

  // Hiển thị thông tin người dùng
  Widget _buildUserInfoSection(UserModel user) {
    return _isEditing ? _buildEditForm() : _buildUserInfoDisplay(user);
  }

  // Hiển thị thông tin người dùng (xem trước)
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

  // Hiển thị thông tin chi tiết
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  // Form chỉnh sửa thông tin người dùng
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
          const SizedBox(height: 20),
          // Phần địa chỉ cải tiến
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Địa chỉ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  TextFormField(
                    controller: _streetAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Số nhà, tên đường',
                      hintText: 'Ví dụ: 123 Nguyễn Văn A',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập địa chỉ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _wardController,
                          decoration: const InputDecoration(
                            labelText: 'Phường/Xã',
                            hintText: 'Ví dụ: Phường 1',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập phường/xã';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _districtController,
                          decoration: const InputDecoration(
                            labelText: 'Quận/Huyện',
                            hintText: 'Ví dụ: Quận 1',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập quận/huyện';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Tỉnh/Thành phố',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    value: _selectedCity,
                    hint: const Text('Chọn tỉnh/thành phố'),
                    isExpanded: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng chọn tỉnh/thành phố';
                      }
                      return null;
                    },
                    items:
                        _cities.map((String city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(city),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCity = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _isDefaultAddress,
                        activeColor: Colors.blue,
                        onChanged: (value) {
                          setState(() {
                            _isDefaultAddress = value ?? false;
                          });
                        },
                      ),
                      const Text('Đặt làm địa chỉ mặc định'),
                    ],
                  ),
                ],
              ),
            ),
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
    _streetAddressController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    super.dispose();
  }
}
