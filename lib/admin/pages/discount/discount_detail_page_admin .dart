import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:share_plus/share_plus.dart';

class DiscountDetailsPageAdmin extends StatelessWidget {
  final DiscountModel discount;
  final Color primaryColor = Color(0xFF2C3E50);
  final Color accentColor = Color(0xFF3498DB);
  final Color backgroundColor = Color(0xFFF5F7FA);

  DiscountDetailsPageAdmin({required this.discount});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();

    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primaryColor,
          secondary: accentColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primaryColor,
          title: Text(
            "Chi Tiết Khuyến Mãi",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: Colors.white),
              onPressed: () {
                // Navigate to edit page
              },
            ),
            IconButton(
              icon: Icon(Icons.share, color: Colors.white),
              onPressed: () {
                // Share discount details
                Share.share(
                  'Khuyến mãi: ${discount.name} - ${_formatDiscountValue()}',
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header with discount name and status
              _buildHeader(statusColor, statusText),

              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24),

                    // Discount value card
                    _buildMainInfoCard(),

                    SizedBox(height: 24),

                    // Time range
                    _buildTimeInfoCard(),

                    SizedBox(height: 24),

                    // Description section
                    if (discount.description?.isNotEmpty ?? false)
                      _buildDescriptionCard(),

                    SizedBox(height: 24),

                    // Barcode section
                    if (discount.barcode?.isNotEmpty ?? false)
                      _buildBarcodeCard(),

                    SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomActionBar(context),
      ),
    );
  }

  Widget _buildHeader(Color statusColor, String statusText) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getStatusIcon(), size: 16, color: statusColor),
                    SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            discount.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Mã: ${discount.id.substring(0, 8)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin khuyến mãi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.discount_outlined,
                    'Loại khuyến mãi',
                    _getDiscountTypeText(),
                    primaryColor,
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  child: _buildInfoItem(
                    Icons.monetization_on_outlined,
                    'Giá trị',
                    _formatDiscountValue(),
                    accentColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfoCard() {
    final startDate = DateTime.fromMillisecondsSinceEpoch(discount.startDate);
    final endDate = DateTime.fromMillisecondsSinceEpoch(discount.endDate);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: primaryColor),
                SizedBox(width: 8),
                Text(
                  'Thời gian hiệu lực',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeInfo(
                    'Bắt đầu',
                    startDate,
                    Colors.green,
                    Icons.play_arrow_rounded,
                  ),
                ),
                Container(
                  height: 60,
                  width: 1,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.grey.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildDateTimeInfo(
                    'Kết thúc',
                    endDate,
                    Colors.red,
                    Icons.stop_rounded,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: _calculateTimeProgress(),
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
            ),
            SizedBox(height: 8),
            Text(
              _getRemainingTimeText(),
              style: TextStyle(
                fontSize: 13,
                color: _getStatusColor(),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeInfo(
    String label,
    DateTime dateTime,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          DateFormat('dd/MM/yyyy').format(dateTime),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        Text(
          DateFormat('HH:mm').format(dateTime),
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description_outlined, color: primaryColor),
                SizedBox(width: 8),
                Text(
                  'Mô tả chi tiết',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              discount.description ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarcodeCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code, color: primaryColor),
                SizedBox(width: 8),
                Text(
                  'Mã khuyến mãi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: discount.barcode!,
                    width: 280,
                    height: 100,
                    drawText: true,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    discount.barcode!,
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            OutlinedButton.icon(
              icon: Icon(Icons.copy),
              label: Text('Sao chép mã'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Copy to clipboard
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: Icon(Icons.edit_outlined),
              label: Text('Chỉnh sửa'),
              style: OutlinedButton.styleFrom(
                foregroundColor: accentColor,
                side: BorderSide(color: accentColor),
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Navigate to edit page
              },
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.share),
              label: Text('Chia sẻ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Share discount details
                Share.share(
                  'Khuyến mãi: ${discount.name} - ${_formatDiscountValue()}',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatDiscountValue() {
    final NumberFormat formatter = NumberFormat('#,##0');
    return discount.type == 'percentage'
        ? '${discount.value}%'
        : '${formatter.format(discount.value)} đ';
  }

  Color _getStatusColor() {
    final now = DateTime.now();
    final startDate = DateTime.fromMillisecondsSinceEpoch(discount.startDate);
    final endDate = DateTime.fromMillisecondsSinceEpoch(discount.endDate);

    if (now.isBefore(startDate)) return Colors.blue;
    if (now.isAfter(endDate)) return Colors.red;
    return Colors.green;
  }

  IconData _getStatusIcon() {
    final now = DateTime.now();
    final startDate = DateTime.fromMillisecondsSinceEpoch(discount.startDate);
    final endDate = DateTime.fromMillisecondsSinceEpoch(discount.endDate);

    if (now.isBefore(startDate)) return Icons.schedule;
    if (now.isAfter(endDate)) return Icons.event_busy;
    return Icons.event_available;
  }

  String _getStatusText() {
    final now = DateTime.now();
    final startDate = DateTime.fromMillisecondsSinceEpoch(discount.startDate);
    final endDate = DateTime.fromMillisecondsSinceEpoch(discount.endDate);

    if (now.isBefore(startDate)) return "Sắp diễn ra";
    if (now.isAfter(endDate)) return "Đã kết thúc";
    return "Đang diễn ra";
  }

  String _getDiscountTypeText() {
    switch (discount.type) {
      case 'percentage':
        return 'Giảm theo phần trăm';
      case 'fixed_amount':
        return 'Giảm theo số tiền';
      default:
        return discount.type;
    }
  }

  double _calculateTimeProgress() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final startDate = discount.startDate;
    final endDate = discount.endDate;

    if (now < startDate) return 0.0;
    if (now > endDate) return 1.0;

    return (now - startDate) / (endDate - startDate);
  }

  String _getRemainingTimeText() {
    final now = DateTime.now();
    final startDate = DateTime.fromMillisecondsSinceEpoch(discount.startDate);
    final endDate = DateTime.fromMillisecondsSinceEpoch(discount.endDate);

    if (now.isBefore(startDate)) {
      final diff = startDate.difference(now);
      if (diff.inDays > 0) {
        return "Còn ${diff.inDays} ngày để bắt đầu";
      } else if (diff.inHours > 0) {
        return "Còn ${diff.inHours} giờ để bắt đầu";
      } else {
        return "Còn ${diff.inMinutes} phút để bắt đầu";
      }
    } else if (now.isAfter(endDate)) {
      return "Khuyến mãi đã kết thúc";
    } else {
      final diff = endDate.difference(now);
      if (diff.inDays > 0) {
        return "Còn ${diff.inDays} ngày để kết thúc";
      } else if (diff.inHours > 0) {
        return "Còn ${diff.inHours} giờ để kết thúc";
      } else {
        return "Còn ${diff.inMinutes} phút để kết thúc";
      }
    }
  }
}
