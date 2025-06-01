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

  // Định nghĩa color palette
  final Color primaryColor = Color(0xFF2C3E50);
  final Color accentColor = Color(0xFF3498DB);
  final Color backgroundColor = Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;

  // Cache filtered discounts để tối ưu hiệu năng
  List<DiscountModel> _filteredDiscounts = [];
  bool _hasInitializedDiscounts = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    // Tải dữ liệu khuyến mãi khi trang được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DiscountProvider>(context, listen: false);
      provider.loadDiscounts();
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
        _updateFilteredDiscounts(
          Provider.of<DiscountProvider>(context, listen: false).discounts,
        );
      }
    });
  }

  void _updateFilteredDiscounts(List<DiscountModel> discounts) {
    if (_searchQuery.isEmpty) {
      _filteredDiscounts = discounts;
      return;
    }

    final lowercaseQuery = _searchQuery.toLowerCase();
    _filteredDiscounts =
        discounts.where((discount) {
          return discount.name.toLowerCase().contains(lowercaseQuery) ||
              (discount.description != null &&
                  discount.description!.toLowerCase().contains(
                    lowercaseQuery,
                  )) ||
              (discount.barcode != null &&
                  discount.barcode!.toLowerCase().contains(lowercaseQuery));
        }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primaryColor,
          secondary: accentColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme(backgroundColor: primaryColor, elevation: 0),
        cardTheme: CardTheme(
          color: cardColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
        ),
      ),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      title:
          _isSearching
              ? _buildSearchField()
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
          tooltip: _isSearching ? 'Đóng tìm kiếm' : 'Tìm kiếm',
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.white),
          onPressed: _refreshDiscounts,
          tooltip: 'Làm mới danh sách',
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Colors.white),
        cursorColor: Colors.white70,
        decoration: InputDecoration(
          hintText: "Tìm kiếm khuyến mãi...",
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.search, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: Colors.white70, size: 20),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _updateFilteredDiscounts(
                  Provider.of<DiscountProvider>(
                    context,
                    listen: false,
                  ).discounts,
                );
              });
            },
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _updateFilteredDiscounts(
              Provider.of<DiscountProvider>(context, listen: false).discounts,
            );
          });
        },
      ),
    );
  }

  void _refreshDiscounts() {
    Provider.of<DiscountProvider>(context, listen: false).loadDiscounts();

    _showSnackBar("Đã làm mới danh sách khuyến mãi", AnimatedSnackBarType.info);
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DiscountAddPageAdmin()),
        );

        if (result == true) {
          _showSnackBar("Đã thêm khuyến mãi mới", AnimatedSnackBarType.success);
        }
      },
      icon: Icon(Icons.add),
      label: Text("Thêm mới"),
      tooltip: 'Thêm khuyến mãi',
    );
  }

  Widget _buildBody() {
    return Consumer<DiscountProvider>(
      builder: (context, discountProvider, child) {
        if (discountProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          );
        }

        // Chỉ cập nhật filteredDiscounts khi discounts thay đổi hoặc khi lần đầu load
        if (!_hasInitializedDiscounts || _filteredDiscounts.isEmpty) {
          _updateFilteredDiscounts(discountProvider.discounts);
          _hasInitializedDiscounts = true;
        }

        if (_filteredDiscounts.isEmpty) {
          return _buildEmptyView();
        }

        return _buildDiscountList();
      },
    );
  }

  Widget _buildDiscountList() {
    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () async {
        await Provider.of<DiscountProvider>(
          context,
          listen: false,
        ).loadDiscounts();
      },
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 12),
        itemCount: _filteredDiscounts.length,
        itemBuilder: (context, index) {
          final discount = _filteredDiscounts[index];
          return AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: 1.0,
            child: DiscountTile(
              discount: discount,
              primaryColor: primaryColor,
              accentColor: accentColor,
              onDeleted: () {
                _showSnackBar(
                  "Đã xóa khuyến mãi",
                  AnimatedSnackBarType.success,
                );
                // Cập nhật lại danh sách khi xóa
                setState(() {
                  _updateFilteredDiscounts(
                    Provider.of<DiscountProvider>(
                      context,
                      listen: false,
                    ).discounts,
                  );
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty
                ? Icons.search_off
                : Icons.discount_outlined,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty
                ? "Không tìm thấy khuyến mãi phù hợp"
                : "Chưa có khuyến mãi nào",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 12),
          Text(
            _searchQuery.isNotEmpty
                ? "Thử tìm với từ khóa khác"
                : "Hãy thêm khuyến mãi đầu tiên",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(height: 32),
          if (_searchQuery.isNotEmpty)
            ElevatedButton.icon(
              icon: Icon(Icons.clear),
              label: Text("Xóa tìm kiếm"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _isSearching = false;
                  _animationController.reverse();
                  _updateFilteredDiscounts(
                    Provider.of<DiscountProvider>(
                      context,
                      listen: false,
                    ).discounts,
                  );
                });
              },
            )
          else
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text("Thêm khuyến mãi mới"),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiscountAddPageAdmin(),
                  ),
                );

                if (result == true) {
                  _showSnackBar(
                    "Đã thêm khuyến mãi mới",
                    AnimatedSnackBarType.success,
                  );
                }
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
      mobileSnackBarPosition: MobileSnackBarPosition.bottom,
    ).show(context);
  }
}

class DiscountTile extends StatelessWidget {
  final DiscountModel discount;
  final VoidCallback? onDeleted;
  final Color primaryColor;
  final Color accentColor;

