// screens/support_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mockhang_app/admin/data/models/consultation_request.dart';
import 'package:mockhang_app/admin/data/service/consultation_service.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Thêm thư viện để tối ưu hiển thị ảnh

class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<ConsultationRequest> _allRequests = [];

  // Định nghĩa màu chủ đạo
  final Color primaryColor = Color(0xFF2C3E50);
  final Color secondaryColor = Color(0xFF34495E);
  final Color accentColor = Color(0xFF3498DB);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRequests();

    // Tối ưu hóa việc lắng nghe: sử dụng .distinct() để tránh render lại khi dữ liệu không thay đổi
    ConsultationService.requestsStream
        .distinct(
          (previous, current) =>
              previous.length == current.length &&
              previous.every(
                (prev) => current.any(
                  (curr) =>
                      prev.id == curr.id && prev.isHandled == curr.isHandled,
                ),
              ),
        )
        .listen((requests) {
          if (mounted) {
            setState(() {
              _allRequests = requests;
            });
          }
        });

    // Thêm listener để phản hồi khi tab thay đổi
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        FocusScope.of(context).unfocus(); // Ẩn bàn phím khi chuyển tab
      }
    });
  }

  Future<void> _loadRequests() async {
    try {
      final requests = ConsultationService.getAllRequests();
      if (mounted) {
        setState(() {
          _allRequests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải dữ liệu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tách logic tính toán ra khỏi build method để tăng hiệu suất
    final pendingRequests =
        _allRequests.where((req) => !req.isHandled).toList();
    final handledRequests = _allRequests.where((req) => req.isHandled).toList();

    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: primaryColor,
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            "Hỗ trợ khách hàng",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _loadRequests();
              },
              tooltip: 'Tải lại dữ liệu',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: accentColor,
            indicatorWeight: 3.0,
            tabs: [
              Tab(
                child: _buildTabLabel(
                  "Yêu cầu chờ",
                  pendingRequests.length,
                  Colors.orange,
                ),
              ),
              Tab(
                child: _buildTabLabel(
                  "Đã xử lý",
                  handledRequests.length,
                  Colors.green,
                ),
              ),
            ],
          ),
        ),
        body:
            _isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                )
                : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRequestsList(pendingRequests, isPending: true),
                    _buildRequestsList(handledRequests, isPending: false),
                  ],
                ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: accentColor,
          child: Icon(Icons.filter_list),
          onPressed: () {
            _showFilterOptions();
          },
          tooltip: 'Lọc yêu cầu',
        ),
      ),
    );
  }

  Widget _buildTabLabel(String title, int count, Color badgeColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        SizedBox(width: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestsList(
    List<ConsultationRequest> requests, {
    required bool isPending,
  }) {
    if (requests.isEmpty) {
      return _buildEmptyState(isPending);
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: _loadRequests,
      child: ListView.builder(
        itemCount: requests.length,
        padding: EdgeInsets.all(12),
        physics: AlwaysScrollableScrollPhysics(), // Cho phép pull-to-refresh
        itemBuilder: (context, index) {
          // Sử dụng const để tối ưu hiệu suất render
          return _buildRequestCard(requests[index], isPending);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isPending) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPending ? Icons.mark_email_unread_outlined : Icons.task_alt,
            size: 72,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            isPending
                ? "Không có yêu cầu đang chờ"
                : "Không có yêu cầu đã xử lý",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            isPending
                ? "Tất cả yêu cầu hỗ trợ đã được xử lý"
                : "Yêu cầu đã xử lý sẽ xuất hiện ở đây",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          SizedBox(height: 24),
          OutlinedButton.icon(
            icon: Icon(Icons.refresh),
            label: Text("Tải lại"),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadRequests();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(ConsultationRequest request, bool isPending) {
    final formattedDate = DateFormat(
      'dd/MM/yyyy - HH:mm',
    ).format(request.timestamp);
    final statusColor = request.isHandled ? Colors.green : Colors.orange;
    final nameInitial =
        request.name.isNotEmpty ? request.name[0].toUpperCase() : "?";

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isPending
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: EdgeInsets.all(0),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Text(
          request.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: primaryColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    request.topic,
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        leading: Hero(
          tag: 'avatar-${request.id}',
          child: CircleAvatar(
            backgroundColor: statusColor,
            child: Text(
              nameInitial,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            request.isHandled ? "Đã xử lý" : "Chờ xử lý",
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.phone, "Số điện thoại", request.phone),
                SizedBox(height: 12),
                if (request.email.isNotEmpty) ...[
                  _buildInfoRow(Icons.email, "Email", request.email),
                  SizedBox(height: 12),
                ],
                _buildInfoRow(Icons.message, "Nội dung", request.message),
                SizedBox(height: 20),
                _buildActionButtons(request),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: primaryColor),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                SelectableText(
                  value,
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ],
            ),
          ),
          if (label == "Số điện thoại" || label == "Email") ...[
            IconButton(
              icon: Icon(
                label == "Số điện thoại"
                    ? Icons.content_copy
                    : Icons.email_outlined,
                size: 18,
                color: accentColor,
              ),
              onPressed: () {
                // Copy to clipboard hoặc mở ứng dụng email
              },
              tooltip: label == "Số điện thoại" ? "Sao chép" : "Gửi email",
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(ConsultationRequest request) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          icon: Icon(Icons.phone),
          label: Text("Gọi"),
          onPressed: () {
            // Thêm chức năng gọi điện
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: accentColor,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            side: BorderSide(color: accentColor),
          ),
        ),
        SizedBox(width: 12),
        ElevatedButton.icon(
          icon: Icon(
            request.isHandled ? Icons.restore : Icons.check_circle,
            size: 18,
          ),
          label: Text(
            request.isHandled ? "Đánh dấu chưa xử lý" : "Đánh dấu đã xử lý",
          ),
          onPressed: () {
            // Thêm hiệu ứng loading khi xử lý
            setState(() {
              _isLoading = true;
            });

            // Giả lập delay xử lý để UX tốt hơn
            Future.delayed(Duration(milliseconds: 300), () {
              ConsultationService.updateRequestStatus(
                request.id,
                !request.isHandled,
              );

              setState(() {
                _isLoading = false;
              });

              // Hiển thị thông báo
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    request.isHandled
                        ? "Đã chuyển trạng thái sang chưa xử lý"
                        : "Đã đánh dấu yêu cầu là đã xử lý",
                  ),
                  backgroundColor:
                      request.isHandled ? Colors.orange : Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: request.isHandled ? Colors.grey[600] : accentColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Lọc yêu cầu hỗ trợ",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 20),
                // Thêm các tùy chọn lọc ở đây
                ListTile(
                  leading: Icon(Icons.date_range, color: accentColor),
                  title: Text("Lọc theo ngày"),
                  onTap: () {
                    Navigator.pop(context);
                    // Hiển thị date picker
                  },
                ),
                ListTile(
                  leading: Icon(Icons.category, color: accentColor),
                  title: Text("Lọc theo chủ đề"),
                  onTap: () {
                    Navigator.pop(context);
                    // Hiển thị danh sách chủ đề
                  },
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Đóng"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: Size(200, 45),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
