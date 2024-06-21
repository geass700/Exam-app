import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Map<String, Database> _databases = {};

  DatabaseHelper._internal();

  Future<Database> getDatabase(String dbName) async {
    if (_databases.containsKey(dbName)) return _databases[dbName]!;

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);

    // ตรวจสอบว่าฐานข้อมูลมีอยู่ในเส้นทางนี้แล้วหรือไม่
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      // ถ้าไม่มี ให้คัดลอกจาก assets
      ByteData data = await rootBundle.load('assets/database/$dbName');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
    }

    Database db = await openDatabase(path);
    _databases[dbName] = db;
    return db;
  }

  Future<List<Map<String, dynamic>>> getQuestions(String tableName) async {
    Database db = await getDatabase('questionDatabase.db');
    return await db.query(tableName);
  }

  Future<List<Map<String, dynamic>>> getSpecificQuestions(String tableName, List<int> questionIds) async {
    Database db = await getDatabase('questionDatabase.db');
    String ids = questionIds.join(',');
    List<Map<String, dynamic>> result = await db.rawQuery('SELECT * FROM $tableName WHERE id IN ($ids)');
    return result;
  }

  Future<Database> _openDatabase(String dbName) async {
    final dbPath = await getDatabasesPath();
    return openDatabase(join(dbPath, dbName));
  }

  Future<List<Map<String, dynamic>>> getAllQuestions(String tableName) async {
    final db = await getDatabase('questionDatabase.db');
    return db.query(tableName);
  }

  Future<void> insertQuizHistory(int categoryId, int questionId, String selectedOption, int score) async {
    Database db = await getDatabase('results.db');
    await db.insert(
      'quiz_history',
      {
        'category_id': categoryId,
        'question_id': questionId,
        'selected_option': selectedOption,
        'score': score,
      },
    );
  }
}
