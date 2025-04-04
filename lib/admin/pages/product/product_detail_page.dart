import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:intl/intl.dart';
import 'package:mockhang_app/admin/pages/product/edit_product_page.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  ProductDetailPage({required this.product});

  // Define color palette
  final Color primaryColor = Color(0xFF2C3E50);
  final Color accentColor = Color(0xFF3498DB);
  final Color backgroundColor = Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;
  final Color priceColor = Color(0xFF27AE60);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Chi tiết sản phẩm",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              tooltip: 'Chỉnh sửa',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProductPage(product: product),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero image section
              _buildHeroImageSection(),

              // Product details card
              _buildProductDetailsCard(context),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProductPage(product: product),
              ),
            );
          },
          backgroundColor: accentColor,
          icon: Icon(Icons.edit_outlined),
          label: Text('Chỉnh sửa'),
        ),
      ),
    );
  }

  Widget _buildHeroImageSection() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child:
            product.imageUrl.isNotEmpty && File(product.imageUrl).existsSync()
                ? Image.file(File(product.imageUrl), fit: BoxFit.cover)
                : Container(
                  color: primaryColor.withOpacity(0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 80,
                        color: primaryColor.withOpacity(0.3),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Không có hình ảnh",
                        style: TextStyle(
                          color: primaryColor.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildProductDetailsCard(BuildContext context) {
    final formatter = NumberFormat('#,###', 'vi_VN');

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name and price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: priceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${formatter.format(product.price)} đ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: priceColor,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Info cards row
            Row(
              children: [
                _buildInfoCard(
                  Icons.category_outlined,
                  "Danh mục",
                  product.category,
                  accentColor.withOpacity(0.1),
                ),
                SizedBox(width: 12),
                _buildInfoCard(
                  Icons.inventory_2_outlined,
                  "Tồn kho",
                  product.stock.toString(),
                  primaryColor.withOpacity(0.1),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Description section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 20,
                        color: primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Mô tả sản phẩm",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : "Không có mô tả chi tiết cho sản phẩm này.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Additional info section if needed
            // You can add more sections here for additional product details

            // Product management buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.visibility_outlined),
                    label: Text("Xem trên cửa hàng"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accentColor,
                      side: BorderSide(color: accentColor),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      // View product in store functionality
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.inventory_2_outlined),
                    label: Text("Cập nhật tồn kho"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      // Update inventory functionality
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String label,
    String value,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: primaryColor),
                SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
