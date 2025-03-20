import '../data_sources/category_db.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final CategoryDatabase categoryDB;

  CategoryRepository(this.categoryDB);

  /// Thêm danh mục mới
  Future<Category> addCategory(Category category) async {
    String docId = await categoryDB.insertCategory(category);

    if (docId.isNotEmpty) {
      // Tạo bản sao của category với ID được gán từ Firestore
      return Category(id: docId, name: category.name, icon: category.icon);
    }

    throw Exception('Không thể thêm danh mục');
  }

  /// Lấy tất cả danh mục
  Future<List<Category>> getCategories() async {
    return await categoryDB.fetchCategories();
  }

  /// Cập nhật danh mục
  Future<bool> updateCategory(Category category) async {
    if (category.id == null || category.id!.isEmpty) {
      throw Exception('Không thể cập nhật - ID danh mục không hợp lệ');
    }

    try {
      await categoryDB.updateCategory(category);
      return true;
    } catch (e) {
      print('Lỗi khi cập nhật danh mục: $e');
      return false;
    }
  }

  /// Xóa danh mục
  Future<bool> deleteCategory(String id) async {
    if (id.isEmpty) {
      throw Exception('Không thể xóa - ID không hợp lệ');
    }

    try {
      await categoryDB.deleteCategory(id);
      return true;
    } catch (e) {
      print('Lỗi khi xóa danh mục: $e');
      return false;
    }
  }

  /// Kiểm tra danh mục tồn tại
  Future<bool> categoryExists(String id) async {
    if (id.isEmpty) return false;

    Category? category = await categoryDB.getCategoryById(id);
    return category != null;
  }

  /// Tìm kiếm danh mục theo tên
  Future<List<Category>> searchCategories(String keyword) async {
    if (keyword.isEmpty) {
      return await getCategories();
    }
    return await categoryDB.searchCategories(keyword);
  }

  /// Lấy một danh mục theo ID
  Future<Category?> getCategoryById(String id) async {
    if (id.isEmpty) {
      throw Exception('ID danh mục không hợp lệ');
    }
    return await categoryDB.getCategoryById(id);
  }

  /// Lấy stream danh mục để lắng nghe thay đổi
  Stream<List<Category>> watchCategories() {
    return categoryDB.watchCategories();
  }
}
