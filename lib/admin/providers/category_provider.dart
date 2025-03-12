import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/category_model.dart';
import 'package:mockhang_app/admin/data/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository categoryRepository;

  CategoryProvider(this.categoryRepository);

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  Future<void> fetchCategories() async {
    _categories = await categoryRepository.getCategories();
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    bool success = await categoryRepository.addCategory(category);
    if (success) {
      _categories.add(category);
      notifyListeners();
    }
  }

  Future<void> updateCategory(Category category) async {
    bool success = await categoryRepository.updateCategory(category);
    if (success) {
      int index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    }
  }

  Future<void> deleteCategory(int id) async {
    bool success = await categoryRepository.deleteCategory(id);
    if (success) {
      _categories.removeWhere((category) => category.id == id);
      notifyListeners();
    }
  }
}
