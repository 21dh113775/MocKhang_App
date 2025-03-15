// dialogs/delete_item_dialog.dart
import 'package:flutter/material.dart';
import 'package:mockhang_app/user/pages/cart/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:mockhang_app/admin/data/models/cart_model.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';

void showDeleteItemDialog(BuildContext context, CartItem item) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text(
            'Bạn có chắc muốn xóa ${item.product.name} khỏi giỏ hàng?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: AppColors.textColor)),
            ),
            TextButton(
              onPressed: () {
                Provider.of<CartProvider>(
                  context,
                  listen: false,
                ).removeItem(item.product.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa sản phẩm khỏi giỏ hàng'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
  );
}
