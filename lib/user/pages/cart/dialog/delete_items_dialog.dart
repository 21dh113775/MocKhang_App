// dialogs/delete_items_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';

void showDeleteItemsDialog(BuildContext context) {
  final cartProvider = Provider.of<CartProvider>(context, listen: false);
  final selectedItems =
      cartProvider.items.where((item) => item.isSelected).toList();

  if (selectedItems.isNotEmpty) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa sản phẩm'),
            content: Text(
              'Bạn có chắc muốn xóa ${selectedItems.length} sản phẩm đã chọn?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  for (var item in selectedItems) {
                    cartProvider.removeItem(item.product.id);
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa các sản phẩm đã chọn'),
                      backgroundColor: Colors.green,
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
}
