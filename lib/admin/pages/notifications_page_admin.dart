import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationsPageAdmin extends StatefulWidget {
  @override
  _NotificationsPageAdminState createState() => _NotificationsPageAdminState();
}

class _NotificationsPageAdminState extends State<NotificationsPageAdmin> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Variables to store selected users
  List<String> _selectedUsers = [];
  bool _sendToAll = false;
  bool _isLoading = false;

  // Error handling variables
  String? _errorMessage;
  bool _showInitError = false;

  // List of users from Firestore
  List<Map<String, dynamic>> _usersList = [];

  // Colors for the theme
  final Color primaryColor = Color(0xFF2C3E50);
  final Color accentColor = Color(0xFF3498DB);
  final Color lightAccentColor = Color(0xFF85C1E9);
  final Color backgroundColor = Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    // Call fetchUsers without showing error message immediately
    _fetchUsers();
  }

  // Fetch users from Firestore
  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear any previous error
    });

    try {
      final QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      List<Map<String, dynamic>> users = [];
      for (var doc in usersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        users.add({
          'id': doc.id,
          'name': data['name'] ?? 'Người dùng không tên',
          'email': data['email'] ?? '',
        });
      }

      setState(() {
        _usersList = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể tải danh sách người dùng: $e';
        _showInitError = true; // Set flag to show error in build method
      });
      print('Error fetching users: $e');
    }
  }

  // Send notification to Firestore
  Future<void> sendNotification() async {
    // Check if title and message are filled
    if (_titleController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      _showSnackBar(
        'Vui lòng nhập đầy đủ tiêu đề và nội dung thông báo',
        isError: true,
      );
      return;
    }

    // Check if recipients are selected
    if (!_sendToAll && _selectedUsers.isEmpty) {
      _showSnackBar(
        'Vui lòng chọn ít nhất một người nhận hoặc chọn Gửi cho tất cả',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create new notification data
      final notificationData = {
        'title': _titleController.text,
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'sendToAll': _sendToAll,
        'recipients': _sendToAll ? ['all'] : _selectedUsers,
      };

      // Add notification to the notifications collection
      await FirebaseFirestore.instance
          .collection('notifications')
          .add(notificationData);

      // Handle specific user notifications
      if (!_sendToAll) {
        // Use batch to perform multiple operations at once
        WriteBatch batch = FirebaseFirestore.instance.batch();

        for (String userId in _selectedUsers) {
          DocumentReference userNotificationRef =
              FirebaseFirestore.instance.collection('user_notifications').doc();

          batch.set(userNotificationRef, {
            'userId': userId,
            'title': _titleController.text,
            'message': _messageController.text,
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });
        }

        await batch.commit();
      } else {
        // If sending to all users, create a record in global_notifications
        await FirebaseFirestore.instance
            .collection('global_notifications')
            .add({
              'title': _titleController.text,
              'message': _messageController.text,
              'timestamp': FieldValue.serverTimestamp(),
            });
      }

      // Reset form after successful send
      _titleController.clear();
      _messageController.clear();
      setState(() {
        _selectedUsers = [];
        _sendToAll = false;
        _isLoading = false;
      });

      _showSnackBar('Thông báo đã được gửi thành công!', isSuccess: true);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      _showSnackBar('Lỗi khi gửi thông báo: $e', isError: true);
    }
  }

  // Custom SnackBar method
  void _showSnackBar(
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    Color backgroundColor =
        isError ? Colors.red : (isSuccess ? Colors.green : primaryColor);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show user selection dialog
  void _showUserSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Row(
                children: [
                  Icon(Icons.people, color: primaryColor),
                  SizedBox(width: 10),
                  Text(
                    'Chọn người nhận thông báo',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_usersList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tổng số người dùng: ${_usersList.length}',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600],
                              ),
                            ),
                            TextButton.icon(
                              icon: Icon(
                                _selectedUsers.length == _usersList.length
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                size: 20,
                                color: accentColor,
                              ),
                              label: Text(
                                _selectedUsers.length == _usersList.length
                                    ? 'Bỏ chọn tất cả'
                                    : 'Chọn tất cả',
                                style: TextStyle(color: accentColor),
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_selectedUsers.length ==
                                      _usersList.length) {
                                    _selectedUsers.clear();
                                  } else {
                                    _selectedUsers =
                                        _usersList
                                            .map((user) => user['id'] as String)
                                            .toList();
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    Divider(height: 1),
                    Expanded(
                      child:
                          _isLoading
                              ? Center(
                                child: CircularProgressIndicator(
                                  color: accentColor,
                                ),
                              )
                              : _usersList.isEmpty
                              ? _buildEmptyUsersList()
                              : ListView.separated(
                                shrinkWrap: true,
                                itemCount: _usersList.length,
                                separatorBuilder:
                                    (context, index) => Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final user = _usersList[index];
                                  final userId = user['id'] as String;
                                  final userName = user['name'] as String;
                                  final userEmail = user['email'] as String;

                                  return CheckboxListTile(
                                    title: Text(
                                      userName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      userEmail,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    secondary: CircleAvatar(
                                      backgroundColor: lightAccentColor,
                                      child: Text(
                                        userName.isNotEmpty
                                            ? userName[0].toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    value: _selectedUsers.contains(userId),
                                    activeColor: accentColor,
                                    checkColor: Colors.white,
                                    onChanged: (bool? selected) {
                                      setState(() {
                                        if (selected == true) {
                                          if (!_selectedUsers.contains(
                                            userId,
                                          )) {
                                            _selectedUsers.add(userId);
                                          }
                                        } else {
                                          _selectedUsers.remove(userId);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Hủy', style: TextStyle(color: Colors.grey[700])),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Update main screen state
                    this.setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Xác nhận (${_selectedUsers.length})',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyUsersList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 48, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Không có người dùng nào',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.orange[700],
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              "Không thể tải danh sách người dùng",
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Vui lòng kiểm tra quyền truy cập Firestore trong Firebase Console",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh, color: Colors.white),
              label: Text(
                "Thử lại",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _fetchUsers,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if there is one and the flag is set
    if (_showInitError && _errorMessage != null) {
      // Use Future.microtask to schedule SnackBar after build is complete
      Future.microtask(() {
        _showSnackBar(_errorMessage!, isError: true);
        // Reset flag to prevent showing the error again
        setState(() {
          _showInitError = false;
        });
      });
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          "Quản lý thông báo",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchUsers,
            tooltip: 'Làm mới danh sách người dùng',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: accentColor),
                    SizedBox(height: 16),
                    Text(
                      "Đang tải dữ liệu...",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
              : (_usersList.isEmpty && !_isLoading)
              ? _buildErrorView()
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(),
                      SizedBox(height: 24),
                      _buildFormCard(),
                      SizedBox(height: 24),
                      _buildRecipientsCard(),
                      SizedBox(height: 32),
                      Center(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.send, color: Colors.white),
                          label: Text(
                            "Gửi thông báo",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          onPressed: sendNotification,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active, size: 48, color: Colors.white),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hệ thống thông báo",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Gửi thông báo đến người dùng đã đăng ký",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, color: primaryColor),
                SizedBox(width: 8),
                Text(
                  "Nội dung thông báo",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            Text(
              "Tiêu đề:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Nhập tiêu đề thông báo",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
                prefixIcon: Icon(Icons.title, color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Nội dung:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Nhập nội dung thông báo chi tiết...",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              textAlignVertical: TextAlignVertical.top,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: primaryColor),
                SizedBox(width: 8),
                Text(
                  "Người nhận thông báo",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            // Checkbox to send to all users
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color:
                    _sendToAll
                        ? lightAccentColor.withOpacity(0.2)
                        : Colors.transparent,
                border: Border.all(
                  color: _sendToAll ? lightAccentColor : Colors.transparent,
                  width: 1,
                ),
              ),
              child: CheckboxListTile(
                title: Text(
                  "Gửi cho tất cả người dùng",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _sendToAll ? primaryColor : Colors.grey[800],
                  ),
                ),
                subtitle: Text(
                  "Thông báo sẽ được gửi đến tất cả người dùng đã đăng ký",
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                secondary: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _sendToAll ? accentColor : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.people,
                    color: _sendToAll ? Colors.white : Colors.grey[600],
                  ),
                ),
                value: _sendToAll,
                onChanged: (bool? value) {
                  setState(() {
                    _sendToAll = value ?? false;
                    if (_sendToAll) {
                      _selectedUsers = [];
                    }
                  });
                },
                activeColor: accentColor,
                checkColor: Colors.white,
                controlAffinity: ListTileControlAffinity.trailing,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Button to select specific users
            if (!_sendToAll)
              Container(
                margin: EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Chọn người nhận cụ thể:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.person_add, color: Colors.white),
                            label: Text(
                              "Chọn người nhận",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _showUserSelectionDialog,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (_selectedUsers.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: lightAccentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: lightAccentColor, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: accentColor,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Đã chọn ${_selectedUsers.length} người dùng",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            TextButton(
                              child: Text(
                                "Xem lại",
                                style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: _showUserSelectionDialog,
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[200]!, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: Colors.red[400],
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Chưa chọn người nhận",
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
