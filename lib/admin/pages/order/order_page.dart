import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/order_model.dart';
import 'package:mockhang_app/admin/pages/order/order_edit_page.dart';
import 'package:mockhang_app/admin/providers/order_provider.dart';
import 'package:mockhang_app/user/pages/checkout/order/order_details_page.dart';
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
  String _searchQuery = '';

  final List<String> _filterOptions = [
    'Tất cả',
    'Đang xử lý',
    'Đang giao hàng',
    'Đã giao hàng',
    'Đã hủy',
  ];

  late OrderProvider _orderProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    try {
      _orderProvider = Provider.of<OrderProvider>(context, listen: false);
      _loadOrders();
    } catch (e) {
      _showErrorSnackBar('Lỗi khởi tạo: ${e.toString()}');
    }
  }

  Future<void> _loadOrders() async {
    try {
      setState(() => _isLoading = true);
      await _orderProvider.loadAllOrders();
    } catch (e) {
      _showErrorSnackBar('Lỗi tải đơn hàng: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  List<OrderModel> _filterAndSearchOrders(List<OrderModel> orders) {
    return orders.where((order) {
      final matchesFilter =
          _selectedFilter == 'Tất cả' || order.status == _selectedFilter;
      final matchesSearch =
          _searchQuery.isEmpty ||
          order.orderId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.customerId.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Đơn hàng'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(children: [_buildSearchBar(), _buildFilterDropdown()]),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredOrders = _filterAndSearchOrders(orderProvider.orders);

          if (filteredOrders.isEmpty) {
            return Center(
              child: Text(
                _searchQuery.isNotEmpty
                    ? 'Không tìm thấy đơn hàng'
                    : 'Không có đơn hàng ${_selectedFilter.toLowerCase()}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadOrders,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return _buildOrderCard(order);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm đơn hàng...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('Lọc: ', style: TextStyle(color: Colors.white)),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: _selectedFilter,
                isExpanded: true,
                underline: const SizedBox(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                items:
                    _filterOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedFilter = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(order),
            const Divider(),
            _buildOrderDetails(order),
            const SizedBox(height: 8),
            _buildOrderActions(order),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(OrderModel order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Đơn hàng #${order.orderId.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        _buildStatusChip(order),
      ],
    );
  }

  Widget _buildStatusChip(OrderModel order) {
    return Chip(
      label: Text(
        order.status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: _getStatusColor(order.status),
    );
  }

  Widget _buildOrderDetails(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Khách hàng', order.customerId),
        _buildInfoRow(
          'Ngày đặt',
          DateFormat('dd/MM/yyyy HH:mm').format(order.dateTime),
        ),
        _buildInfoRow(
          'Tổng tiền',
          '${NumberFormat('#,###').format(order.totalAmount)} VNĐ',
        ),
        _buildInfoRow('Thanh toán', order.paymentMethod),
        _buildInfoRow('Vận chuyển', order.shippingMethod),
      ],
    );
  }

  Widget _buildOrderActions(OrderModel order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showOrderDetails(order),
          icon: const Icon(Icons.visibility),
          label: const Text('Chi tiết'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _editOrder(order),
          icon: const Icon(Icons.edit),
          label: const Text('Chỉnh sửa'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
          ),
        ),
      ],
    );
  }

  void _showOrderDetails(OrderModel order) {
    // Triển khai trang chi tiết đơn hàng
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderDetailPage(order: order)),
    );
  }

  void _editOrder(OrderModel order) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderEditPage(order: order)),
    );

    if (result == true) {
      _loadOrders();
    }
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
