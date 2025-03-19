import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';
import 'package:mockhang_app/admin/providers/favorite_provider.dart';
import 'package:mockhang_app/user/pages/home/productsection/product_detail_page_user.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the widget is mounted before using context
      if (mounted) {
        final favoriteProvider = Provider.of<FavoriteProvider>(
          context,
          listen: false,
        );
        setState(() {
          _isFavorite = favoriteProvider.isFavorite(widget.product);
        });
      }
    });
  }

  void _addToCart(BuildContext context) {
    // Check if widget is mounted before using context
    if (!mounted) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(widget.product, quantity);

    if (!mounted) return; // Check again before using context
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
    if (!mounted) return;

    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );
    favoriteProvider.toggleFavorite(widget.product);

    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (!mounted) return;

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
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: InkWell(
        onTap:
            widget.onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: widget.product),
                ),
              );
            },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image section with badges
            Stack(
              children: [
                // Product image
                Hero(
                  tag: '${widget.product.id}_${UniqueKey()}',
                  child: SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: _loadImage(),
                  ),
                ),

                // Favorite button
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.white.withOpacity(0.8),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _toggleFavorite,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color:
                              _isFavorite ? Colors.red : Colors.grey.shade700,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                // Low stock badge
                if (isLowStock)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Sắp hết hàng',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Product info section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product name
                    Text(
                      widget.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Price with currency
                    Text(
                      '${_formatCurrency(widget.product.price)} đ',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Stock indicator
                    Text(
                      'Còn: ${widget.product.stock}',
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            isLowStock
                                ? Colors.red.shade700
                                : Colors.grey.shade700,
                        fontWeight:
                            isLowStock ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),

                    const Spacer(),

                    // Add to cart button
                    SizedBox(
                      width: double.infinity,
                      height: 28,
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
                        icon: const Icon(Icons.add_shopping_cart, size: 14),
                        label: const Text(
                          'Thêm vào giỏ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
          Icon(Icons.image_not_supported, size: 24, color: Colors.grey[600]),
          const SizedBox(height: 2),
          Text(
            'Lỗi tải hình ảnh',
            style: TextStyle(color: Colors.grey[600], fontSize: 10),
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
