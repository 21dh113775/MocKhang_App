// cart_app_bar.dart
import 'package:flutter/material.dart';
import 'package:mockhang_app/user/pages/cart/utils/constants.dart';
import 'package:mockhang_app/user/pages/cart/dialog/delete_items_dialog.dart';
import 'package:provider/provider.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';

class CartAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CartAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    // Modified to use what's available in CartProvider
    final hasSelectedItems = cartProvider.items.any((item) => item.isSelected);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Text(
        'Giỏ hàng',
        style: TextStyle(
          color: AppColors.textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (hasSelectedItems)
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => showDeleteItemsDialog(context),
          ),
      ],
    );
  }
}
