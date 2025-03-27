import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mockhang_app/admin/data/models/order_model.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';

class OrderDetailPage extends StatelessWidget {
  final OrderModel order;

  const OrderDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Chi Tiết Đơn Hàng'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildOrderStatusCard(context),
            _buildOrderInfoCard(context, dateFormat, currencyFormat),
            _buildProductsSection(context, currencyFormat),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (order.status) {
      case 'Đang xử lý':
        statusColor = Colors.blue;
        statusIcon = Icons.pending_actions;
        break;
      case 'Đang giao':
        statusColor = Colors.orange;
        statusIcon = Icons.local_shipping;
        break;
      case 'Đã giao':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Đã hủy':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, size: 40, color: statusColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    _getStatusDescription(order.status),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'Đang xử lý':
        return 'Đơn hàng của bạn đang được chuẩn bị';
      case 'Đang giao':
        return 'Đơn hàng đang trên đường giao đến bạn';
      case 'Đã giao':
        return 'Đơn hàng đã giao thành công';
      case 'Đã hủy':
        return 'Đơn hàng đã bị hủy';
      default:
        return '';
    }
  }

  Widget _buildOrderInfoCard(
    BuildContext context,
    DateFormat dateFormat,
    NumberFormat currencyFormat,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin đơn hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Mã đơn hàng:',
              '#${order.orderId.substring(0, 8)}...',
            ),
            _buildInfoRow('Ngày đặt:', dateFormat.format(order.dateTime)),
            _buildInfoRow('Phương thức giao hàng:', order.shippingMethod),
            _buildInfoRow('Phương thức thanh toán:', order.paymentMethod),

            if (order.messageForShop != null &&
                order.messageForShop!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Lời nhắn:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(order.messageForShop ?? ''),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(
    BuildContext context,
    NumberFormat currencyFormat,
  ) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sản phẩm đã đặt',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final productId = order.items[index];
                return FutureBuilder<DocumentSnapshot>(
                  future:
                      FirebaseFirestore.instance
                          .collection('products')
                          .doc(productId)
                          .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return ListTile(
                        title: Text('Sản phẩm không tồn tại (ID: $productId)'),
                        subtitle: const Text('Sản phẩm này có thể đã bị xóa'),
                      );
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final product = Product(
                      id: productId,
                      name: data['name'] ?? 'Không có tên',
                      price: (data['price'] ?? 0).toDouble(),
                      description: data['description'] ?? '',
                      imageUrl: data['imageUrl'] ?? '',
                      category: data['category'] ?? '',
                      stock: data['stock'] ?? 0, // Add the stock parameter
                    );

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (ctx, err, _) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.description.length > 100
                                    ? '${product.description.substring(0, 100)}...'
                                    : product.description,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currencyFormat.format(product.price),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng tiền:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  currencyFormat.format(order.totalAmount),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
