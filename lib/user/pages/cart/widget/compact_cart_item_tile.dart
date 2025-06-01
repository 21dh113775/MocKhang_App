import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mockhang_app/admin/data/models/cart_model.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';
import 'package:mockhang_app/user/pages/cart/utils/formatters.dart'
    as CurrencyFormatter;
import '../../home/productsection/product_detail_page_user.dart';

class CompactCartItemTile extends StatelessWidget {
  final CartItem cartItem;
  final CartProvider cartProvider;

  const CompactCartItemTile({
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
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckbox(context),
              _buildProductImage(context),
              const SizedBox(width: 8),
              Expanded(child: _buildProductDetails(context)),
              _buildDeleteButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return Checkbox(
      value: cartItem.isSelected,
      activeColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      onChanged: (value) {
        cartProvider.toggleItemSelection(cartItem.product.id);
      },
    );
  }

  Widget _buildProductImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 70,
        height: 70,
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
            fontSize: 13,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          'Danh mục: ${cartItem.product.category}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.formatCurrency(cartItem.product.price),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
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
