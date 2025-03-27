import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String customerId;
  final double totalAmount;
  final String status;
  final DateTime dateTime; // Trường thời gian
  final List<String> items;
  final String shippingMethod;
  final String paymentMethod;
  final String messageForShop;
  final String? paypalTransactionId;

  OrderModel({
    required this.orderId,
    required this.customerId,
    required this.totalAmount,
    required this.status,
    required this.dateTime,
    required this.items,
    required this.shippingMethod,
    required this.paymentMethod,
    this.messageForShop = '',
    this.paypalTransactionId,
  });

  // Phương thức copyWith cho phép sao chép đối tượng với các giá trị thay đổi
  OrderModel copyWith({
    String? orderId,
    String? customerId,
    double? totalAmount,
    String? status,
    DateTime? dateTime,
    List<String>? items,
    String? shippingMethod,
    String? paymentMethod,
    String? messageForShop,
    String? paypalTransactionId,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      dateTime: dateTime ?? this.dateTime,
      items: items ?? this.items,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      messageForShop: messageForShop ?? this.messageForShop,
      paypalTransactionId: paypalTransactionId ?? this.paypalTransactionId,
    );
  }

  // Chuyển đối tượng thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'totalAmount': totalAmount,
      'status': status,
      'dateTime':
          dateTime.toIso8601String(), // Chuyển DateTime thành ISO8601 string
      'items': items,
      'shippingMethod': shippingMethod,
      'paymentMethod': paymentMethod,
      'messageForShop': messageForShop,
      'paypalTransactionId': paypalTransactionId,
    };
  }

  // Tạo OrderModel từ Map
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] ?? '',
      customerId: map['customerId'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'Đang xử lý',
      // Kiểm tra và chuyển đổi trường dateTime từ Timestamp sang DateTime
      dateTime:
          (map['dateTime'] is Timestamp)
              ? (map['dateTime'] as Timestamp).toDate()
              : DateTime.parse(map['dateTime']),
      items: List<String>.from(map['items'] ?? []),
      shippingMethod: map['shippingMethod'] ?? 'Tiêu chuẩn',
      paymentMethod: map['paymentMethod'] ?? 'Tiền mặt',
      messageForShop: map['messageForShop'] ?? '',
      paypalTransactionId: map['paypalTransactionId'],
    );
  }
}
