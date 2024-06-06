import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';
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
  Database? scoreListdatabase;
  String loadedpoolStr = '';
  String loadednextquestionStr ='';
  String loadedScoreStr ='';

  @override
  void initState() {
    super.initState();
    _initializeDonePool().then((_) async {
      await _initializenextsetDatabase();
      await _initializeScoreList();
      await _calculatePool();
      _calculateScore();
      _calculateNextSet();



      WidgetsBinding.instance.addPostFrameCallback((_) => _showScoreDialog());
    });
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

  Map<String, List<int>> scoreList = {
    'car_maintenance.db': [0,0],
    'save_drive.db': [0,0],
    'manners_and_conscience.db': [0,0],
    'warning_sign.db': [0,0],
    'mandatory_sign.db': [0,0],
    'dangerous_situations.db': [0,0],
    'law_land_traffic.db': [0,0],
    'law_automobile.db': [0,0],
    'law_commercial_and_criminal.db': [0,0],
  };

   Map<String, List<int>> donepoolList = {
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

  Future<void> _calculatePool() async {
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
        if (index >= 0 && index <= 7) {
          thisdonepoolset['car_maintenance.db']!.add(question['id']);
        }
        if (index >= 8 && index <= 21) {
          thisdonepoolset['save_drive.db']!.add(question['id']);
        }
        if (index >= 22 && index <= 28) {
          thisdonepoolset['manners_and_conscience.db']!.add(question['id']);
        }
        if (index >= 29 && index <= 32) {
          thisdonepoolset['warning_sign.db']!.add(question['id']);
        }
        if (index >= 33 && index <= 35) {
          thisdonepoolset['mandatory_sign.db']!.add(question['id']);
        }
        if (index == 36) {
          thisdonepoolset['dangerous_situations.db']!.add(question['id']);
        }
        if (index >= 37 && index <= 39) {
          thisdonepoolset['law_land_traffic.db']!.add(question['id']);
        }
        if (index >= 40 && index <= 45) {
          thisdonepoolset['law_automobile.db']!.add(question['id']);
        }
        if (index >= 46 && index <= 50) {
          thisdonepoolset['law_commercial_and_criminal.db']!
              .add(question['id']);
        }
      }
    });
    // print('ล่างนี้คือthisdonepoolset');
    // print(thisdonepoolset);
    // print('------');
    await _loadPool();
    print('นี่คือ loadedpoolStr ' + loadedpoolStr + 'End loadedpoolStr---');
    Map<String, dynamic> jsonMap = jsonDecode(loadedpoolStr);
    Map<String, List<int>> oldpoolList =
        jsonMap.map((key, value) => MapEntry(key, List<int>.from(value)));
    // print('ของเก่านะ' + oldpoolList.toString());

    Map<String, List<int>> mergedDonepoolList = {};
    oldpoolList.forEach((key, value) {
      Set<int> mergedSet = Set<int>.from(value)
        ..addAll(thisdonepoolset[key] ?? []);
      mergedDonepoolList[key] = mergedSet.toList();
    });
    // print('ของใหม่' + mergedDonepoolList.toString());
    String mergedStr = jsonEncode(mergedDonepoolList);
    print('this is mergeStr' + mergedStr);
    await _updatePool(mergedStr);
    donepoolList = mergedDonepoolList;
  }

  Future<void> _calculateNextSet() async {
    print('เริ่มหาข้อใหม่');
    final Map<String, List<int>> nextquestionset = {
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
        if (index >= 0 && index <= 7) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          // print(donepoolList);
          // print('this is id: ' + question['id'].toString());
          // print(similarityList);
          // print('********');
          for (int sim in similarityList) {
            if (!donepoolList['car_maintenance.db']!.contains(sim) && !nextquestionset['car_maintenance.db']!.contains(sim)) {
              select = sim;
              nextquestionset['car_maintenance.db']!.add(select);
              break;
            }
          }

          if (select == -1) {
            for (int sim in similarityList) {
              if (!nextquestionset['car_maintenance.db']!.contains(sim)) {
                select = sim;
                nextquestionset['car_maintenance.db']!.add(select);
                break;
              }
            }
          }
          // print('this is select:' + select.toString() + '||');
        }
        if (index >= 8 && index <= 21) {

          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          // print(donepoolList);
          // print('this is id: ' + question['id'].toString());
          // print(similarityList);
          // print('********');
          for (int sim in similarityList) {

            if (!donepoolList['save_drive.db']!.contains(sim) && !nextquestionset['save_drive.db']!.contains(sim)) {
              select = sim;
              nextquestionset['save_drive.db']!.add(select);
              break;
            }
          }

          if (select == -1) {
            for (int sim in similarityList) {
              if (!nextquestionset['save_drive.db']!.contains(sim)) {
                select = sim;
                nextquestionset['save_drive.db']!.add(select);
                break;
              }
            }
          }
          // print('this is select:' + select.toString() + '||');
        }
        if (index >= 22 && index <= 28) {

          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          // print(donepoolList);
          // print('this is id: ' + question['id'].toString());
          // print(similarityList);
          // print('********');
          for (int sim in similarityList) {

            if (!donepoolList['manners_and_conscience.db']!.contains(sim) && !nextquestionset['manners_and_conscience.db']!.contains(sim)) {
              select = sim;
              nextquestionset['manners_and_conscience.db']!.add(select);
              break;
            }
          }

          if (select == -1) {
            for (int sim in similarityList) {
              if (!nextquestionset['manners_and_conscience.db']!.contains(sim)) {
                select = sim;
                nextquestionset['manners_and_conscience.db']!.add(select);
                break;
              }
            }
          }
          // print('this is select:' + select.toString() + '||');
        }
        if (index >= 29 && index <= 32) {

          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          // print(donepoolList);
          // print('this is id: ' + question['id'].toString());
          // print(similarityList);
          // print('********');
          for (int sim in similarityList) {
            //print(sim);
            if (!donepoolList['warning_sign.db']!.contains(sim) && !nextquestionset['warning_sign.db']!.contains(sim)) {
              select = sim;
              nextquestionset['warning_sign.db']!.add(select);
              break;
            }
          }

          if (select == -1) {
            for (int sim in similarityList) {
              if (!nextquestionset['warning_sign.db']!.contains(sim)) {
                select = sim;
                nextquestionset['warning_sign.db']!.add(select);
                break;
              }
            }
          }
          // print('this is select:' + select.toString() + '||');
        }
        if (index >= 33 && index <= 35) {

          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          // print(donepoolList);
          // print('this is id: ' + question['id'].toString());
          // print(similarityList);
          // print('********');
          for (int sim in similarityList) {
            //print(sim);
            if (!donepoolList['mandatory_sign.db']!.contains(sim) && !nextquestionset['mandatory_sign.db']!.contains(sim)) {
              select = sim;
              nextquestionset['mandatory_sign.db']!.add(select);
              break;
            }
          }

          if (select == -1) {
            for (int sim in similarityList) {
              if (!nextquestionset['mandatory_sign.db']!.contains(sim)) {
                select = sim;
                nextquestionset['mandatory_sign.db']!.add(select);
                break;
              }
            }
          }
          // print('this is select:' + select.toString() + '||');
        }
        if (index == 36) {

          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          // print(donepoolList);
          // print('this is id: ' + question['id'].toString());
          // print(similarityList);
          // print('********');
          for (int sim in similarityList) {
            //print(sim);
            if (!donepoolList['dangerous_situations.db']!.contains(sim) && !nextquestionset['dangerous_situations.db']!.contains(sim)) {
              select = sim;
              nextquestionset['dangerous_situations.db']!.add(select);
              break;
            }
          }

          if (select == -1) {
            for (int sim in similarityList) {
              if (!nextquestionset['dangerous_situations.db']!.contains(sim)) {
                select = sim;
                nextquestionset['dangerous_situations.db']!.add(select);
                break;
              }
            }
          }
          // print('this is select:' + select.toString() + '||');
        }
        if (index >= 37 && index <= 39) {

          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          // print(donepoolList);
          // print('this is id: ' + question['id'].toString());
          // print(similarityList);
          // print('********');
          for (int sim in similarityList) {
            //print(sim);
            if (!donepoolList['law_land_traffic.db']!.contains(sim) && !nextquestionset['law_land_traffic.db']!.contains(sim)) {
              select = sim;
              nextquestionset['law_land_traffic.db']!.add(select);
              break;
            }
          }

          if (select == -1) {
            for (int sim in similarityList) {
              if (!nextquestionset['law_land_traffic.db']!.contains(sim)) {
                select = sim;
                nextquestionset['law_land_traffic.db']!.add(select);
                break;
              }
            }
          }
          // print('this is select:' + select.toString() + '||');
        }
        if (index >= 40 && index <= 45) {

          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          // print(donepoolList);
          // print('this is id: ' + question['id'].toString());
          // print(similarityList);
          // print('********');
          for (int sim in similarityList) {
           // print(sim);
            if (!donepoolList['law_automobile.db']!.contains(sim) && !nextquestionset['law_automobile.db']!.contains(sim)) {
              select = sim;
              nextquestionset['law_automobile.db']!.add(select);
              break;
            }
          }

          if (select == -1) {
            for (int sim in similarityList) {
              if (!nextquestionset['law_automobile.db']!.contains(sim)) {
                select = sim;
                nextquestionset['law_automobile.db']!.add(select);
                break;
              }
            }
          }
          // print('this is select:' + select.toString() + '||');
        }
        if (index >= 46 && index <= 50) {

          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          // print(donepoolList);
          // print('this is id: ' + question['id'].toString());
          // print(similarityList);
          // print('********');
          for (int sim in similarityList) {
            //print(sim);
            if (!donepoolList['law_commercial_and_criminal.db']!.contains(sim) && !nextquestionset['law_commercial_and_criminal.db']!.contains(sim)) {
              select = sim;
              nextquestionset['law_commercial_and_criminal.db']!.add(select);
              break;
            }
          }

          if (select == -1) {
            for (int sim in similarityList) {
              if (!nextquestionset['law_commercial_and_criminal.db']!.contains(sim)) {
                select = sim;
                nextquestionset['law_commercial_and_criminal.db']!.add(select);
                break;
              }
            }
          }
          // print('this is select:' + select.toString() + '||');
        }
      } else {
        if (index >= 0 && index <= 7) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int i = similarityList.length - 1; i >= 0; i--) {
            int sim = similarityList[i];
            if (!donepoolList['car_maintenance.db']!.contains(sim) && !nextquestionset['car_maintenance.db']!.contains(sim)) {
              select = sim;
              nextquestionset['car_maintenance.db']!.add(select);
              break;
            }
          }

          if (select == -1 && similarityList.isNotEmpty) {
            for (int i = similarityList.length - 1; i >= 0; i--) {
              int sim = similarityList[i];
              if (!nextquestionset['car_maintenance.db']!.contains(sim)) {
                select = sim;
                nextquestionset['car_maintenance.db']!.add(select);
                break;
              }
            }
          }
        }
        if (index >= 8 && index <= 21) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int i = similarityList.length - 1; i >= 0; i--) {
            int sim = similarityList[i];
            if (!donepoolList['save_drive.db']!.contains(sim) && !nextquestionset['save_drive.db']!.contains(sim)) {
              select = sim;
              nextquestionset['save_drive.db']!.add(select);
              break;
            }
          }

          if (select == -1 && similarityList.isNotEmpty) {
            for (int i = similarityList.length - 1; i >= 0; i--) {
              int sim = similarityList[i];
              if (!nextquestionset['save_drive.db']!.contains(sim)) {
                select = sim;
                nextquestionset['save_drive.db']!.add(select);
                break;
              }
            }
          }
        }
        if (index >= 22 && index <= 28) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int i = similarityList.length - 1; i >= 0; i--) {
            int sim = similarityList[i];
            if (!donepoolList['manners_and_conscience.db']!.contains(sim) && !nextquestionset['manners_and_conscience.db']!.contains(sim)) {
              select = sim;
              nextquestionset['manners_and_conscience.db']!.add(select);
              break;
            }
          }

          if (select == -1 && similarityList.isNotEmpty) {
            for (int i = similarityList.length - 1; i >= 0; i--) {
              int sim = similarityList[i];
              if (!nextquestionset['manners_and_conscience.db']!.contains(sim)) {
                select = sim;
                nextquestionset['manners_and_conscience.db']!.add(select);
                break;
              }
            }
          }
        }
        if (index >= 29 && index <= 32) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int i = similarityList.length - 1; i >= 0; i--) {
            int sim = similarityList[i];
            if (!donepoolList['warning_sign.db']!.contains(sim) && !nextquestionset['warning_sign.db']!.contains(sim)) {
              select = sim;
              nextquestionset['warning_sign.db']!.add(select);
              break;
            }
          }

          if (select == -1 && similarityList.isNotEmpty) {
            for (int i = similarityList.length - 1; i >= 0; i--) {
              int sim = similarityList[i];
              if (!nextquestionset['warning_sign.db']!.contains(sim)) {
                select = sim;
                nextquestionset['warning_sign.db']!.add(select);
                break;
              }
            }
          }
        }
        if (index >= 33 && index <= 35) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int i = similarityList.length - 1; i >= 0; i--) {
            int sim = similarityList[i];
            if (!donepoolList['mandatory_sign.db']!.contains(sim) && !nextquestionset['mandatory_sign.db']!.contains(sim)) {
              select = sim;
              nextquestionset['mandatory_sign.db']!.add(select);
              break;
            }
          }

          if (select == -1 && similarityList.isNotEmpty) {
            for (int i = similarityList.length - 1; i >= 0; i--) {
              int sim = similarityList[i];
              if (!nextquestionset['mandatory_sign.db']!.contains(sim)) {
                select = sim;
                nextquestionset['mandatory_sign.db']!.add(select);
                break;
              }
            }
          }
        }
        if (index == 36) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int i = similarityList.length - 1; i >= 0; i--) {
            int sim = similarityList[i];
            if (!donepoolList['dangerous_situations.db']!.contains(sim) && !nextquestionset['dangerous_situations.db']!.contains(sim)) {
              select = sim;
              nextquestionset['dangerous_situations.db']!.add(select);
              break;
            }
          }

          if (select == -1 && similarityList.isNotEmpty) {
            for (int i = similarityList.length - 1; i >= 0; i--) {
              int sim = similarityList[i];
              if (!nextquestionset['dangerous_situations.db']!.contains(sim)) {
                select = sim;
                nextquestionset['dangerous_situations.db']!.add(select);
                break;
              }
            }
          }
        }
        if (index >= 37 && index <= 39) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int i = similarityList.length - 1; i >= 0; i--) {
            int sim = similarityList[i];
            if (!donepoolList['law_land_traffic.db']!.contains(sim) && !nextquestionset['law_land_traffic.db']!.contains(sim)) {
              select = sim;
              nextquestionset['law_land_traffic.db']!.add(select);
              break;
            }
          }

          if (select == -1 && similarityList.isNotEmpty) {
            for (int i = similarityList.length - 1; i >= 0; i--) {
              int sim = similarityList[i];
              if (!nextquestionset['law_land_traffic.db']!.contains(sim)) {
                select = sim;
                nextquestionset['law_land_traffic.db']!.add(select);
                break;
              }
            }
          }
        }
        if (index >= 40 && index <= 45) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int i = similarityList.length - 1; i >= 0; i--) {
            int sim = similarityList[i];
            if (!donepoolList['law_automobile.db']!.contains(sim) && !nextquestionset['law_automobile.db']!.contains(sim)) {
              select = sim;
              nextquestionset['law_automobile.db']!.add(select);
              break;
            }
          }

          if (select == -1 && similarityList.isNotEmpty) {
            for (int i = similarityList.length - 1; i >= 0; i--) {
              int sim = similarityList[i];
              if (!nextquestionset['law_automobile.db']!.contains(sim)) {
                select = sim;
                nextquestionset['law_automobile.db']!.add(select);
                break;
              }
            }
          }
        }
        if (index >= 46 && index <= 50) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int i = similarityList.length - 1; i >= 0; i--) {
            int sim = similarityList[i];
            if (!donepoolList['law_commercial_and_criminal.db']!.contains(sim) && !nextquestionset['law_commercial_and_criminal.db']!.contains(sim)) {
              select = sim;
              nextquestionset['law_commercial_and_criminal.db']!.add(select);
              break;
            }
          }

          if (select == -1 && similarityList.isNotEmpty) {
            for (int i = similarityList.length - 1; i >= 0; i--) {
              int sim = similarityList[i];
              if (!nextquestionset['law_commercial_and_criminal.db']!.contains(sim)) {
                select = sim;
                nextquestionset['law_commercial_and_criminal.db']!.add(select);
                break;
              }
            }
          }
        }
      }
    });
    print(nextquestionset);
    String nextquestionStr = jsonEncode(nextquestionset);
    _updatenextsetdatabase(nextquestionStr);
  }


  Future<void> _initializenextsetDatabase() async {
    nextsetdatabase = await openDatabase(
      path.join(await getDatabasesPath(), 'nextSetExam.db'),
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE nextsetExam(id INTEGER PRIMARY KEY AUTOINCREMENT, nextsetdata TEXT)",
        );
      },
      version: 1,
    );
    if (nextsetdatabase != null) {
      List<Map<String, dynamic>> results = await nextsetdatabase!
          .query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
      print(
          'จาก initializenextsetDatabase นี่คือ Data in nextsetdata database: $results');
    }
  }

  Future<void> _initializeScoreList() async {
    scoreListdatabase = await openDatabase(
      path.join(await getDatabasesPath(), 'scoreList.db'),
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE scorelist(id INTEGER PRIMARY KEY AUTOINCREMENT, scoredata TEXT)",
        );
      },
      version: 1,
    );
    if (scoreListdatabase != null) {
      List<Map<String, dynamic>> results = await scoreListdatabase!
          .query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
      print(
          'จาก _initializeScoreList Database นี่คือ Data in scoredata database: $results');
    }
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
      List<Map<String, dynamic>> results = await donepooldatabase!
          .query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
      print(
          'จาก initializeDonePool นี่คือ Data in donepool database: $results');
    }
  }

  Future<void> _updateScore(String newData) async {
    print('กำลังจะอัพScore');
    if (scoreListdatabase != null) {
      await scoreListdatabase!.update(
        'scorelist',
        {'scoredata': newData},
        where: 'id = ?',
        whereArgs: [1],
      );
      print('อัพเดทสกอแล้ว');
      //printDatabaseData();
    } else {
      print('อยากอัพ Score แต่ว่าง');
      print('นี่คือนิวดาต้า Score' + newData);
      insertScore(newData);
      print('ทดลองinsertแแทนละ');
    }
  }

  Future<void> _updatePool(String newData) async {
    print('กำลังจะอัพ');
    if (donepooldatabase != null) {
      await donepooldatabase!.update(
        'donepool',
        {'donedata': newData},
        where: 'id = ?',
        whereArgs: [1],
      );
      print('อัพเดทแล้ว');
      //printDatabaseData();
    } else {
      print('อยากอัพแต่ว่าง');
      print('นี่คือนิวดาต้า' + newData);
      insertPool(newData);
      print('ทดลองinsertแแทนละ');
    }
  }

  void printDatabaseData() async {
    if (nextsetdatabase != null) {
      print('เริ่มปริ้น');
      List<Map<String, dynamic>> results =
          await nextsetdatabase!.query('nextsetExam');
      if (results.isNotEmpty) {
        print('Data in nextsetExam database:');
        results.forEach((row) {
          print(row);
        });
      } else {
        print('No data found in nextsetExam');
      }
      print('ปริ้นเสร็จ');
    } else {
      print('Database is not initialized.');
    }
  }

  Future<void> insertPool(String newData) async {
    final db = donepooldatabase;

    await db!.insert(
      'donepool',
      {'donedata': newData},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertNext(String newData) async {
    final db = nextsetdatabase;

    await db!.insert(
      'nextsetExam',
      {'nextsetdata': newData},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertScore(String newData) async {
    final db = scoreListdatabase;

    await db!.insert(
      'scorelist',
      {'id': 1,'scoredata': newData},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _loadScore() async {
    print('เริ่มโหลดScore');
    if (scoreListdatabase != null) {
      List<Map<String, dynamic>> results = await scoreListdatabase!.query('scorelist');
      if(results.isNotEmpty){
        print('นี่คือสิ่งที่ได้จาก scorelist: $results');
        loadedScoreStr = results.first['scoredata'];
        print('โหลดสำเร็จ $loadedScoreStr');
      }else{
        print('scorelist น่าจะว่าง');
      }
    }else{
      loadedScoreStr =jsonEncode(scoreList);
      insertScore(loadedScoreStr);
      print('scoreLisitdatabase empty');
    }
  }


  Future<void> _loadPool() async {
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
        print('ลองเพิ่มให้ละ');
      }
    } else {
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

  void _updatenextsetdatabase(String newData) async {
    print('กำลังจะอัพnextset');
    print('นี่คือนิวดาต้าnextset: $newData');

    if (nextsetdatabase != null) {
      // ตรวจสอบว่ามีข้อมูลในตารางหรือไม่
      List<Map<String, dynamic>> result = await nextsetdatabase!.query('nextSetExam');
      print('ข้อมูลใน nextsetExam ก่อนการอัพเดท: $result');
      await nextsetdatabase!.insert(
        'nextsetExam',
        {'id': 1, 'nextsetdata': newData},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Inserted initial data into nextsetExam');

      await nextsetdatabase!.update(
        'nextSetExam',
        {'nextsetdata': newData},
        where: 'id = ?',
        whereArgs: [1],
      );
      print('อัพเดทnextsetแล้ว');

      // ตรวจสอบข้อมูลหลังการอัพเดท
      result = await nextsetdatabase!.query('nextSetExam');
      print('ข้อมูลใน nextsetExam หลังการอัพเดท: $result');
    } else {
      print('อยากอัพnextsetแต่ว่าง');

      insertNext(newData);
    }
    printDatabaseData();
  }

  void _loaddatabase() async {
    if (nextsetdatabase != null) {
      List<Map<String, dynamic>> results =
          await nextsetdatabase!.query('nextSetExam');
      print('Loaded data from nextSetExam: $results');
      if (results.isNotEmpty) {
        loadednextquestionStr = results.first['nextSetExam'];
        print('Loaded data from nextSetExam: $results');
      }
    }
  }

  Future<void> _calculateScore() async {
    score = 0;
    Map<String, List<int>> thisscoreList = {
      'car_maintenance.db': [0,0],
      'save_drive.db': [0,0],
      'manners_and_conscience.db': [0,0],
      'warning_sign.db': [0,0],
      'mandatory_sign.db': [0,0],
      'dangerous_situations.db': [0,0],
      'law_land_traffic.db': [0,0],
      'law_automobile.db': [0,0],
      'law_commercial_and_criminal.db': [0,0],
    };
    widget.questions.asMap().forEach((index, question) {
      if (widget.answers[index] == question['correct_answer']) {
        score++;
        if (index >= 0 && index <= 7) {
          thisscoreList['car_maintenance.db']![0] += 1;
        }
        if (index >= 8 && index <= 21) {
          thisscoreList['save_drive.db']![0] += 1;
        }
        if (index >= 22 && index <= 28) {
          thisscoreList['manners_and_conscience.db']![0] += 1;
        }
        if (index >= 29 && index <= 32) {
          thisscoreList['warning_sign.db']![0] += 1;
        }
        if (index >= 33 && index <= 35) {
          thisscoreList['mandatory_sign.db']![0] += 1;
        }
        if (index == 36) {
          thisscoreList['dangerous_situations.db']![0] += 1;
        }
        if (index >= 37 && index <= 39) {
          thisscoreList['law_land_traffic.db']![0] += 1;
        }
        if (index >= 40 && index <= 45) {
          thisscoreList['law_automobile.db']![0] += 1;
        }
        if (index >= 46 && index <= 50) {
          thisscoreList['law_commercial_and_criminal.db']![0] += 1;
        }
      }
      if (index >= 0 && index <= 7) {
        thisscoreList['car_maintenance.db']![1] += 1;
      }
      if (index >= 8 && index <= 21) {
        thisscoreList['save_drive.db']![1] += 1;
      }
      if (index >= 22 && index <= 28) {
        thisscoreList['manners_and_conscience.db']![1] += 1;
      }
      if (index >= 29 && index <= 32) {
        thisscoreList['warning_sign.db']![1] += 1;
      }
      if (index >= 33 && index <= 35) {
        thisscoreList['mandatory_sign.db']![1] += 1;
      }
      if (index == 36) {
        thisscoreList['dangerous_situations.db']![1] += 1;
      }
      if (index >= 37 && index <= 39) {
        thisscoreList['law_land_traffic.db']![1] += 1;
      }
      if (index >= 40 && index <= 45) {
        thisscoreList['law_automobile.db']![1] += 1;
      }
      if (index >= 46 && index <= 50) {
        thisscoreList['law_commercial_and_criminal.db']![1] += 1;
      }
    });

    print('thisสกอลิสนะ :$thisscoreList');
    await _loadScore();
    var decoded = jsonDecode(loadedScoreStr);
    print('this is decoded $decoded');
    print(decoded.runtimeType);
    var predata1 = jsonEncode(thisscoreList);
    var data1 = jsonDecode(predata1);
    Map<String, dynamic> sumresult = {};

    data1.forEach((key, value1) {
      if (decoded.containsKey(key)) {
        var value2 = decoded[key];
        var sum = [value1[0] + value2[0], value1[1] + value2[1]];
        sumresult[key] = sum;
      }
    });
    print('this is sumresult $sumresult');
    String sumresultStr = jsonEncode(sumresult);
    _updateScore(sumresultStr);
    await _loadScore();
    print('สกอหลังอัพเดท $loadedScoreStr');
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
          IconButton(icon: Icon(Icons.print), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.questions.length,
        itemBuilder: (context, index) {
          final question = widget.questions[index];
          final correctAnswer = question['correct_answer'] ?? '';
          final userAnswer = widget.answers[index] ?? '';
          final questionId =
              question['id'] ?? 'N/A'; // Change 'question_id' to 'id'

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
                              if (isCorrect)
                                Icon(Icons.check, color: Colors.green),
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
