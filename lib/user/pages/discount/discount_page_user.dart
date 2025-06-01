import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:mockhang_app/admin/providers/discount_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DiscountPageUser extends StatefulWidget {
  @override
  _DiscountPageUserState createState() => _DiscountPageUserState();
}

class _DiscountPageUserState extends State<DiscountPageUser>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  List<String> _savedDiscountIds = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    // Tải dữ liệu khuyến mãi và mã đã lưu khi trang được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiscountProvider>(context, listen: false).loadDiscounts();
      _loadSavedDiscounts();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Đọc danh sách mã khuyến mãi đã lưu từ SharedPreferences
  Future<void> _loadSavedDiscounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _savedDiscountIds = prefs.getStringList('saved_discounts') ?? [];
      });
    } catch (e) {
      print('Error loading saved discounts: $e');
    }
  }

  // Lưu danh sách mã khuyến mãi vào SharedPreferences
  Future<void> _saveDiscountToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('saved_discounts', _savedDiscountIds);
    } catch (e) {
      print('Error saving to SharedPreferences: $e');
    }
  }

  // Lưu một mã khuyến mãi
  Future<void> _saveDiscount(DiscountModel discount) async {
    setState(() {
      if (!_savedDiscountIds.contains(discount.id)) {
        _savedDiscountIds.add(discount.id);
        _saveDiscountToPrefs();
        _showSnackBar(
          "Đã lưu mã khuyến mãi '${discount.name}'",
          AnimatedSnackBarType.success,
        );
      } else {
        _showSnackBar(
          "Mã khuyến mãi này đã được lưu",
          AnimatedSnackBarType.info,
        );
      }
    });
  }

  // Xóa một mã khuyến mãi đã lưu
  Future<void> _removeSavedDiscount(String discountId) async {
    setState(() {
      _savedDiscountIds.remove(discountId);
      _saveDiscountToPrefs();
    });
  }

  // Thực hiện tìm kiếm
  List<DiscountModel> _getFilteredDiscounts(List<DiscountModel> discounts) {
    if (_searchQuery.isEmpty) {
      return discounts;
    }

    final lowercaseQuery = _searchQuery.toLowerCase();
    return discounts.where((discount) {
      return discount.name.toLowerCase().contains(lowercaseQuery) ||
          (discount.description != null &&
              discount.description!.toLowerCase().contains(lowercaseQuery)) ||
          (discount.barcode != null &&
              discount.barcode!.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        appBar: _buildAppBar(),
        body: TabBarView(
          children: [_buildAvailableDiscountsTab(), _buildSavedDiscountsTab()],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      title:
          _isSearching
              ? TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Tìm kiếm khuyến mãi...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
              : Text(
                "Khuyến Mãi",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: Colors.white,
          ),
          onPressed: _toggleSearch,
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            Provider.of<DiscountProvider>(
              context,
              listen: false,
            ).loadDiscounts();
            _loadSavedDiscounts();
            _showSnackBar(
              "Đã làm mới danh sách khuyến mãi",
              AnimatedSnackBarType.info,
            );
          },
        ),
      ],
      bottom: TabBar(
        indicatorColor: Colors.white,
        tabs: [Tab(text: "Khuyến Mãi Có Sẵn"), Tab(text: "Đã Lưu")],
      ),
    );
  }

  // Xây dựng tab cho các khuyến mãi có sẵn
  Widget _buildAvailableDiscountsTab() {
    return Consumer<DiscountProvider>(
      builder: (context, discountProvider, child) {
        if (discountProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final filteredDiscounts = _getFilteredDiscounts(
          discountProvider.discounts,
        );

        if (filteredDiscounts.isEmpty) {
          return _buildEmptyView();
        }

        return ListView.builder(
          itemCount: filteredDiscounts.length,
          itemBuilder: (context, index) {
            final discount = filteredDiscounts[index];
            return DiscountCard(
              discount: discount,
              isSaved: _savedDiscountIds.contains(discount.id),
              onSave: () => _saveDiscount(discount),
              onRemove: null, // Không cần chức năng xóa ở tab này
            );
          },
        );
      },
    );
  }

  // Xây dựng tab cho các khuyến mãi đã lưu
  Widget _buildSavedDiscountsTab() {
    return Consumer<DiscountProvider>(
      builder: (context, discountProvider, child) {
        if (discountProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        // Lọc danh sách các mã đã lưu
        final savedDiscounts =
            discountProvider.discounts
                .where((discount) => _savedDiscountIds.contains(discount.id))
                .toList();

        if (savedDiscounts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Bạn chưa lưu mã khuyến mãi nào",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.discount),
                  label: Text("Xem khuyến mãi có sẵn"),
                  onPressed: () {
                    DefaultTabController.of(context).animateTo(0);
                  },
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: savedDiscounts.length,
          itemBuilder: (context, index) {
            final discount = savedDiscounts[index];
            return DiscountCard(
              discount: discount,
              isSaved: true,
              onSave: null, // Không cần chức năng lưu ở tab này
              onRemove: () => _removeSavedDiscount(discount.id),
            );
          },
        );
      },
    );
  }

  // Khi không tìm thấy kết quả tìm kiếm
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? "Không tìm thấy khuyến mãi phù hợp"
                : "Chưa có khuyến mãi nào",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 24),
          if (_searchQuery.isNotEmpty)
            ElevatedButton.icon(
              icon: Icon(Icons.clear),
              label: Text("Xóa tìm kiếm"),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _isSearching = false;
                  _animationController.reverse();
                });
              },
            ),
        ],
      ),
    );
  }

  // Hiển thị thông báo
  void _showSnackBar(String message, AnimatedSnackBarType type) {
    AnimatedSnackBar.material(
      message,
      type: type,
      duration: Duration(seconds: 3),
    ).show(context);
  }

  // Thay đổi trạng thái tìm kiếm
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _animationController.forward();
      } else {
        _searchController.clear();
        _searchQuery = '';
        _animationController.reverse();
      }
    });
  }
}

