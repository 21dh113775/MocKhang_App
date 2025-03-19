class OrderModel {
  final String orderId;
  final String customerId;
  final double totalAmount;
  final String status;
  final DateTime dateTime;
  final List<String> items; // Danh sách ID của sản phẩm trong đơn hàng
  final String shippingMethod;
  final String paymentMethod;
  final String messageForShop;

  OrderModel({
    required this.orderId,
    required this.customerId,
    required this.totalAmount,
    required this.status,
    required this.dateTime,
    required this.items,
    required this.shippingMethod,
    required this.paymentMethod,
    required this.messageForShop,
  });

  // Phương thức copyWith
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
    );
  }

  // Chuyển đổi OrderModel sang Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'totalAmount': totalAmount,
      'status': status,
      'dateTime': dateTime,
      'items': items,
      'shippingMethod': shippingMethod,
      'paymentMethod': paymentMethod,
      'messageForShop': messageForShop,
    };
  }

  // Chuyển đổi từ Map sang OrderModel
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'],
      customerId: map['customerId'],
      totalAmount: map['totalAmount'],
      status: map['status'],
      dateTime: map['dateTime'].toDate(),
      items: List<String>.from(map['items']),
      shippingMethod: map['shippingMethod'],
      paymentMethod: map['paymentMethod'],
      messageForShop: map['messageForShop'],
    );
  }
}
