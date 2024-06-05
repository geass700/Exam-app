import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class Simulation_ResultPage extends StatefulWidget {
  final Map<int, String> answers;
  final List<Map<String, dynamic>> questions;

  Simulation_ResultPage({required this.answers, required this.questions});

  @override
  _Simulation_ResultPageState createState() => _Simulation_ResultPageState();
}

class _Simulation_ResultPageState extends State<Simulation_ResultPage> {
  int score = 0;
  Database? nextsetdatabase;
  Database? donepooldatabase;
  String loadedpoolStr = '';
  @override
  void initState() {
    super.initState();
    _initializenextsetDatabase();
    _initializeDonePool();
    _calculatePool();
    _calculateScore();

    WidgetsBinding.instance.addPostFrameCallback((_) => _showScoreDialog());
  }

  final Map<String, List<int>> nextSetQuestions = {
    'car_maintenance.db': List.filled(8, 0),
    'save_drive.db': List.filled(14, 0),
    'manners_and_conscience.db': List.filled(7, 0),
    'warning_sign.db': List.filled(4, 0),
    'mandatory_sign.db': List.filled(3, 0),
    'dangerous_situations.db': List.filled(1, 0),
    'law_land_traffic.db': List.filled(3, 0),
    'law_automobile.db': List.filled(6, 0),
    'law_commercial_and_criminal.db': List.filled(4, 0),
  };

  final Map<String, List<int>> donepoolList = {
    'car_maintenance.db': [],
    'save_drive.db': [],
    'manners_and_conscience.db': [],
    'warning_sign.db': [],
    'mandatory_sign.db': [],
    'dangerous_situations.db': [],
    'law_land_traffic.db': [],
    'law_automobile.db': [],
    'law_commercial_and_criminal.db': [],
  };

  void _calculatePool() {
    final Map<String, List<int>> thisdonepoolset = {
      'car_maintenance.db': [],
      'save_drive.db': [],
      'manners_and_conscience.db': [],
      'warning_sign.db': [],
      'mandatory_sign.db': [],
      'dangerous_situations.db': [],
      'law_land_traffic.db': [],
      'law_automobile.db': [],
      'law_commercial_and_criminal.db': [],
    };

    widget.questions.asMap().forEach((index, question) {
      if (widget.answers[index] == question['correct_answer']) {
        if(index >= 1 && index <= 8){
          thisdonepoolset['car_maintenance.db']!.add(question['id']);
        }
        if(index >= 9 && index <= 22){
          thisdonepoolset['save_drive.db']!.add(question['id']);
        }
        if(index >= 23 && index <= 29){
          thisdonepoolset['manners_and_conscience.db']!.add(question['id']);
        }
        if(index >= 30 && index <= 33){
          thisdonepoolset['warning_sign.db']!.add(question['id']);
        }
        if(index >= 34 && index <= 36){
          thisdonepoolset['mandatory_sign.db']!.add(question['id']);
        }
        if(index == 37){
          thisdonepoolset['dangerous_situations.db']!.add(question['id']);
        }
        if(index >= 38 && index <= 40){
          thisdonepoolset['law_land_traffic.db']!.add(question['id']);
        }
        if(index >= 41 && index <= 46){
          thisdonepoolset['law_automobile.db']!.add(question['id']);
        }
        if(index >= 47 && index <= 50){
          thisdonepoolset['law_commercial_and_criminal.db']!.add(question['id']);
        }
      }
    });
    print('ล่างนี้คือthisdonepoolset');
    print(thisdonepoolset);
    print('------');
    _loadPool();
    print('นี่คือ loadedpoolStr '+loadedpoolStr);
    Map<String, dynamic> jsonMap = jsonDecode(loadedpoolStr);
    Map<String, List<int>> oldpoolList = jsonMap.map((key, value) => MapEntry(key, List<int>.from(value)));
    print('ของเก่านะ'+ oldpoolList.toString());

    Map<String, List<int>> mergedDonepoolList = {};
    oldpoolList.forEach((key, value) {
      Set<int> mergedSet = Set<int>.from(value)..addAll(thisdonepoolset[key] ?? []);
      mergedDonepoolList[key] = mergedSet.toList();
    });
    print('ของใหม่'+mergedDonepoolList.toString());
    String mergedStr = jsonEncode(mergedDonepoolList);
    _updatePool(mergedStr);
  }


