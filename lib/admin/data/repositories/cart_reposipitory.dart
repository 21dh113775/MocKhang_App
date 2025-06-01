import 'package:mockhang_app/admin/data/models/cart_model.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mockhang_app/admin/data/data_sources/product_db.dart';

class CartRepository {
  final ProductDatabase productDatabase; // Cơ sở dữ liệu sản phẩm
  CartRepository(this.productDatabase);

  // Giả sử bạn có một phương thức để lấy giỏ hàng từ cơ sở dữ liệu
  Future<List<CartItem>> fetchCartItems() async {
    final db = await productDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cart',
    ); // Giả sử bạn có một bảng 'cart'
    return List.generate(maps.length, (i) {
      return CartItem.fromMap(maps[i]); // Chuyển từ Map thành CartItem
    });
  }

  // Thêm sản phẩm vào giỏ hàng
  Future<void> addProductToCart(CartItem cartItem) async {
    final db = await productDatabase.database;
    await db.insert(
      'cart', // Tên bảng giỏ hàng
      cartItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Cập nhật số lượng sản phẩm trong giỏ hàng
  Future<void> updateQuantity(int productId, int quantity) async {
    final db = await productDatabase.database;
    await db.update(
      'cart',
      {'quantity': quantity},
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  // Xóa sản phẩm khỏi giỏ hàng
  Future<void> removeProduct(int productId) async {
    final db = await productDatabase.database;
    await db.delete('cart', where: 'productId = ?', whereArgs: [productId]);
  }

  // Lấy tổng số tiền trong giỏ hàng
  Future<double> getTotalPrice() async {
    final db = await productDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('cart');
    double totalPrice = 0;
    for (var map in maps) {
      final cartItem = CartItem.fromMap(map);
      totalPrice += cartItem.product.price * cartItem.quantity;
    }
    return totalPrice;
  }
}
