import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:mockhang_app/admin/data/models/user_model.dart';

class AccountPageAdmin extends StatefulWidget {
  const AccountPageAdmin({Key? key}) : super(key: key);

  @override
  State<AccountPageAdmin> createState() => _AccountPageAdminState();
}

class _AccountPageAdminState extends State<AccountPageAdmin> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Ensure initialization
      if (!userProvider.isInitialized) {
        await userProvider.initialize();
      }

      // Refresh data to ensure we have current user info
      await userProvider.refreshUserData();

      // ĐÃ XÓA đoạn kiểm tra quyền admin

      // Get all users
      await userProvider.getAllUsersWithoutCheck();
    } catch (e) {
      print('Error loading users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách người dùng: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              await _loadUsers(); // Refresh users
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = userProvider.allUsers;

          if (users.isEmpty) {
            return const Center(child: Text('Không có người dùng nào'));
          }

          return Column(
            children: [
              _buildStatisticCards(users),
              const Divider(),
              Expanded(child: _buildUserList(users)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatisticCards(List<UserModel> users) {
    final int totalUsers = users.length;
    final int completedProfiles =
        users.where((user) => user.isProfileCompleted).length;
    final int incompleteProfiles = totalUsers - completedProfiles;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildStatCard("Tổng số", totalUsers.toString(), Colors.blue),
          _buildStatCard(
            "Đã cập nhật",
            completedProfiles.toString(),
            Colors.green,
          ),
          _buildStatCard(
            "Chưa cập nhật",
            incompleteProfiles.toString(),
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            backgroundImage:
                user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null ? const Icon(Icons.person) : null,
          ),
          title: Text(user.fullName),
          subtitle: Text(user.email),
          trailing: Icon(
            user.isProfileCompleted ? Icons.check_circle : Icons.warning,
            color: user.isProfileCompleted ? Colors.green : Colors.orange,
          ),
          onTap: () => _showUserDetailsDialog(context, user),
        );
      },
    );
  }

  void _showUserDetailsDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thông tin chi tiết: ${user.fullName}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (user.avatarUrl != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(user.avatarUrl!),
                      ),
                    ),
                  ),
                _buildDetailItem('ID:', user.id),
                _buildDetailItem('Email:', user.email),
                _buildDetailItem('Họ tên:', user.fullName),
                _buildDetailItem(
                  'Số điện thoại:',
                  user.phoneNumber ?? 'Chưa cập nhật',
                ),
                _buildDetailItem('Địa chỉ:', user.address ?? 'Chưa cập nhật'),
                _buildDetailItem(
                  'Vai trò:',
                  user.role == 'admin' ? 'Quản trị viên' : 'Người dùng',
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
                _buildDetailItem(
                  'Trạng thái hồ sơ:',
                  user.isProfileCompleted ? 'Đã hoàn thành' : 'Chưa hoàn thành',
                  textColor:
                      user.isProfileCompleted ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Đóng'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(color: textColor))),
        ],
      ),
    );
  }
}
