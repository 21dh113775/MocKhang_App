import 'package:flutter/foundation.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoriteProvider with ChangeNotifier {
  List<Product> _favoriteItems = [];

  List<Product> get favoriteItems => _favoriteItems;

  FavoriteProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesData = prefs.getStringList('favorites') ?? [];

      _favoriteItems = [];
      for (var jsonString in favoritesData) {
        try {
          final Map<String, dynamic> productMap = jsonDecode(jsonString);
          final product = Product.fromJson(productMap);
          _favoriteItems.add(product);
        } catch (e) {
          debugPrint('Error parsing product: $e');
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesData =
          _favoriteItems.map((product) {
            return jsonEncode(product.toMap());
          }).toList();

      await prefs.setStringList('favorites', favoritesData);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  bool isFavorite(Product product) {
    return _favoriteItems.any((item) => item.id == product.id);
  }

  void toggleFavorite(Product product) {
    final isExist = _favoriteItems.any((item) => item.id == product.id);

    if (isExist) {
      _favoriteItems.removeWhere((item) => item.id == product.id);
    } else {
      _favoriteItems.add(product);
    }

    notifyListeners();
    _saveFavorites();
  }

  void clearFavorites() {
    _favoriteItems.clear();
    notifyListeners();
    _saveFavorites();
  }
}
