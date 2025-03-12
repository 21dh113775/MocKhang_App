import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  Widget _buildProductImage() {
    final path = product.imageUrl;
    if (path.startsWith('http') || path.startsWith('https')) {
      return Image.network(
        path,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
      );
    } else {
      return Image.file(
        File(path),
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
      );
    }
  }

  Widget _buildErrorImage() {
    return Container(
      width: double.infinity,
      height: 250,
      color: Colors.grey[300],
      child: Center(
        child: Icon(Icons.broken_image, size: 48, color: Colors.grey[600]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero animation (tag phải trùng với bên ProductItemCard)
            Hero(tag: 'product_${product.id}', child: _buildProductImage()),
            const SizedBox(height: 16),
            // Tên sản phẩm
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Giá
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${product.price} đ',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Danh mục & Tồn kho
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Danh mục: ${product.category}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Số lượng tồn kho: ${product.stock}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            // Mô tả
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Mô tả sản phẩm',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                product.description,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            // Nút "Thêm vào giỏ hàng"
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Thêm logic "thêm vào giỏ hàng"
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Thêm vào giỏ hàng'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
