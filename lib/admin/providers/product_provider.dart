import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/admin/data/repositories/product_repository.dart'
    show ProductDatabase;

class ProductProvider extends ChangeNotifier {
  final ProductDatabase productDatabase;

  ProductProvider(this.productDatabase);

  List<Product> _products = [];
  List<Product> get products => _products;

  List<Product> _filteredProducts = [];
  List<Product> get filteredProducts => _filteredProducts;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isLoading = false; // Trạng thái tải dữ liệu
  bool get isLoading => _isLoading;

  String _errorMessage = ''; // Thông báo lỗi
  String get errorMessage => _errorMessage;

  // Lấy tất cả sản phẩm từ Firestore và cập nhật vào danh sách
  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = ''; // Reset lỗi trước khi tải lại
    _safeNotifyListeners();

    try {
      _products = await productDatabase.fetchProducts();
      _filteredProducts = List.from(_products);
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách sản phẩm: $e';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  void _safeNotifyListeners() {
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          notifyListeners();
        } catch (e) {
          print('Error during notifyListeners: $e');
        }
      });
    } else {
      Future.microtask(() {
        try {
          notifyListeners();
        } catch (e) {
          print('Error during notifyListeners: $e');
        }
      });
    }
  }

  // Tìm kiếm sản phẩm theo từ khóa
  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    if (_searchQuery.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
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
    _safeNotifyListeners();
  }

  // Reset tìm kiếm và hiển thị lại tất cả sản phẩm
  void resetSearch() {
    _searchQuery = '';
    _filteredProducts = List.from(_products);
    _safeNotifyListeners();
  }

  Future<void> addProduct(Product product) async {
    if (_isLoading) return; // Tránh việc thêm trong khi đang tải dữ liệu

    _isLoading = true;
    _errorMessage = ''; // Reset lỗi trước khi thêm sản phẩm
    _safeNotifyListeners();

    try {
      String docId = await productDatabase.insertProduct(product);

      // Tạo một đối tượng Product mới với docId
      Product newProduct = product.copyWith(id: docId);

      _products.add(newProduct);

      // Kiểm tra nếu từ khóa tìm kiếm rỗng hoặc sản phẩm phù hợp với từ khóa, thêm vào danh sách đã lọc
      if (_searchQuery.isEmpty ||
          newProduct.name.toLowerCase().contains(_searchQuery)) {
        _filteredProducts.add(newProduct);
      }
      _safeNotifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể thêm sản phẩm: $e';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Cập nhật sản phẩm trong Firestore
  Future<void> updateProduct(Product product) async {
    if (_isLoading) return; // Tránh việc cập nhật trong khi đang tải dữ liệu

    _isLoading = true;
    _errorMessage = ''; // Reset lỗi trước khi cập nhật sản phẩm
    _safeNotifyListeners();

    try {
      await productDatabase.updateProduct(product);
      int index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        searchProducts(_searchQuery); // Cập nhật lại kết quả tìm kiếm
      }
      _safeNotifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể cập nhật sản phẩm: $e';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Xóa sản phẩm khỏi Firestore
  Future<void> deleteProduct(String id) async {
    if (_isLoading) return; // Tránh việc xóa trong khi đang tải dữ liệu

    _isLoading = true;
    _errorMessage = ''; // Reset lỗi trước khi xóa sản phẩm
    _safeNotifyListeners();

    try {
      await productDatabase.deleteProduct(id);
      _products.removeWhere((product) => product.id == id);
      _filteredProducts.removeWhere((product) => product.id == id);
      _safeNotifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể xóa sản phẩm: $e';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Modify this method in product_provider.dart
  Future<void> importStock(String productId, int quantityToAdd) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = '';
    _safeNotifyListeners();

    try {
      // No need to convert productId to string anymore
      await ProductDatabase.instance.updateStock(productId, quantityToAdd);

      int index = _products.indexWhere((product) => product.id == productId);
      if (index != -1) {
        Product updatedProduct = _products[index].copyWith(
          stock: _products[index].stock + quantityToAdd,
          importedQuantity: _products[index].importedQuantity + quantityToAdd,
        );
        _products[index] = updatedProduct;
        searchProducts(_searchQuery);
      }
      _safeNotifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể nhập kho: $e';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Lắng nghe sự thay đổi của sản phẩm theo thời gian thực (optional)
  Stream<List<Product>> watchProducts() {
    return productDatabase.watchProducts();
  }

  // Tìm kiếm sản phẩm theo từ khóa, tìm kiếm sẽ cập nhật theo thời gian thực
  Future<void> realTimeSearch(String query) async {
    try {
      List<Product> result = await productDatabase.searchProducts(query);
      _filteredProducts = result;
      _safeNotifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể tìm kiếm sản phẩm: $e';
      _safeNotifyListeners();
    }
  }
}
