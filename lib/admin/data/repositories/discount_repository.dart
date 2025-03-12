import 'package:mockhang_app/admin/data/data_sources/discount_db.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:uuid/uuid.dart';

class DiscountRepository {
  final DiscountDatabase _database = DiscountDatabase.instance;
  final _uuid = Uuid();

  // Thêm khuyến mãi mới
  Future<DiscountModel> createDiscount(DiscountModel discount) async {
    final db = await _database.database;
    final id = _uuid.v4();
    final newDiscount = discount.copyWith(id: id);

    await db.insert('discounts', newDiscount.toJson());
    return newDiscount;
  }

  // Lấy tất cả khuyến mãi
  Future<List<DiscountModel>> getAllDiscounts() async {
    final db = await _database.database;
    final result = await db.query('discounts');

    return result.map((json) => DiscountModel.fromJson(json)).toList();
  }

  // Lấy khuyến mãi theo ID
  Future<DiscountModel?> getDiscountById(String id) async {
    final db = await _database.database;
    final maps = await db.query('discounts', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return DiscountModel.fromJson(maps.first);
    }
    return null;
  }

  // Cập nhật khuyến mãi
  Future<int> updateDiscount(DiscountModel discount) async {
    final db = await _database.database;

    return await db.update(
      'discounts',
      discount.toJson(),
      where: 'id = ?',
      whereArgs: [discount.id],
    );
  }

  // Xóa khuyến mãi
  Future<int> deleteDiscount(String id) async {
    final db = await _database.database;

    return await db.delete('discounts', where: 'id = ?', whereArgs: [id]);
  }

  // Lấy khuyến mãi hiện tại (còn hiệu lực)
  Future<List<DiscountModel>> getActiveDiscounts() async {
    final db = await _database.database;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    final result = await db.query(
      'discounts',
      where: 'startDate <= ? AND endDate >= ?',
      whereArgs: [currentTime, currentTime],
    );

    return result.map((json) => DiscountModel.fromJson(json)).toList();
  }
}
