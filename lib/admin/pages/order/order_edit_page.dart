import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mockhang_app/admin/data/models/order_model.dart';
import 'package:mockhang_app/admin/providers/order_provider.dart';

class OrderEditPage extends StatefulWidget {
  final OrderModel order;

  const OrderEditPage({Key? key, required this.order}) : super(key: key);

  @override
  _OrderEditPageState createState() => _OrderEditPageState();
}

class _OrderEditPageState extends State<OrderEditPage> {
  late OrderModel _editedOrder;
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các trường chỉnh sửa
  late TextEditingController _customerIdController;
  late TextEditingController _totalAmountController;
  late TextEditingController _messageController;
  late TextEditingController _shippingMethodController;
  late TextEditingController _paymentMethodController;

  // Danh sách trạng thái và phương thức
  final List<String> _statusOptions = [
    'Đang xử lý',
    'Đang giao hàng',
    'Đã giao hàng',
    'Đã hủy',
  ];

  final List<String> _shippingMethods = ['Tiêu chuẩn', 'Nhanh', 'Hỏa tốc'];

  final List<String> _paymentMethods = ['Tiền mặt', 'Chuyển khoản', 'PayPal'];

  @override
  void initState() {
    super.initState();
    // Sao chép đối tượng đơn hàng để chỉnh sửa
    _editedOrder = widget.order;

    // Khởi tạo controllers
    _customerIdController = TextEditingController(
      text: _editedOrder.customerId,
    );
    _totalAmountController = TextEditingController(
      text: _editedOrder.totalAmount.toStringAsFixed(0),
    );
    _messageController = TextEditingController(
      text: _editedOrder.messageForShop,
    );
    _shippingMethodController = TextEditingController(
      text:
          _shippingMethods.contains(_editedOrder.shippingMethod)
              ? _editedOrder.shippingMethod
              : _shippingMethods.first,
    );
    _paymentMethodController = TextEditingController(
      text: _editedOrder.paymentMethod,
    );
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ cho controllers
    _customerIdController.dispose();
    _totalAmountController.dispose();
    _messageController.dispose();
    _shippingMethodController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Tạo đơn hàng mới với các thông tin đã chỉnh sửa
        final updatedOrder = _editedOrder.copyWith(
          customerId: _customerIdController.text,
          totalAmount: double.parse(_totalAmountController.text),
          status: _editedOrder.status, // Giữ nguyên trạng thái hiện tại
          messageForShop: _messageController.text,
          shippingMethod: _shippingMethodController.text,
          paymentMethod: _paymentMethodController.text,
        );

        // Gọi phương thức cập nhật từ provider
        await Provider.of<OrderProvider>(
          context,
          listen: false,
        ).updateOrder(updatedOrder);

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật đơn hàng thành công'),
            backgroundColor: Colors.green,
          ),
        );

        // Quay lại trang trước và truyền kết quả thành công
        Navigator.pop(context, true);
      } catch (e) {
        // Xử lý lỗi nếu cập nhật không thành công
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
          'Chỉnh sửa Đơn hàng #${_editedOrder.orderId.substring(0, 8)}',
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
            _buildEditableTextField(
              controller: _customerIdController,
              label: 'ID Khách hàng',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập ID khách hàng';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(_editedOrder.dateTime)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildEditableTextField(
              controller: _totalAmountController,
              label: 'Tổng tiền (VNĐ)',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tổng tiền';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildStatusDropdown(),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMethodDropdown(
              label: 'Phương thức vận chuyển',
              controller: _shippingMethodController,
              options: _shippingMethods,
            ),
            const SizedBox(height: 16),
            _buildMethodDropdown(
              label: 'Phương thức thanh toán',
              controller: _paymentMethodController,
              options: _paymentMethods,
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
              itemCount: _editedOrder.items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_editedOrder.items[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _removeItem(index);
                    },
                  ),
                );
              },
            ),
            ElevatedButton.icon(
              onPressed: _addNewItem,
              icon: const Icon(Icons.add),
              label: const Text('Thêm sản phẩm'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _editedOrder.status,
      decoration: const InputDecoration(
        labelText: 'Trạng thái đơn hàng',
        border: OutlineInputBorder(),
      ),
      items:
          _statusOptions.map((status) {
            return DropdownMenuItem(value: status, child: Text(status));
          }).toList(),
      onChanged: (newStatus) {
        if (newStatus != null) {
          setState(() {
            _editedOrder = _editedOrder.copyWith(status: newStatus);
          });
        }
      },
    );
  }

  Widget _buildMethodDropdown({
    required String label,
    required TextEditingController controller,
    required List<String> options,
  }) {
    return DropdownButtonFormField<String>(
      value:
          options.contains(controller.text) ? controller.text : options.first,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items:
          options.map((method) {
            return DropdownMenuItem(value: method, child: Text(method));
          }).toList(),
      onChanged: (newMethod) {
        if (newMethod != null) {
          controller.text = newMethod;
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng chọn $label';
        }
        return null;
      },
    );
  }

  void _removeItem(int index) {
    setState(() {
      final updatedItems = List<String>.from(_editedOrder.items);
      updatedItems.removeAt(index);
      _editedOrder = _editedOrder.copyWith(items: updatedItems);
    });
  }

  void _addNewItem() {
    final TextEditingController itemController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm sản phẩm mới'),
          content: TextField(
            controller: itemController,
            decoration: const InputDecoration(
              labelText: 'Tên sản phẩm',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (itemController.text.isNotEmpty) {
                  setState(() {
                    final updatedItems = List<String>.from(_editedOrder.items)
                      ..add(itemController.text);
                    _editedOrder = _editedOrder.copyWith(items: updatedItems);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }
}
