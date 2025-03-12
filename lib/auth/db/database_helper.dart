// lib/auth/db/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    await _ensureAdminExists(); // Đảm bảo tài khoản admin tồn tại
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    debugPrint('SQLite database path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) async {
        debugPrint('Database opened successfully');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint('Creating new database with tables');
    await db.execute('''
      CREATE TABLE admin(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        name TEXT NOT NULL
      )
    ''');

    // Insert default admin account
    await _insertDefaultAdmin(db);
  }

  Future<void> _insertDefaultAdmin(Database db) async {
    debugPrint('Inserting default admin account');
    await db.insert('admin', {
      'email': 'admin@gmail.com',
      'password': 'admin123',
      'name': 'Admin',
    });
  }

  // Đảm bảo tài khoản admin đã tồn tại
  Future<void> _ensureAdminExists() async {
    final db = await database;
    final List<Map<String, dynamic>> admins = await db.query('admin');

    if (admins.isEmpty) {
      debugPrint('No admin accounts found, creating default admin');
      await _insertDefaultAdmin(db);
    } else {
      debugPrint('Admin accounts already exist: ${admins.length}');
    }
  }

  // Kiểm tra xem tài khoản admin có tồn tại không
  Future<bool> validateAdmin(String email, String password) async {
    debugPrint('Validating admin: $email');
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'admin',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    debugPrint('Admin validation result: ${result.isNotEmpty}');
    if (result.isNotEmpty) {
      debugPrint('Admin found: ${result.first}');
    }

    return result.isNotEmpty;
  }

  // Lấy tất cả tài khoản admin (cho debug)
  Future<List<Map<String, dynamic>>> getAllAdmins() async {
    final db = await database;
    return await db.query('admin');
  }

  // Đặt lại cơ sở dữ liệu (chỉ dùng khi debug)
  Future<void> resetDatabase() async {
    debugPrint('Resetting database...');
    String path = join(await getDatabasesPath(), 'app_database.db');
    await deleteDatabase(path);
    _database = null;
    await database; // Khởi tạo lại
    debugPrint('Database reset completed');
  }
}
