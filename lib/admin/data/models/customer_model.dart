class Customer {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final int orderCount;

  Customer({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.orderCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'orderCount': orderCount,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
      orderCount: map['orderCount'] ?? 0,
    );
  }
}
