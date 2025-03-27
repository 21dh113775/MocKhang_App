import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockhang_app/admin/data/data_sources/discount_db.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'dart:developer' as developer;

class DiscountRepository {
  final _uuid = Uuid();

  // Tạo mã vạch an toàn và có tính duy nhất
  // Tạo mã vạch duy nhất cho discount
  String generateBarcode(String id) {
    try {
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Cắt ID với timestamp để tạo mã vạch duy nhất
      String barcodeBase =
          id.substring(0, min(id.length, 10)) +
          timeStamp.substring(timeStamp.length - 8);

      // Chỉ giữ lại các ký tự số
      String numericOnly = barcodeBase.replaceAll(RegExp(r'[^0-9]'), '');

      // Đảm bảo mã vạch dài đủ 13 ký tự
      while (numericOnly.length < 13) {
        numericOnly += Random().nextInt(10).toString();
      }

      return numericOnly.substring(0, 13); // Cắt lại để luôn có 13 ký tự
    } catch (e) {
      developer.log('Lỗi tạo mã vạch', name: 'DiscountRepository', error: e);
      return DateTime.now().millisecondsSinceEpoch.toString().padLeft(
        13,
        '0',
      ); // Tạo mã vạch fallback
    }
  }

  // Kiểm tra tính hợp lệ của mã vạch (13 ký tự và phải là số)
  bool isValidBarcode(String barcode) {
    if (barcode.length != 13) return false; // Đảm bảo mã vạch có 13 ký tự
    if (!RegExp(r'^[0-9]+$').hasMatch(barcode))
      return false; // Chỉ cho phép các ký tự số

    // Kiểm tra mã vạch theo công thức Luhn
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final digit = int.parse(barcode[i]);
      sum += (i % 2 == 0) ? digit : digit * 3;
    }

    final checkDigit = (10 - (sum % 10)) % 10;
    return int.parse(barcode[12]) ==
        checkDigit; // So sánh với ký tự kiểm tra cuối cùng
  }

  // Thêm khuyến mãi với xử lý ngoại lệ và log chi tiết
  Future<DiscountModel> createDiscount(DiscountModel discount) async {
    try {
      // Kiểm tra xem discount có hợp lệ không
      if (discount.name.isEmpty || discount.value <= 0) {
        throw ArgumentError('Tên khuyến mãi hoặc giá trị không hợp lệ');
      }

      // Tạo ID và mã vạch duy nhất
      final id = _uuid.v4();
      final barcode = generateBarcode(id);

      // Tạo khuyến mãi mới với ID và mã vạch
      final newDiscount = discount.copyWith(id: id, barcode: barcode);

      // Thêm vào Firestore
      await DiscountDatabase.discountsCollection
          .doc(id)
          .set(newDiscount.toJson());

      developer.log(
        'Thêm khuyến mãi thành công',
        name: 'DiscountRepository',
        error: {'discountId': id, 'discountName': newDiscount.name},
      );

      return newDiscount;
    } catch (e) {
      developer.log(
        'Lỗi khi thêm khuyến mãi',
        name: 'DiscountRepository',
        error: e,
      );
      rethrow; // Ném lại exception để gọi hàm xử lý ở tầng trên
    }
  }

  // Lấy tất cả khuyến mãi với xử lý ngoại lệ
  Future<List<DiscountModel>> getAllDiscounts() async {
    try {
      final snapshot = await DiscountDatabase.discountsCollection.get();

      return snapshot.docs
          .map((doc) {
            try {
              return DiscountModel.fromJson(doc.data() as Map<String, dynamic>);
            } catch (e) {
              developer.log(
                'Lỗi parse dữ liệu khuyến mãi',
                name: 'DiscountRepository',
                error: e,
              );
              // Bỏ qua document lỗi
              return null;
            }
          })
          .whereType<DiscountModel>()
          .toList();
    } catch (e) {
      developer.log(
        'Lỗi lấy danh sách khuyến mãi',
        name: 'DiscountRepository',
        error: e,
      );
      return []; // Trả về danh sách rỗng thay vì ném lỗi
    }
  }

  // Lấy thông tin khuyến mãi theo ID với xử lý chi tiết
  Future<DiscountModel?> getDiscountById(String id) async {
    try {
      final doc = await DiscountDatabase.discountsCollection.doc(id).get();

      if (doc.exists) {
        return DiscountModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      developer.log(
        'Lỗi lấy khuyến mãi theo ID',
        name: 'DiscountRepository',
        error: {'discountId': id, 'errorDetails': e},
      );
      return null;
    }
  }

  // Cập nhật khuyến mãi với validation
  // Cập nhật khuyến mãi với validation
  Future<bool> updateDiscount(DiscountModel discount) async {
    try {
      // Kiểm tra tính hợp lệ của khuyến mãi trước khi cập nhật
      if (discount.id.isEmpty) {
        throw ArgumentError('ID khuyến mãi không hợp lệ');
      }

      // Cập nhật khuyến mãi
      await DiscountDatabase.discountsCollection
          .doc(discount.id)
          .update(discount.toJson());

      developer.log(
        'Cập nhật khuyến mãi thành công',
        name: 'DiscountRepository',
        error: {'discountId': discount.id, 'discountName': discount.name},
      );

      return true;
    } catch (e) {
      developer.log(
        'Lỗi cập nhật khuyến mãi',
        name: 'DiscountRepository',
        error: e,
      );
      return false;
    }
  }

  // Xóa khuyến mãi với xác nhận
  Future<bool> deleteDiscount(String id) async {
    try {
      // Kiểm tra tính hợp lệ của ID
      if (id.isEmpty) {
        throw ArgumentError('ID khuyến mãi không hợp lệ');
      }

      await DiscountDatabase.discountsCollection.doc(id).delete();

      developer.log(
        'Xóa khuyến mãi thành công',
        name: 'DiscountRepository',
        error: {'discountId': id},
      );

      return true;
    } catch (e) {
      developer.log('Lỗi xóa khuyến mãi', name: 'DiscountRepository', error: e);
      return false;
    }
  }

  // Lấy các khuyến mãi đang hoạt động với filter nâng cao
  Future<List<DiscountModel>> getActiveDiscounts() async {
    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      final snapshot =
          await DiscountDatabase.discountsCollection
              .where('startDate', isLessThanOrEqualTo: currentTime)
              .where('endDate', isGreaterThanOrEqualTo: currentTime)
              .get();

      return snapshot.docs
          .map(
            (doc) => DiscountModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      developer.log(
        'Lỗi lấy khuyến mãi đang hoạt động',
        name: 'DiscountRepository',
        error: e,
      );
      return [];
    }
  }
}
