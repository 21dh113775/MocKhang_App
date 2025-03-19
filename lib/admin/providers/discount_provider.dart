import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:mockhang_app/admin/data/repositories/discount_repository.dart';

class DiscountProvider extends ChangeNotifier {
  final DiscountRepository _repository = DiscountRepository();

  // State management
  List<DiscountModel> _discounts = [];
  List<DiscountModel> _activeDiscounts = [];
  DiscountModel? _selectedDiscount;
  bool _isLoading = false;
  bool _isProcessing = false; // Trạng thái khi đang xử lý CRUD
  String? _error;
  String? _successMessage;

  // Getters
  List<DiscountModel> get discounts => _discounts;
  List<DiscountModel> get activeDiscounts => _activeDiscounts;
  DiscountModel? get selectedDiscount => _selectedDiscount;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  String? get successMessage => _successMessage;

  // Lấy số lượng khuyến mãi
  int get discountCount => _discounts.length;

  // Lấy số lượng khuyến mãi đang hoạt động
  int get activeDiscountCount => _activeDiscounts.length;

  // Helper method để tìm discount trong cache một cách an toàn
  DiscountModel? _findDiscountInCache(bool Function(DiscountModel) test) {
    try {
      return _discounts.firstWhere(test);
    } catch (_) {
      return null;
    }
  }

