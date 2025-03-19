class Product {
  final int? id;
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'soldQuantity': soldQuantity,
      'importedQuantity': importedQuantity,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: map['price'],
      stock: map['stock'],
      soldQuantity: map['soldQuantity'] ?? 0,
      importedQuantity: map['importedQuantity'] ?? 0,
      imageUrl: map['imageUrl']?.toString() ?? '', // Đảm bảo không bị null
      description: map['description'] ?? '',
    );
  }

  // Check if this is correctly implemented in your Product model
  Product copyWith({
    int? id,
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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: json['price'] is int ? json['price'].toDouble() : json['price'],
      stock: json['stock'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
