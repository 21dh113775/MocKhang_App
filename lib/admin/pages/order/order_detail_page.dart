import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mockhang_app/admin/data/models/order_model.dart';
import 'package:mockhang_app/admin/providers/order_provider.dart';
import 'package:provider/provider.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderModel order;

  const OrderDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late OrderModel _currentOrder;
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các trường có thể chỉnh sửa
  late TextEditingController _messageController;
  late TextEditingController _shippingMethodController;
  late TextEditingController _paymentMethodController;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _messageController = TextEditingController(
      text: _currentOrder.messageForShop,
    );
    _shippingMethodController = TextEditingController(
      text: _currentOrder.shippingMethod,
    );
    _paymentMethodController = TextEditingController(
      text: _currentOrder.paymentMethod,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _shippingMethodController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedOrder = _currentOrder.copyWith(
          messageForShop: _messageController.text,
          shippingMethod: _shippingMethodController.text,
          paymentMethod: _paymentMethodController.text,
        );

        await Provider.of<OrderProvider>(
          context,
          listen: false,
        ).updateOrder(updatedOrder);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật đơn hàng thành công'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi tiết Đơn hàng #${_currentOrder.orderId.substring(0, 8)}',
        ),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderInfoSection(),
              const SizedBox(height: 16),
              _buildEditableSection(),
              const SizedBox(height: 16),
              _buildItemsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('ID Khách hàng', _currentOrder.customerId),
            _buildInfoRow(
              'Ngày đặt',
              DateFormat('dd/MM/yyyy HH:mm').format(_currentOrder.dateTime),
            ),
            _buildInfoRow(
              'Tổng tiền',
              '${NumberFormat('#,###').format(_currentOrder.totalAmount)} VNĐ',
            ),
            _buildInfoRow('Trạng thái', _currentOrder.status),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _shippingMethodController,
              decoration: const InputDecoration(
                labelText: 'Phương thức vận chuyển',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập phương thức vận chuyển';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _paymentMethodController,
              decoration: const InputDecoration(
                labelText: 'Phương thức thanh toán',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập phương thức thanh toán';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Lời nhắn cho shop',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Các sản phẩm trong đơn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _currentOrder.items.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(_currentOrder.items[index]));
              },
            ),
          ],
        ),
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
