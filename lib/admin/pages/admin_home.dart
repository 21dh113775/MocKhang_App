import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'account_page.dart';
import 'category/category_page.dart';
import 'product/product_page.dart';
import 'warehouse/warehouse_page.dart';
import 'order_page.dart';
import 'settings_page.dart';
import 'reports_page.dart';
import 'support_page.dart';
import 'discount/discount_page.dart';
import 'payments_page.dart';
import 'delivery_page.dart';
import 'notifications_page.dart';
import 'cms_page.dart';
import '../widgets/admin_drawer.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    AccountPage(),
    CategoryPage(),
    ProductPage(),
    WarehousePage(),
    OrderPage(),
    SettingsPage(),
    ReportsPage(),
    SupportPage(),
    DiscountPage(),
    PaymentsPage(),
    DeliveryPage(),
    NotificationsPage(),
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
