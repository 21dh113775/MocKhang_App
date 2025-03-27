import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockhang_app/admin/data/models/order_model.dart';
import 'package:mockhang_app/admin/providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CustomerOrdersPage extends StatefulWidget {
  const CustomerOrdersPage({Key? key}) : super(key: key);

  @override
  State<CustomerOrdersPage> createState() => _CustomerOrdersPageState();
}

class _CustomerOrdersPageState extends State<CustomerOrdersPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await Provider.of<OrderProvider>(
          context,
          listen: false,
        ).loadCustomerOrders(currentUser.uid);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải đơn hàng: ${e.toString()}')),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  String _getStatusColor(String status) {
    switch (status) {
      case 'Đang xử lý':
        return 'processing';
      case 'Đang giao hàng':
        return 'shipping';
      case 'Đã giao hàng':
        return 'delivered';
      case 'Đã hủy':
        return 'cancelled';
      default:
        return 'default';
    }
  }

  Color _getStatusColorValue(String colorName) {
    switch (colorName) {
      case 'processing':
        return Colors.blue;
      case 'shipping':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đơn hàng của tôi'), elevation: 0),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Consumer<OrderProvider>(
                builder: (context, orderProvider, child) {
                  final orders = orderProvider.orders;

                  if (orders.isEmpty) {
                    return const Center(
                      child: Text('Bạn chưa có đơn hàng nào'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final statusColor = _getStatusColor(order.status);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Đơn hàng #${order.orderId.substring(0, 8)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        order.status,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      backgroundColor: _getStatusColorValue(
                                        statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                _buildInfoRow(
                                  'Ngày đặt',
                                  DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                  ).format(order.dateTime),
                                ),
                                _buildInfoRow(
                                  'Tổng tiền',
                                  '${NumberFormat('#,###').format(order.totalAmount)} VNĐ',
                                ),
                                _buildInfoRow(
                                  'Phương thức thanh toán',
                                  order.paymentMethod,
                                ),
                                _buildInfoRow(
                                  'Phương thức vận chuyển',
                                  order.shippingMethod,
                                ),
                                if (order.messageForShop.isNotEmpty)
                                  _buildInfoRow(
                                    'Lời nhắn',
                                    order.messageForShop,
                                  ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    // Chi tiết đơn hàng
                                    // TODO: Chuyển đến trang chi tiết đơn hàng
                                  },
                                  child: const Text('Xem chi tiết'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
