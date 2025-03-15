// providers/cart_provider.dart
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/cart_model.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  DiscountModel? _appliedDiscount;

  List<CartItem> get items => _items;
  DiscountModel? get appliedDiscount => _appliedDiscount;

  // Thêm sản phẩm vào giỏ hàng
  void addItem(Product product, int quantity) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItem(product: product, quantity: quantity, isSelected: true),
      );
    }
    notifyListeners();
  }

  // Cập nhật số lượng sản phẩm
  void updateQuantity(int? productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  // Giảm số lượng sản phẩm
  void decreaseQuantity(int? productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0 && _items[index].quantity > 1) {
      _items[index].quantity--;
      notifyListeners();
    }
  }

  // Tăng số lượng sản phẩm
  void increaseQuantity(int? productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  // Xóa sản phẩm khỏi giỏ hàng
  void removeItem(int? productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // Cập nhật trạng thái chọn của sản phẩm
  void toggleItemSelection(int? productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].isSelected = !_items[index].isSelected;
      notifyListeners();
    }
  }

  // Chọn tất cả sản phẩm
  void selectAll(bool isSelected) {
    for (var item in _items) {
      item.isSelected = isSelected;
    }
    notifyListeners();
  }

  // Áp dụng mã giảm giá
  void applyDiscount(DiscountModel discount) {
    _appliedDiscount = discount;
    notifyListeners();
  }

  // Xóa mã giảm giá
  void removeDiscount() {
    _appliedDiscount = null;
    notifyListeners();
  }

  // Tính tổng số lượng sản phẩm đã chọn
  int get selectedItemCount {
    return _items
        .where((item) => item.isSelected)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  // Tính tổng tiền sản phẩm đã chọn (chưa áp dụng giảm giá)
  double get subtotal {
    return _items
        .where((item) => item.isSelected)
        .fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  // Tính số tiền được giảm
  double get discountAmount {
    if (_appliedDiscount == null) return 0;

    if (_appliedDiscount!.type == 'percentage') {
      return subtotal * _appliedDiscount!.value / 100;
    } else {
      return _appliedDiscount!.value;
    }
  }

  // Tính tổng tiền phải thanh toán
  double get total {
    return subtotal - discountAmount;
  }

  // Kiểm tra xem giỏ hàng có trống không
  bool get isEmpty => _items.isEmpty;

  // Kiểm tra xem có sản phẩm nào được chọn không
  bool get hasSelectedItems => _items.any((item) => item.isSelected);
}
