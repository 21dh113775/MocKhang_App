// home_screen.dart
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/pages/account_page.dart';
import 'package:mockhang_app/admin/providers/category_provider.dart';
import 'package:mockhang_app/admin/providers/product_provider.dart';
import 'package:mockhang_app/user/pages/cart/cart_page.dart';
import 'package:mockhang_app/user/pages/consultation_page.dart';
import 'package:mockhang_app/user/pages/discount_page_user.dart';
import 'package:mockhang_app/user/pages/home/banner_section.dart';
import 'package:mockhang_app/user/pages/home/category_section.dart';
import 'package:mockhang_app/user/pages/home/product_section.dart';
import 'package:mockhang_app/user/pages/home/search_bar.dart';
import 'package:mockhang_app/user/widgets/bottom_nav_bar_widget.dart';
import 'package:mockhang_app/user/widgets/drawer_widget.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  bool _isCategoryLoading = true;
  String? _categoryError;
  bool _isProductLoading = true;
  String? _productError;

  // Biến state cho bottom nav bar
  int _currentIndex = 0;

  // Danh sách các trang nội dung
  final List<Widget> _pages = [
    Container(), // Placeholder cho trang chủ
    const DiscountPageUser(), // Trang Khuyến Mãi
    ConsultationPage(), // Trang Liên Hệ
    const CartPage(), // Trang Giỏ Hàng
    AccountPage(), // Trang Tài Khoản
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadCategories(), _loadProducts()]);
  }

  Future<void> _loadCategories() async {
    try {
      final catProvider = Provider.of<CategoryProvider>(context, listen: false);
      await catProvider.fetchCategories();
      setState(() {
        _isCategoryLoading = false;
      });
    } catch (error) {
      setState(() {
        _isCategoryLoading = false;
        _categoryError = error.toString();
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      await productProvider.fetchProducts();
      setState(() {
        _isProductLoading = false;
      });
    } catch (error) {
      setState(() {
        _isProductLoading = false;
        _productError = error.toString();
      });
    }
  }

  // Widget chính cho trang Home
  Widget _buildHomePage() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.brown,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeSearchBar(onSubmitted: null),
            const BannerSection(),
            const SizedBox(height: 16),
            CategorySection(
              isLoading: _isCategoryLoading,
              error: _categoryError,
              categories: Provider.of<CategoryProvider>(context).categories,
              onRefresh: _loadData,
            ),
            const SizedBox(height: 16),
            ProductSection(
              isLoading: _isProductLoading,
              error: _productError,
              products: Provider.of<ProductProvider>(context).products,
              onRefresh: _loadData,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cấu hình trang chủ (index 0)
    _pages[0] = _buildHomePage();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phong Thuỷ Shop'),
        centerTitle: true,
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      drawer: const DrawerWidget(),
      // Hiển thị trang tương ứng với tab được chọn
      body: _pages[_currentIndex],
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  // Scroll to top functionality
                  Scrollable.ensureVisible(
                    context,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                backgroundColor: Colors.brown,
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              )
              : null,
      bottomNavigationBar: BottomNavBarWidget(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        showLabels: false, // Không hiển thị nhãn dưới NavBar
      ),
    );
  }
}
