// home_screen.dart
import 'package:flutter/material.dart';

import 'package:mockhang_app/admin/providers/category_provider.dart';
import 'package:mockhang_app/admin/providers/product_provider.dart';
import 'package:mockhang_app/user/pages/account_page_user.dart';
import 'package:mockhang_app/user/pages/cart/cart_page.dart';
import 'package:mockhang_app/user/pages/consultation_page.dart';
import 'package:mockhang_app/user/pages/discount/discount_page_user.dart';
import 'package:mockhang_app/user/pages/home/widget/banner_section.dart';
import 'package:mockhang_app/user/pages/home/widget/category_section.dart';
import 'package:mockhang_app/user/pages/home/productsection/product_section.dart';
import 'package:mockhang_app/user/pages/home/widget/search_bar.dart';
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
    DiscountPageUser(), // Trang Khuyến Mãi
    ConsultationPage(), // Trang Liên Hệ
    CartPage(), // Trang Giỏ Hàng
    AccountPageUser(), // Trang Tài Khoản
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
      backgroundColor: Colors.white,
      color: Colors.brown,
      strokeWidth: 3.0,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                return HomeSearchBar(
                  initialValue: productProvider.searchQuery,
                  onSearch: (query) {
                    productProvider.searchProducts(query);
                  },
                  onReset: () {
                    productProvider.resetSearch();
                  },
                );
              },
            ),
            const BannerSection(),
            const SizedBox(height: 16),
            CategorySection(
              isLoading: _isCategoryLoading,
              error: _categoryError,
              categories: Provider.of<CategoryProvider>(context).categories,
              onRefresh: _loadData,
            ),
            const SizedBox(height: 16),
            Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                return ProductSection(
                  isLoading: _isProductLoading,
                  error: _productError,
                  // Sử dụng danh sách lọc thay vì toàn bộ sản phẩm
                  products: productProvider.filteredProducts,
                  onRefresh: _loadData,
                );
              },
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
      // Thay đổi phần body để luôn hiển thị bottom nav bar
      body: Stack(
        children: [
          // Trang nội dung hiện tại
          Positioned.fill(child: _pages[_currentIndex]),

          // Floating Action Button (nếu ở trang chủ)
          if (_currentIndex == 0)
            Positioned(
              bottom: 80, // Điều chỉnh vị trí so với bottom nav bar
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  PrimaryScrollController.of(context).animateTo(
                    0.0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOutQuad,
                  );
                },
                backgroundColor: Colors.brown[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.arrow_upward, color: Colors.white, size: 28),
              ),
            ),
        ],
      ),

      // Bottom Navigation Bar luôn cố định
      bottomNavigationBar: BottomNavBarWidget(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        showLabels: false,
      ),
    );
  }
}
