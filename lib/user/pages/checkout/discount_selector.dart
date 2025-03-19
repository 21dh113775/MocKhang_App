import 'package:flutter/material.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:intl/intl.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscountSelector extends StatefulWidget {
  final Function(DiscountModel?) onDiscountSelected;
  final double orderTotal;
  final List<DiscountModel> availableDiscounts;

  const DiscountSelector({
    Key? key,
    required this.onDiscountSelected,
    required this.orderTotal,
    required this.availableDiscounts,
  }) : super(key: key);

  @override
  State<DiscountSelector> createState() => _DiscountSelectorState();
}

class _DiscountSelectorState extends State<DiscountSelector> {
  DiscountModel? _selectedDiscount;
  List<DiscountModel> _savedDiscounts = [];
  bool _isLoading = true;
  final TextEditingController _discountCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedDiscounts();
  }

  @override
  void dispose() {
    _discountCodeController.dispose();
    super.dispose();
  }

  // Tải danh sách mã giảm giá đã lưu
  Future<void> _loadSavedDiscounts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIds = prefs.getStringList('saved_discounts') ?? [];

      // Ghi log để kiểm tra
      print('Saved discount IDs: $savedIds');
      print('Available discounts: ${widget.availableDiscounts.length}');

      // Lọc các khuyến mãi đã lưu - bỏ điều kiện isValid() để xem có hiển thị không
      final savedDiscounts =
          widget.availableDiscounts
              .where((discount) => savedIds.contains(discount.id))
              .toList();

      print('Filtered saved discounts: ${savedDiscounts.length}');

      setState(() {
        _savedDiscounts = savedDiscounts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading saved discounts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Debug - kiểm tra mã giảm giá đã lưu
  void _debugSavedDiscounts() {
    print('Current saved discounts:');
    for (var discount in _savedDiscounts) {
      print(
        'ID: ${discount.id}, Name: ${discount.name}, Valid: ${discount.isValid()}',
      );
    }
  }

  // Kiểm tra mã khuyến mãi
  void _checkDiscountCode() {
    final code = _discountCodeController.text.trim();
    if (code.isEmpty) {
      _showSnackBar(
        "Vui lòng nhập mã khuyến mãi",
        AnimatedSnackBarType.warning,
      );
      return;
    }

    try {
      final matchingDiscount = widget.availableDiscounts.firstWhere(
        (discount) => discount.code == code && discount.isValid(),
        orElse:
            () => DiscountModel(
              id: '',
              code: '',
              name: '',
              type: '',
              value: 0,
              startDate: 0,
              endDate: 0,
            ),
      );

      if (matchingDiscount.id.isNotEmpty) {
        _applyDiscount(matchingDiscount);
        _discountCodeController.clear();
      } else {
        _showSnackBar(
          "Mã khuyến mãi không hợp lệ hoặc đã hết hạn",
          AnimatedSnackBarType.error,
        );
      }
    } catch (e) {
      _showSnackBar(
        "Lỗi khi áp dụng mã khuyến mãi: ${e.toString()}",
        AnimatedSnackBarType.error,
      );
    }
  }

  // Áp dụng mã khuyến mãi
  void _applyDiscount(DiscountModel discount) {
    setState(() {
      _selectedDiscount = discount;
    });
    widget.onDiscountSelected(discount);

    _showSnackBar(
      "Đã áp dụng khuyến mãi '${discount.name}'",
      AnimatedSnackBarType.success,
    );
  }

  // Xóa mã khuyến mãi đang áp dụng
  void _removeDiscount() {
    setState(() {
      _selectedDiscount = null;
    });
    widget.onDiscountSelected(null);

    _showSnackBar("Đã hủy áp dụng khuyến mãi", AnimatedSnackBarType.info);
  }

  // Tính số tiền giảm
  double _calculateDiscountAmount() {
    if (_selectedDiscount == null) return 0;

    if (_selectedDiscount!.type == 'percentage') {
      return widget.orderTotal * _selectedDiscount!.value / 100;
    } else {
      return _selectedDiscount!.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug - in ra thông tin để kiểm tra
    _debugSavedDiscounts();

    final discountAmount = _calculateDiscountAmount();
    final finalTotal = widget.orderTotal - discountAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_selectedDiscount != null)
          _buildSelectedDiscountCard()
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hiển thị dropdown mã khuyến mãi đã lưu trước tiên
              if (_savedDiscounts.isNotEmpty) _buildSavedDiscountsDropdown(),

              if (_savedDiscounts.isNotEmpty) const SizedBox(height: 20),

              // Nhập mã khuyến mãi
              _buildDiscountInputSection(),
            ],
          ),

        if (_selectedDiscount != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tổng tiền:"),
                    Text(
                      "${_formatCurrency(widget.orderTotal)} VNĐ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Giảm giá:"),
                    Text(
                      "-${_formatCurrency(discountAmount)} VNĐ",
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Thành tiền:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${_formatCurrency(finalTotal)} VNĐ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Dropdown để chọn mã khuyến mãi đã lưu
  Widget _buildSavedDiscountsDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Mã khuyến mãi đã lưu",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DiscountModel>(
              isExpanded: true,
              hint: const Text("Chọn mã khuyến mãi đã lưu"),
              value: null,
              items:
                  _savedDiscounts.map((discount) {
                    return DropdownMenuItem<DiscountModel>(
                      value: discount,
                      child: Text(
                        "${discount.name} (${_getDiscountText(discount)})",
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
              onChanged: (DiscountModel? discount) {
                if (discount != null) {
                  _applyDiscount(discount);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  String _getDiscountText(DiscountModel discount) {
    return discount.type == 'percentage'
        ? "Giảm ${discount.value}%"
        : "Giảm ${_formatCurrency(discount.value)}đ";
  }

  // Phần nhập mã khuyến mãi
  Widget _buildDiscountInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Nhập mã khuyến mãi",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _discountCodeController,
                decoration: const InputDecoration(
                  hintText: "Nhập mã khuyến mãi",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _checkDiscountCode,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text("Áp dụng"),
            ),
          ],
        ),
      ],
    );
  }

  // Phần hiển thị khuyến mãi đã chọn
  Widget _buildSelectedDiscountCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        "Đang áp dụng",
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: _removeDiscount,
                  tooltip: 'Hủy áp dụng',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _selectedDiscount!.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _selectedDiscount!.type == 'percentage'
                  ? "Giảm ${_selectedDiscount!.value}% trên tổng hóa đơn"
                  : "Giảm ${_formatCurrency(_selectedDiscount!.value)} VNĐ trên tổng hóa đơn",
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm định dạng số tiền
  String _formatCurrency(double value) {
    final format = NumberFormat.currency(locale: "vi_VN", symbol: "");
    return format.format(value);
  }

  // Hiển thị SnackBar thông báo
  void _showSnackBar(String message, AnimatedSnackBarType type) {
    AnimatedSnackBar.material(
      message,
      type: type,
      duration: const Duration(seconds: 3),
    ).show(context);
  }
}
