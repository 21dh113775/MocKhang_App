import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DeliveryManagementPage extends StatefulWidget {
  @override
  _DeliveryManagementPageState createState() => _DeliveryManagementPageState();
}

class _DeliveryManagementPageState extends State<DeliveryManagementPage> {
  // Màu chủ đạo
  final Color primaryColor = Color(0xFF2C3E50);
  final Color accentColor = Color(0xFF3498DB);
  final Color successColor = Color(0xFF27AE60);
  final Color warningColor = Color(0xFFF39C12);
  final Color dangerColor = Color(0xFFE74C3C);

  // Dữ liệu mẫu cho đơn hàng
  final List<Map<String, dynamic>> deliveries = [
    {
      'id': 'DH001',
      'customer': 'Nguyễn Văn A',
      'address': 'Quận 1, TP HCM',
      'date': '25/03/2025',
      'status': 'Đang giao',
      'amount': '1,250,000 đ',
    },
    {
      'id': 'DH002',
      'customer': 'Trần Thị B',
      'address': 'Quận 7, TP HCM',
      'date': '26/03/2025',
      'status': 'Chờ xác nhận',
      'amount': '850,000 đ',
    },
    {
      'id': 'DH003',
      'customer': 'Lê Văn C',
      'address': 'Quận Cầu Giấy, Hà Nội',
      'date': '27/03/2025',
      'status': 'Đã giao',
      'amount': '2,100,000 đ',
    },
    {
      'id': 'DH004',
      'customer': 'Phạm Thị D',
      'address': 'Quận 2, TP HCM',
      'date': '28/03/2025',
      'status': 'Đã hủy',
      'amount': '750,000 đ',
    },
    {
      'id': 'DH005',
      'customer': 'Hoàng Văn E',
      'address': 'Quận Hai Bà Trưng, Hà Nội',
      'date': '29/03/2025',
      'status': 'Đang giao',
      'amount': '1,450,000 đ',
    },
  ];

  // Chỉ mục tab hiện tại
  int _selectedTabIndex = 0;

  // Bộ lọc
  String _selectedStatus = 'Tất cả';
  String _searchQuery = '';

  // Danh sách trạng thái
  final List<String> statuses = [
    'Tất cả',
    'Chờ xác nhận',
    'Đang giao',
    'Đã giao',
    'Đã hủy',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          "Quản lý vận chuyển",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(icon: Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildTopStats(),
          _buildFilterSection(),
          _buildTabs(),
          Expanded(child: _buildDeliveryList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Thêm đơn hàng mới
        },
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: primaryColor),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'admin@example.com',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.dashboard_outlined, 'Trang chủ'),
            _buildDrawerItem(Icons.inventory_2_outlined, 'Sản phẩm'),
            _buildDrawerItem(Icons.shopping_bag_outlined, 'Đơn hàng'),
            _buildDrawerItem(
              Icons.local_shipping_outlined,
              'Vận chuyển',
              isSelected: true,
            ),
            _buildDrawerItem(Icons.people_outline, 'Khách hàng'),
            _buildDrawerItem(Icons.bar_chart_outlined, 'Báo cáo'),
            Divider(),
            _buildDrawerItem(Icons.settings_outlined, 'Cài đặt'),
            _buildDrawerItem(Icons.help_outline, 'Trợ giúp'),
            _buildDrawerItem(Icons.logout, 'Đăng xuất'),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title, {
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? accentColor : Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? accentColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {},
      selected: isSelected,
    );
  }

  Widget _buildTopStats() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan vận chuyển',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              _buildStatCard(
                'Đơn hàng mới',
                '12',
                Icons.new_releases_outlined,
                accentColor,
              ),
              _buildStatCard(
                'Đang giao',
                '28',
                Icons.delivery_dining,
                warningColor,
              ),
              _buildStatCard(
                'Hoàn thành',
                '156',
                Icons.check_circle_outline,
                successColor,
              ),
              _buildStatCard('Đã hủy', '8', Icons.cancel_outlined, dangerColor),
            ],
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
  ) {
    return Expanded(
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 18),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm đơn hàng, khách hàng...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  statuses.map((status) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: _selectedStatus == status,
                        selectedColor: accentColor.withOpacity(0.2),
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = status;
                          });
                        },
                        labelStyle: TextStyle(
                          color:
                              _selectedStatus == status
                                  ? accentColor
                                  : Colors.grey[700],
                          fontWeight:
                              _selectedStatus == status
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 10),
      child: Row(
        children: [
          _buildTab('Tất cả đơn', 0),
          _buildTab('Trong ngày', 1),
          _buildTab('Tuần này', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    bool isSelected = _selectedTabIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? primaryColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 3,
              color: isSelected ? primaryColor : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryList() {
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        final delivery = deliveries[index];
        return _buildDeliveryCard(delivery);
      },
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> delivery) {
    Color statusColor;
    IconData statusIcon;

    switch (delivery['status']) {
      case 'Đang giao':
        statusColor = warningColor;
        statusIcon = Icons.local_shipping;
        break;
      case 'Đã giao':
        statusColor = successColor;
        statusIcon = Icons.check_circle;
        break;
      case 'Chờ xác nhận':
        statusColor = accentColor;
        statusIcon = Icons.pending;
        break;
      case 'Đã hủy':
        statusColor = dangerColor;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        childrenPadding: EdgeInsets.all(16),
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.1),
          child: Text(
            delivery['id'].substring(2),
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          delivery['customer'],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              '${delivery['date']} | ${delivery['amount']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                SizedBox(width: 4),
                Text(
                  delivery['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.keyboard_arrow_down, color: primaryColor),
        children: [
          Divider(),
          _buildDeliveryDetail(
            'Địa chỉ giao hàng',
            delivery['address'],
            Icons.location_on_outlined,
          ),
          SizedBox(height: 12),
          _buildDeliveryDetail(
            'Mã đơn hàng',
            delivery['id'],
            Icons.numbers_outlined,
          ),
          SizedBox(height: 12),
          _buildDeliveryDetail(
            'Ngày đặt hàng',
            delivery['date'],
            Icons.calendar_today_outlined,
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.edit_outlined, size: 16),
                label: Text('Sửa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.visibility_outlined, size: 16),
                label: Text('Chi tiết'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey[600])),
        Expanded(
          child: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
