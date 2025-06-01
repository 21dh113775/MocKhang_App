import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/admin/data/repositories/product_repository.dart';
import 'package:mockhang_app/admin/pages/product/add_product_page.dart';
import 'package:mockhang_app/admin/pages/product/product_detail_page.dart';
import 'package:mockhang_app/admin/providers/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ProductPageAdmin extends StatefulWidget {
  const ProductPageAdmin({Key? key}) : super(key: key);

  @override
  State<ProductPageAdmin> createState() => _ProductPageAdminState();
}

class _ProductPageAdminState extends State<ProductPageAdmin> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  final Color _primaryColor = const Color(0xFF2C3E50);
  final currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductPageAdmin()),
    );

    if (result == true) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    }
  }

  void _navigateToProductDetail(Product product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
    // Refresh sau khi quay về từ trang chi tiết
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }

  void _navigateToEditProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductPageAdmin(productToEdit: product),
      ),
    );

    if (result == true) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    }
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc muốn xóa sản phẩm "${product.name}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy', style: TextStyle(color: _primaryColor)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct(product.id!);
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(String id) async {
    try {
      await Provider.of<ProductProvider>(
        context,
        listen: false,
      ).deleteProduct(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa sản phẩm thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể xóa sản phẩm: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImportStockDialog(Product product) {
    final TextEditingController quantityController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nhập kho cho ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Số lượng hiện tại: ${product.stock}'),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số lượng nhập thêm',
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _primaryColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy', style: TextStyle(color: _primaryColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
              onPressed: () {
                Navigator.of(context).pop();
                if (quantityController.text.isNotEmpty) {
                  final quantity = int.tryParse(quantityController.text);
                  if (quantity != null && quantity > 0) {
                    _importStock(product.id!, quantity);
                  }
                }
              },
              child: const Text('Nhập kho'),
            ),
          ],
        );
      },
    );
  }

  void _importStock(String productId, int quantity) async {
    try {
      await Provider.of<ProductProvider>(
        context,
        listen: false,
      ).importStock(productId, quantity);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã nhập kho thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể nhập kho: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true, // Căn giữa tiêu đề
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm sản phẩm...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    Provider.of<ProductProvider>(
                      context,
                      listen: false,
                    ).searchProducts(value);
                  },
                )
                : const Text(
                  'Quản lý sản phẩm',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  Provider.of<ProductProvider>(
                    context,
                    listen: false,
                  ).resetSearch();
                }
              });
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: _primaryColor),
            );
          }

          if (productProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lỗi: ${productProvider.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                    ),
                    onPressed: () => productProvider.fetchProducts(),
                    child: const Text(
                      'Thử lại',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          final products = productProvider.filteredProducts;
          if (products.isEmpty) {
            return Center(
              child:
                  productProvider.searchQuery.isNotEmpty
                      ? Text(
                        'Không tìm thấy sản phẩm phù hợp với từ khóa "${productProvider.searchQuery}"',
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có sản phẩm nào',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                            ),
                           onPressed: _navigateToAddProduct,
                             icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Thêm sản phẩm mới',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
            );
          }

          return RefreshIndicator(
            color: _primaryColor,
            onRefresh: () => productProvider.fetchProducts(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _navigateToProductDetail(product),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hình ảnh sản phẩm
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                product.imageUrl.isNotEmpty
                                    ? Image.network(
                                      product.imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      cacheWidth: 160,
                                      cacheHeight: 160,
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: _primaryColor,
                                              value:
                                                  loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[300],
                                          child: const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.image_not_supported,
                                                size: 30,
                                              ),
                                              Text(
                                                "Lỗi ảnh",
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                    : Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.inventory,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                          ),
                          // Thông tin sản phẩm
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: _primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.category,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(product.category),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.monetization_on,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        currencyFormat.format(product.price),
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.inventory_2,
                                        size: 16,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Kho: ${product.stock}',
                                        style: TextStyle(
                                          color:
                                              product.stock > 10
                                                  ? Colors.blue
                                                  : Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Action buttons
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // IconButton(
                              //   icon: Icon(
                              //     Icons.remove_red_eye,
                              //     color: _primaryColor,
                              //   ),
                              //   tooltip: 'Xem chi tiết',
                              //   onPressed:
                              //       () => _navigateToProductDetail(product),
                              // ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_box,
                                  color: Colors.blue,
                                ),
                                tooltip: 'Nhập kho',
                                onPressed:
                                    () => _showImportStockDialog(product),
                              ),
                              // IconButton(
                              //   icon: const Icon(
                              //     Icons.edit,
                              //     color: Colors.orange,
                              //   ),
                              //   tooltip: 'Sửa',
                              //   onPressed:
                              //       () => _navigateToEditProduct(product),
                              // ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: 'Xóa',
                                onPressed:
                                    () => _showDeleteConfirmation(product),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddProduct,
        label: const Text(
          'Thêm sản phẩm',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: _primaryColor,
      ),
    );
  }
}
