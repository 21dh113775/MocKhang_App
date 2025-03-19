import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockhang_app/admin/data/models/order_model.dart';

class OrderDB {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lưu đơn hàng vào Firestore
  Future<void> saveOrder(OrderModel order) async {
    try {
      await _firestore
          .collection('orders')
          .doc(order.orderId)
          .set(order.toMap());
    } catch (e) {
      throw Exception('Lỗi khi lưu đơn hàng: $e');
    }
  }

  // Lấy danh sách đơn hàng của khách hàng
  Future<List<OrderModel>> getCustomerOrders(String customerId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('orders')
              .where('customerId', isEqualTo: customerId)
              .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách đơn hàng: $e');
    }
  }

  // Lấy danh sách tất cả các đơn hàng (admin)
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final querySnapshot = await _firestore.collection('orders').get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy tất cả đơn hàng: $e');
    }
  }

  // Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception('Lỗi khi cập nhật trạng thái đơn hàng: $e');
    }
  }
}
