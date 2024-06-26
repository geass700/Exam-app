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

    // ลบฐานข้อมูลที่มีอยู่
    await deleteDatabase(path);

    // คัดลอกฐานข้อมูลจาก assets
    await copyDatabaseFromAssets(path, dbName);

    Database db = await openDatabase(path);
    _databases[dbName] = db;

    return db;
  }

  Future<void> copyDatabaseFromAssets(String path, String dbName) async {
    ByteData data = await rootBundle.load('assets/database/$dbName');
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes);
  }

  Future<List<Map<String, dynamic>>> getQuestions(String dbName) async {
    Database db = await getDatabase(dbName);
    return await db.query('questions');
  }

  Future<List<Map<String, dynamic>>> getSpecificQuestions(String dbName, List<int> questionIds) async {
    Database db = await getDatabase(dbName);
    String ids = questionIds.join(',');
    List<Map<String, dynamic>> result = await db.rawQuery('SELECT * FROM questions WHERE id IN ($ids)');
    return result;
  }

  Future<Map<int, int>> getLastQuestionsByCategory(List<int> categoryIds) async {
    Database db = await getDatabase('results.db');
    Map<int, int> lastQuestions = {};
    for (var categoryId in categoryIds) {
      List<Map<String, dynamic>> result = await db.query(
        'quiz_history',
        where: 'category_id = ?',
        whereArgs: [categoryId],
        orderBy: 'id DESC',
        limit: 1,
      );
      if (result.isNotEmpty) {
        lastQuestions[categoryId] = result.first['question_id'];
      }
    }
    return lastQuestions;
  }

}
