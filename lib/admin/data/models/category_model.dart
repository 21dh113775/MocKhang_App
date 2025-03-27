class Category {
  final String? id; // The unique ID
  final String name; // The category name
  final String?
  icon; // Optional icon (can be used for text-based or simple icons)
  final String? imageUrl; // Field for the category image URL

  // Constructor
  Category({this.id, required this.name, this.icon, this.imageUrl});

  // Convert Category object to a Map (useful for Firestore or other databases)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'imageUrl': imageUrl, // Include image URL in the map
    };
  }

  // Create Category instance from a Map (useful when fetching from a database)
  factory Category.fromMap(Map<String, dynamic> map, String docId) {
    return Category(
      id: docId,
      name: map['name'] ?? '',
      icon: map['icon'],
      imageUrl: map['imageUrl'], // Handle the image URL from the map
    );
  }

  // Copy function to modify category attributes
  Category copyWith({
    String? id,
    String? name,
    String? icon,
    String? imageUrl,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
