import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/order_model.dart';
import 'package:mockhang_app/admin/data/repositories/order_repository.dart';

class OrderProvider with ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();
  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  // Lấy đơn hàng của khách hàng
  Future<void> loadCustomerOrders(String customerId) async {
    _orders = await _orderRepository.getCustomerOrders(customerId);
    notifyListeners();
  }

  // Lấy tất cả các đơn hàng (dành cho admin)
  Future<void> loadAllOrders() async {
    _orders = await _orderRepository.getAllOrders();
    notifyListeners();
  }

  // Lưu đơn hàng
  Future<void> saveOrder(OrderModel order) async {
    await _orderRepository.saveOrder(order);
    _orders.add(order);
    notifyListeners();
  }

  // Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _orderRepository.updateOrderStatus(orderId, status);
    // Cập nhật lại trạng thái đơn hàng trong danh sách
    final index = _orders.indexWhere((order) => order.orderId == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: status);
      notifyListeners();
    }
  }
}
