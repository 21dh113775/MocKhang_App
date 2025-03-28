import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mockhang_app/admin/data/models/cart_model.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';
import 'package:mockhang_app/user/pages/cart/utils/formatters.dart'
    as CurrencyFormatter;

import '../../home/productsection/product_detail_page_user.dart';

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;
  final CartProvider cartProvider;

  const CartItemTile({
    Key? key,
    required this.cartItem,
    required this.cartProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _navigateToProductDetail(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckbox(context),
              _buildProductImage(context),
              const SizedBox(width: 12),
              Expanded(child: _buildProductDetails(context)),
              _buildDeleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return Transform.scale(
      scale: 0.9,
      child: Checkbox(
        value: cartItem.isSelected,
        activeColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onChanged: (value) {
          cartProvider.toggleItemSelection(cartItem.product.id);
        },
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _buildImageWidget(),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (cartItem.product.imageUrl.isEmpty) {
      return const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: 20,
      );
    }

    return cartItem.product.imageUrl.startsWith('http')
        ? CachedNetworkImage(
          imageUrl: cartItem.product.imageUrl,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          errorWidget:
              (context, url, error) => const Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey,
                size: 20,
              ),
        )
        : Image.file(
          File(cartItem.product.imageUrl),
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => const Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey,
                size: 20,
              ),
        );
  }

  Widget _buildProductDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cartItem.product.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'Danh mục: ${cartItem.product.category}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              CurrencyFormatter.formatCurrency(cartItem.product.price),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            _buildQuantityControl(),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityControl() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            onTap: () {
              if (cartItem.quantity > 1) {
                cartProvider.decreaseQuantity(cartItem.product.id);
              }
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              '${cartItem.quantity}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onTap: () {
              cartProvider.increaseQuantity(cartItem.product.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius:
              icon == Icons.remove
                  ? const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  )
                  : const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
      onPressed: () {
        cartProvider.removeItem(cartItem.product.id);
      },
    );
  }

  void _navigateToProductDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: cartItem.product),
      ),
    );
  }
}
