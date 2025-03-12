import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';

class WarehousePage extends StatefulWidget {
  @override
  _WarehousePageState createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  final TextEditingController _quantityController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await Provider.of<ProductProvider>(
        context,
        listen: false,
      ).fetchProducts();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kho hàng"),
        // Loại bỏ automaticallyImplyLeading để không hiển thị nút quay lại
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<ProductProvider>(
                context,
                listen: false,
              ).fetchProducts();
              setState(() {
                _isLoading = false;
              });
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Không có sản phẩm nào trong kho",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: productProvider.products.length,
          itemBuilder: (context, index) {
            final product = productProvider.products[index];
            return _buildProductCard(context, product);
          },
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(product.imageUrl),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow(Icons.inventory, "Tồn kho", "${product.stock}"),
                  SizedBox(height: 4),
                  _buildInfoRow(
                    Icons.shopping_cart,
                    "Đã bán",
                    "${product.soldQuantity}",
                  ),
                  SizedBox(height: 4),
                  _buildInfoRow(
                    Icons.add_box,
                    "Đã nhập",
                    "${product.importedQuantity}",
                  ),
                ],
              ),
            ),
            _buildImportButton(context, product.id!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text("$label: ", style: TextStyle(color: Colors.grey[700])),
        Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildProductImage(String imageUrl) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child:
            imageUrl.isNotEmpty && File(imageUrl).existsSync()
                ? Image.file(File(imageUrl), fit: BoxFit.cover)
                : Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
                ),
      ),
    );
  }

  Widget _buildImportButton(BuildContext context, int productId) {
    return ElevatedButton.icon(
      icon: Icon(Icons.add, size: 16),
      label: Text("Nhập kho"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: () => _showImportDialog(context, productId),
    );
  }

  void _showImportDialog(BuildContext context, int productId) {
    _quantityController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.inventory_2, color: Colors.green),
              SizedBox(width: 8),
              Text("Nhập hàng"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nhập số lượng bổ sung vào kho:"),
              SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Số lượng",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.add_shopping_cart),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              icon: Icon(Icons.cancel, size: 16),
              label: Text("Hủy"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.save, size: 16),
              label: Text("Xác nhận"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final quantity = int.tryParse(_quantityController.text) ?? 0;
                if (quantity > 0) {
                  Provider.of<ProductProvider>(
                    context,
                    listen: false,
                  ).importStock(productId, quantity);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã nhập thêm $quantity sản phẩm vào kho'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Vui lòng nhập số lượng hợp lệ'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
