import 'dart:convert';
import 'package:flutter/material.dart';
import 'testTile.dart';
import 'main_page.dart';
import 'catagory.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class StatPage extends StatefulWidget {
  const StatPage({super.key});

  @override
  State<StatPage> createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  Database? scoredatabase;
  Map<String, List<int>> loadedScore = {};

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    await _openDatabase();
    await _loadScore();
  }

  Future<void> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final dbPathWithName = path.join(dbPath, 'scoreList.db');
    scoredatabase = await openDatabase(
      dbPathWithName,
      version: 1,
    );
  }

  Future<void> _loadScore() async {
    if (scoredatabase != null) {
      final List<Map<String, dynamic>> result = await scoredatabase!.query('scorelist');
      Map<String, dynamic> data = json.decode(result.first['scoredata']);
      setState(() {
        loadedScore = data.map((key, value) => MapEntry(key, List<int>.from(value)));
      });
    }
  }

  // Map ที่เก็บจำนวนข้อสอบทั้งหมดสำหรับแต่ละหมวด
  final Map<String, int> totalQuestionsMap = {
    'car_maintenance.db': 126,
    'save_drive.db': 212,
    'manners_and_conscience.db': 108,
    'warning_sign.db': 58,
    'mandatory_sign.db': 38,
    'dangerous_situations.db': 21,
    'law_land_traffic.db': 52,
    'law_automobile.db': 88,
    'law_commercial_and_criminal.db': 63,
  };

  List<Category> cats = [
    Category(
      Name: 'การบำรุงรักษารถ',
      Id: 1,
      data: 'car_maintenance.db',
    ),
    Category(
      Name: 'เทคนิคการขับขี่อย่างปลอดภัย',
      Id: 2,
      data: 'save_drive.db',
    ),
    Category(
      Name: 'มารยาทและจิตสำนึก',
      Id: 3,
      data: 'manners_and_conscience.db',
    ),
    Category(
      Name: 'ป้ายเตือน',
      Id: 4,
      data: 'warning_sign.db',
    ),
    Category(
      Name: 'ป้ายบังคับ',
      Id: 5,
      data: 'mandatory_sign.db',
    ),
    Category(
      Name: 'การรับรู้สถานการณ์อันตราย',
      Id: 6,
      data: 'dangerous_situations.db',
    ),
    Category(
      Name: 'กฎหมายว่าด้วยการจราจรทางบก',
      Id: 7,
      data: 'law_land_traffic.db',
    ),
    Category(
      Name: 'กฎหมายว่าด้วยรถยนต์',
      Id: 8,
      data: 'law_automobile.db',
    ),
    Category(
      Name: 'หมวดกฎหมายแพ่งพาณิชย์และกฎหมายอาญา',
      Id: 9,
      data: 'law_commercial_and_criminal.db',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: handleClickBack),
        title: Text('สถิติ'),
        backgroundColor: Color(0xFF92CA68),
      ),
      body: ListView.builder(
        itemCount: cats.length,
        itemBuilder: (context, int index) {
          var cat = cats[index];
          var scores = loadedScore[cat.data] ?? [0, 0];
          var totalQuestions = scores[1];
          var correctAnswers = scores[0];
          var percentage = totalQuestions > 0
              ? (correctAnswers / totalQuestions * 100).toStringAsFixed(2)
              : "0";

          // ดึงจำนวนข้อสอบทั้งหมดจาก map
          var totalQuestionsInCategory = totalQuestionsMap[cat.data] ?? 0;

          return Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(cat.Name),
                  Text('คุณทำข้อสอบไปแล้ว $totalQuestions ข้อ (จาก $totalQuestionsInCategory ข้อ)'),
                  Text('อัตราการทำข้อสอบถูก $percentage %'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void handleClickBack() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }
}
