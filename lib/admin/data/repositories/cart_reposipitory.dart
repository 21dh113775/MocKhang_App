import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockhang_app/admin/data/models/cart_model.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/admin/data/data_sources/product_db.dart';

class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductDatabase productDatabase;
  final String _cartCollection = 'cart';

  CartRepository(this.productDatabase);

  // Lấy giỏ hàng từ Firestore
  Future<List<CartItem>> fetchCartItems(String userId) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection(_cartCollection)
              .where('userId', isEqualTo: userId)
              .get();

      List<CartItem> cartItems = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Lấy thông tin sản phẩm từ ProductDatabase
        Product? product = await productDatabase.getProductById(
          data['productId'],
        );

        if (product != null) {
          cartItems.add(
            CartItem(
              product: product,
              quantity: data['quantity'] ?? 1,
              isSelected: data['isSelected'] ?? true,
            ),
          );
        }
      }

      return cartItems;
    } catch (e) {
      throw Exception('Không thể lấy giỏ hàng: $e');
    }
  }

  // Thêm sản phẩm vào giỏ hàng
  Future<void> addProductToCart(String userId, CartItem cartItem) async {
    try {
      await _firestore.collection(_cartCollection).add({
        'userId': userId,
        'productId': cartItem.product.id,
        'quantity': cartItem.quantity,
        'isSelected': cartItem.isSelected,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Không thể thêm vào giỏ hàng: $e');
    }
  }

  // Cập nhật số lượng sản phẩm trong giỏ hàng
  Future<void> updateQuantity(
    String userId,
    String productId,
    int quantity,
  ) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection(_cartCollection)
              .where('userId', isEqualTo: userId)
              .where('productId', isEqualTo: productId)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({
          'quantity': quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Không thể cập nhật số lượng: $e');
    }
  }

  // Xóa sản phẩm khỏi giỏ hàng
  Future<void> removeProduct(String userId, String productId) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection(_cartCollection)
              .where('userId', isEqualTo: userId)
              .where('productId', isEqualTo: productId)
              .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Không thể xóa sản phẩm: $e');
    }
  }

  // Lấy tổng số tiền trong giỏ hàng
  Future<double> getTotalPrice(String userId) async {
    try {
      List<CartItem> cartItems = await fetchCartItems(userId);
      double totalPrice = 0;

      for (var cartItem in cartItems) {
        if (cartItem.isSelected) {
          totalPrice += cartItem.product.price * cartItem.quantity;
        }
      }

      return totalPrice;
    } catch (e) {
      throw Exception('Không thể tính tổng tiền: $e');
    }
  }

  // Xóa toàn bộ giỏ hàng
  Future<void> clearCart(String userId) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection(_cartCollection)
              .where('userId', isEqualTo: userId)
              .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Không thể xóa giỏ hàng: $e');
    }
  }
}
