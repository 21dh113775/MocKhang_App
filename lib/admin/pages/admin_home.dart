import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/pages/account_page_admin.dart';
import 'package:mockhang_app/admin/pages/discount/discount_page_admin.dart';
import 'package:mockhang_app/admin/pages/notifications_page_admin.dart';
import 'package:mockhang_app/admin/widget/admin_drawer.dart';
import 'dashboard_page.dart';
import 'category/category_page.dart';
import 'product/product_page.dart';
import 'warehouse/warehouse_page.dart';
import 'settings_page.dart';
import 'reports_page.dart';
import 'support_page.dart';
import 'payments_page.dart';
import 'delivery_page.dart';
import 'cms_page.dart';
import '../../admin/pages/order/order_page.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    AdminDashboardPage(),
    AccountPageAdmin(),
    CategoryPage(),
    ProductPageAdmin(),
    WarehousePage(),
    AdminOrdersPage(),
    SettingsPage(),
    ReportsPage(),
    SupportPage(),
    DiscountPageAdmin(),
    PaymentsPageAdmin(),
    DeliveryManagementPage(),
    NotificationsPageAdmin(),
    CMSPage(),
  ];

  void _onMenuSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Đóng menu sau khi chọn
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quản lý Admin")),
      drawer: AdminDrawer(onMenuSelected: _onMenuSelected),
      body: _pages[_selectedIndex],
    );
  }
}
