import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/order_model.dart';
import 'package:mockhang_app/admin/providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({Key? key}) : super(key: key);

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  bool _isLoading = true;
  String _selectedFilter = 'Tất cả';
  final List<String> _filterOptions = [
    'Tất cả',
    'Đang xử lý',
    'Đang giao hàng',
    'Đã giao hàng',
    'Đã hủy',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      await Provider.of<OrderProvider>(context, listen: false).loadAllOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải đơn hàng: ${e.toString()}')),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đang xử lý':
        return Colors.blue;
      case 'Đang giao hàng':
        return Colors.orange;
      case 'Đã giao hàng':
        return Colors.green;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    if (_selectedFilter == 'Tất cả') {
      return orders;
    }
    return orders.where((order) => order.status == _selectedFilter).toList();
  }

  void _showUpdateStatusDialog(BuildContext context, OrderModel order) {
    String newStatus = order.status;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cập nhật trạng thái'),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      _filterOptions
                          .where((status) => status != 'Tất cả')
                          .map(
                            (status) => RadioListTile<String>(
                              title: Text(status),
                              value: status,
                              groupValue: newStatus,
                              onChanged: (value) {
                                setState(() {
                                  newStatus = value!;
                                });
                              },
                            ),
                          )
                          .toList(),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await Provider.of<OrderProvider>(
                      context,
                      listen: false,
                    ).updateOrderStatus(order.orderId, newStatus);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cập nhật trạng thái thành công'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Cập nhật'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý đơn hàng'), elevation: 0),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                const Text('Lọc theo trạng thái:'),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFilter = newValue!;
                      });
                    },
                    items:
                        _filterOptions.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Consumer<OrderProvider>(
                      builder: (context, orderProvider, child) {
                        final filteredOrders = _filterOrders(
                          orderProvider.orders,
                        );

                        if (filteredOrders.isEmpty) {
                          return Center(
                            child: Text(
                              _selectedFilter == 'Tất cả'
                                  ? 'Không có đơn hàng nào'
                                  : 'Không có đơn hàng ${_selectedFilter.toLowerCase()}',
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: _loadOrders,
                          child: ListView.builder(
                            itemCount: filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = filteredOrders[index];

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          InkWell(
                                            onTap:
                                                () => _showUpdateStatusDialog(
                                                  context,
                                                  order,
                                                ),
                                            child: Chip(
                                              label: Text(
                                                order.status,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              backgroundColor: _getStatusColor(
                                                order.status,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      _buildInfoRow(
                                        'ID Khách hàng',
                                        order.customerId,
                                      ),
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              // Chi tiết đơn hàng
                                              // TODO: Chuyển đến trang chi tiết đơn hàng
                                            },
                                            child: const Text('Xem chi tiết'),
                                          ),
                                          ElevatedButton(
                                            onPressed:
                                                () => _showUpdateStatusDialog(
                                                  context,
                                                  order,
                                                ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                            ),
                                            child: const Text(
                                              'Cập nhật trạng thái',
                                            ),
                                          ),
                                        ],
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
          ),
        ],
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