class DiscountCard extends StatelessWidget {
  final DiscountModel discount;
  final bool isSaved;
  final VoidCallback? onSave;
  final VoidCallback? onRemove;

  DiscountCard({
    required this.discount,
    required this.isSaved,
    this.onSave,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getDiscountValueText(discount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Spacer(),
                _buildActionButton(),
              ],
            ),
            SizedBox(height: 8),
            Text(
              discount.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              discount.description ?? "Không có mô tả",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(
                  context,
                  "Loại: ${_getDiscountTypeText(discount.type)}",
                  Icons.category,
                ),
              ],
            ),
            SizedBox(height: 16),
            if (discount.barcode != null && discount.barcode!.isNotEmpty) ...[
              Divider(),
              Center(
                child: Column(
                  children: [
                    Text(
                      "Mã Khuyến Mãi",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: discount.barcode!,
                      width: 200,
                      height: 70,
                      drawText: true,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getDiscountValueText(DiscountModel discount) {
    return discount.type == 'percentage'
        ? "Giảm ${discount.value}%"
        : "Giảm ${_formatCurrency(discount.value)}đ";
  }

  String _formatCurrency(num value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).primaryColor),
          SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (isSaved) {
      return onRemove != null
          ? IconButton(
            icon: Icon(Icons.bookmark, color: Colors.orange),
            onPressed: onRemove,
            tooltip: 'Bỏ lưu khuyến mãi',
          )
          : Icon(Icons.bookmark, color: Colors.orange);
    } else {
      return onSave != null
          ? IconButton(
            icon: Icon(Icons.bookmark_add_outlined),
            onPressed: onSave,
            tooltip: 'Lưu khuyến mãi',
          )
          : SizedBox.shrink();
    }
  }

  String _getDiscountTypeText(String type) {
    switch (type) {
      case 'percentage':
        return 'Phần trăm';
      case 'fixed_amount':
        return 'Số tiền cố định';
      default:
        return type;
    }
  }
}
