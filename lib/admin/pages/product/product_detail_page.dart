import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'edit_product_page.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  ProductDetailPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chi tiết sản phẩm")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm
            Center(
              child:
                  product.imageUrl.isNotEmpty &&
                          File(product.imageUrl).existsSync()
                      ? Image.file(
                        File(product.imageUrl),
                        height: 200,
                        fit: BoxFit.cover,
                      )
                      : Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Icon(Icons.image, size: 100, color: Colors.grey),
                      ),
            ),
            SizedBox(height: 20),

            // Tên sản phẩm
            Text(
              product.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            // Giá tiền
            Text(
              "Giá: ${product.price} VND",
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),

            SizedBox(height: 10),

            // Danh mục
            Text(
              "Danh mục: ${product.category}",
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 10),

            // Số lượng tồn kho
            Text(
              "Số lượng tồn kho: ${product.stock}",
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 10),

            // Mô tả sản phẩm
            Text(
              "Mô tả sản phẩm:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(product.description, style: TextStyle(fontSize: 16)),

            SizedBox(height: 20),

            // Nút chỉnh sửa sản phẩm
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.edit),
                label: Text("Chỉnh sửa sản phẩm"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProductPage(product: product),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
