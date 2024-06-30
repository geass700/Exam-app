import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UserdataHandle {
  UserdataHandle._privateConstructor();
  static final UserdataHandle instance = UserdataHandle._privateConstructor();
  static const _databaseName = 'UserDb.db';
  static const _databaseVersion = 1;
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory dataDir = await getApplicationDocumentsDirectory();
    String dbPath = join(dataDir.path, _databaseName);
    return await openDatabase(dbPath,
        version: _databaseVersion, onCreate: _onCreateTable);
  }

  _onCreateTable(Database db, int version) async {
    await db.execute(
      "CREATE TABLE doneTable(id INTEGER PRIMARY KEY AUTOINCREMENT, question_id INTEGER NOT NULL, category TEXT NOT NULL)",
    );
    await db.execute(
      "CREATE TABLE nextsetTable(id INTEGER NOT NULL PRIMARY KEY, question_id INTEGER NOT NULL, category TEXT NOT NULL)",
    );
    await db.execute(
      "CREATE TABLE scoreTable(id INTEGER NOT NULL PRIMARY KEY, correct INTEGER NOT NULL,  total INTEGER NOT NULL, category TEXT NOT NULL)",
    );

  }

  Future<void> insertDoneTable(int q_id, String category) async {
    Database db = await database;
    await db.insert(
      'doneTable',
      {'question_id': q_id, 'category': category},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertNextSetTable(int id,int q_id, String category) async {
    Database db = await database;
    await db.insert(
      'nextsetTable',
      {'id': id, 'question_id': q_id, 'category': category},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertScoreTable(int id,int correct,int total, String category) async {
    Database db = await database;
    await db.insert(
      'scoreTable',
      {'id': id, 'correct': correct, 'total': total, 'category': category},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateNextSetTable(int id, int q_id, String category) async {
    Database db = await database;
    await db.update(
      'nextsetTable',
      {'question_id': q_id, 'category': category},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, List<int>>> getDoneTableData() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('doneTable');

    Map<String, List<int>> result = {};
    for (var map in maps) {
      String category = map['category'];
      int questionId = map['question_id'];
      if (!result.containsKey(category)) {
        result[category] = [];
      }
      result[category]!.add(questionId);
    }
    return result;
  }

  Future<Map<String, List<int>>> getNextSetTableData() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('nextsetTable');

    Map<String, List<int>> result = {};
    for (var map in maps) {
      String category = map['category'];
      int questionId = map['question_id'];
      if (!result.containsKey(category)) {
        result[category] = [];
      }
      result[category]!.add(questionId);
    }
    return result;
  }

  Future<Map<String, List<int>>> getScoreTableData() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('scoreTable');

    Map<String, List<int>> result = {};
    for (var map in maps) {
      String category = map['category'];
      int correct = map['correct'];
      int total = map['total'];
      if (!result.containsKey(category)) {
        result[category] = [];
      }
      result[category]!.add(correct);
      result[category]!.add(total);
    }
    return result;
  }

}