import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/admin/data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository productRepository;

  ProductProvider(this.productRepository);

  List<Product> _products = [];
  List<Product> get products => _products;

  Future<void> fetchProducts() async {
    _products = await productRepository.getProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    bool success = await productRepository.addProduct(product);
    if (success) {
      _products.add(product);
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    bool success = await productRepository.updateProduct(product);
    if (success) {
      int index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
    }
  }

  Future<void> deleteProduct(int id) async {
    bool success = await productRepository.deleteProduct(id);
    if (success) {
      _products.removeWhere((product) => product.id == id);
      notifyListeners();
    }
  }

  /// **Hàm nhập hàng**
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
        notifyListeners();
      }
    }
  }
}
