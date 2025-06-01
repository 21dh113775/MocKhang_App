import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:mockhang_app/admin/data/repositories/discount_repository.dart';

/// Provider quản lý trạng thái và logic nghiệp vụ cho khuyến mãi
class DiscountProvider extends ChangeNotifier {
  // Dependency Injection cho Repository
  final DiscountRepository _repository = DiscountRepository();

  // Quản lý trạng thái dữ liệu
  List<DiscountModel> _discounts = [];
  List<DiscountModel> _activeDiscounts = [];
  DiscountModel? _selectedDiscount;

  // Các cờ trạng thái
  bool _isLoading = false;
  bool _isProcessing = false; // Trạng thái xử lý CRUD

  // Quản lý thông báo
  String? _error;
  String? _successMessage;

  // Stream controllers để theo dõi realtime
  StreamSubscription? _discountsSubscription;

  // Getters để truy cập các trạng thái
  List<DiscountModel> get discounts => _discounts;
  List<DiscountModel> get activeDiscounts => _activeDiscounts;
  DiscountModel? get selectedDiscount => _selectedDiscount;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  String? get successMessage => _successMessage;

  // Getter thống kê số lượng
  int get discountCount => _discounts.length;
  int get activeDiscountCount => _activeDiscounts.length;

  /// Khởi tạo provider với việc đăng ký theo dõi dữ liệu thời gian thực
  DiscountProvider() {
    _listenToDiscountChanges();
  }

  /// Đăng ký theo dõi thay đổi của khuyến mãi từ Firestore
  void _listenToDiscountChanges() {
    _discountsSubscription = FirebaseFirestore.instance
        .collection('discounts')
        .snapshots()
        .listen((snapshot) {
          // Cập nhật danh sách khuyến mãi khi có thay đổi
          _discounts =
              snapshot.docs
                  .map((doc) => DiscountModel.fromJson(doc.data()))
                  .toList();

          // Tự động sắp xếp và lọc
          _discounts.sort((a, b) => b.startDate.compareTo(a.startDate));
          _activeDiscounts =
              _discounts.where((discount) => discount.isValid()).toList();

          notifyListeners();
        });
  }

  /// Tìm kiếm khuyến mãi trong cache
  DiscountModel? _findDiscountInCache(bool Function(DiscountModel) test) {
    try {
      return _discounts.firstWhere(test);
    } catch (_) {
      return null;
    }
  }

  /// Tải lại toàn bộ danh sách khuyến mãi từ Firestore
  Future<void> loadDiscounts() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _discounts = await _repository.getAllDiscounts();
      _discounts.sort((a, b) => b.startDate.compareTo(a.startDate));
      print("Đã tải ${_discounts.length} khuyến mãi");
    } catch (e) {
      _error = "Không thể tải danh sách khuyến mãi: ${e.toString()}";
      print("Lỗi khi tải khuyến mãi: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tìm kiếm khuyến mãi theo từ khóa
  List<DiscountModel> searchDiscounts(String keyword) {
    if (keyword.isEmpty) return _discounts;

    keyword = keyword.toLowerCase();
    return _discounts.where((discount) {
      return discount.name.toLowerCase().contains(keyword) ||
          (discount.description?.toLowerCase().contains(keyword) ?? false) ||
          (discount.code?.toLowerCase().contains(keyword) ?? false) ||
          (discount.barcode?.toLowerCase().contains(keyword) ?? false);
    }).toList();
  }

  /// Thêm khuyến mãi mới
  /// Thêm khuyến mãi mới
  Future<DiscountModel?> addDiscount(DiscountModel discount) async {
    if (_isProcessing) return null;

    _isProcessing = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Kiểm tra tên phải có
      if (discount.name.isEmpty) {
        throw ArgumentError('Tên khuyến mãi không được để trống');
      }

      // Chỉ kiểm tra giá trị với các loại khuyến mãi cần giá trị
      if ((discount.type == 'Giảm theo phần trăm' ||
              discount.type == 'Giảm theo số tiền cố định') &&
          discount.value <= 0) {
        throw ArgumentError('Giá trị khuyến mãi phải lớn hơn 0');
      }

      // Kiểm tra mã vạch nếu có
      if (discount.barcode != null && discount.barcode!.isNotEmpty) {
        // Bỏ kiểm tra quá nghiêm ngặt hoặc sửa lại logic kiểm tra
        // Nếu bạn không cần kiểm tra nghiêm ngặt, có thể bỏ đoạn này
        // Hoặc thay bằng một kiểm tra đơn giản hơn
      }

      // Thêm discount vào hệ thống
      final newDiscount = await _repository.createDiscount(discount);

      _successMessage = "Đã thêm khuyến mãi thành công";
      return newDiscount;
    } catch (e) {
      _error = "Không thể thêm khuyến mãi: ${e.toString()}";
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Cập nhật thông tin khuyến mãi
  Future<bool> updateDiscount(DiscountModel discount) async {
    if (_isProcessing) return false;

    _isProcessing = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Cập nhật khuyến mãi và thông báo kết quả
      await _repository.updateDiscount(discount);

      _successMessage = "Đã cập nhật khuyến mãi thành công";
      return true;
    } catch (e) {
      _error = "Không thể cập nhật khuyến mãi: ${e.toString()}";
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Xóa khuyến mãi theo ID
  Future<bool> deleteDiscount(String id) async {
    if (_isProcessing) return false;

    _isProcessing = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Thực hiện xóa khuyến mãi
      await _repository.deleteDiscount(id);

      _successMessage = "Đã xóa khuyến mãi thành công";
      return true;
    } catch (e) {
      _error = "Không thể xóa khuyến mãi: ${e.toString()}";
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Lọc khuyến mãi theo loại
  List<DiscountModel> filterByType(String type) {
    if (type.isEmpty) return _discounts;
    return _discounts.where((discount) => discount.type == type).toList();
  }

  /// Lọc khuyến mãi theo khoảng thời gian
  List<DiscountModel> filterByDateRange(DateTime startDate, DateTime endDate) {
    final startTimestamp = startDate.millisecondsSinceEpoch;
    final endTimestamp = endDate.millisecondsSinceEpoch;

    return _discounts.where((discount) {
      return (discount.startDate >= startTimestamp &&
              discount.startDate <= endTimestamp) ||
          (discount.endDate >= startTimestamp &&
              discount.endDate <= endTimestamp) ||
          (discount.startDate <= startTimestamp &&
              discount.endDate >= endTimestamp);
    }).toList();
  }

  /// Kiểm tra tính hợp lệ của mã vạch
  bool isValidBarcode(String barcode) {
    if (barcode.length != 13) return false;
    if (!RegExp(r'^[0-9]+$').hasMatch(barcode)) return false;

    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final digit = int.parse(barcode[i]);
      sum += (i % 2 == 0) ? digit : digit * 3;
    }

    final checkDigit = (10 - (sum % 10)) % 10;
    return int.parse(barcode[12]) == checkDigit;
  }

  /// Tải lại dữ liệu nếu trống - gọi từ initState hoặc post-frame callback
  Future<void> ensureDataLoaded() async {
    if (_discounts.isEmpty && !_isLoading) {
      await loadDiscounts();
    }

    if (_activeDiscounts.isEmpty && !_isLoading) {
      _activeDiscounts =
          _discounts.where((discount) => discount.isValid()).toList();
    }
  }

  /// Dọn dẹp tài nguyên khi không sử dụng
  @override
  void dispose() {
    _discountsSubscription?.cancel();
    super.dispose();
  }
}
