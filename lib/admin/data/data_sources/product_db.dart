import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ProductDatabase {
  static final ProductDatabase instance = ProductDatabase._init();
  static Database? _database;

  ProductDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'products.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            price REAL NOT NULL,
            stock INTEGER NOT NULL,
            soldQuantity INTEGER DEFAULT 0,
            importedQuantity INTEGER DEFAULT 0,
            imageUrl TEXT,
            description TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE products ADD COLUMN soldQuantity INTEGER DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE products ADD COLUMN importedQuantity INTEGER DEFAULT 0',
          );
        }
      },
    );
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Product>> fetchProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;

    // Debugging print statements to check if data is correct
    print('Updating product: ${product.toMap()}');

    // Update the product and check if it worked
    int result = await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );

    print('Update result: $result');
    return result;
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateStock(
    int productId,
    int stock,
    int sold,
    int imported,
  ) async {
    final db = await database;
    return await db.update(
      'products',
      {'stock': stock, 'soldQuantity': sold, 'importedQuantity': imported},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }
}
