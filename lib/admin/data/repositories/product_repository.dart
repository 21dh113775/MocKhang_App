import '../data_sources/product_db.dart';
import '../models/product_model.dart';

class ProductRepository {
  final ProductDatabase productDB;

  ProductRepository(this.productDB);

  // Thêm sản phẩm mới
  Future<bool> addProduct(Product product) async {
    int result = await productDB.insertProduct(product);
    return result > 0;
  }

  // Lấy tất cả sản phẩm
  Future<List<Product>> getProducts() async {
    return await productDB.fetchProducts();
  }

  // Cập nhật sản phẩm
  Future<bool> updateProduct(Product product) async {
    // Kiểm tra dữ liệu sản phẩm trước khi thực hiện cập nhật
    if (product.id == null || product.id! <= 0) {
      return false; // Trả về false nếu sản phẩm không có ID hợp lệ
    }

    // Gọi phương thức cập nhật trong ProductDatabase
    int result = await productDB.updateProduct(product);

    // Nếu kết quả trả về lớn hơn 0, tức là cập nhật thành công
    return result > 0;
  }

  // Xóa sản phẩm theo ID
  Future<bool> deleteProduct(int id) async {
    int result = await productDB.deleteProduct(id);
    return result > 0;
  }

  // Cập nhật kho hàng
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
