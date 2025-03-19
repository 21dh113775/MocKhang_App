import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart'; // Make sure to add this package to your pubspec.yaml

class NotificationsPageUser extends StatefulWidget {
  const NotificationsPageUser({Key? key}) : super(key: key);

  @override
  _NotificationsPageUserState createState() => _NotificationsPageUserState();
}

class _NotificationsPageUserState extends State<NotificationsPageUser>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  late String userId;

  @override
  void initState() {
    super.initState();
    // Initialize the user ID
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _tabController = TabController(length: 2, vsync: this);
    // Mark notifications as read when opening the page
    if (userId.isNotEmpty) {
      _markNotificationsAsRead();
    }
  }

  // Mark notifications as read
  Future<void> _markNotificationsAsRead() async {
    try {
      // Get all unread personal notifications
      final unreadNotificationsQuery =
          await FirebaseFirestore.instance
              .collection('user_notifications')
              .where('userId', isEqualTo: userId)
              .where('read', isEqualTo: false)
              .get();

      // Update read status
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in unreadNotificationsQuery.docs) {
        batch.update(doc.reference, {'read': true});
      }

      // Commit changes
      await batch.commit();
    } catch (e) {
      print('Lỗi khi đánh dấu thông báo đã đọc: $e');
    }
  }

  // Format timestamp
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Chưa có thời gian';

    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hôm nay lúc ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Hôm qua lúc ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thông báo"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: "Tất cả"), Tab(text: "Cá nhân")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCombinedNotificationsList(),
          _buildPersonalNotificationsList(),
        ],
      ),
    );
  }

  // Combined notifications list
  Widget _buildCombinedNotificationsList() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _isLoading = true;
            });
            await Future.delayed(Duration(milliseconds: 800));
            setState(() {
              _isLoading = false;
            });
          },
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchAllNotifications(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Bạn chưa có thông báo nào",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              final notifications = snapshot.data!;
              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationCard(notifications[index]);
                },
              );
            },
          ),
        );
  }

  // Fetch all notifications from different collections
  Future<List<Map<String, dynamic>>> _fetchAllNotifications() async {
    List<Map<String, dynamic>> allNotifications = [];

    try {
      // Get notifications where recipients contains userId or 'all'
      final QuerySnapshot generalNotificationsSnapshot =
          await FirebaseFirestore.instance
              .collection('notifications')
              .orderBy('timestamp', descending: true)
              .get();

      for (var doc in generalNotificationsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List? recipients = data['recipients'] as List?;

        if (recipients != null &&
            (recipients.contains(userId) || recipients.contains('all'))) {
          allNotifications.add(data);
        }
      }

      // Get user-specific notifications
      final QuerySnapshot personalNotificationsSnapshot =
          await FirebaseFirestore.instance
              .collection('user_notifications')
              .where('userId', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .get();

      for (var doc in personalNotificationsSnapshot.docs) {
        allNotifications.add(doc.data() as Map<String, dynamic>);
      }

      // Get global notifications
      final QuerySnapshot globalNotificationsSnapshot =
          await FirebaseFirestore.instance
              .collection('global_notifications')
              .orderBy('timestamp', descending: true)
              .get();

      for (var doc in globalNotificationsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Add recipients field to match format of other notifications
        data['recipients'] = ['all'];
        allNotifications.add(data);
      }

      // Sort by timestamp (newest first)
      allNotifications.sort((a, b) {
        final aTimestamp = a['timestamp'] as Timestamp?;
        final bTimestamp = b['timestamp'] as Timestamp?;
        if (aTimestamp == null) return 1;
        if (bTimestamp == null) return -1;
        return bTimestamp.compareTo(aTimestamp);
      });

      // Limit to 50 notifications
      if (allNotifications.length > 50) {
        allNotifications = allNotifications.sublist(0, 50);
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }

    return allNotifications;
  }

  // Personal notifications list
  Widget _buildPersonalNotificationsList() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _isLoading = true;
            });
            await Future.delayed(Duration(milliseconds: 800));
            setState(() {
              _isLoading = false;
            });
          },
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('user_notifications')
                    .where('userId', isEqualTo: userId)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mark_email_unread,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Bạn chưa có thông báo cá nhân nào",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var notification = snapshot.data!.docs[index];
                  Map<String, dynamic> data =
                      notification.data() as Map<String, dynamic>;

                  return _buildNotificationCard(data);
                },
              );
            },
          ),
        );
  }

  // Notification card
  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    // Check if this is a personal notification
    final bool isPersonal =
        notification['recipients'] == null ||
        (notification['recipients'] is List &&
            (notification['recipients'] as List).contains(userId) &&
            !(notification['recipients'] as List).contains('all'));

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: InkWell(
        onTap: () {
          _showNotificationDetail(notification);
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isPersonal ? Icons.person : Icons.public,
                    color: isPersonal ? Colors.blue : Colors.green,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notification['title'] ?? 'Không có tiêu đề',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                notification['message'] ?? 'Không có nội dung',
                style: TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTimestamp(notification['timestamp']),
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  if (notification.containsKey('read') &&
                      notification['read'] == false)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show notification detail
  void _showNotificationDetail(Map<String, dynamic> notification) {
    // If this is a user_notification, mark it as read
    if (notification.containsKey('userId') &&
        notification.containsKey('read') &&
        notification['read'] == false) {
      // Find the document and update it
      FirebaseFirestore.instance
          .collection('user_notifications')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isEqualTo: notification['timestamp'])
          .get()
          .then((querySnapshot) {
            for (var doc in querySnapshot.docs) {
              doc.reference.update({'read': true});
            }
          });
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(notification['title'] ?? 'Không có tiêu đề'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(notification['message'] ?? 'Không có nội dung'),
                  SizedBox(height: 16),
                  Text(
                    _formatTimestamp(notification['timestamp']),
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Đóng'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
