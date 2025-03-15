// dialogs/apply_discount_dialog.dart
import 'package:flutter/material.dart';
import 'package:mockhang_app/user/pages/cart/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';
import 'package:mockhang_app/admin/providers/discount_provider.dart';

void showApplyDiscountDialog(BuildContext context) {
  final discountController = TextEditingController();
  final discountProvider = Provider.of<DiscountProvider>(
    context,
    listen: false,
  );

  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Áp dụng mã giảm giá'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: discountController,
                decoration: InputDecoration(
                  labelText: 'Nhập mã giảm giá',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/discount');
                },
                child: Text(
                  'Xem tất cả mã giảm giá',
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: AppColors.textColor)),
            ),
            TextButton(
              onPressed: () {
                final code = discountController.text.trim();
                if (code.isNotEmpty) {
                  final discount = discountProvider.discounts.firstWhere(
                    (d) => d.code == code,
                    orElse:
                        () => DiscountModel(
                          id: '',
                          name: '',
                          value: 0,
                          type: '',
                          startDate: 0,
                          endDate: 0,
                        ),
                  );

                  if (discount.id.isNotEmpty) {
                    final now = DateTime.now().millisecondsSinceEpoch;
                    if (discount.startDate <= now && discount.endDate >= now) {
                      Provider.of<CartProvider>(
                        context,
                        listen: false,
                      ).applyDiscount(discount);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đã áp dụng mã giảm giá ${discount.name}',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mã giảm giá đã hết hạn'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mã giảm giá không hợp lệ'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Áp dụng',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
  );
}
