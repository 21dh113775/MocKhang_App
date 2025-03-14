class Category {
  final int? id;
  final String name;
  final String? icon;

  Category({this.id, required this.name, this.icon});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(id: map['id'], name: map['name']);
  }
}
