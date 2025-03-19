import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/admin/data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository productRepository;

  ProductProvider(this.productRepository);

  List<Product> _products = [];
  List<Product> get products => _products;

  // Danh sách sản phẩm được lọc qua tìm kiếm
  List<Product> _filteredProducts = [];
  List<Product> get filteredProducts => _filteredProducts;

  // Từ khóa tìm kiếm hiện tại
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  Future<void> fetchProducts() async {
    _products = await productRepository.getProducts();
    // Mặc định, danh sách lọc ban đầu là toàn bộ sản phẩm
    _filteredProducts = List.from(_products);
    notifyListeners();
  }

  // Phương thức tìm kiếm sản phẩm
  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();

    if (_searchQuery.isEmpty) {
      // Nếu không có từ khóa, hiển thị tất cả sản phẩm
      _filteredProducts = List.from(_products);
    } else {
      // Nếu có từ khóa, lọc sản phẩm theo tên và mô tả
      _filteredProducts =
          _products.where((product) {
            return product.name.toLowerCase().contains(_searchQuery) ||
                (product.description != null &&
                    product.description!.toLowerCase().contains(
                      _searchQuery,
                    )) ||
                product.category.toLowerCase().contains(_searchQuery);
          }).toList();
    }
    notifyListeners();
  }

  // Reset tìm kiếm
  void resetSearch() {
    _searchQuery = '';
    _filteredProducts = List.from(_products);
    notifyListeners();
  }

  // Giữ nguyên các phương thức khác
  Future<void> addProduct(Product product) async {
    bool success = await productRepository.addProduct(product);
    if (success) {
      _products.add(product);
      // Cập nhật danh sách lọc nếu cần thiết
      if (_searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery) ||
          (product.description != null &&
              product.description!.toLowerCase().contains(_searchQuery)) ||
          product.category.toLowerCase().contains(_searchQuery)) {
        _filteredProducts.add(product);
      }
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    bool success = await productRepository.updateProduct(product);
    if (success) {
      int index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        // Cập nhật lại kết quả tìm kiếm
        searchProducts(_searchQuery);
      }
    }
  }

  Future<void> deleteProduct(int id) async {
    bool success = await productRepository.deleteProduct(id);
    if (success) {
      _products.removeWhere((product) => product.id == id);
      _filteredProducts.removeWhere((product) => product.id == id);
      notifyListeners();
    }
  }

  Future<void> importStock(int productId, int quantityToAdd) async {
    int index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      int newStock = _products[index].stock + quantityToAdd;
      int newImported = _products[index].importedQuantity + quantityToAdd;

      bool success = await productRepository.updateStock(
        productId,
        newStock,
        _products[index].soldQuantity,
        newImported,
      );
      if (success) {
        _products[index] = Product(
          id: _products[index].id,
          name: _products[index].name,
          category: _products[index].category,
          price: _products[index].price,
          stock: newStock,
          soldQuantity: _products[index].soldQuantity,
          importedQuantity: newImported,
          imageUrl: _products[index].imageUrl,
          description: _products[index].description,
        );
        // Cập nhật lại kết quả tìm kiếm
        searchProducts(_searchQuery);
      }
    }
  }
}
