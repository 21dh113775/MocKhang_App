import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mockhang_app/admin/data/models/order_model.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:path/path.dart';

class OrderDetailPage extends StatelessWidget {
  final OrderModel order;

  const OrderDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Đơn Hàng'),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              _buildOrderStatusCard(context),
              _buildOrderInfoCard(context, dateFormat, currencyFormat),
              _buildShippingAddressCard(context),
              _buildProductsSection(context, currencyFormat),
              _buildTotalSummaryCard(context, currencyFormat),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusImage;

    switch (order.status) {
      case 'Đang xử lý':
        statusColor = Colors.blue;
        statusIcon = Icons.pending_actions;
        statusImage = 'processing';
        break;
      case 'Đang giao':
        statusColor = Colors.orange;
        statusIcon = Icons.local_shipping;
        statusImage = 'shipping';
        break;
      case 'Đã giao':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusImage = 'delivered';
        break;
      case 'Đã hủy':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusImage = 'cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusImage = 'unknown';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [statusColor.withOpacity(0.1), Colors.white],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(statusIcon, size: 32, color: statusColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.status,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      _buildStatusIndicator(context, order.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusDescription(order.status),
                    style: TextStyle(color: Colors.grey[700], fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, String status) {
    final List<String> allStatuses = [
      'Đang xử lý',
      'Đang giao',
      'Đã giao',
      'Đã hủy',
    ];

    if (status == 'Đã hủy') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Đã hủy',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    int currentIndex = allStatuses.indexOf(status);
    if (currentIndex == -1) currentIndex = 0;

    return Row(
      children: List.generate(3, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                index <= currentIndex
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
          ),
        );
      }),
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
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Thông tin đơn hàng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context: context,
              icon: Icons.numbers,
              label: 'Mã đơn hàng:',
              value: '#${order.orderId.substring(0, 8)}...',
            ),
            _buildInfoRow(
              context: context,
              icon: Icons.calendar_today,
              label: 'Ngày đặt:',
              value: dateFormat.format(order.dateTime),
            ),
            _buildInfoRow(
              context: context,
              icon: Icons.local_shipping_outlined,
              label: 'Phương thức giao hàng:',
              value: order.shippingMethod,
            ),
            _buildInfoRow(
              context: context,
              icon: Icons.payment,
              label: 'Phương thức thanh toán:',
              value: order.paymentMethod,
            ),

            if (order.messageForShop != null &&
                order.messageForShop!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.message_outlined,
                        color: Theme.of(context).primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Lời nhắn:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8, left: 26),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      order.messageForShop ?? '',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingAddressCard(BuildContext context) {
    // Giả sử bạn có thông tin địa chỉ giao hàng trong model OrderModel
    // Nếu không có, bạn có thể thêm vào hoặc bỏ qua phần này

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Địa chỉ nhận hàng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            // Thay thế bằng thông tin địa chỉ thực tế từ model của bạn
            const Text(
              'Nguyễn Văn A',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text('0912345678'),
            const SizedBox(height: 4),
            const Text(
              '123 Đường ABC, Phường XYZ, Quận 1, TP. Hồ Chí Minh',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Sản phẩm đã đặt',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder:
                  (context, index) =>
                      Divider(color: Colors.grey[300], height: 32),
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
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[400]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sản phẩm không tồn tại',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                  Text(
                                    'ID: $productId',
                                    style: TextStyle(color: Colors.red[400]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                      stock: data['stock'] ?? 0,
                    );

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (ctx, err, _) => Container(
                                    width: 90,
                                    height: 90,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  ),
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
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currencyFormat.format(product.price),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Số lượng: 1',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSummaryCard(
    BuildContext context,
    NumberFormat currencyFormat,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Tổng thanh toán',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildPriceRow(
              context: context,
              label: 'Tổng tiền hàng:',
              value: currencyFormat.format(
                order.totalAmount - 30000,
              ), // Giả sử phí vận chuyển là 30,000đ
              isTotal: false,
            ),
            _buildPriceRow(
              context: context,
              label: 'Phí vận chuyển:',
              value: currencyFormat.format(30000), // Giả sử phí vận chuyển
              isTotal: false,
            ),
            const Divider(height: 16),
            _buildPriceRow(
              context: context,
              label: 'Tổng thanh toán:',
              value: currencyFormat.format(order.totalAmount),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow({
    required BuildContext context,
    required String label,
    required String value,
    required bool isTotal,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Theme.of(context).primaryColor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
