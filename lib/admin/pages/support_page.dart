// screens/support_page.dart (cập nhật từ code bạn cung cấp)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần thêm thư viện intl
import 'package:mockhang_app/admin/data/models/consultation_request.dart';
import 'package:mockhang_app/admin/data/service/consultation_service.dart';

class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<ConsultationRequest> _allRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRequests();

    // Lắng nghe các thay đổi từ service
    ConsultationService.requestsStream.listen((requests) {
      setState(() {
        _allRequests = requests;
      });
    });
  }

  void _loadRequests() async {
    // Trong thực tế, bạn sẽ tải dữ liệu từ backend
    setState(() {
      _allRequests = ConsultationService.getAllRequests();
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingRequests =
        _allRequests.where((req) => !req.isHandled).toList();
    final handledRequests = _allRequests.where((req) => req.isHandled).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Hỗ trợ khách hàng"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Yêu cầu chờ (${pendingRequests.length})"),
            Tab(text: "Đã xử lý (${handledRequests.length})"),
          ],
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Yêu cầu chờ xử lý
                  _buildRequestsList(pendingRequests),
                  // Tab 2: Yêu cầu đã xử lý
                  _buildRequestsList(handledRequests),
                ],
              ),
    );
  }

  Widget _buildRequestsList(List<ConsultationRequest> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_email_unread_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "Không có yêu cầu nào",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: requests.length,
      padding: EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final request = requests[index];
        final formattedDate = DateFormat(
          'dd/MM/yyyy - HH:mm',
        ).format(request.timestamp);

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              request.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "${request.topic} • $formattedDate",
              style: TextStyle(fontSize: 12),
            ),
            leading: CircleAvatar(
              backgroundColor: request.isHandled ? Colors.green : Colors.orange,
              child: Icon(
                request.isHandled ? Icons.check : Icons.hourglass_empty,
                color: Colors.white,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(Icons.phone, "Số điện thoại", request.phone),
                    SizedBox(height: 8),
                    if (request.email.isNotEmpty) ...[
                      _infoRow(Icons.email, "Email", request.email),
                      SizedBox(height: 8),
                    ],
                    _infoRow(Icons.message, "Nội dung", request.message),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          icon: Icon(Icons.phone),
                          label: Text("Gọi"),
                          onPressed: () {
                            // Thêm chức năng gọi điện
                          },
                        ),
                        SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: Icon(
                            request.isHandled
                                ? Icons.restore
                                : Icons.check_circle,
                          ),
                          label: Text(
                            request.isHandled
                                ? "Đánh dấu chưa xử lý"
                                : "Đánh dấu đã xử lý",
                          ),
                          onPressed: () {
                            ConsultationService.updateRequestStatus(
                              request.id,
                              !request.isHandled,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                request.isHandled
                                    ? Colors.grey
                                    : Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}
