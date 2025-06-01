import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:mockhang_app/admin/data/models/user_model.dart';
import 'package:shimmer/shimmer.dart';

class AccountPageAdmin extends StatefulWidget {
  const AccountPageAdmin({Key? key}) : super(key: key);

  @override
  State<AccountPageAdmin> createState() => _AccountPageAdminState();
}

class _AccountPageAdminState extends State<AccountPageAdmin> {
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<UserModel>? _filteredUsers;

  // Để lưu trữ người dùng đang được xem
  UserModel? _selectedUser;

  @override
  void initState() {
    super.initState();
    _loadUsers();

    // Thêm pagination khi cuộn xuống cuối danh sách
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreUsers();
    }
  }

  Future<void> _loadMoreUsers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!_isLoading && userProvider.allUsers.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        final lastUser = userProvider.allUsers.last;
        await userProvider.getAllUsersWithoutCheck(
          limit: 20,
          lastUser: lastUser,
        );

        // Nếu có tìm kiếm, áp dụng lại bộ lọc
        _applySearchFilter();
      } catch (e) {
        print('Error loading more users: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Đảm bảo đã khởi tạo
      if (!userProvider.isInitialized) {
        await userProvider.initialize();
      }

      // Làm mới dữ liệu
      await userProvider.refreshUserData();

      // Lấy tất cả người dùng với số lượng ban đầu giới hạn để tối ưu hiệu suất
      await userProvider.getAllUsersWithoutCheck(limit: 20);
    } catch (e) {
      print('Error loading users: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải danh sách người dùng: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applySearchFilter() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (_searchQuery.isEmpty) {
      _filteredUsers = null; // Sử dụng toàn bộ danh sách
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredUsers =
          userProvider.allUsers.where((user) {
            return user.fullName.toLowerCase().contains(query) ||
                user.email.toLowerCase().contains(query) ||
                (user.phoneNumber?.toLowerCase().contains(query) ?? false);
          }).toList();
    }
    setState(() {});
  }

  Future<void> _confirmDeleteUser(BuildContext context, UserModel user) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xác nhận xóa người dùng'),
            content: Text(
              'Bạn có chắc chắn muốn xóa người dùng "${user.fullName}" không? '
              'Hành động này không thể hoàn tác và sẽ xóa tất cả dữ liệu liên quan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Xóa'),
              ),
            ],
          ),
    );

    if (result == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.deleteUser(user.id);

        // Hiển thị thông báo thành công
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa người dùng ${user.fullName} thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Cập nhật lại bộ lọc tìm kiếm
        _applySearchFilter();
      } catch (e) {
        print('Error deleting user: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể xóa người dùng: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới danh sách',
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              await _loadUsers();
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final users = _filteredUsers ?? userProvider.allUsers;

          return Column(
            children: [
              _buildSearchBar(),
              _buildStatisticCards(users),
              const Divider(height: 1),
              Expanded(
                child:
                    _selectedUser != null
                        ? _buildUserDetailView()
                        : _buildUserListView(users, userProvider.isLoading),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo tên, email, số điện thoại...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _filteredUsers = null;
                      });
                    },
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _applySearchFilter();
          });
        },
      ),
    );
  }

  Widget _buildStatisticCards(List<UserModel> users) {
    final int totalUsers = users.length;
    final int completedProfiles =
        users.where((user) => user.isProfileCompleted).length;
    final int incompleteProfiles = totalUsers - completedProfiles;

    // Further reduce height by another 5px
    return Container(
      height: 85, // Reduced from 90 to 85
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 2.0,
      ), // Reduced vertical padding further
      child: Row(
        children: [
          _buildStatCard(
            "Tổng số",
            totalUsers.toString(),
            Icons.people,
            Colors.blue,
            const Color(0xFFE3F2FD),
          ),
          _buildStatCard(
            "Đã cập nhật",
            completedProfiles.toString(),
            Icons.check_circle,
            Colors.green,
            const Color(0xFFE8F5E9),
          ),
          _buildStatCard(
            "Chưa cập nhật",
            incompleteProfiles.toString(),
            Icons.warning,
            Colors.orange,
            const Color(0xFFFFF8E1),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    return Expanded(
      child: Card(
        elevation: 1, // Further reduced from 2 to 1
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ), // Reduced from 12 to 10
        color: bgColor,
        margin: const EdgeInsets.symmetric(
          horizontal: 3.0,
          vertical: 1.0,
        ), // Reduced margins
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 6.0,
            horizontal: 8.0,
          ), // Reduced vertical padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize:
                MainAxisSize.min, // Add this to minimize vertical space
            children: [
              Icon(icon, size: 18, color: color), // Reduced from 20 to 18
              const SizedBox(height: 2), // Reduced from 4 to 2
              Text(
                value,
                style: TextStyle(
                  fontSize: 16, // Reduced from 18 to 16
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              // Removed SizedBox here
              Text(
                title,
                style: TextStyle(
                  fontSize: 11, // Reduced from 12 to 11
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserListView(List<UserModel> users, bool isProviderLoading) {
    if (_isLoading && users.isEmpty) {
      return _buildShimmerList();
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Chưa có người dùng nào'
                  : 'Không tìm thấy người dùng phù hợp',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadUsers,
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: users.length + (isProviderLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == users.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final user = users[index];
              return _buildUserListTile(user);
            },
          ),
        ),
        if (_isLoading && users.isNotEmpty)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder:
            (_, __) => Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48.0,
                    height: 48.0,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16.0,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8.0),
                        Container(
                          width: 120.0,
                          height: 12.0,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildUserListTile(UserModel user) {
    final bool isCompleted = user.isProfileCompleted;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: Hero(
          tag: 'avatar-${user.id}',
          child: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[200],
            backgroundImage:
                user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child:
                user.avatarUrl == null
                    ? Icon(Icons.person, color: Colors.grey[600])
                    : null,
          ),
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.warning,
                  size: 16,
                  color: isCompleted ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  isCompleted ? 'Hồ sơ hoàn thiện' : 'Chưa cập nhật đầy đủ',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCompleted ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Thay đổi trailing từ Row thành Row với ConstrainedBox để giới hạn chiều rộng
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 100,
          ), // Giới hạn chiều rộng
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                tooltip: 'Xem chi tiết',
                padding: const EdgeInsets.all(4), // Giảm padding của button
                constraints: const BoxConstraints(), // Bỏ constraints mặc định
                onPressed: () {
                  setState(() {
                    _selectedUser = user;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Xóa người dùng',
                padding: const EdgeInsets.all(4), // Giảm padding của button
                constraints: const BoxConstraints(), // Bỏ constraints mặc định
                onPressed: () => _confirmDeleteUser(context, user),
              ),
            ],
          ),
        ),
        onTap: () {
          setState(() {
            _selectedUser = user;
          });
        },
      ),
    );
  }

  Widget _buildUserDetailView() {
    if (_selectedUser == null) return const SizedBox.shrink();

    final user = _selectedUser!;
    final bool isCompleted = user.isProfileCompleted;

    return WillPopScope(
      onWillPop: () async {
        setState(() {
          _selectedUser = null;
        });
        return false;
      },
      child: Column(
        children: [
          // Thanh công cụ
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            color: Colors.grey[100],
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedUser = null;
                    });
                  },
                ),
                const Text(
                  'Chi tiết người dùng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Xóa người dùng',
                  onPressed: () => _confirmDeleteUser(context, user),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin cơ bản
                  Center(
                    child: Column(
                      children: [
                        Hero(
                          tag: 'avatar-${user.id}',
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[200],
                            backgroundImage:
                                user.avatarUrl != null
                                    ? NetworkImage(user.avatarUrl!)
                                    : null,
                            child:
                                user.avatarUrl == null
                                    ? Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey[600],
                                    )
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(
                            isCompleted
                                ? 'Hồ sơ hoàn thiện'
                                : 'Chưa cập nhật đầy đủ',
                          ),
                          backgroundColor:
                              isCompleted
                                  ? Colors.green[100]
                                  : Colors.orange[100],
                          avatar: Icon(
                            isCompleted ? Icons.check_circle : Icons.warning,
                            color: isCompleted ? Colors.green : Colors.orange,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Thông tin chi tiết
                  _buildDetailSection('Thông tin cá nhân', [
                    _buildDetailItem('Họ tên:', user.fullName),
                    _buildDetailItem(
                      'Số điện thoại:',
                      user.phoneNumber ?? 'Chưa cập nhật',
                      isHighlighted: user.phoneNumber == null,
                    ),
                    _buildDetailItem(
                      'Địa chỉ:',
                      user.address ?? 'Chưa cập nhật',
                      isHighlighted: user.address == null,
                    ),
                  ]),

                  const SizedBox(height: 16),

                  _buildDetailSection('Thông tin tài khoản', [
                    _buildDetailItem('ID:', user.id),
                    _buildDetailItem(
                      'Vai trò:',
                      user.role == 'admin' ? 'Quản trị viên' : 'Người dùng',
                      textColor: user.role == 'admin' ? Colors.red : null,
                    ),
                    _buildDetailItem(
                      'Ngày tạo:',
                      '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                    ),
                    _buildDetailItem(
                      'Đăng nhập cuối:',
                      user.lastLogin != null
                          ? '${user.lastLogin!.day}/${user.lastLogin!.month}/${user.lastLogin!.year}'
                          : 'Chưa có',
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Nút xóa người dùng ở cuối trang
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmDeleteUser(context, user),
                      icon: const Icon(Icons.delete),
                      label: const Text('Xóa người dùng này'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Thêm khoảng cách dưới cùng
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value, {
    Color? textColor,
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isHighlighted ? Colors.orange : textColor,
                fontWeight: isHighlighted ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
