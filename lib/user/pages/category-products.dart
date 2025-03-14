import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/category_model.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/admin/providers/product_provider.dart';
import 'package:mockhang_app/user/pages/product_detail_page_user.dart';
import 'package:mockhang_app/user/widgets/product_item_card.dart';
import 'package:provider/provider.dart';

class CategoryProductsPage extends StatefulWidget {
  final Category category;

  const CategoryProductsPage({Key? key, required this.category})
    : super(key: key);

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  bool _isLoading = true;
  String? _error;
  List<Product> _categoryProducts = [];

  @override
  void initState() {
    super.initState();
    _loadCategoryProducts();
  }

  Future<void> _loadCategoryProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      // Đảm bảo sản phẩm đã được tải
      if (productProvider.products.isEmpty) {
        await productProvider.fetchProducts();
      }

      // Lọc sản phẩm theo danh mục (sử dụng tên danh mục thay vì ID)
      _categoryProducts =
          productProvider.products
              .where((product) => product.category == widget.category.name)
              .toList();

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  Widget _buildProductGrid() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.brown),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi khi tải dữ liệu',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Colors.red[700])),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadCategoryProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_categoryProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, color: Colors.grey[400], size: 64),
            const SizedBox(height: 16),
            Text(
              'Không có sản phẩm nào trong danh mục này',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategoryProducts,
      color: Colors.brown,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categoryProducts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          final product = _categoryProducts[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPageUser(product: product),
                ),
              );
            },
            child: ProductItemCard(product: product),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        centerTitle: true,
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Thêm chức năng lọc sản phẩm
              showModalBottomSheet(
                context: context,
                builder:
                    (context) => Container(
                      padding: const EdgeInsets.all(16),
                      height: 300,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sắp xếp theo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFilterOption(
                            'Giá: Thấp đến cao',
                            Icons.arrow_upward,
                          ),
                          _buildFilterOption(
                            'Giá: Cao đến thấp',
                            Icons.arrow_downward,
                          ),
                          _buildFilterOption('Mới nhất', Icons.fiber_new),
                          _buildFilterOption(
                            'Bán chạy nhất',
                            Icons.trending_up,
                          ),
                        ],
                      ),
                    ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Thêm chức năng tìm kiếm trong danh mục
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(
                  categoryName: widget.category.name,
                  products: _categoryProducts,
                ),
              );
            },
          ),
        ],
      ),
      body: _buildProductGrid(),
    );
  }

  Widget _buildFilterOption(String title, IconData icon) {
    return InkWell(
      onTap: () {
        // Xử lý sắp xếp sản phẩm theo lựa chọn
        Navigator.pop(context);
        setState(() {
          if (title == 'Giá: Thấp đến cao') {
            _categoryProducts.sort((a, b) => a.price.compareTo(b.price));
          } else if (title == 'Giá: Cao đến thấp') {
            _categoryProducts.sort((a, b) => b.price.compareTo(a.price));
          } else if (title == 'Mới nhất') {
            // Giả sử ID lớn hơn là sản phẩm mới hơn
            _categoryProducts.sort((a, b) {
              // Xử lý null safety cho id
              final aId = a.id ?? 0;
              final bId = b.id ?? 0;
              return bId.compareTo(aId);
            });
          } else if (title == 'Bán chạy nhất') {
            _categoryProducts.sort(
              (a, b) => b.soldQuantity.compareTo(a.soldQuantity),
            );
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.brown),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// Tạo một SearchDelegate tùy chỉnh cho tìm kiếm sản phẩm trong danh mục
class ProductSearchDelegate extends SearchDelegate<Product?> {
  final String categoryName;
  final List<Product> products;

  ProductSearchDelegate({required this.categoryName, required this.products});

  @override
  String get searchFieldLabel => 'Tìm kiếm trong $categoryName';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredProducts =
        products
            .where(
              (product) =>
                  product.name.toLowerCase().contains(query.toLowerCase()) ||
                  product.description.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nhập từ khóa để tìm kiếm sản phẩm',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy sản phẩm phù hợp',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredProducts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return GestureDetector(
          onTap: () {
            close(context, product);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPageUser(product: product),
              ),
            );
          },
          child: ProductItemCard(product: product),
        );
      },
    );
  }
}