  // Lấy tất cả khuyến mãi
  Future<void> loadDiscounts() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _discounts = await _repository.getAllDiscounts();
      // Sắp xếp theo thời gian bắt đầu, mới nhất lên đầu
      _discounts.sort((a, b) => b.startDate.compareTo(a.startDate));
      print("Đã tải ${_discounts.length} khuyến mãi");
    } catch (e) {
      print("Lỗi khi tải khuyến mãi: $e");
      _error = "Không thể tải danh sách khuyến mãi: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy các khuyến mãi đang hoạt động
  Future<void> loadActiveDiscounts() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activeDiscounts = await _repository.getActiveDiscounts();
      print("Đã tải ${_activeDiscounts.length} khuyến mãi đang hoạt động");
    } catch (e) {
      print("Lỗi khi tải khuyến mãi đang hoạt động: $e");
      _error = "Không thể tải khuyến mãi đang hoạt động: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tìm kiếm khuyến mãi theo từ khóa
  List<DiscountModel> searchDiscounts(String keyword) {
    if (keyword.isEmpty) return _discounts;

    keyword = keyword.toLowerCase();
    return _discounts
        .where(
          (discount) =>
              discount.name.toLowerCase().contains(keyword) ||
              (discount.description?.toLowerCase().contains(keyword) ??
                  false) ||
              (discount.code?.toLowerCase().contains(keyword) ?? false) ||
              (discount.barcode?.toLowerCase().contains(keyword) ?? false),
        )
        .toList();
  }

  // Tìm kiếm khuyến mãi theo mã vạch
  Future<DiscountModel?> findDiscountByBarcode(String barcode) async {
    if (_isProcessing) return null;

    _isProcessing = true;
    notifyListeners();

    try {
      // Tìm trong cache trước
      final cachedDiscount = _findDiscountInCache(
        (discount) => discount.barcode == barcode,
      );

      if (cachedDiscount != null) {
        return cachedDiscount;
      }

      // Tìm trong database
      final db = await _repository.database;
      final result = await db.query(
        'discounts',
        where: 'barcode = ?',
        whereArgs: [barcode],
      );

      if (result.isNotEmpty) {
        return DiscountModel.fromJson(result.first);
      }

      return null;
    } catch (e) {
      print("Lỗi khi tìm khuyến mãi theo mã vạch: $e");
      _error = "Không thể tìm khuyến mãi: ${e.toString()}";
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Thêm khuyến mãi mới
  Future<DiscountModel?> addDiscount(DiscountModel discount) async {
    if (_isProcessing) return null;

    _isProcessing = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      print("Đang thêm khuyến mãi mới: ${discount.name}");
      final newDiscount = await _repository.createDiscount(discount);
      _discounts.add(newDiscount);

      // Tự động sắp xếp lại danh sách
      _discounts.sort((a, b) => b.startDate.compareTo(a.startDate));

      _successMessage = "Đã thêm khuyến mãi thành công";
      print("Đã thêm khuyến mãi thành công với ID: ${newDiscount.id}");

      // Cập nhật danh sách khuyến mãi đang hoạt động
      await loadActiveDiscounts();

      return newDiscount;
    } catch (e) {
      print("Lỗi khi thêm khuyến mãi: $e");
      _error = "Không thể thêm khuyến mãi: ${e.toString()}";
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Cập nhật khuyến mãi
  Future<bool> updateDiscount(DiscountModel discount) async {
    if (_isProcessing) return false;

    _isProcessing = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      print("Đang cập nhật khuyến mãi: ${discount.id}");
      final result = await _repository.updateDiscount(discount);

      if (result > 0) {
        // Cập nhật thành công
        final index = _discounts.indexWhere((d) => d.id == discount.id);
        if (index != -1) {
          _discounts[index] = discount;

          // Nếu đang hiển thị chi tiết discount này, cập nhật lại
          if (_selectedDiscount?.id == discount.id) {
            _selectedDiscount = discount;
          }

          _successMessage = "Đã cập nhật khuyến mãi thành công";
          print("Đã cập nhật khuyến mãi thành công");

          // Cập nhật danh sách khuyến mãi đang hoạt động
          await loadActiveDiscounts();

          return true;
        }
      }

      _error = "Không thể cập nhật khuyến mãi";
      return false;
    } catch (e) {
      print("Lỗi khi cập nhật khuyến mãi: $e");
      _error = "Không thể cập nhật khuyến mãi: ${e.toString()}";
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Xóa khuyến mãi
  Future<bool> deleteDiscount(String id) async {
    if (_isProcessing) return false;

    _isProcessing = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      print("Đang xóa khuyến mãi: $id");
      final result = await _repository.deleteDiscount(id);

      if (result > 0) {
        // Xóa thành công
        _discounts.removeWhere((discount) => discount.id == id);

        // Nếu đang hiển thị chi tiết discount này, xóa lựa chọn
        if (_selectedDiscount?.id == id) {
          _selectedDiscount = null;
        }

        _successMessage = "Đã xóa khuyến mãi thành công";
        print("Đã xóa khuyến mãi thành công");

        // Cập nhật danh sách khuyến mãi đang hoạt động
        await loadActiveDiscounts();

        return true;
      }

      _error = "Không thể xóa khuyến mãi";
      return false;
    } catch (e) {
      print("Lỗi khi xóa khuyến mãi: $e");
      _error = "Không thể xóa khuyến mãi: ${e.toString()}";
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Lấy thông tin khuyến mãi theo ID
  Future<DiscountModel?> getDiscount(String id) async {
    // Tìm trong cache trước
    final cachedDiscount = _findDiscountInCache(
      (discount) => discount.id == id,
    );

    if (cachedDiscount != null) {
      // Update selection without notifying during build
      _selectedDiscount = cachedDiscount;
      notifyListeners();
      return cachedDiscount;
    }

    // Nếu không có trong cache, tải từ database
    if (_isProcessing) return null;

    _isProcessing = true;
    notifyListeners();

    try {
      print("Đang tải thông tin khuyến mãi ID: $id");
      final discount = await _repository.getDiscountById(id);

      if (discount != null) {
        _selectedDiscount = discount;
        print("Đã tải thông tin khuyến mãi: ${discount.name}");
      } else {
        print("Không tìm thấy khuyến mãi với ID: $id");
      }

      return discount;
    } catch (e) {
      print("Lỗi khi tải thông tin khuyến mãi: $e");
      _error = "Không thể tải thông tin khuyến mãi: ${e.toString()}";
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Tạo mã vạch mới cho khuyến mãi
  Future<bool> generateNewBarcode(String discountId) async {
    if (_isProcessing) return false;

    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      // Tìm khuyến mãi
      final discount = _findDiscountInCache(
        (discount) => discount.id == discountId,
      );

      final discountToUpdate =
          discount ?? await _repository.getDiscountById(discountId);

      if (discountToUpdate == null) {
        _error = "Không tìm thấy khuyến mãi";
        return false;
      }

      // Tạo mã vạch mới
      final newBarcode = _repository.generateBarcode(discountId);

      // Cập nhật khuyến mãi với mã vạch mới
      final updatedDiscount = discountToUpdate.copyWith(barcode: newBarcode);
      final success = await updateDiscount(updatedDiscount);

      if (success) {
        _successMessage = "Đã tạo mã vạch mới thành công";
        return true;
      } else {
        _error = "Không thể cập nhật mã vạch";
        return false;
      }
    } catch (e) {
      print("Lỗi khi tạo mã vạch mới: $e");
      _error = "Không thể tạo mã vạch mới: ${e.toString()}";
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Kiểm tra một mã vạch đã tồn tại hay chưa
  Future<bool> isBarcodeExists(String barcode) async {
    try {
      final discount = await findDiscountByBarcode(barcode);
      return discount != null;
    } catch (e) {
      print("Lỗi khi kiểm tra mã vạch: $e");
      return false;
    }
  }

  // Làm mới dữ liệu sau khi có thay đổi
  Future<void> refreshData() async {
    await loadDiscounts();
    await loadActiveDiscounts();
  }

  // Xóa lỗi
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Xóa thông báo thành công
  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  // Tải lại dữ liệu nếu trống - call this from initState or post-frame callback
  Future<void> ensureDataLoaded() async {
    if (_discounts.isEmpty && !_isLoading) {
      await loadDiscounts();
    }

    if (_activeDiscounts.isEmpty && !_isLoading) {
      await loadActiveDiscounts();
    }
  }

  // Lọc khuyến mãi theo loại - pure function, no state update
  List<DiscountModel> filterByType(String type) {
    if (type.isEmpty) return _discounts;
    return _discounts.where((discount) => discount.type == type).toList();
  }

  // Lọc khuyến mãi theo thời gian - pure function, no state update
  List<DiscountModel> filterByDateRange(DateTime startDate, DateTime endDate) {
    final startTimestamp = startDate.millisecondsSinceEpoch;
    final endTimestamp = endDate.millisecondsSinceEpoch;

    return _discounts
        .where(
          (discount) =>
              (discount.startDate >= startTimestamp &&
                  discount.startDate <= endTimestamp) ||
              (discount.endDate >= startTimestamp &&
                  discount.endDate <= endTimestamp) ||
              (discount.startDate <= startTimestamp &&
                  discount.endDate >= endTimestamp),
        )
        .toList();
  }

  // Kiểm tra xem mã vạch có hợp lệ không (theo định dạng EAN-13)
  bool isValidBarcode(String barcode) {
    // Kiểm tra độ dài và định dạng của mã vạch
    if (barcode.length != 13) return false;

    // Kiểm tra chỉ chứa số
    if (!RegExp(r'^[0-9]+$').hasMatch(barcode)) return false;

    // Kiểm tra mã kiểm tra EAN-13 (check digit)
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final digit = int.parse(barcode[i]);
      sum += (i % 2 == 0) ? digit : digit * 3;
    }

    final checkDigit = (10 - (sum % 10)) % 10;
    return int.parse(barcode[12]) == checkDigit;
  }
}
