import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/cart_model.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  DiscountModel? _appliedDiscount;

  // Thêm các thuộc tính mới cho phương thức thanh toán và vận chuyển
  String? _paymentMethod;
  String? _shippingMethod;
  String? _orderMessage; // Lưu thông tin lời nhắn
  TextEditingController discountController = TextEditingController();

  // Getter để lấy thông tin các thuộc tính
  List<CartItem> get items => _items;
  DiscountModel? get appliedDiscount => _appliedDiscount;
  String? get paymentMethod => _paymentMethod;
  String? get shippingMethod => _shippingMethod;
  String? get orderMessage => _orderMessage;

  void _safeNotifyListeners() {
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      Future.microtask(() => notifyListeners());
    }
  }

  // Cập nhật các phương thức chọn phương thức thanh toán và vận chuyển
  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void clearCart() {
    _items.clear(); // Xóa toàn bộ giỏ hàng
    notifyListeners();
  }

  void setShippingMethod(String method) {
    _shippingMethod = method;
    notifyListeners();
  }

  // Thêm sản phẩm vào giỏ hàng
  void addItem(Product product, int quantity) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );
    String imageUrl = product.imageUrl;

    // Kiểm tra đường dẫn hình ảnh hợp lệ
    if (imageUrl.isEmpty || !Uri.tryParse(imageUrl)!.isAbsolute) {
      imageUrl =
          'https://via.placeholder.com/150'; // Cung cấp hình ảnh mặc định
    }

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          product: product.copyWith(imageUrl: imageUrl),
          quantity: quantity,
          isSelected: true,
        ),
      );
    }
    notifyListeners();
  }

  // Cập nhật số lượng sản phẩm trong giỏ hàng
  void updateQuantity(String? productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  // Giảm số lượng sản phẩm
  void decreaseQuantity(String? productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0 && _items[index].quantity > 1) {
      _items[index].quantity--;
      notifyListeners();
    }
  }

  // Tăng số lượng sản phẩm
  void increaseQuantity(String? productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  // Xóa sản phẩm khỏi giỏ hàng
  void removeItem(String? productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // Cập nhật trạng thái chọn sản phẩm
  void toggleItemSelection(String? productId) {
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

  // Kiểm tra xem có đủ dữ liệu để thanh toán không
  bool get isValidCheckout {
    return _items.isNotEmpty &&
        hasSelectedItems &&
        paymentMethod != null &&
        shippingMethod != null;
  }

  // Các phương thức xử lý vận chuyển và thanh toán
  double get standardShippingCost => 20000; // Phí giao hàng tiêu chuẩn
  double get expressShippingCost => 40000; // Phí giao hàng nhanh

  double get shippingCost {
    if (_shippingMethod == 'Express') {
      return expressShippingCost;
    } else {
      return standardShippingCost;
    }
  }

  // Thêm thông tin lời nhắn
  void setOrderMessage(String message) {
    _orderMessage = message;
    notifyListeners();
  }
}

// Extension để kiểm tra tính hợp lệ của mã giảm giá
extension DiscountValidation on DiscountModel {
  bool isValid() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= startDate && now <= endDate;
  }
}
