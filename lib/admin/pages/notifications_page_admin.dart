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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập đầy đủ tiêu đề và nội dung thông báo'),
        ),
      );
      return;
    }

    // Check if recipients are selected
    if (!_sendToAll && _selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng chọn ít nhất một người nhận hoặc chọn Gửi cho tất cả',
          ),
        ),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thông báo đã được gửi thành công!')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi gửi thông báo: $e')));
    }
  }

  // Show user selection dialog
  void _showUserSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Chọn người nhận thông báo'),
              content: Container(
                width: double.maxFinite,
                child:
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : _usersList.isEmpty
                        ? Center(child: Text('Không có người dùng nào'))
                        : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _usersList.length,
                          itemBuilder: (context, index) {
                            final user = _usersList[index];
                            final userId = user['id'] as String;
                            final userName = user['name'] as String;
                            final userEmail = user['email'] as String;

                            return CheckboxListTile(
                              title: Text(userName),
                              subtitle: Text(userEmail),
                              value: _selectedUsers.contains(userId),
                              onChanged: (bool? selected) {
                                setState(() {
                                  if (selected == true) {
                                    if (!_selectedUsers.contains(userId)) {
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
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Update main screen state
                    this.setState(() {});
                  },
                  child: Text('Xác nhận (${_selectedUsers.length})'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if there is one and the flag is set
    if (_showInitError && _errorMessage != null) {
      // Use Future.microtask to schedule SnackBar after build is complete
      Future.microtask(() {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
        // Reset flag to prevent showing the error again
        setState(() {
          _showInitError = false;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Quản lý thông báo"),
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
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tiêu đề:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: "Nhập tiêu đề thông báo",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Nội dung:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Nhập nội dung thông báo",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                      ),
                      SizedBox(height: 24),
                      Text(
                        "Người nhận:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),

                      // Checkbox to send to all users
                      CheckboxListTile(
                        title: Text("Gửi cho tất cả người dùng"),
                        value: _sendToAll,
                        onChanged: (bool? value) {
                          setState(() {
                            _sendToAll = value ?? false;
                            if (_sendToAll) {
                              _selectedUsers = [];
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      // Button to select specific users
                      if (!_sendToAll)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              ElevatedButton.icon(
                                icon: Icon(Icons.person_add),
                                label: Text("Chọn người nhận"),
                                onPressed: _showUserSelectionDialog,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child:
                                    _selectedUsers.isNotEmpty
                                        ? Text(
                                          "Đã chọn ${_selectedUsers.length} người dùng",
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                          ),
                                        )
                                        : Text(
                                          "Chưa chọn người nhận",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 32),
                      Center(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.send),
                          label: Text("Gửi thông báo"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          onPressed: sendNotification,
                        ),
                      ),

                      // Show error message if users list is empty
                      if (_usersList.isEmpty && !_isLoading)
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange,
                                  size: 48,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Không thể tải danh sách người dùng",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Vui lòng kiểm tra quyền truy cập Firestore trong Firebase Console",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.refresh),
                                  label: Text("Thử lại"),
                                  onPressed: _fetchUsers,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
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
