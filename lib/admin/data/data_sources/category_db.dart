import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category_model.dart';

class CategoryDatabase {
  static final CategoryDatabase instance = CategoryDatabase._init();
  static Database? _database;

  CategoryDatabase._init();

  /// Lấy Database (tạo nếu chưa có)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Khởi tạo Database SQLite
  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'categories.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// **Thêm danh mục**
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// **Lấy tất cả danh mục**
  Future<List<Category>> fetchCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  /// **Cập nhật danh mục**
  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// **Xóa danh mục**
  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  /// **Xóa toàn bộ danh mục**
  Future<void> clearCategories() async {
    final db = await database;
    await db.delete('categories');
  }

  /// **Đóng Database**
  Future<void> close() async {
    final db = await _database;
    if (db != null) {
      await db.close();
    }
  }
}
