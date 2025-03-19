import 'dart:math';
import 'package:mockhang_app/admin/data/data_sources/discount_db.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart'; // Đảm bảo import sqflite

class DiscountRepository {
  final DiscountDatabase _database = DiscountDatabase.instance;
  final _uuid = Uuid();

  // Getter để lấy database từ DiscountDatabase
  Future<Database> get database async {
    return await _database.database; // Trả về database từ DiscountDatabase
  }

  // Tạo mã vạch dựa trên ID
  String generateBarcode(String id) {
    // Sử dụng 10 ký tự đầu tiên của id + thời gian hiện tại để tạo mã vạch duy nhất
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    String barcodeBase =
        id.substring(0, min(id.length, 10)) +
        timeStamp.substring(timeStamp.length - 8);

    // Định dạng mã theo chuẩn EAN-13 hoặc format khác
    // Ở đây chúng ta đơn giản hóa bằng cách tạo một chuỗi số 13 chữ số
    String numericOnly = barcodeBase.replaceAll(RegExp(r'[^0-9]'), '');

    // Đảm bảo đủ 13 chữ số (hoặc điều chỉnh theo nhu cầu)
    while (numericOnly.length < 13) {
      numericOnly += Random().nextInt(10).toString();
    }

    return numericOnly.substring(0, 13);
  }

  // Thêm khuyến mãi mới với mã vạch
  Future<DiscountModel> createDiscount(DiscountModel discount) async {
    final db = await database; // Sử dụng getter database
    final id = _uuid.v4();

    // Tạo mã vạch mới
    final barcode = generateBarcode(id);

    final newDiscount = discount.copyWith(id: id, barcode: barcode);

    await db.insert('discounts', newDiscount.toJson());
    return newDiscount;
  }

  // Lấy tất cả khuyến mãi
  Future<List<DiscountModel>> getAllDiscounts() async {
    final db = await database; // Sử dụng getter database
    final result = await db.query('discounts');

    return result.map((json) => DiscountModel.fromJson(json)).toList();
  }

  // Lấy thông tin khuyến mãi theo ID
  Future<DiscountModel?> getDiscountById(String id) async {
    final db = await database; // Sử dụng getter database
    final maps = await db.query('discounts', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return DiscountModel.fromJson(maps.first);
    }
    return null;
  }

  // Cập nhật khuyến mãi
  Future<int> updateDiscount(DiscountModel discount) async {
    final db = await database; // Sử dụng getter database

    return await db.update(
      'discounts',
      discount.toJson(),
      where: 'id = ?',
      whereArgs: [discount.id],
    );
  }

  // Xóa khuyến mãi
  Future<int> deleteDiscount(String id) async {
    final db = await database; // Sử dụng getter database

    return await db.delete('discounts', where: 'id = ?', whereArgs: [id]);
  }

  // Lấy các khuyến mãi đang hoạt động
  Future<List<DiscountModel>> getActiveDiscounts() async {
    final db = await database; // Sử dụng getter database
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    final result = await db.query(
      'discounts',
      where: 'startDate <= ? AND endDate >= ?',
      whereArgs: [currentTime, currentTime],
    );

    return result.map((json) => DiscountModel.fromJson(json)).toList();
  }
}
