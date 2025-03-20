class Category {
  final String?
  id; // Thay đổi từ int sang String vì Firestore sử dụng String ID
  final String name;
  final String? icon;

  Category({this.id, required this.name, this.icon});

  Map<String, dynamic> toMap() {
    return {'name': name, 'icon': icon};
  }

  factory Category.fromMap(Map<String, dynamic> map, String docId) {
    return Category(id: docId, name: map['name'] ?? '', icon: map['icon']);
  }

  // Tạo bản sao của category với ID mới
  Category copyWith({String? id, String? name, String? icon}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }
}
