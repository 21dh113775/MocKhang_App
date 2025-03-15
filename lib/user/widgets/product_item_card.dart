import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';
import 'package:mockhang_app/user/pages/product_detail_page_user.dart';
import 'package:provider/provider.dart';

class ProductItemCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductItemCard({Key? key, required this.product, this.onTap})
    : super(key: key);

  @override
  _ProductItemCardState createState() => _ProductItemCardState();
}

class _ProductItemCardState extends State<ProductItemCard> {
  bool _isFavorite = false;
  int quantity = 1;

  void _addToCart(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(widget.product, quantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.brown.shade800,
        content: Row(
          children: [
            const Icon(Icons.shopping_cart_checkout, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Đã thêm ${widget.product.name} vào giỏ hàng',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'XEM',
          textColor: const Color.fromARGB(255, 255, 149, 0),
          onPressed: () {
            Navigator.pushNamed(context, '/cart'); // Navigate to Cart page
          },
        ),
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // TODO: Implement saving to favorites logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor:
            _isFavorite ? Colors.red.shade800 : Colors.grey.shade800,
        content: Row(
          children: [
            Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _isFavorite
                    ? 'Đã thêm vào danh sách yêu thích'
                    : 'Đã xóa khỏi danh sách yêu thích',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = widget.product.stock <= 5;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(6),
      child: InkWell(
        onTap:
            widget.onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ProductDetailPageUser(product: widget.product),
                ),
              );
            },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with badges
            Stack(
              children: [
                // Product image
                Hero(
                  tag: 'product_${widget.product.id}',
                  child: SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: _loadImage(),
                  ),
                ),

                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.white.withOpacity(0.8),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _toggleFavorite,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color:
                              _isFavorite ? Colors.red : Colors.grey.shade700,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                // Low stock badge
                if (isLowStock)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Sắp hết hàng',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Product info section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product name
                  Text(
                    widget.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Price with currency
                  Row(
                    children: [
                      Text(
                        '${_formatCurrency(widget.product.price)} đ',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Stock indicator
                      Text(
                        'Còn: ${widget.product.stock}',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isLowStock
                                  ? Colors.red.shade700
                                  : Colors.grey.shade700,
                          fontWeight:
                              isLowStock ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: ElevatedButton.icon(
                      onPressed: () => _addToCart(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: const Text(
                        'Thêm vào giỏ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadImage() {
    if (widget.product.imageUrl.startsWith('http') ||
        widget.product.imageUrl.startsWith('https')) {
      return Image.network(
        widget.product.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey.shade100,
            child: Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                color: Colors.brown,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(widget.product.imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
      );
    }
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 30, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Text(
            'Lỗi tải hình ảnh',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(num amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
