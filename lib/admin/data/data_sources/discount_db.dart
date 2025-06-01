import 'package:cloud_firestore/cloud_firestore.dart';

/// Lớp quản lý kết nối và thao tác với Firestore cho các khuyến mãi
class DiscountDatabase {
  // Singleton instance để quản lý kết nối Firestore
  static final DiscountDatabase instance = DiscountDatabase._init();

  // Tham chiếu tới Firestore instance
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tên collection lưu trữ khuyến mãi trong Firestore
  static const String _collectionName = 'discounts';

  // Hàm khởi tạo private để đảm bảo chỉ tạo duy nhất một instance
  DiscountDatabase._init();

  /// Lấy tham chiếu tới collection khuyến mãi trong Firestore
  ///
  /// Returns: CollectionReference để thực hiện các thao tác trên collection khuyến mãi
  static CollectionReference get discountsCollection {
    return _firestore.collection(_collectionName);
  }

  /// Thực hiện truy vấn khuyến mãi với các điều kiện tùy chọn
  ///
  /// [queryBuilder]: Hàm cho phép tùy chỉnh truy vấn Firestore
  /// Returns: Future chứa danh sách kết quả truy vấn
  Future<QuerySnapshot> queryDiscounts(Function(Query)? queryBuilder) async {
    Query query = discountsCollection;

    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    try {
      return await query.get();
    } catch (e) {
      print('Lỗi khi truy vấn khuyến mãi: $e');
      rethrow; // Ném lỗi lên để có thể xử lý ở tầng gọi
    }
  }

  /// Theo dõi thay đổi của một khuyến mãi cụ thể
  ///
  /// [discountId]: ID của khuyến mãi cần theo dõi
  /// Returns: Stream chứa DocumentSnapshot của khuyến mãi
  Stream<DocumentSnapshot> streamDiscount(String discountId) {
    try {
      return discountsCollection.doc(discountId).snapshots();
    } catch (e) {
      print('Lỗi khi theo dõi khuyến mãi: $e');
      rethrow;
    }
  }

  /// Theo dõi danh sách khuyến mãi với điều kiện tùy chọn
  ///
  /// [queryBuilder]: Hàm cho phép tùy chỉnh truy vấn Firestore
  /// Returns: Stream chứa QuerySnapshot của các khuyến mãi
  Stream<QuerySnapshot> streamDiscounts(Function(Query)? queryBuilder) {
    Query query = discountsCollection;

    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    try {
      return query.snapshots();
    } catch (e) {
      print('Lỗi khi theo dõi danh sách khuyến mãi: $e');
      rethrow;
    }
  }

  /// Thêm hook transaction để thực hiện các thao tác phức tạp
  ///
  /// [transactionHandler]: Hàm xử lý transaction
  /// Returns: Future<void>
  Future<void> runTransaction(
    Future<void> Function(Transaction) transactionHandler,
  ) async {
    try {
      await _firestore.runTransaction(transactionHandler);
    } catch (e) {
      print('Lỗi khi thực hiện transaction: $e');
      rethrow;
    }
  }

  /// Thực hiện batch write để thực hiện nhiều thao tác cùng lúc
  ///
  /// [batchHandler]: Hàm xử lý batch write
  /// Returns: Future<void>
  Future<void> runBatch(Function(WriteBatch) batchHandler) async {
    try {
      final batch = _firestore.batch();
      batchHandler(batch);
      await batch.commit();
    } catch (e) {
      print('Lỗi khi thực hiện batch write: $e');
      rethrow;
    }
  }

  /// Kiểm tra kết nối Firestore
  ///
  /// Returns: Trạng thái kết nối (true nếu kết nối thành công, false nếu không)
  Future<bool> testConnection() async {
    try {
      await _firestore.collection('test').get();
      return true;
    } catch (e) {
      print('Lỗi kết nối Firestore: $e');
      return false;
    }
  }

  // Truy vấn các khuyến mãi đang hoạt động (valid discounts)
  Future<QuerySnapshot> queryActiveDiscounts() async {
    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      return await discountsCollection
          .where('startDate', isLessThanOrEqualTo: currentTime)
          .where('endDate', isGreaterThanOrEqualTo: currentTime)
          .get();
    } catch (e) {
      print('Lỗi khi truy vấn khuyến mãi đang hoạt động: $e');
      rethrow;
    }
  }

  // /// Đặt thiết lập offline cho Firestore
  // ///
  // /// [enable]: Bật/tắt chế độ offline
  // Future<void> setOfflineMode(bool enable) async {
  //   try {
  //     await _firestore.settings = Settings(
  //       persistenceEnabled: enable,
  //       cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  //     );
  //     print('Firestore offline mode: ${enable ? "Bật" : "Tắt"}');
  //   } catch (e) {
  //     print('Lỗi khi thiết lập chế độ offline: $e');
  //     rethrow;
  //   }
  // }
}
