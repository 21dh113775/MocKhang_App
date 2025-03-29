// order_management.dart
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/order_model.dart';
import 'package:mockhang_app/admin/providers/order_provider.dart';
import 'package:mockhang_app/user/pages/AccountUser/app_theme.dart'
    show AppTheme;
import 'package:provider/provider.dart';

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({Key? key}) : super(key: key);

  @override
  _OrderManagementPageState createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.loadCustomerOrders('current_user_id');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final orders = orderProvider.orders;

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return OrderItemCard(order: order);
          },
        );
      },
    );
  }
}

class OrderItemCard extends StatelessWidget {
  final OrderModel order;

  const OrderItemCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mã đơn: ${order.orderId}', style: AppTheme.title1),
                _buildStatusChip(order.status),
              ],
            ),
            const SizedBox(height: 8),

            Text('Tổng tiền: ${order.totalAmount} VND'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _showOrderDetails(context),
              child: const Text('Chi tiết đơn hàng'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status) {
      case 'Đang xử lý':
        chipColor = Colors.orange;
        break;
      case 'Đang giao':
        chipColor = Colors.blue;
        break;
      case 'Hoàn thành':
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.white)),
      backgroundColor: chipColor,
    );
  }

  void _showOrderDetails(BuildContext context) {
    // Hiển thị chi tiết đơn hàng
  }
}
