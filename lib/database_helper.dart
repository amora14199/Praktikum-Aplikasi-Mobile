import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_tracker.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        nominal INTEGER NOT NULL,
        kategori TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        is_pengeluaran INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // Password disimpan dalam bentuk hash, bukan teks asli
  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // ---------- USER ----------

  /// Return true kalau berhasil, false kalau email sudah terdaftar
  Future<bool> registerUser(String nama, String email, String password) async {
    final db = await database;
    try {
      await db.insert('users', {
        'nama': nama,
        'email': email.toLowerCase(),
        'password': hashPassword(password),
      });
      return true;
    } on DatabaseException {
      return false;
    }
  }

  /// Return data user kalau email & password cocok, null kalau salah
  Future<Map<String, Object?>?> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email.toLowerCase(), hashPassword(password)],
      limit: 1,
    );
    return result.isEmpty ? null : result.first;
  }

  // ---------- TRANSAKSI ----------

  Future<int> insertTransaksi({
    required int userId,
    required String title,
    required int nominal,
    required String kategori,
    required String tanggal,
    required bool isPengeluaran,
  }) async {
    final db = await database;
    return db.insert('transactions', {
      'user_id': userId,
      'title': title,
      'nominal': nominal,
      'kategori': kategori,
      'tanggal': tanggal,
      'is_pengeluaran': isPengeluaran ? 1 : 0,
    });
  }

  Future<List<Map<String, Object?>>> getTransaksi(int userId) async {
    final db = await database;
    return db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }
}