  Future<void> _initializenextsetDatabase() async {
    nextsetdatabase = await openDatabase(
      path.join(await getDatabasesPath(), 'nextSetExam.db'),
      onCreate: (db, version) {
        return db.execute(
          '''
        CREATE TABLE nextSetExam(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nextsetdata TEXT
        )
        ''',
        );
      },
      version: 1,
    );
  }

  Future<void> _initializeDonePool() async {
    donepooldatabase = await openDatabase(
      path.join(await getDatabasesPath(), 'donePool.db'),
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE donepool(id INTEGER PRIMARY KEY AUTOINCREMENT, donedata TEXT)",
        );
      },
      version: 1,
    );

    if (donepooldatabase != null) {
      List<Map<String, dynamic>> results = await donepooldatabase!.query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
      print('จาก initializeDonePool นี่คือ Data in donepool database: $results');
    }
  }




  void _updatePool(String newData) async {
    print('กำลังจะอัพ');
    if (donepooldatabase != null) {
      await donepooldatabase!.update(
        'donepool',
        {'donedata': newData},
        where: 'id = ?',
        whereArgs: [1],
      );
      print('อัพเดทแล้ว');
    }
    else{
      print('อยากอัพแต่ว่าง');
      print('นี่คือนิวดาต้า'+newData);
      insertPool(newData);
      print('ทดลองinsertแแทนละ');
    }
  }

  Future<void> insertPool(String newData) async {
    final db = donepooldatabase;

    await db?.insert(
      'donepool',
      {'donedata': newData},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  void _loadPool() async {
    print('เริ่มโหลด');
    if (donepooldatabase != null) {
      List<Map<String, dynamic>> results = await donepooldatabase!.query('donepool');
      print('ล่างนี้รีเซ้า');
      print(results);
      if (results.isNotEmpty) {
        loadedpoolStr = results.first['donedata'];
        print('Loaded data from donepool: $results');

      } else {
        print('No data found in donepool');
      }
    }
    else{
      final Map<String, List<int>> emptydonepoolList = {
        'car_maintenance.db': [],
        'save_drive.db': [],
        'manners_and_conscience.db': [],
        'warning_sign.db': [],
        'mandatory_sign.db': [],
        'dangerous_situations.db': [],
        'law_land_traffic.db': [],
        'law_automobile.db': [],
        'law_commercial_and_criminal.db': [],
      };
      loadedpoolStr = jsonEncode(emptydonepoolList);
      insertPool(loadedpoolStr);
      print('ว่างแต่ลองเพิ่มให้ละ');
    }

  }

  void _updatenextsetdatabase(String newData)async{
    if (nextsetdatabase!= null) {
      await nextsetdatabase!.insert('nextSetExam', {'nextsetdata': newData}, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  }
  void _loaddatabase() async{
    if (nextsetdatabase!= null) {
      List<Map<String, dynamic>> results = await nextsetdatabase!.query('nextSetExam');
      print('Loaded data from nextSetExam: $results');
    }
  }
  void _calculateScore() {
    score = 0;

    widget.questions.asMap().forEach((index, question) {
      //print(question['similarity']);
      if (widget.answers[index] == question['correct_answer']) {
        score++;

      }
    });
  }


  void _showScoreDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ผลการทำข้อสอบ'),
          content: Text('คุณได้คะแนน $score/${widget.questions.length}'),
          actions: [
            TextButton(
              child: Text('ดูเฉลย'),
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ผลการทำข้อสอบ'),
        backgroundColor: Color(0xFF92CA68),
        actions: [
          IconButton(
            onPressed: handleClickHome,
            icon: Icon(Icons.home),
          ),
          IconButton(
            icon: Icon(Icons.print),
            onPressed: (){}
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.questions.length,
        itemBuilder: (context, index) {
          final question = widget.questions[index];
          final correctAnswer = question['correct_answer'] ?? '';
          final userAnswer = widget.answers[index] ?? '';
          final questionId = question['id'] ?? 'N/A'; // Change 'question_id' to 'id'

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Color(0xFFE4F3D8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ID: $questionId',
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Question ${index + 1}: ${question['question_text'] ?? ''}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      4,
                          (i) {
                        String option = question['choice_${i + 1}'] ?? '';
                        bool isCorrect = option == correctAnswer;
                        return RadioListTile<String>(
                          title: Row(
                            children: [
                              Expanded(child: Text(option)),
                              if (isCorrect) Icon(Icons.check, color: Colors.green),
                            ],
                          ),
                          value: option,
                          groupValue: userAnswer,
                          onChanged: null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void handleClickHome() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }
}
