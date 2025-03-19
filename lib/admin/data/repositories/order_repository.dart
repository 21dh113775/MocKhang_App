import 'package:mockhang_app/admin/data/data_sources/order_db.dart';
import 'package:mockhang_app/admin/data/models/order_model.dart';

class OrderRepository {
  final OrderDB _orderDB = OrderDB();

  Future<void> saveOrder(OrderModel order) async {
    await _orderDB.saveOrder(order);
  }

  Future<List<OrderModel>> getCustomerOrders(String customerId) async {
    return await _orderDB.getCustomerOrders(customerId);
  }

  Future<List<OrderModel>> getAllOrders() async {
    return await _orderDB.getAllOrders();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _orderDB.updateOrderStatus(orderId, status);
  }
}
