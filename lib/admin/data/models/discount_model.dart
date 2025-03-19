class DiscountModel {
  final String id;
  final String name;
  final String type;
  final double value;
  final int startDate;
  final int endDate;
  final String? code;
  final String? description;
  final String? barcode;

  DiscountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.startDate,
    required this.endDate,
    this.code,
    this.description,
    this.barcode,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      value: json['value'].toDouble(),
      startDate: json['startDate'],
      endDate: json['endDate'],
      code: json['code'],
      description: json['description'],
      barcode: json['barcode'],
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
      'code': code,
      'description': description,
      'barcode': barcode,
    };
  }

  DiscountModel copyWith({
    String? id,
    String? name,
    String? type,
    double? value,
    int? startDate,
    int? endDate,
    String? code,
    String? description,
    String? barcode,
  }) {
    return DiscountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      code: code ?? this.code,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
    );
  }

  // Phương thức kiểm tra tính hợp lệ của mã giảm giá
  bool isValid() {
    final currentDate = DateTime.now().millisecondsSinceEpoch;

    // Kiểm tra xem mã giảm giá có trong thời gian hợp lệ không
    return currentDate >= startDate && currentDate <= endDate;
  }
}
