// cart_item_tile.dart
import 'package:flutter/material.dart';
import 'package:mockhang_app/user/pages/cart/utils/constants.dart';
import 'package:mockhang_app/user/pages/cart/utils/formatters.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mockhang_app/admin/data/models/cart_model.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';
// Thay thế với đường dẫn chính xác
import 'package:mockhang_app/user/pages/cart/dialog/delete_item_dialog.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onSelectionChanged;

  const CartItemTile({
    Key? key,
    required this.item,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox chọn sản phẩm
            Checkbox(
              value: item.isSelected,
              activeColor: AppColors.primaryColor,
              onChanged: (value) {
                cartProvider.toggleItemSelection(item.product.id);
                onSelectionChanged();
              },
            ),

            // Hình ảnh sản phẩm
            _buildProductImage(),

            const SizedBox(width: 12),

            // Thông tin sản phẩm
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfo(),
                  const SizedBox(height: 8),
                  _buildQuantityControls(
                    context,
                    cartProvider,
                  ), // Truyền context vào đây
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        item.product.imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder:
            (ctx, err, _) => Container(
              width: 80,
              height: 80,
              color: AppColors.accentColor,
              child: Icon(Icons.image_not_supported, color: Colors.grey),
            ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.product.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
            fontSize: 16,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${formatCurrency(item.product.price)} đ',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Thêm tham số BuildContext context
  Widget _buildQuantityControls(
    BuildContext context,
    CartProvider cartProvider,
  ) {
    return Row(
      children: [
        // Nút giảm số lượng
        InkWell(
          onTap:
              item.quantity > 1
                  ? () => cartProvider.decreaseQuantity(item.product.id)
                  : null,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.remove,
              size: 16,
              color: item.quantity > 1 ? AppColors.primaryColor : Colors.grey,
            ),
          ),
        ),

        // Hiển thị số lượng
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.zero,
          ),
          child: Text(
            '${item.quantity}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        // Nút tăng số lượng
        InkWell(
          onTap: () => cartProvider.increaseQuantity(item.product.id),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.add, size: 16, color: AppColors.primaryColor),
          ),
        ),

        const Spacer(),

        // Nút xóa sản phẩm
        IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => showDeleteItemDialog(context, item),
        ),
      ],
    );
  }
}
