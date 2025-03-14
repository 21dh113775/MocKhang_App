import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/category_model.dart';
import 'package:mockhang_app/admin/pages/account_page.dart';
import 'package:mockhang_app/admin/providers/category_provider.dart';
import 'package:mockhang_app/admin/providers/product_provider.dart';
import 'package:mockhang_app/user/pages/cart_page.dart';
import 'package:mockhang_app/user/pages/consultation_page.dart';
import 'package:mockhang_app/user/pages/discount_page_user.dart';
import 'package:mockhang_app/user/pages/product_detail_page_user.dart';
import 'package:mockhang_app/user/widgets/bottom_nav_bar_widget.dart';
import 'package:mockhang_app/user/widgets/category_item_card.dart'
    show CategoryItemCard;
import 'package:mockhang_app/user/widgets/drawer_widget.dart';
import 'package:mockhang_app/user/widgets/product_item_card.dart'
    show ProductItemCard;
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

  // Biến state cho banner slider
  int _currentBannerIndex = 0;

  // Dữ liệu mẫu cho banner
  final List<Map<String, dynamic>> _bannerItems = [
    {
      'image': 'assets/banner.png',
      'title': 'Khuyến mãi lớn',
      'subtitle': 'Giảm đến 30% cho đơn hàng đầu tiên',
      'route': '/discount',
    },
    {
      'image': 'assets/banner1.png',
      'title': 'Bộ sưu tập mới',
      'subtitle': 'Phong thủy cho năm mới',
      'route': '/collection',
    },
    {
      'image': 'assets/banner.png',
      'title': 'Miễn phí vận chuyển',
      'subtitle': 'Cho đơn hàng trên 500.000đ',
      'route': '/shipping',
    },
  ];

  // Dữ liệu mẫu cho sản phẩm nổi bật
  final List<Map<String, dynamic>> _featuredCategories = [
    {'title': 'Mới nhất', 'key': 'newest'},
    {'title': 'Phổ biến', 'key': 'popular'},
    {'title': 'Bán chạy', 'key': 'bestseller'},
    {'title': 'Giảm giá', 'key': 'discount'},
  ];

  int _selectedFeaturedIndex = 0;

  // Danh sách các trang nội dung
  final List<Widget> _pages = [
    Container(), // Placeholder cho trang chủ
    DiscountPageUser(), // Trang Khuyến Mãi
    ConsultationPage(), // Trang Liên Hệ
    CartPage(), // Trang Giỏ Hàng
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm sản phẩm...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: Icon(Icons.filter_list, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.brown[300]!, width: 1),
          ),
        ),
        onSubmitted: (query) {
          // TODO: Triển khai tìm kiếm sản phẩm theo từ khoá
        },
      ),
    );
  }

  Widget _buildBannerSection() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 180,
            viewportFraction: 0.92,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            onPageChanged: (index, reason) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
          ),
          items:
              _bannerItems.map((banner) {
                return Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        // Xử lý khi nhấn vào banner
                        Navigator.pushNamed(context, banner['route']);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            children: [
                              // Banner image
                              Image.asset(
                                banner['image'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.brown[100],
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.brown,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Banner gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                              // Banner text
                              Positioned(
                                bottom: 20,
                                left: 20,
                                right: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      banner['title'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      banner['subtitle'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: 10),
        // Dots indicator
        DotsIndicator(
          dotsCount: _bannerItems.length,
          position: _currentBannerIndex.toDouble(),
          decorator: DotsDecorator(
            size: const Size.square(8.0),
            activeSize: const Size(18.0, 8.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            color: Colors.grey[400]!,
            activeColor: Colors.brown,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(List<Category> categories) {
    if (_isCategoryLoading) {
      return _buildLoadingSection('Danh mục');
    }
    if (_categoryError != null) {
      return _buildErrorSection('Danh mục', _categoryError!);
    }
    if (categories.isEmpty) {
      return _buildEmptySection('Danh mục', 'Chưa có danh mục nào!');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Danh mục sản phẩm',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Điều hướng đến trang tất cả danh mục
                  Navigator.pushNamed(context, '/categories');
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Xem tất cả'),
                style: TextButton.styleFrom(foregroundColor: Colors.brown),
              ),
            ],
          ),
        ),
        Container(
          height: 100, // Giảm chiều cao để tránh tràn
          decoration: BoxDecoration(
            color: Colors.brown.shade50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 6), // Giảm padding
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                ), // Giảm padding giữa các card
                child: CategoryItemCard(category: cat),
              );
            },
          ),
        ),
        // Loại bỏ phần "Kéo để xem thêm" để giảm chiều cao
      ],
    );
  }

  Widget _buildFeaturedTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            _featuredCategories.length,
            (index) => GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFeaturedIndex = index;
                  // TODO: Load products based on selected category
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      _selectedFeaturedIndex == index
                          ? Colors.brown
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        _selectedFeaturedIndex == index
                            ? Colors.brown
                            : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  _featuredCategories[index]['title'],
                  style: TextStyle(
                    color:
                        _selectedFeaturedIndex == index
                            ? Colors.white
                            : Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductSection() {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    if (_isProductLoading) {
      return _buildLoadingSection('Sản phẩm nổi bật');
    }
    if (_productError != null) {
      return _buildErrorSection('Sản phẩm nổi bật', _productError!);
    }
    if (products.isEmpty) {
      return _buildEmptySection('Sản phẩm nổi bật', 'Chưa có sản phẩm nào!');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sản phẩm nổi bật',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Điều hướng đến trang tất cả sản phẩm
                  Navigator.pushNamed(context, '/productsuser');
                },
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(color: Colors.brown),
                ),
              ),
            ],
          ),
        ),
        _buildFeaturedTabBar(),
        const SizedBox(height: 16),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return GestureDetector(
              onTap: () {
                // Chuyển đến trang chi tiết sản phẩm khi nhấn vào sản phẩm
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ProductDetailPageUser(product: product),
                  ),
                );
              },
              child: ProductItemCard(product: product),
            );
          },
        ),
      ],
    );
  }

  // Các hàm helper
  Widget _buildLoadingSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: CircularProgressIndicator(color: Colors.brown),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorSection(String title, String errorMsg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 8),
                Text(
                  'Lỗi khi tải dữ liệu:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  errorMsg,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[700]),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySection(String title, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.grey[400],
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(message, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      ],
    );
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
            _buildSearchBar(),
            _buildBannerSection(),
            const SizedBox(height: 16),
            _buildCategorySection(
              Provider.of<CategoryProvider>(context).categories,
            ),
            const SizedBox(height: 16),
            _buildProductSection(),
            const SizedBox(
              height: 30,
            ), // Padding cuối cùng để tránh bị che bởi bottom nav bar
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
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                ), // Change color to white
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
