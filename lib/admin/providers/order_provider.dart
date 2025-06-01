import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/order_model.dart';
import 'package:mockhang_app/admin/data/repositories/order_repository.dart';

class OrderProvider with ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();
  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  // Lấy đơn hàng của khách hàng
  Future<void> loadCustomerOrders(String customerId) async {
    try {
      _orders = await _orderRepository.getCustomerOrders(customerId);
      if (_orders.isEmpty) {
        // Thông báo nếu không có đơn hàng
        debugPrint("Không có đơn hàng cho khách hàng với ID: $customerId");
      }
      notifyListeners();
    } catch (e) {
      // Xử lý lỗi khi lấy dữ liệu
      debugPrint("Lỗi khi tải đơn hàng của khách hàng: $e");
      throw Exception("Không thể tải đơn hàng");
    }
  }

  // Lấy tất cả các đơn hàng (dành cho admin)
  Future<void> loadAllOrders() async {
    try {
      _orders = await _orderRepository.getAllOrders();
      if (_orders.isEmpty) {
        // Thông báo nếu không có đơn hàng
        debugPrint("Không có đơn hàng nào");
      }
      notifyListeners();
    } catch (e) {
      // Xử lý lỗi khi gọi API
      debugPrint("Lỗi khi tải tất cả đơn hàng: $e");
      throw Exception("Không thể tải tất cả đơn hàng");
    }
  }

  // Lưu đơn hàng
  Future<void> saveOrder(OrderModel order) async {
    try {
      await _orderRepository.saveOrder(order);
      _orders.add(order);
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi khi lưu đơn hàng: $e");
      throw Exception("Không thể lưu đơn hàng");
    }
  }

  // Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _orderRepository.updateOrderStatus(orderId, status);
      // Cập nhật lại trạng thái đơn hàng trong danh sách
      final index = _orders.indexWhere((order) => order.orderId == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: status);
        notifyListeners();
      } else {
        debugPrint("Không tìm thấy đơn hàng với ID: $orderId");
        throw Exception("Không tìm thấy đơn hàng để cập nhật");
      }
    } catch (e) {
      debugPrint("Lỗi khi cập nhật trạng thái đơn hàng: $e");
      throw Exception("Không thể cập nhật trạng thái đơn hàng");
    }
  }

  // Thêm vào OrderProvider class
  Future<void> updateOrder(OrderModel updatedOrder) async {
    try {
      await _orderRepository.updateOrder(updatedOrder);

      // Cập nhật đơn hàng trong danh sách
      final index = _orders.indexWhere(
        (order) => order.orderId == updatedOrder.orderId,
      );
      if (index != -1) {
        _orders[index] = updatedOrder;
        notifyListeners();
      } else {
        debugPrint("Không tìm thấy đơn hàng để cập nhật");
        throw Exception("Không tìm thấy đơn hàng để cập nhật");
      }
    } catch (e) {
      debugPrint("Lỗi khi cập nhật đơn hàng: $e");
      throw Exception("Không thể cập nhật đơn hàng");
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _orderRepository.deleteOrder(orderId);
      // Loại bỏ đơn hàng khỏi danh sách
      _orders.removeWhere((order) => order.orderId == orderId);
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi khi xóa đơn hàng: $e");
      throw Exception("Không thể xóa đơn hàng");
    }
  }
}
