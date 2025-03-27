import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id; // ID sản phẩm được lấy từ Firestore (là String)
  final String name;
  final String category;
  final double price;
  final int stock;
  final int soldQuantity;
  final int importedQuantity;
  final String imageUrl;
  final String description;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.soldQuantity = 0,
    this.importedQuantity = 0,
    required this.imageUrl,
    required this.description,
  });

  /// **Chuyển đổi đối tượng Product thành Map để lưu vào Firestore**
  ///
  /// Phương thức này dùng để chuyển đối tượng `Product` thành một `Map<String, dynamic>`
  /// để có thể lưu trữ vào Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'soldQuantity': soldQuantity,
      'importedQuantity': importedQuantity,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(), // Tự động tạo thời gian server
      'updatedAt': FieldValue.serverTimestamp(), // Thêm thời gian cập nhật
    };
  }

  /// **Chuyển đổi Map từ Firestore thành đối tượng Product**
  ///
  /// Phương thức này giúp chuyển đổi dữ liệu trả về từ Firestore thành đối tượng `Product`.
  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price:
          (map['price'] is int)
              ? (map['price'] as int).toDouble()
              : map['price'] ?? 0.0,
      stock: map['stock'] ?? 0,
      soldQuantity: map['soldQuantity'] ?? 0,
      importedQuantity: map['importedQuantity'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
    );
  }

  /// **Hàm tạo đối tượng Product từ JSON (nếu cần dùng trong các API khác)**
  ///
  /// Phương thức này dùng khi nhận dữ liệu dưới dạng JSON từ API hoặc từ các nguồn ngoài Firestore.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price:
          json['price'] is int
              ? json['price'].toDouble()
              : json['price'] ?? 0.0,
      stock: json['stock'] ?? 0,
      soldQuantity: json['soldQuantity'] ?? 0,
      importedQuantity: json['importedQuantity'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
    );
  }

  /// **Sao chép đối tượng Product với các thay đổi cụ thể**
  ///
  /// Phương thức `copyWith` này giúp bạn tạo ra một bản sao của đối tượng `Product`
  /// nhưng có thể thay đổi một số thuộc tính nhất định.
  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? stock,
    int? soldQuantity,
    int? importedQuantity,
    String? imageUrl,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      soldQuantity: soldQuantity ?? this.soldQuantity,
      importedQuantity: importedQuantity ?? this.importedQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }

  /// **Kiểm tra tính hợp lệ của dữ liệu sản phẩm**
  ///
  /// Phương thức này kiểm tra xem dữ liệu của sản phẩm có hợp lệ không.
  bool get isValid {
    return name.isNotEmpty && category.isNotEmpty && price > 0 && stock >= 0;
  }

  /// **In thông tin sản phẩm ra dưới dạng chuỗi**
  ///
  /// Phương thức này giúp in ra thông tin sản phẩm dưới dạng chuỗi để dễ dàng kiểm tra.
  @override
  String toString() {
    return 'Product{id: $id, name: $name, category: $category, price: $price, stock: $stock, soldQuantity: $soldQuantity, importedQuantity: $importedQuantity, imageUrl: $imageUrl, description: $description}';
  }
}
