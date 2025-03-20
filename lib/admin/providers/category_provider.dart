import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/category_model.dart';
import 'package:mockhang_app/admin/data/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository categoryRepository;
  StreamSubscription? _categoriesSubscription;

  CategoryProvider(this.categoryRepository);

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Lấy danh sách danh mục
  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await categoryRepository.getCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error fetching categories: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Thêm danh mục mới
  Future<void> addCategory(Category category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Category newCategory = await categoryRepository.addCategory(category);
      // Nếu đang lắng nghe thay đổi thì không cần thêm vào mảng categories
      // vì danh sách sẽ tự cập nhật qua stream
      if (_categoriesSubscription == null) {
        _categories.add(newCategory);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error adding category: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Cập nhật danh mục
  Future<void> updateCategory(Category category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (category.id == null || category.id!.isEmpty) {
        throw Exception('ID danh mục không hợp lệ');
      }

      bool success = await categoryRepository.updateCategory(category);

      // Nếu không đang lắng nghe thay đổi thì cập nhật mảng categories
      if (_categoriesSubscription == null && success) {
        int index = _categories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          _categories[index] = category;
        } else {
          await fetchCategories();
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error updating category: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Xóa danh mục
  Future<void> deleteCategory(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (id.isEmpty) {
        throw Exception('ID danh mục không hợp lệ');
      }

      // Nếu không đang lắng nghe thay đổi thì kiểm tra danh mục tồn tại
      if (_categoriesSubscription == null) {
        bool exists = _categories.any((category) => category.id == id);
        if (!exists) {
          _isLoading = false;
          _error = 'Không tìm thấy danh mục với ID: $id';
          notifyListeners();
          throw Exception('Không tìm thấy danh mục với ID: $id');
        }
      }

      bool success = await categoryRepository.deleteCategory(id);

      // Nếu không đang lắng nghe thay đổi thì cập nhật mảng categories
      if (_categoriesSubscription == null && success) {
        _categories.removeWhere((category) => category.id == id);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error deleting category: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Tìm kiếm danh mục theo tên
  Future<void> searchCategories(String keyword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await categoryRepository.searchCategories(keyword);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error searching categories: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Lắng nghe thay đổi theo thời gian thực từ Firestore
  void listenToCategories() {
    // Hủy subscription cũ nếu có
    _categoriesSubscription?.cancel();

    // Thiết lập subscription mới
    _categoriesSubscription = categoryRepository.watchCategories().listen(
      (updatedCategories) {
        _categories = updatedCategories;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        print('Error listening to categories: $error');
        notifyListeners();
      },
    );
  }

  /// Hủy lắng nghe
  void cancelListening() {
    _categoriesSubscription?.cancel();
    _categoriesSubscription = null;
  }

  /// Đảm bảo hủy subscription khi không cần thiết nữa
  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    super.dispose();
  }
}
