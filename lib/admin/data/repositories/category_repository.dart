import '../data_sources/category_db.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final CategoryDatabase categoryDB;

  CategoryRepository(this.categoryDB);

  // Cập nhật phương thức này để trả về Category thay vì chỉ trả về bool
  Future<Category> addCategory(Category category) async {
    int insertedId = await categoryDB.insertCategory(category);

    if (insertedId > 0) {
      // Tạo bản sao của category với ID được gán từ cơ sở dữ liệu
      return Category(
        id: insertedId,
        name: category.name,
        // Thêm các trường khác nếu model Category của bạn có thêm
      );
    }

    throw Exception('Không thể thêm danh mục');
  }

  Future<List<Category>> getCategories() async {
    return await categoryDB.fetchCategories();
  }

  Future<bool> updateCategory(Category category) async {
    if (category.id == null) {
      throw Exception('Không thể cập nhật - ID danh mục không hợp lệ');
    }

    int result = await categoryDB.updateCategory(category);
    return result > 0;
  }

  Future<bool> deleteCategory(int id) async {
    if (id == null) {
      throw Exception('Không thể xóa - ID không hợp lệ');
    }

    int result = await categoryDB.deleteCategory(id);

    if (result <= 0) {
      throw Exception('Không thể xóa danh mục với ID: $id');
    }

    return result > 0;
  }

  // Phương thức để kiểm tra một danh mục có tồn tại không
  Future<bool> categoryExists(int id) async {
    if (id == null) return false;

    List<Category> categories = await getCategories();
    return categories.any((category) => category.id == id);
  }
}
