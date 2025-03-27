import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/pages/account_page_admin.dart';
import 'package:mockhang_app/admin/pages/category/category_page.dart';
import 'package:mockhang_app/admin/pages/cms_page.dart';
import 'package:mockhang_app/admin/pages/dashboard_page.dart';
import 'package:mockhang_app/admin/pages/delivery_page.dart';
import 'package:mockhang_app/admin/pages/notifications_page_admin.dart';
import 'package:mockhang_app/admin/pages/product/product_page.dart';
import 'package:mockhang_app/admin/pages/settings_page.dart';
import 'package:mockhang_app/admin/pages/support_page.dart' show SupportPage;
import 'package:mockhang_app/admin/pages/warehouse/warehouse_page.dart';
import 'package:mockhang_app/admin/widget/admin_drawer.dart';
import 'pages/discount/discount_page_admin.dart';
import 'pages/order/order_page.dart';
import 'pages/payments_page.dart' show PaymentsPage, PaymentsPageAdmin;
import 'pages/reports_page.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
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
    DeliveryPage(),
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
