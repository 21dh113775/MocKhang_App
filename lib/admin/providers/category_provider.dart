import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/category_model.dart';
import 'package:mockhang_app/admin/data/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository categoryRepository;

  CategoryProvider(this.categoryRepository);

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  Future<void> fetchCategories() async {
    try {
      _categories = await categoryRepository.getCategories();
      notifyListeners();
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      // Sử dụng phương thức đã cập nhật từ repository để nhận lại category có ID
      Category newCategory = await categoryRepository.addCategory(category);

      // Thêm danh mục mới với ID đã được cập nhật vào danh sách
      _categories.add(newCategory);
      notifyListeners();
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      bool success = await categoryRepository.updateCategory(category);
      if (success) {
        int index = _categories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          _categories[index] = category;
          notifyListeners();
        } else {
          // Nếu không tìm thấy danh mục trong danh sách, tải lại danh sách
          await fetchCategories();
        }
      }
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      // Kiểm tra xem có danh mục nào có ID này trong danh sách không
      bool exists = _categories.any((category) => category.id == id);

      if (!exists) {
        throw Exception('Không tìm thấy danh mục với ID: $id');
      }

      bool success = await categoryRepository.deleteCategory(id);

      if (success) {
        _categories.removeWhere((category) => category.id == id);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }
}
