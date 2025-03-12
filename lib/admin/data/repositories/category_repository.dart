import '../data_sources/category_db.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final CategoryDatabase categoryDB;

  CategoryRepository(this.categoryDB); // ✅ Truyền đúng instance

  Future<bool> addCategory(Category category) async {
    int result = await categoryDB.insertCategory(category);
    return result > 0;
  }

  Future<List<Category>> getCategories() async {
    return await categoryDB.fetchCategories();
  }

  Future<bool> updateCategory(Category category) async {
    int result = await categoryDB.updateCategory(category);
    return result > 0;
  }

  Future<bool> deleteCategory(int id) async {
    int result = await categoryDB.deleteCategory(id);
    return result > 0;
  }
}
