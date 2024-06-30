import 'dart:convert';
import 'package:flutter/material.dart';
import 'testTile.dart';
import 'main_page.dart';
import 'catagory.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'userdatahandle.dart';

class StatPage extends StatefulWidget {
  const StatPage({super.key});

  @override
  State<StatPage> createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  final UserdataHandle UserHelper = UserdataHandle.instance;

  @override
  void initState() {
    super.initState();
    _loadScore();
  }

  Map<String, List<int>> score = {
    'car_maintenance': [0, 0],
    'save_drive': [0, 0],
    'manners_and_conscience': [0, 0],
    'warning_sign': [0, 0],
    'mandatory_sign': [0, 0],
    'dangerous_situations': [0, 0],
    'law_land_traffic': [0, 0],
    'law_automobile': [0, 0],
    'law_commercial_and_criminal': [0, 0],
  };

  Future<void> _loadScore() async {
    Map<String, List<int>> scoreTableData = await UserHelper.getScoreTableData();
    if (scoreTableData.isNotEmpty) {
      setState(() {
        score = scoreTableData;
      });
    }
  }

  final Map<String, int> totalQuestionsMap = {
    'car_maintenance': 126,
    'save_drive': 212,
    'manners_and_conscience': 108,
    'warning_sign': 58,
    'mandatory_sign': 38,
    'dangerous_situations': 21,
    'law_land_traffic': 52,
    'law_automobile': 88,
    'law_commercial_and_criminal': 63,
  };

  List<Category> cats = [
    Category(
      Name: 'การบำรุงรักษารถ',
      Id: 1,
      data: 'car_maintenance',
    ),
    Category(
      Name: 'เทคนิคการขับขี่อย่างปลอดภัย',
      Id: 2,
      data: 'save_drive',
    ),
    Category(
      Name: 'มารยาทและจิตสำนึก',
      Id: 3,
      data: 'manners_and_conscience',
    ),
    Category(
      Name: 'ป้ายเตือน',
      Id: 4,
      data: 'warning_sign',
    ),
    Category(
      Name: 'ป้ายบังคับ',
      Id: 5,
      data: 'mandatory_sign',
    ),
    Category(
      Name: 'การรับรู้สถานการณ์อันตราย',
      Id: 6,
      data: 'dangerous_situations',
    ),
    Category(
      Name: 'กฎหมายว่าด้วยการจราจรทางบก',
      Id: 7,
      data: 'law_land_traffic',
    ),
    Category(
      Name: 'กฎหมายว่าด้วยรถยนต์',
      Id: 8,
      data: 'law_automobile',
    ),
    Category(
      Name: 'หมวดกฎหมายแพ่งพาณิชย์และกฎหมายอาญา',
      Id: 9,
      data: 'law_commercial_and_criminal',
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
          var scores = score[cat.data] ?? [0, 0];
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
