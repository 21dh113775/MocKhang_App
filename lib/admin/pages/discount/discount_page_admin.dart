import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:mockhang_app/admin/pages/discount/discount_add.dart';
import 'package:mockhang_app/admin/pages/discount/discount_detail_page_admin%20.dart';
import 'package:mockhang_app/admin/pages/discount/discount_edit_page.dart';
import 'package:mockhang_app/admin/providers/discount_provider.dart';
import 'package:provider/provider.dart';

class DiscountPageAdmin extends StatefulWidget {
  @override
  _DiscountPageAdminState createState() => _DiscountPageAdminState();
}

class _DiscountPageAdminState extends State<DiscountPageAdmin>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    // Tải dữ liệu khuyến mãi khi trang được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiscountProvider>(context, listen: false).loadDiscounts();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiscountAddPageAdmin()),
          );

          if (result == true) {
            _showSnackBar(
              "Đã thêm khuyến mãi mới",
              AnimatedSnackBarType.success,
            );
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Thêm khuyến mãi',
        backgroundColor: Theme.of(context).primaryColor,
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
                "Quản lý Khuyến Mãi",
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
            _showSnackBar(
              "Đã làm mới danh sách khuyến mãi",
              AnimatedSnackBarType.info,
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
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
            return DiscountTile(
              discount: discount,
              onDeleted: () {
                _showSnackBar(
                  "Đã xóa khuyến mãi",
                  AnimatedSnackBarType.success,
                );
              },
            );
          },
        );
      },
    );
  }

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

  void _showSnackBar(String message, AnimatedSnackBarType type) {
    AnimatedSnackBar.material(
      message,
      type: type,
      duration: Duration(seconds: 3),
    ).show(context);
  }
}

class DiscountTile extends StatelessWidget {
  final DiscountModel discount;
  final VoidCallback? onDeleted;

  DiscountTile({required this.discount, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: _getStatusColor(), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề và menu tùy chọn
            Row(
              children: [
                Expanded(
                  child: Text(
                    discount.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildPopupMenu(context),
              ],
            ),

            SizedBox(height: 12),

            // Thông tin chi tiết khuyến mãi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailChip(
                  context,
                  Icons.discount_outlined,
                  'Loại',
                  _getDiscountTypeText(discount.type),
                ),
                _buildDetailChip(
                  context,
                  Icons.monetization_on_outlined,
                  'Giá trị',
                  _formatDiscountValue(),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Thời gian hiệu lực
            Row(
              children: [
                Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatDiscountPeriod(),
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ),
              ],
            ),

            // Mô tả (nếu có)
            if (discount.description != null &&
                discount.description!.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                'Mô tả: ${discount.description}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Mã vạch (nếu có)
            if (discount.barcode != null && discount.barcode!.isNotEmpty) ...[
              SizedBox(height: 12),
              Center(
                child: BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: discount.barcode!,
                  width: 250,
                  height: 80,
                  drawText: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Định dạng giá trị khuyến mãi
  String _formatDiscountValue() {
    final value = discount.value;
    return discount.type == 'Giảm theo phần trăm'
        ? '$value%'
        : '${NumberFormat('#,##0').format(value)} đ';
  }

  // Định dạng thời gian hiệu lực khuyến mãi
  String _formatDiscountPeriod() {
    final startDate = DateTime.fromMillisecondsSinceEpoch(discount.startDate);
    final endDate = DateTime.fromMillisecondsSinceEpoch(discount.endDate);

    return 'Từ ${DateFormat('dd/MM/yyyy HH:mm').format(startDate)} '
        'đến ${DateFormat('dd/MM/yyyy HH:mm').format(endDate)}';
  }

  // Lấy màu trạng thái của khuyến mãi
  Color _getStatusColor() {
    final now = DateTime.now();
    final startDate = DateTime.fromMillisecondsSinceEpoch(discount.startDate);
    final endDate = DateTime.fromMillisecondsSinceEpoch(discount.endDate);

    if (now.isBefore(startDate)) return Colors.blue.shade100;
    if (now.isAfter(endDate)) return Colors.red.shade100;
    return Colors.green.shade100;
  }

  // Xây dựng chip chi tiết
  Widget _buildDetailChip(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).primaryColor),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        switch (value) {
          case 'view':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => DiscountDetailsPageAdmin(discount: discount),
              ),
            );
            break;
          case 'edit':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiscountEditPageAdmin(discount: discount),
              ),
            ).then((result) {
              if (result == true) {
                AnimatedSnackBar.material(
                  "Đã cập nhật khuyến mãi",
                  type: AnimatedSnackBarType.success,
                ).show(context);
              }
            });
            break;
          case 'delete':
            _showDeleteDialog(context);
            break;
        }
      },
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Xem chi tiết'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa'),
                ],
              ),
            ),
          ],
    );
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

  void _showDeleteDialog(BuildContext context) {
    final discountProvider = Provider.of<DiscountProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Xóa Khuyến Mãi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
              SizedBox(height: 16),
              Text("Bạn có chắc chắn muốn xóa khuyến mãi này?"),
              SizedBox(height: 8),
              Text(
                "Hành động này không thể hoàn tác.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                discountProvider.deleteDiscount(discount.id);
                Navigator.pop(context);
                if (onDeleted != null) {
                  onDeleted!();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Xóa", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
