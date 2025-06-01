import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';

class OrderSummary extends StatelessWidget {
  final CartProvider cartProvider;

  const OrderSummary({Key? key, required this.cartProvider}) : super(key: key);

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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thông tin đơn hàng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.receipt_long, color: Colors.blue),
              ],
            ),
            const Divider(thickness: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartProvider.items.length,
              itemBuilder: (context, index) {
                final item = cartProvider.items[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text('SL: ${item.quantity}'),
                  trailing: Text(
                    '${item.quantity * item.product.price} VNĐ',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                );
              },
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tạm tính:'),
                Text('${cartProvider.subtotal} VNĐ'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
