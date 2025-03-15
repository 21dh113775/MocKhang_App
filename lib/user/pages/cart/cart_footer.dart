// cart_footer.dart
import 'package:flutter/material.dart';
import 'package:mockhang_app/user/pages/cart/dialog/apply_discount_dialog.dart';
import 'package:mockhang_app/user/pages/cart/utils/constants.dart';
import 'package:mockhang_app/user/pages/cart/utils/formatters.dart';
import 'package:provider/provider.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';

class CartFooter extends StatelessWidget {
  const CartFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDiscountSection(context, cartProvider),
          const SizedBox(height: 16),
          _buildTotalSection(cartProvider),
          const SizedBox(height: 16),
          _buildCheckoutButton(context, cartProvider),
        ],
      ),
    );
  }

  Widget _buildDiscountSection(
    BuildContext context,
    CartProvider cartProvider,
  ) {
    return InkWell(
      onTap: () => showApplyDiscountDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.discount_outlined,
              color: AppColors.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              cartProvider.appliedDiscount != null
                  ? '${cartProvider.appliedDiscount!.name} (${cartProvider.appliedDiscount!.type == 'percentage' ? '${cartProvider.appliedDiscount!.value}%' : '${formatCurrency(cartProvider.appliedDiscount!.value)} đ'})'
                  : 'Sử dụng mã giảm giá',
              style: TextStyle(color: AppColors.textColor),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  // cart_footer.dart (tiếp tục)
  Widget _buildTotalSection(CartProvider cartProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tổng tiền:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        Text(
          '${formatCurrency(cartProvider.total)} đ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton(BuildContext context, CartProvider cartProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            cartProvider.hasSelectedItems
                ? () {
                  Navigator.pushNamed(context, '/checkout');
                }
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          cartProvider.hasSelectedItems
              ? 'Thanh toán (${cartProvider.selectedItemCount} sản phẩm)'
              : 'Vui lòng chọn sản phẩm',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
