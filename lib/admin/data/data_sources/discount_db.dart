import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DiscountDatabase {
  static final DiscountDatabase instance = DiscountDatabase._init();
  static Database? _database;

  DiscountDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('discounts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE discounts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        value REAL NOT NULL,
        startDate INTEGER NOT NULL,
        endDate INTEGER NOT NULL,
        imageUrl TEXT
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
