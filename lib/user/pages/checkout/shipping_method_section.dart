import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';

class ShippingMethodSection extends StatelessWidget {
  final CartProvider cartProvider;

  const ShippingMethodSection({Key? key, required this.cartProvider})
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phương thức vận chuyển',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.local_shipping, color: Colors.blue),
              ],
            ),
            const Divider(thickness: 1),
            RadioListTile<String>(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Giao hàng tiêu chuẩn'),
                  Text('${cartProvider.standardShippingCost} VNĐ'),
                ],
              ),
              subtitle: const Text('Nhận hàng trong 3-5 ngày'),
              value: 'Standard',
              groupValue: cartProvider.shippingMethod,
              onChanged: (value) {
                cartProvider.setShippingMethod(value!);
              },
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.blue,
            ),
            RadioListTile<String>(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Giao hàng nhanh'),
                  Text('${cartProvider.expressShippingCost} VNĐ'),
                ],
              ),
              subtitle: const Text('Nhận hàng trong 1-2 ngày'),
              value: 'Express',
              groupValue: cartProvider.shippingMethod,
              onChanged: (value) {
                cartProvider.setShippingMethod(value!);
              },
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
