import 'package:mockhang_app/admin/data/data_sources/order_db.dart';
import 'package:mockhang_app/admin/data/models/order_model.dart';

class OrderRepository {
  // Khởi tạo đối tượng OrderDB để tương tác với Firestore
  final OrderDB _orderDB = OrderDB();

  // Hàm lưu đơn hàng vào Firestore thông qua OrderDB
  Future<void> saveOrder(OrderModel order) async {
    try {
      await _orderDB.saveOrder(order);
    } catch (e) {
      // Ném ra lỗi với thông báo chi tiết nếu có sự cố xảy ra khi lưu đơn hàng
      throw Exception('Lỗi khi lưu đơn hàng trong OrderRepository: $e');
    }
  }

  // Hàm lấy danh sách đơn hàng của khách hàng dựa trên customerId
  Future<List<OrderModel>> getCustomerOrders(String customerId) async {
    try {
      return await _orderDB.getCustomerOrders(customerId);
    } catch (e) {
      // Ném ra lỗi với thông báo chi tiết nếu có sự cố xảy ra khi lấy đơn hàng của khách hàng
      throw Exception('Lỗi khi lấy đơn hàng của khách hàng: $e');
    }
  }

  // Hàm lấy danh sách tất cả các đơn hàng (dành cho admin)
  Future<List<OrderModel>> getAllOrders() async {
    try {
      return await _orderDB.getAllOrders();
    } catch (e) {
      // Ném ra lỗi với thông báo chi tiết nếu có sự cố xảy ra khi lấy tất cả đơn hàng
      throw Exception('Lỗi khi lấy tất cả đơn hàng: $e');
    }
  }

  // Hàm cập nhật trạng thái đơn hàng dựa trên orderId và status mới
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _orderDB.updateOrderStatus(orderId, status);
    } catch (e) {
      // Ném ra lỗi với thông báo chi tiết nếu có sự cố xảy ra khi cập nhật trạng thái đơn hàng
      throw Exception('Lỗi khi cập nhật trạng thái đơn hàng: $e');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _orderDB.deleteOrder(orderId);
    } catch (e) {
      throw Exception('Lỗi khi xóa đơn hàng trong repository: $e');
    }
  }

  // Thêm vào OrderRepository class
  Future<void> updateOrder(OrderModel updatedOrder) async {
    try {
      await _orderDB.updateOrder(updatedOrder);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật đơn hàng trong repository: $e');
    }
  }
}
