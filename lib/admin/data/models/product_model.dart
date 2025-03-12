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
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
