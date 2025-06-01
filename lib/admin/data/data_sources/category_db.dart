import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryDatabase {
  static final CategoryDatabase instance = CategoryDatabase._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'categories';

  CategoryDatabase._init();

  /// Lấy collection categories từ Firestore
  CollectionReference<Map<String, dynamic>> get _categoriesCollection =>
      _firestore.collection(_collectionName);

  /// **Thêm danh mục**
  Future<String> insertCategory(Category category) async {
    try {
      DocumentReference docRef = await _categoriesCollection.add({
        'name': category.name,
        'icon': category.icon,
        'imageUrl': category.imageUrl, // Save image URL
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Không thể thêm danh mục: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      if (category.id == null || category.id!.isEmpty) {
        throw Exception('ID danh mục không hợp lệ');
      }

      await _categoriesCollection.doc(category.id).update({
        'name': category.name,
        'icon': category.icon,
        'imageUrl': category.imageUrl, // Update image URL
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Không thể cập nhật danh mục: $e');
    }
  }

  /// **Lấy tất cả danh mục**
  Future<List<Category>> fetchCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await _categoriesCollection.orderBy('name').get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Category(
          id: doc.id,
          name: data['name'] ?? '',
          icon: data['icon'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Không thể lấy danh sách danh mục: $e');
    }
  }

  /// **Xóa danh mục**
  Future<void> deleteCategory(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('ID danh mục không hợp lệ');
      }
      await _categoriesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Không thể xóa danh mục: $e');
    }
  }

  /// **Xóa toàn bộ danh mục**
  Future<void> clearCategories() async {
    try {
      WriteBatch batch = _firestore.batch();
      QuerySnapshot querySnapshot = await _categoriesCollection.get();

      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Không thể xóa toàn bộ danh mục: $e');
    }
  }

  /// **Lấy một danh mục theo ID**
  Future<Category?> getCategoryById(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('ID danh mục không hợp lệ');
      }

      DocumentSnapshot doc = await _categoriesCollection.doc(id).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Category(
          id: doc.id,
          name: data['name'] ?? '',
          icon: data['icon'],
        );
      }
      return null;
    } catch (e) {
      throw Exception('Không thể lấy danh mục: $e');
    }
  }

  /// **Lắng nghe sự thay đổi của danh mục theo thời gian thực**
  Stream<List<Category>> watchCategories() {
    return _categoriesCollection.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Category(
          id: doc.id,
          name: data['name'] ?? '',
          icon: data['icon'],
        );
      }).toList();
    });
  }

  /// **Tìm kiếm danh mục theo tên**
  Future<List<Category>> searchCategories(String keyword) async {
    try {
      // Firestore không hỗ trợ tìm kiếm contains trực tiếp
      // Nên ta lấy tất cả rồi lọc ở client
      QuerySnapshot querySnapshot = await _categoriesCollection.get();

      return querySnapshot.docs
          .map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return Category(
              id: doc.id,
              name: data['name'] ?? '',
              icon: data['icon'],
            );
          })
          .where(
            (category) =>
                category.name.toLowerCase().contains(keyword.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception('Không thể tìm kiếm danh mục: $e');
    }
  }
}
