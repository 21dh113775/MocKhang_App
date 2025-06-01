import 'package:flutter/material.dart';

class CMSPage extends StatefulWidget {
  @override
  _CMSPageState createState() => _CMSPageState();
}

class _CMSPageState extends State<CMSPage> with SingleTickerProviderStateMixin {
  // Màu chủ đạo
  final Color primaryColor = Color(0xFF2C3E50);
  final Color accentColor = Color(0xFF3498DB);
  final Color lightBlue = Color(0xFFE1F5FE);

  // Dữ liệu mẫu cho các trang
  final List<Map<String, dynamic>> pages = [
    {
      'title': 'Trang chủ',
      'url': '/home',
      'lastUpdated': '28/03/2025',
      'status': 'Đã xuất bản',
      'type': 'Trang tĩnh',
    },
    {
      'title': 'Giới thiệu',
      'url': '/about',
      'lastUpdated': '25/03/2025',
      'status': 'Đã xuất bản',
      'type': 'Trang tĩnh',
    },
    {
      'title': 'Sản phẩm mới',
      'url': '/new-products',
      'lastUpdated': '29/03/2025',
      'status': 'Bản nháp',
      'type': 'Danh mục',
    },
    {
      'title': 'Khuyến mãi tháng 3',
      'url': '/promotions/march',
      'lastUpdated': '15/03/2025',
      'status': 'Đã xuất bản',
      'type': 'Bài viết',
    },
    {
      'title': 'Chính sách vận chuyển',
      'url': '/shipping-policy',
      'lastUpdated': '20/02/2025',
      'status': 'Đã xuất bản',
      'type': 'Trang tĩnh',
    },
    {
      'title': 'Hướng dẫn mua hàng',
      'url': '/shopping-guide',
      'lastUpdated': '10/03/2025',
      'status': 'Đã xuất bản',
      'type': 'Hướng dẫn',
    },
  ];

  // Dữ liệu mẫu cho các menu
  final List<Map<String, dynamic>> menus = [
    {
      'name': 'Menu chính',
      'items': 6,
      'location': 'Header',
      'lastUpdated': '25/03/2025',
    },
    {
      'name': 'Menu footer',
      'items': 4,
      'location': 'Footer',
      'lastUpdated': '15/03/2025',
    },
    {
      'name': 'Menu danh mục',
      'items': 8,
      'location': 'Sidebar',
      'lastUpdated': '20/03/2025',
    },
  ];

  // Tab controller
  TabController? _tabController;

  // Search query
  String _searchQuery = '';

  // Content type filter
  String _selectedContentType = 'Tất cả';
  final List<String> contentTypes = [
    'Tất cả',
    'Trang tĩnh',
    'Bài viết',
    'Danh mục',
    'Hướng dẫn',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Hiển thị Snackbar khi widget được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Trang quản lý nội dung đang trong quá trình cải tiến, chúng tôi sẽ cập nhật phiên bản mới sớm nhất!',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange[700],
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'ĐÓNG',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          "Quản lý nội dung",
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
          IconButton(icon: Icon(Icons.help_outline), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.account_circle_outlined),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [Tab(text: "Nội dung"), Tab(text: "Menu"), Tab(text: "Media")],
        ),
      ),
      drawer: _buildDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [_buildContentTab(), _buildMenuTab(), _buildMediaTab()],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Thêm nội dung mới
        },
        tooltip: 'Thêm nội dung mới',
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
            _buildDrawerItem(Icons.shopping_bag_outlined, 'Đơn hàng'),
            _buildDrawerItem(Icons.inventory_2_outlined, 'Sản phẩm'),
            _buildDrawerItem(Icons.local_shipping_outlined, 'Vận chuyển'),
            _buildDrawerItem(
              Icons.article_outlined,
              'Quản lý nội dung',
              isSelected: true,
            ),
            _buildDrawerItem(Icons.people_outline, 'Khách hàng'),
            _buildDrawerItem(Icons.bar_chart_outlined, 'Thống kê'),
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

  Widget _buildContentTab() {
    return Column(
      children: [
        _buildContentHeader(),
        _buildContentFilters(),
        Expanded(child: _buildContentList()),
      ],
    );
  }

  Widget _buildContentHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quản lý nội dung',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tạo, chỉnh sửa và quản lý nội dung trang web',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.add),
            label: Text('Thêm mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm nội dung...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
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
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Loại nội dung:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        contentTypes.map((type) {
                          return Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(type),
                              selected: _selectedContentType == type,
                              selectedColor: accentColor.withOpacity(0.2),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedContentType = type;
                                });
                              },
                              labelStyle: TextStyle(
                                color:
                                    _selectedContentType == type
                                        ? accentColor
                                        : Colors.grey[700],
                                fontWeight:
                                    _selectedContentType == type
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      color: Colors.white,
      child: ListView.separated(
        padding: EdgeInsets.all(0),
        itemCount: pages.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          return _buildContentItem(pages[index]);
        },
      ),
    );
  }

  Widget _buildContentItem(Map<String, dynamic> page) {
    Color statusColor;

    if (page['status'] == 'Đã xuất bản') {
      statusColor = Colors.green;
    } else if (page['status'] == 'Bản nháp') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.grey;
    }

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  page['title'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  page['url'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  page['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Cập nhật: ${page['lastUpdated']}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                page['type'],
                style: TextStyle(color: accentColor, fontSize: 12),
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: Colors.grey[600],
                size: 20,
              ),
              onPressed: () {},
              tooltip: 'Chỉnh sửa',
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
            SizedBox(width: 12),
            IconButton(
              icon: Icon(
                Icons.copy_outlined,
                color: Colors.grey[600],
                size: 20,
              ),
              onPressed: () {},
              tooltip: 'Sao chép',
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
            SizedBox(width: 12),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.grey[600],
                size: 20,
              ),
              onPressed: () {},
              tooltip: 'Xóa',
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ),
      ),
      onTap: () {},
    );
  }

  Widget _buildMenuTab() {
    return Column(
      children: [_buildMenuHeader(), Expanded(child: _buildMenuList())],
    );
  }

  Widget _buildMenuHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quản lý menu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tạo và quản lý menu cho trang web',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.add),
            label: Text('Thêm menu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: ListView.builder(
        itemCount: menus.length,
        itemBuilder: (context, index) {
          return _buildMenuItem(menus[index]);
        },
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> menu) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu, color: primaryColor),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    menu['name'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(child: Text('Chỉnh sửa'), value: 'edit'),
                        PopupMenuItem(child: Text('Xóa'), value: 'delete'),
                      ],
                  onSelected: (value) {},
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildMenuInfoItem('Vị trí', menu['location']),
                SizedBox(width: 16),
                _buildMenuInfoItem('Số mục', '${menu['items']} mục'),
                SizedBox(width: 16),
                _buildMenuInfoItem('Cập nhật', menu['lastUpdated']),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  child: Text('Xem trước'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Chỉnh sửa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuInfoItem(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildMediaTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Thư viện Media',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tính năng này sẽ có mặt trong phiên bản cập nhật sắp tới',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.upload_file),
            label: Text('Tải lên tệp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
