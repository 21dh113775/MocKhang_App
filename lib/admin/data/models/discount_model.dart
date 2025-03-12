class DiscountModel {
  final String id;
  final String name;
  final String type;
  final double value;
  final int startDate;
  final int endDate;
  final String? imageUrl;
  final String? code; // Thêm trường này
  final String? description; // Thêm trường này

  DiscountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
    this.code, // Thêm vào constructor
    this.description,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      value: json['value'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'value': value,
      'startDate': startDate,
      'endDate': endDate,
      'imageUrl': imageUrl,
    };
  }

  DiscountModel copyWith({
    String? id,
    String? name,
    String? type,
    double? value,
    int? startDate,
    int? endDate,
    String? imageUrl,
  }) {
    return DiscountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
