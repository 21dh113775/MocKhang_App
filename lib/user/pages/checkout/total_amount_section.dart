import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';

class TotalAmountSection extends StatelessWidget {
  final CartProvider cartProvider;

  const TotalAmountSection({Key? key, required this.cartProvider})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi tiết thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            _buildPriceRow('Tạm tính', '${cartProvider.subtotal} VNĐ'),
            _buildPriceRow(
              'Phí vận chuyển',
              '${cartProvider.shippingCost} VNĐ',
            ),
            if (cartProvider.appliedDiscount != null)
              _buildPriceRow(
                'Giảm giá',
                '-${cartProvider.discountAmount} VNĐ',
                valueColor: Colors.red,
              ),
            const Divider(),
            _buildPriceRow(
              'Tổng cộng',
              '${cartProvider.total} VNĐ',
              isBold: true,
              valueColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
