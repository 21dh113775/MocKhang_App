import 'dart:async';
import 'dart:io';
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

  // Safe notification method to prevent build-phase updates
  void _safeNotifyListeners() {
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      // Fallback if WidgetsBinding is not available
      Future.microtask(() => notifyListeners());
    }
  }

  // Set loading state safely
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _safeNotifyListeners();
    }
  }

  // Set error state safely
  void _setError(String? errorMessage) {
    _error = errorMessage;
    _safeNotifyListeners();
  }

  /// Lấy danh sách danh mục
  Future<List<Category>> fetchCategories() async {
    _setLoading(true);
    _setError(null);

    try {
      _categories = await categoryRepository.getCategories();
      _setLoading(false);
      return _categories;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  /// Thêm danh mục mới
  Future<Category> addCategory(Category category) async {
    _setLoading(true);
    _setError(null);
    print('Adding category with image path: ${category.imageUrl}');
    if (category.imageUrl != null) {
      File imageFile = File(category.imageUrl!);
      print('Image file exists: ${imageFile.existsSync()}');
    }
    try {
      Category newCategory = await categoryRepository.addCategory(category);
      if (_categoriesSubscription == null) {
        _categories.add(newCategory);
        _safeNotifyListeners();
      }
      _setLoading(false);
      return newCategory;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      print('Error adding category: $e');
      rethrow;
    }
  }

  /// Cập nhật danh mục
  Future<bool> updateCategory(Category category) async {
    _setLoading(true);
    _setError(null);

    try {
      if (category.id == null || category.id!.isEmpty) {
        throw Exception('ID danh mục không hợp lệ');
      }

      bool success = await categoryRepository.updateCategory(category);

      if (_categoriesSubscription == null && success) {
        int index = _categories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          _categories[index] = category;
          _safeNotifyListeners();
        } else {
          await fetchCategories();
        }
      }

      _setLoading(false);
      return success;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      print('Error updating category: $e');
      rethrow;
    }
  }

  /// Xóa danh mục
  Future<bool> deleteCategory(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      if (id.isEmpty) {
        throw Exception('ID danh mục không hợp lệ');
      }

      // Nếu không đang lắng nghe thay đổi thì kiểm tra danh mục tồn tại
      if (_categoriesSubscription == null) {
        bool exists = _categories.any((category) => category.id == id);
        if (!exists) {
          _setLoading(false);
          _setError('Không tìm thấy danh mục với ID: $id');
          throw Exception('Không tìm thấy danh mục với ID: $id');
        }
      }

      bool success = await categoryRepository.deleteCategory(id);

      // Nếu không đang lắng nghe thay đổi thì cập nhật mảng categories
      if (_categoriesSubscription == null && success) {
        _categories.removeWhere((category) => category.id == id);
        _safeNotifyListeners();
      }

      _setLoading(false);
      return success;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      print('Error deleting category: $e');
      rethrow;
    }
  }

  /// Tìm kiếm danh mục theo tên
  Future<List<Category>> searchCategories(String keyword) async {
    _setLoading(true);
    _setError(null);

    try {
      _categories = await categoryRepository.searchCategories(keyword);
      _setLoading(false);
      return _categories;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      print('Error searching categories: $e');
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
        _safeNotifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        print('Error listening to categories: $error');
        _safeNotifyListeners();
      },
    );
  }

  /// Hủy lắng nghe
  void cancelListening() {
    _categoriesSubscription?.cancel();
    _categoriesSubscription = null;
  }

  /// Lấy danh mục mặc định (danh mục đầu tiên nếu có)
  String? getDefaultCategory() {
    if (_categories.isNotEmpty) {
      return _categories.first.name;
    }
    return null;
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    super.dispose();
  }
}
