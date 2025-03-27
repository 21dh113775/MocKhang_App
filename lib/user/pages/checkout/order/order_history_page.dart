import 'package:flutter/material.dart';
import 'package:mockhang_app/user/pages/checkout/order/order_details_page.dart';
import 'package:provider/provider.dart';
import 'package:mockhang_app/admin/providers/order_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử Đơn hàng')),
      body:
          currentUser == null
              ? const Center(child: Text('Vui lòng đăng nhập để xem đơn hàng'))
              : FutureBuilder(
                future: orderProvider.loadCustomerOrders(currentUser.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (orderProvider.orders.isEmpty) {
                    return const Center(child: Text('Không có đơn hàng nào.'));
                  }

                  return ListView.builder(
                    itemCount: orderProvider.orders.length,
                    itemBuilder: (context, index) {
                      final order = orderProvider.orders[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(
                            'Đơn hàng #${order.orderId.substring(0, 8)}...',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tổng tiền: ${order.totalAmount.toStringAsFixed(0)} đ',
                              ),
                              Text('Ngày đặt: ${_formatDate(order.dateTime)}'),
                            ],
                          ),
                          trailing: _buildStatusChip(order.status),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => OrderDetailPage(order: order),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Đang xử lý':
        color = Colors.blue;
        break;
      case 'Đang giao':
        color = Colors.orange;
        break;
      case 'Đã giao':
        color = Colors.green;
        break;
      case 'Đã hủy':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.all(0),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
