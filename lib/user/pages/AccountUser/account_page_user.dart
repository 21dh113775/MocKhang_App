import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/user_model.dart';
import 'package:mockhang_app/admin/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  File? _selectedImage;
  bool _isEditing = false;
  bool _isLoading = false;

  // Thông tin thống kê người dùng (giả định)
  final int _orderCount = 0;
  final int _favoriteCount = 0;
  final double _rewardPoints = 0;

  final List<String> _cities = [
    'Hà Nội',
    'TP. Hồ Chí Minh',
    'Đà Nẵng',
    'Cần Thơ',
    'Hải Phòng',
    'An Giang',
    'Bà Rịa - Vũng Tàu',
    'Bắc Giang',
    'Bắc Kạn',
    'Bạc Liêu',
    'Bắc Ninh',
    'Bến Tre',
    'Bình Định',
    'Bình Dương',
    'Bình Phước',
    'Bình Thuận',
    'Cà Mau',
    'Cao Bằng',
    'Đắk Lắk',
    'Đắk Nông',
    'Điện Biên',
    'Đồng Nai',
    'Đồng Tháp',
    'Gia Lai',
    'Hà Giang',
    'Hà Nam',
    'Hà Tĩnh',
    'Hải Dương',
    'Hậu Giang',
    'Hòa Bình',
    'Hưng Yên',
    'Khánh Hòa',
    'Kiên Giang',
    'Kon Tum',
    'Lai Châu',
    'Lâm Đồng',
    'Lạng Sơn',
    'Lào Cai',
    'Long An',
    'Nam Định',
    'Nghệ An',
    'Ninh Bình',
    'Ninh Thuận',
    'Phú Thọ',
    'Phú Yên',
    'Quảng Bình',
    'Quảng Nam',
    'Quảng Ngãi',
    'Quảng Ninh',
    'Quảng Trị',
    'Sóc Trăng',
    'Sơn La',
    'Tây Ninh',
    'Thái Bình',
    'Thái Nguyên',
    'Thanh Hóa',
    'Thừa Thiên Huế',
    'Tiền Giang',
    'Trà Vinh',
    'Tuyên Quang',
    'Vĩnh Long',
    'Vĩnh Phúc',
    'Yên Bái',
  ]..sort();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUserData();

      final user = userProvider.currentUser;
      if (user != null) {
        _fullNameController.text = user.fullName;
        _phoneNumberController.text = user.phoneNumber ?? '';
        _addressController.text = user.address ?? '';

        try {
          final addressParts =
              user.address?.split(',').map((e) => e.trim()).toList();
          if (addressParts != null && addressParts.isNotEmpty) {
            _streetAddressController.text = addressParts[0];
            if (addressParts.length > 1) _wardController.text = addressParts[1];
            if (addressParts.length > 2)
              _districtController.text = addressParts[2];
            if (addressParts.length > 3) _selectedCity = addressParts.last;
          }
        } catch (e) {
          debugPrint("Error parsing address: $e");
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể tải thông tin người dùng: ${error.toString()}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Tối ưu chất lượng ảnh
        maxWidth: 800,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (mounted) {
          setState(() => _selectedImage = file);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chọn ảnh: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
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
          avatarFile: _selectedImage,
          isDefaultAddress: _isDefaultAddress,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
            _isEditing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Cập nhật thông tin thành công'
                    : userProvider.errorMessage ?? 'Cập nhật thất bại',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.currentUser;

          if (_isLoading || user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(user, theme),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!user.isProfileCompleted)
                        _buildProfileCompletionMessage(),
                      _buildUserStats(theme),
                      _buildUserInfoSection(user),
                      const SizedBox(height: 100), // Padding bottom for FAB
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton:
          _isEditing
              ? FloatingActionButton.extended(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('Lưu thông tin'),
                backgroundColor: Colors.brown,
              )
              : FloatingActionButton(
                onPressed: () {
                  setState(() => _isEditing = true);
                },
                backgroundColor: Colors.brown,
                child: const Icon(Icons.edit),
                tooltip: 'Chỉnh sửa thông tin',
              ),
    );
  }

  SliverAppBar _buildAppBar(UserModel user, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      backgroundColor: Colors.brown,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Tài khoản của tôi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        background: Stack(
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
                child: Hero(
                  tag: 'profile-image',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 47,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (user.avatarUrl != null
                                  ? CachedNetworkImageProvider(user.avatarUrl!)
                                      as ImageProvider
                                  : null),
                      child:
                          _selectedImage == null && user.avatarUrl == null
                              ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.brown,
                              )
                              : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (!_isEditing)
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Hiển thị dialog xác nhận đăng xuất
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Đăng xuất'),
                      content: const Text('Bạn có chắc muốn đăng xuất?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('HỦY'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Xử lý đăng xuất tại đây
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('ĐĂNG XUẤT'),
                        ),
                      ],
                    ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildUserStats(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.shopping_bag,
            title: 'Đơn hàng',
            value: '$_orderCount',
            color: Colors.blue,
            onTap: () {
              Navigator.pushNamed(context, '/order-history');
            },
          ),
          _buildStatItem(
            icon: Icons.favorite,
            title: 'Yêu thích',
            value: '$_favoriteCount',
            color: Colors.red,
            onTap: () {
              // Điều hướng đến trang yêu thích
              Navigator.pushNamed(context, '/favorite');
            },
          ),
          _buildStatItem(
            icon: Icons.stars,
            title: 'Điểm thưởng',
            value: '$_rewardPoints',
            color: Colors.amber,
            onTap: () {
              // Điều hướng đến trang điểm thưởng
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              children: [
                Icon(icon, color: color, size: 26),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCompletionMessage() {
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
            if (!_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _isEditing = true);
                  },
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

  Widget _buildUserInfoSection(UserModel user) {
    return _isEditing ? _buildEditForm() : _buildUserInfoDisplay(user);
  }

  Widget _buildUserInfoDisplay(UserModel user) {
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
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                        color:
                            user.isProfileCompleted
                                ? Colors.green
                                : Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.isProfileCompleted
                            ? 'Đã xác thực'
                            : 'Chưa xác thực',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
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
        ),

        // Card cài đặt tài khoản
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Cài đặt tài khoản',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSettingItem(
                icon: Icons.lock,
                title: 'Thay đổi mật khẩu',
                onTap: () {
                  // Điều hướng đến trang đổi mật khẩu
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                icon: Icons.notifications,
                title: 'Cài đặt thông báo',
                onTap: () {
                  // Điều hướng đến trang cài đặt thông báo
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                icon: Icons.language,
                title: 'Ngôn ngữ',
                value: 'Tiếng Việt',
                onTap: () {
                  // Hiển thị dialog chọn ngôn ngữ
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                icon: Icons.privacy_tip,
                title: 'Quyền riêng tư',
                onTap: () {
                  // Điều hướng đến trang quyền riêng tư
                },
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildEditForm() {
    final user = Provider.of<UserProvider>(context).currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Chỉnh sửa thông tin',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 57,
                        backgroundColor: Colors.grey[300],
                        backgroundImage:
                            _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (user?.avatarUrl != null
                                    ? CachedNetworkImageProvider(
                                          user!.avatarUrl!,
                                        )
                                        as ImageProvider
                                    : null),
                        child:
                            _selectedImage == null && user?.avatarUrl == null
                                ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.brown,
                                )
                                : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.brown,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
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
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin cơ bản',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Họ và tên',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.brown,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.brown,
                              width: 2,
                            ),
                          ),
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
                        decoration: InputDecoration(
                          labelText: 'Số điện thoại',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(
                            Icons.phone,
                            color: Colors.brown,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.brown,
                              width: 2,
                            ),
                          ),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.brown),
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
                        decoration: InputDecoration(
                          labelText: 'Số nhà, tên đường',
                          hintText: 'Ví dụ: 123 Nguyễn Văn A',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(
                            Icons.home,
                            color: Colors.brown,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.brown,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập địa chỉ đường';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _wardController,
                        decoration: InputDecoration(
                          labelText: 'Phường/Xã',
                          hintText: 'Ví dụ: Phường 1',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(
                            Icons.location_city,
                            color: Colors.brown,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.brown,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập phường/xã';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _districtController,
                        decoration: InputDecoration(
                          labelText: 'Quận/Huyện',
                          hintText: 'Ví dụ: Quận 1',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(
                            Icons.location_city,
                            color: Colors.brown,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.brown,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập quận/huyện';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration: InputDecoration(
                          labelText: 'Tỉnh/Thành phố',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(
                            Icons.location_city,
                            color: Colors.brown,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.brown,
                              width: 2,
                            ),
                          ),
                        ),
                        items:
                            _cities.map<DropdownMenuItem<String>>((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCity = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng chọn tỉnh/thành phố';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text(
                          'Đặt làm địa chỉ mặc định',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: _isDefaultAddress,
                        activeColor: Colors.brown,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? value) {
                          setState(() {
                            _isDefaultAddress = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _isEditing = false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('HỦY'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text('LƯU THAY ĐỔI'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
