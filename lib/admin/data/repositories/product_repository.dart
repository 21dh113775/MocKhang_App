import '../data_sources/product_db.dart';
import '../models/product_model.dart';

class ProductRepository {
  final ProductDatabase productDB;

  ProductRepository(this.productDB);

  Future<bool> addProduct(Product product) async {
    int result = await productDB.insertProduct(product);
    return result > 0;
  }

  Future<List<Product>> getProducts() async {
    return await productDB.fetchProducts();
  }

  Future<bool> updateProduct(Product product) async {
    int result = await productDB.updateProduct(product);
    return result > 0;
  }

  Future<bool> deleteProduct(int id) async {
    int result = await productDB.deleteProduct(id);
    return result > 0;
  }

  /// **Hàm cập nhật kho hàng**
  Future<bool> updateStock(
    int productId,
    int stock,
    int sold,
    int imported,
  ) async {
    int result = await productDB.updateStock(productId, stock, sold, imported);
    return result > 0;
  }
}
