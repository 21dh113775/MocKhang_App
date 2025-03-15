// cart_header.dart
import 'package:flutter/material.dart';
import 'package:mockhang_app/user/pages/cart/dialog/delete_items_dialog.dart';
import 'package:mockhang_app/user/pages/cart/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';

class CartHeader extends StatelessWidget {
  final bool selectAll;
  final Function(bool?) onSelectAllChanged;

  const CartHeader({
    Key? key,
    required this.selectAll,
    required this.onSelectAllChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: selectAll,
            activeColor: AppColors.primaryColor,
            onChanged: onSelectAllChanged,
          ),
          Text(
            'Chọn tất cả',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            label: Text('Xóa đã chọn', style: TextStyle(color: Colors.red)),
            onPressed:
                cartProvider.hasSelectedItems
                    ? () => showDeleteItemsDialog(context)
                    : null,
          ),
        ],
      ),
    );
  }
}