  const DiscountTile({
    Key? key,
    required this.discount,
    required this.primaryColor,
    required this.accentColor,
    this.onDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với status badge
            _buildHeader(context, statusColor, statusText),

            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.withOpacity(0.1),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin chi tiết khuyến mãi
                  _buildDetailsSection(context),

                  SizedBox(height: 16),

                  // Thời gian hiệu lực
                  _buildDateTimeSection(),

                  // Mô tả (nếu có)
                  if (discount.description != null &&
                      discount.description!.isNotEmpty)
                    _buildDescriptionSection(),

                  // Mã vạch (nếu có)
                  if (discount.barcode != null && discount.barcode!.isNotEmpty)
                    _buildBarcodeSection(),
                ],
              ),
            ),

            // Footer với actions
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color statusColor,
    String statusText,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getStatusIcon(), size: 16, color: statusColor),
                SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              discount.name,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildPopupMenu(context),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDetailCard(
            context,
            Icons.discount_outlined,
            'Loại khuyến mãi',
            _getDiscountTypeText(discount.type),
            primaryColor.withOpacity(0.08),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildDetailCard(
            context,
            Icons.monetization_on_outlined,
            'Giá trị',
            _formatDiscountValue(),
            primaryColor.withOpacity(0.08),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color bgColor,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: primaryColor),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    final startDate = DateTime.fromMillisecondsSinceEpoch(discount.startDate);
    final endDate = DateTime.fromMillisecondsSinceEpoch(discount.endDate);

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, size: 16, color: primaryColor),
              SizedBox(width: 8),
              Text(
                'Thời gian hiệu lực',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDateItem(
                  'Bắt đầu',
                  startDate,
                  Icons.play_arrow_rounded,
                  Colors.green,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey.withOpacity(0.3),
                margin: EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _buildDateItem(
                  'Kết thúc',
                  endDate,
                  Icons.stop_rounded,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(
    String label,
    DateTime date,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          DateFormat('dd/MM/yyyy').format(date),
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          DateFormat('HH:mm').format(date),
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, size: 16, color: primaryColor),
              SizedBox(width: 8),
              Text(
                'Mô tả',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            discount.description!,
            style: TextStyle(color: Colors.grey[800], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeSection() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code, size: 16, color: primaryColor),
              SizedBox(width: 8),
              Text(
                'Mã khuyến mãi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Center(
            child: BarcodeWidget(
              barcode: Barcode.code128(),
              data: discount.barcode!,
              width: 220,
              height: 70,
              drawText: true,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            icon: Icon(Icons.visibility_outlined, size: 18),
            label: Text('Chi tiết'),
            style: TextButton.styleFrom(foregroundColor: primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => DiscountDetailsPageAdmin(discount: discount),
                ),
              );
            },
          ),
          SizedBox(width: 8),
          OutlinedButton.icon(
            icon: Icon(Icons.edit_outlined, size: 18),
            label: Text('Sửa'),
            style: OutlinedButton.styleFrom(
              foregroundColor: accentColor,
              side: BorderSide(color: accentColor),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => DiscountEditPageAdmin(discount: discount),
                ),
              ).then((result) {
                if (result == true) {
                  AnimatedSnackBar.material(
                    "Đã cập nhật khuyến mãi",
                    type: AnimatedSnackBarType.success,
                  ).show(context);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  // Định dạng giá trị khuyến mãi
  String _formatDiscountValue() {
    final value = discount.value;
    return discount.type == 'percentage'
        ? '$value%'
        : '${NumberFormat('#,##0').format(value)} đ';
  }

  // Lấy màu trạng thái của khuyến mãi
  Color _getStatusColor() {
    final now = DateTime.now();
    final startDate = DateTime.fromMillisecondsSinceEpoch(discount.startDate);
    final endDate = DateTime.fromMillisecondsSinceEpoch(discount.endDate);

    if (now.isBefore(startDate)) return Colors.blue;
    if (now.isAfter(endDate)) return Colors.red;
    return Colors.green;
  }

  // Lấy icon trạng thái
  IconData _getStatusIcon() {
    final now = DateTime.now();
    final startDate = DateTime.fromMillisecondsSinceEpoch(discount.startDate);
    final endDate = DateTime.fromMillisecondsSinceEpoch(discount.endDate);

    if (now.isBefore(startDate)) return Icons.schedule;
    if (now.isAfter(endDate)) return Icons.event_busy;
    return Icons.event_available;
  }

  // Lấy text trạng thái
  String _getStatusText() {
    final now = DateTime.now();
    final startDate = DateTime.fromMillisecondsSinceEpoch(discount.startDate);
    final endDate = DateTime.fromMillisecondsSinceEpoch(discount.endDate);

    if (now.isBefore(startDate)) return "Sắp diễn ra";
    if (now.isAfter(endDate)) return "Đã kết thúc";
    return "Đang diễn ra";
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: primaryColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: Offset(0, 40),
      elevation: 4,
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
          case 'share':
            // Thêm chức năng chia sẻ mã khuyến mãi
            break;
        }
      },
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: primaryColor),
                  SizedBox(width: 12),
                  Text('Xem chi tiết'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: accentColor),
                  SizedBox(width: 12),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, color: Colors.purple),
                  SizedBox(width: 12),
                  Text('Chia sẻ'),
                ],
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Xóa', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
    );
  }

  String _getDiscountTypeText(String type) {
    switch (type) {
      case 'percentage':
        return 'Giảm theo phần trăm';
      case 'fixed_amount':
        return 'Giảm theo số tiền';
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
