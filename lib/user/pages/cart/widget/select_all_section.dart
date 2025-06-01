import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class SelectAllSection extends StatelessWidget {
  const SelectAllSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        bool allSelected = cartProvider.items.every((item) => item.isSelected);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Checkbox(
                value: allSelected,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  cartProvider.selectAll(value ?? false);
                },
              ),
              const Text(
                'Chọn tất cả',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed:
                    cartProvider.items.isEmpty
                        ? null
                        : () => _showDeleteConfirmationDialog(
                          context,
                          cartProvider,
                        ),
                icon: const Icon(Icons.delete_outline, size: 20),
                label: const Text('Xóa đã chọn'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    CartProvider cartProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có muốn xóa tất cả sản phẩm đã chọn?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  for (var item in List.from(cartProvider.items)) {
                    if (item.isSelected) {
                      cartProvider.removeItem(item.product.id);
                    }
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Xóa'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );
  }
}
