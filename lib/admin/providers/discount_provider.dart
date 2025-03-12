import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:mockhang_app/admin/data/repositories/discount_repository.dart'
    show DiscountRepository;

class DiscountProvider extends ChangeNotifier {
  final DiscountRepository _repository = DiscountRepository();

  List<DiscountModel> _discounts = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<DiscountModel> get discounts => _discounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Lấy tất cả khuyến mãi
  Future<void> loadDiscounts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print("Đang tải danh sách khuyến mãi...");
      _discounts = await _repository.getAllDiscounts();
      print("Đã tải ${_discounts.length} khuyến mãi");

      // Debug: Kiểm tra dữ liệu đã tải
      if (_discounts.isNotEmpty) {
        print("Mẫu khuyến mãi đầu tiên: ${_discounts.first}");
      } else {
        print("Không có khuyến mãi nào được tìm thấy");
      }
    } catch (e) {
      print("Lỗi khi tải khuyến mãi: $e");
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thêm khuyến mãi mới
  Future<void> addDiscount(DiscountModel discount) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print("Đang thêm khuyến mãi mới: ${discount.name}");
      final newDiscount = await _repository.createDiscount(discount);
      _discounts.add(newDiscount);
      print("Đã thêm khuyến mãi thành công với ID: ${newDiscount.id}");
    } catch (e) {
      print("Lỗi khi thêm khuyến mãi: $e");
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật khuyến mãi
  Future<void> updateDiscount(DiscountModel discount) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print("Đang cập nhật khuyến mãi: ${discount.id}");
      await _repository.updateDiscount(discount);
      final index = _discounts.indexWhere((d) => d.id == discount.id);
      if (index != -1) {
        _discounts[index] = discount;
        print("Đã cập nhật khuyến mãi thành công");
      } else {
        print("Không tìm thấy khuyến mãi trong danh sách local");
        // Nếu không tìm thấy trong danh sách local, tải lại toàn bộ
        await loadDiscounts();
      }
    } catch (e) {
      print("Lỗi khi cập nhật khuyến mãi: $e");
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Xóa khuyến mãi
  Future<void> deleteDiscount(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print("Đang xóa khuyến mãi: $id");
      await _repository.deleteDiscount(id);
      _discounts.removeWhere((discount) => discount.id == id);
      print("Đã xóa khuyến mãi thành công");
    } catch (e) {
      print("Lỗi khi xóa khuyến mãi: $e");
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy thông tin khuyến mãi theo ID
  Future<DiscountModel?> getDiscount(String id) async {
    try {
      print("Đang tải thông tin khuyến mãi ID: $id");
      final discount = await _repository.getDiscountById(id);
      print("Đã tải thông tin khuyến mãi: ${discount?.name}");
      return discount;
    } catch (e) {
      print("Lỗi khi tải thông tin khuyến mãi: $e");
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Làm mới dữ liệu sau khi có thay đổi
  void refreshData() {
    loadDiscounts();
  }

  // Xóa lỗi
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Tải lại dữ liệu nếu trống
  Future<void> ensureDataLoaded() async {
    if (_discounts.isEmpty && !_isLoading) {
      await loadDiscounts();
    }
  }
}
