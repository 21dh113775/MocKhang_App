import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';
import 'package:mockhang_app/admin/providers/favorite_provider.dart';
import 'package:mockhang_app/user/pages/home/productsection/price_formatter.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final List<Product> relatedProducts;

  const ProductDetailPage({
    Key? key,
    required this.product,
    this.relatedProducts = const [],
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  final ScrollController _scrollController = ScrollController();

  // Màu chủ đạo - định nghĩa màu một lần để tái sử dụng
  static const Color primaryColor = Color(0xFF795548);
  static const Color accentColor = Color(0xFFD7CCC8);
  static const Color textColor = Color(0xFF5D4037);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      if (quantity < widget.product.stock) {
        quantity++;
      } else {
        _showStockLimitSnackBar();
      }
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (quantity > 1) {
        quantity--;
      }
    });
  }

  void _showStockLimitSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đạt giới hạn số lượng trong kho'),
        backgroundColor: primaryColor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _addToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(
      widget.product,
      quantity,
    ); // Thay addToCart thành addItem

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm $quantity ${widget.product.name} vào giỏ hàng'),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'XEM GIỎ HÀNG',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ),
    );
  }

  void _buyNow() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(
      widget.product,
      quantity,
    ); // Thay addToCart thành addItem
    Navigator.pushNamed(context, '/checkout');
  }

  void _toggleFavorite() {
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );
    favoriteProvider.toggleFavorite(widget.product);

    final isFavorite = favoriteProvider.isFavorite(widget.product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? 'Đã thêm ${widget.product.name} vào danh sách yêu thích'
              : 'Đã xóa ${widget.product.name} khỏi danh sách yêu thích',
        ),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'XEM',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, '/favorite'),
        ),
      ),
    );
  }

  void _shareProduct() {
    // TODO: Thêm logic chia sẻ sản phẩm thực tế
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang chia sẻ sản phẩm ${widget.product.name}'),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final isFavorite = favoriteProvider.isFavorite(widget.product);
    final mediaQuery = MediaQuery.of(context);
    final isPhone = mediaQuery.size.width < 600;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(isFavorite),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(),
                _buildProductInfo(isFavorite),
                _buildQuantitySection(),
                _buildDescriptionSection(),
                if (widget.relatedProducts.isNotEmpty)
                  _buildRelatedProductsSection(isPhone),
                const SizedBox(height: 80), // Space for bottom bar
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(isFavorite),
    );
  }

  Widget _buildAppBar(bool isFavorite) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      title: Text(
        widget.product.name,
        style: const TextStyle(fontSize: 18),
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.white,
          ),
          onPressed: _toggleFavorite,
          tooltip: isFavorite ? 'Xóa khỏi yêu thích' : 'Thêm vào yêu thích',
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareProduct,
          tooltip: 'Chia sẻ sản phẩm',
        ),
      ],
    );
  }

  Widget _buildProductImage() {
    return Hero(
      tag: 'product_${widget.product.id}',
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final path = widget.product.imageUrl;

    if (path.startsWith('http') || path.startsWith('https')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildImagePlaceholder(),
        errorWidget: (context, url, error) => _buildErrorImage(),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
      );
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: accentColor.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(color: primaryColor),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      color: accentColor.withOpacity(0.3),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 64, color: textColor),
            SizedBox(height: 8),
            Text('Không thể tải hình ảnh', style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(bool isFavorite) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              _buildFavoriteButton(isFavorite),
            ],
          ),
          const SizedBox(height: 12),

          _buildRatingBar(),
          const SizedBox(height: 12),

          _buildPrice(),
          const SizedBox(height: 12),

          _buildCategoryAndStock(),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(bool isFavorite) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleFavorite,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            firstChild: const Icon(Icons.favorite, color: Colors.red, size: 24),
            secondChild: Icon(
              Icons.favorite_border,
              color: textColor.withOpacity(0.7),
              size: 24,
            ),
            crossFadeState:
                isFavorite
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBar() {
    return Row(
      children: [
        RatingBar.builder(
          initialRating: 4.5,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 18,
          ignoreGestures: true,
          itemBuilder:
              (context, _) => const Icon(Icons.star, color: primaryColor),
          onRatingUpdate: (rating) {},
        ),
        const SizedBox(width: 8),
        Text(
          '4.5 (123 đánh giá)',
          style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildPrice() {
    return Row(
      children: [
        const Icon(Icons.monetization_on, color: primaryColor, size: 20),
        const SizedBox(width: 4),
        Text(
          widget.product.price.toVND(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryAndStock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category, size: 16, color: textColor.withOpacity(0.7)),
            const SizedBox(width: 4),
            Text(
              'Danh mục: ${widget.product.category}',
              style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.inventory_2,
              size: 16,
              color: textColor.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              'Còn lại: ${widget.product.stock} sản phẩm',
              style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Số lượng:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 12),
              _buildQuantitySelector(),
              const Spacer(),
              Text(
                'Còn lại: ${widget.product.stock}',
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: accentColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _decrementQuantity,
            customBorder: const CircleBorder(),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.remove, color: textColor, size: 18),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: accentColor),
                right: BorderSide(color: accentColor),
              ),
            ),
            child: Text(
              quantity.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          InkWell(
            onTap: _incrementQuantity,
            customBorder: const CircleBorder(),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.add, color: textColor, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Thêm vào giỏ'),
            onPressed: _addToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: textColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.flash_on),
            label: const Text('Mua ngay'),
            onPressed: _buyNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description, color: primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Mô tả sản phẩm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.description,
            style: TextStyle(
              fontSize: 15,
              color: textColor.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProductsSection(bool isPhone) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.view_module, color: primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Sản phẩm liên quan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.relatedProducts.length,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder:
                  (context, index) =>
                      _buildRelatedProductItem(widget.relatedProducts[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProductItem(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductDetailPage(
                  product: product,
                  relatedProducts:
                      widget.relatedProducts
                          .where((p) => p.id != product.id)
                          .toList(),
                ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: Border.all(color: accentColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      color: accentColor.withOpacity(0.3),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: 120,
                      color: accentColor.withOpacity(0.3),
                      child: const Center(
                        child: Icon(Icons.image, color: textColor),
                      ),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price} đ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: primaryColor, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        '4.5',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isFavorite) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : textColor,
                ),
                onPressed: _toggleFavorite,
                tooltip:
                    isFavorite ? 'Xóa khỏi yêu thích' : 'Thêm vào yêu thích',
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.chat, color: textColor),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng đang phát triển'),
                      backgroundColor: primaryColor,
                    ),
                  );
                },
                tooltip: 'Chat với người bán',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _buyNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Mua Ngay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
