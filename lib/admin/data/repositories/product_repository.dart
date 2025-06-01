import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductDatabase {
  static final ProductDatabase instance = ProductDatabase._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'products';

  ProductDatabase._init();

  // Lấy collection products từ Firestore
  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firestore.collection(_collectionName);

  /// **Thêm sản phẩm vào Firestore**
  Future<String> insertProduct(Product product) async {
    try {
      DocumentReference docRef = await _productsCollection.add({
        'name': product.name,
        'category': product.category,
        'price': product.price,
        'stock': product.stock,
        'soldQuantity': product.soldQuantity,
        'importedQuantity': product.importedQuantity,
        'imageUrl': product.imageUrl,
        'description': product.description,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Không thể thêm sản phẩm: $e');
    }
  }

  /// **Lấy tất cả sản phẩm từ Firestore**
  Future<List<Product>> fetchProducts() async {
    try {
      QuerySnapshot querySnapshot =
          await _productsCollection.orderBy('name').get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Không thể lấy danh sách sản phẩm: $e');
    }
  }

  /// **Cập nhật sản phẩm trong Firestore**
  Future<void> updateProduct(Product product) async {
    try {
      if (product.id == null || product.id!.isEmpty) {
        throw Exception('ID sản phẩm không hợp lệ');
      }

      // Cập nhật thông tin sản phẩm
      await _productsCollection.doc(product.id).update({
        'name': product.name,
        'category': product.category,
        'price': product.price,
        'stock': product.stock,
        'soldQuantity': product.soldQuantity,
        'importedQuantity': product.importedQuantity,
        'imageUrl': product.imageUrl,
        'description': product.description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Không thể cập nhật sản phẩm: $e');
    }
  }

  /// **Xóa sản phẩm khỏi Firestore**
  Future<void> deleteProduct(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('ID sản phẩm không hợp lệ');
      }
      await _productsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Không thể xóa sản phẩm: $e');
    }
  }

  /// **Lắng nghe sự thay đổi của sản phẩm theo thời gian thực**
  Stream<List<Product>> watchProducts() {
    return _productsCollection.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Product.fromMap(data, doc.id);
      }).toList();
    });
  }

  /// **Tìm kiếm sản phẩm theo tên**
  Future<List<Product>> searchProducts(String keyword) async {
    try {
      // Firestore không hỗ trợ tìm kiếm contains trực tiếp
      // Nên ta lấy tất cả rồi lọc ở client
      QuerySnapshot querySnapshot = await _productsCollection.get();

      return querySnapshot.docs
          .map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return Product.fromMap(data, doc.id);
          })
          .where(
            (product) =>
                product.name.toLowerCase().contains(keyword.toLowerCase()) ||
                product.category.toLowerCase().contains(keyword.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception('Không thể tìm kiếm sản phẩm: $e');
    }
  }

  /// **Cập nhật số lượng kho của sản phẩm**
  Future<void> updateStock(String productId, int quantityToAdd) async {
    try {
      if (productId.isEmpty) {
        throw Exception('ID sản phẩm không hợp lệ');
      }

      DocumentSnapshot docSnapshot =
          await _productsCollection.doc(productId).get();

      if (!docSnapshot.exists) {
        throw Exception("Sản phẩm không tồn tại");
      }

      Map<String, dynamic> productData =
          docSnapshot.data() as Map<String, dynamic>;

      int currentStock = productData['stock'] ?? 0;
      int currentImportedQuantity = productData['importedQuantity'] ?? 0;

      // Cập nhật số lượng kho và số lượng nhập
      await _productsCollection.doc(productId).update({
        'stock': currentStock + quantityToAdd,
        'importedQuantity': currentImportedQuantity + quantityToAdd,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Không thể cập nhật kho sản phẩm: $e');
    }
  }
}
