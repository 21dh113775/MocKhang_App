import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/admin/data/repositories/product_repository.dart';
import 'package:mockhang_app/admin/pages/product/add_product_page.dart';

import 'package:mockhang_app/admin/providers/product_provider.dart';
import 'package:provider/provider.dart';

class ProductPageAdmin extends StatefulWidget {
  const ProductPageAdmin({Key? key}) : super(key: key);

  @override
  State<ProductPageAdmin> createState() => _ProductPageAdminState();
}

class _ProductPageAdminState extends State<ProductPageAdmin> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Tải danh sách sản phẩm khi trang được khởi tạo
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

    // Nếu có kết quả trả về (đã thêm hoặc cập nhật sản phẩm), tải lại danh sách
    if (result == true) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    }
  }

  void _navigateToEditProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductPageAdmin(productToEdit: product),
      ),
    );

    // Nếu có kết quả trả về (đã cập nhật sản phẩm), tải lại danh sách
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
              child: const Text('Hủy'),
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
        const SnackBar(content: Text('Đã xóa sản phẩm thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể xóa sản phẩm: $e')));
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
                decoration: const InputDecoration(
                  labelText: 'Số lượng nhập thêm',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã nhập kho thành công')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể nhập kho: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm sản phẩm...',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    Provider.of<ProductProvider>(
                      context,
                      listen: false,
                    ).searchProducts(value);
                  },
                )
                : const Text('Quản lý sản phẩm'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
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
            return const Center(child: CircularProgressIndicator());
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
                    onPressed: () => productProvider.fetchProducts(),
                    child: const Text('Thử lại'),
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
                      : const Text(
                        'Chưa có sản phẩm nào. Hãy thêm sản phẩm mới.',
                      ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => productProvider.fetchProducts(),
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: ListTile(
                    leading:
                        product.imageUrl.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                product.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                // Thêm cacheWidth và cacheHeight để cải thiện hiệu suất
                                cacheWidth: 100,
                                cacheHeight: 100,
                                // Thêm loadingBuilder để hiển thị tiến trình tải
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(
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
                                errorBuilder: (context, error, stackTrace) {
                                  // Ghi log lỗi để debug
                                  print("Lỗi khi tải ảnh sản phẩm: $error");
                                  print("URL gây lỗi: ${product.imageUrl}");

                                  // Hiển thị container với biểu tượng lỗi
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[300],
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported,
                                          size: 22,
                                        ),
                                        Text(
                                          "Lỗi",
                                          style: TextStyle(fontSize: 9),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                            : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              child: const Icon(Icons.inventory),
                            ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Danh mục: ${product.category}'),
                        Text(
                          'Giá: ${product.price.toStringAsFixed(0)} đ',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Kho: ${product.stock}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_box, color: Colors.blue),
                          tooltip: 'Nhập kho',
                          onPressed: () => _showImportStockDialog(product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          tooltip: 'Sửa',
                          onPressed: () => _navigateToEditProduct(product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Xóa',
                          onPressed: () => _showDeleteConfirmation(product),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () => _navigateToEditProduct(product),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        tooltip: 'Thêm sản phẩm mới',
        child: const Icon(Icons.add),
      ),
    );
  }
}
