import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';
import 'main_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'userdatahandle.dart';

class New_Simulation_ResultPage extends StatefulWidget {
  final Map<int, String> answers;
  final List<Map<String, dynamic>> questions;
  New_Simulation_ResultPage({required this.answers, required this.questions});

  @override
  _New_Simulation_ResultPageState createState() => _New_Simulation_ResultPageState();
}

class _New_Simulation_ResultPageState extends State<New_Simulation_ResultPage> {
  int score = 0;
  final UserdataHandle dbHelper = UserdataHandle.instance;
  Map<String, List<int>> ?scoreTableData;
  @override
  void initState() {
    super.initState();
      _calculateScore().then((_) =>_calculateNextSet());
      WidgetsBinding.instance.addPostFrameCallback((_) => _showScoreDialog());

  }

  Future<void> _calculateScore() async {
    score = 0;
    Map<String, List<int>> thisScoreList = {
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

    // รอบแรก: คำนวณคะแนน
    for (int index = 0; index < widget.questions.length; index++) {
      var question = widget.questions[index];
      if (widget.answers[index] == question['correct_answer']) {
        score++;
        if (index >= 0 && index <= 7) {
          thisScoreList['car_maintenance']![0] += 1;
        } else if (index >= 8 && index <= 21) {
          thisScoreList['save_drive']![0] += 1;
        } else if (index >= 22 && index <= 28) {
          thisScoreList['manners_and_conscience']![0] += 1;
        } else if (index >= 29 && index <= 32) {
          thisScoreList['warning_sign']![0] += 1;
        } else if (index >= 33 && index <= 35) {
          thisScoreList['mandatory_sign']![0] += 1;
        } else if (index == 36) {
          thisScoreList['dangerous_situations']![0] += 1;
        } else if (index >= 37 && index <= 39) {
          thisScoreList['law_land_traffic']![0] += 1;
        } else if (index >= 40 && index <= 45) {
          thisScoreList['law_automobile']![0] += 1;
        } else if (index >= 46 && index <= 50) {
          thisScoreList['law_commercial_and_criminal']![0] += 1;
        }
      }

      if (index >= 0 && index <= 7) {
        thisScoreList['car_maintenance']![1] += 1;
      } else if (index >= 8 && index <= 21) {
        thisScoreList['save_drive']![1] += 1;
      } else if (index >= 22 && index <= 28) {
        thisScoreList['manners_and_conscience']![1] += 1;
      } else if (index >= 29 && index <= 32) {
        thisScoreList['warning_sign']![1] += 1;
      } else if (index >= 33 && index <= 35) {
        thisScoreList['mandatory_sign']![1] += 1;
      } else if (index == 36) {
        thisScoreList['dangerous_situations']![1] += 1;
      } else if (index >= 37 && index <= 39) {
        thisScoreList['law_land_traffic']![1] += 1;
      } else if (index >= 40 && index <= 45) {
        thisScoreList['law_automobile']![1] += 1;
      } else if (index >= 46 && index <= 50) {
        thisScoreList['law_commercial_and_criminal']![1] += 1;
      }
    }

    // รอบที่สอง: Insert ข้อมูลลงในฐานข้อมูล
    for (int index = 0; index < widget.questions.length; index++) {
      var question = widget.questions[index];
      if (widget.answers[index] == question['correct_answer']) {
        if (index >= 0 && index <= 7) {
          await dbHelper.insertDoneTable(question['id'], 'car_maintenance');
        } else if (index >= 8 && index <= 21) {
          await dbHelper.insertDoneTable(question['id'], 'save_drive');
        } else if (index >= 22 && index <= 28) {
          await dbHelper.insertDoneTable(question['id'], 'manners_and_conscience');
        } else if (index >= 29 && index <= 32) {
          await dbHelper.insertDoneTable(question['id'], 'warning_sign');
        } else if (index >= 33 && index <= 35) {
          await dbHelper.insertDoneTable(question['id'], 'mandatory_sign');
        } else if (index == 36) {
          await dbHelper.insertDoneTable(question['id'], 'dangerous_situations');
          print('danger inserted');
        } else if (index >= 37 && index <= 39) {
          await dbHelper.insertDoneTable(question['id'], 'law_land_traffic');
        } else if (index >= 40 && index <= 45) {
          await dbHelper.insertDoneTable(question['id'], 'law_automobile');
        } else if (index >= 46 && index <= 50) {
          await dbHelper.insertDoneTable(question['id'], 'law_commercial_and_criminal');
        }
      }
    }
    
    print(thisScoreList); // แสดงผลลัพธ์สำหรับตรวจสอบ
    Map<String, List<int>> scoreTableData = await dbHelper.getScoreTableData();
    if(scoreTableData.isNotEmpty){
      Map<String, List<int>> resultMap = {};

      for (var key in thisScoreList.keys) {
        resultMap[key] = [
          thisScoreList[key]![0] + scoreTableData[key]![0],
          thisScoreList[key]![1] + scoreTableData[key]![1]
        ];
      }
      print('resultMap: $resultMap');
      int id = 1;
      for (var entry in resultMap.entries) {
        String category = entry.key;
        int correct = entry.value[0];
        int total = entry.value[1];
        await dbHelper.insertScoreTable(id, correct, total, category);
        id++;
      }
    }else{
      int id = 1;
      for (var entry in thisScoreList.entries) {
        String category = entry.key;
        int correct = entry.value[0];
        int total = entry.value[1];
        await dbHelper.insertScoreTable(id, correct, total, category);
        id++;
      }
    }

  }



  Future<void> _calculateNextSet() async {
    Map<String, List<int>> doneTableData = await dbHelper.getDoneTableData();
    Map<String, List<int>> nextquestionset = {
      'car_maintenance': [],
      'save_drive': [],
      'manners_and_conscience': [],
      'warning_sign': [],
      'mandatory_sign': [],
      'dangerous_situations': [],
      'law_land_traffic': [],
      'law_automobile': [],
      'law_commercial_and_criminal': [],
    };
    if (doneTableData.isEmpty) {
      doneTableData = nextquestionset;
      print('donetabledata is empty');
    }else{
      doneTableData.forEach((key, value) {
        if (nextquestionset.containsKey(key)) {
          nextquestionset[key] = List<int>.from(value);
        }
      });
      doneTableData = nextquestionset;
    }

    print('this is donetabledata$doneTableData');
    for (int index = 0; index < widget.questions.length; index++) {
      var question = widget.questions[index];
      if (widget.answers[index] == question['correct_answer']) {
        if (index >= 0 && index <= 7) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int sim in similarityList) {
            if (!doneTableData['car_maintenance']!.contains(sim) && !nextquestionset['car_maintenance']!.contains(sim)) {
              select = sim;
              nextquestionset['car_maintenance']!.add(select);
              break;
            }
          }
          if (select == -1) {
            for (int sim in similarityList) {
              if (!nextquestionset['car_maintenance']!.contains(sim)) {
                select = sim;
                nextquestionset['car_maintenance']!.add(select);
                break;
              }
            }
          }
          await dbHelper.insertNextSetTable(index+1,select, 'car_maintenance');
        }
        else if (index >= 8 && index <= 21) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int sim in similarityList) {
            if (!doneTableData['save_drive']!.contains(sim) && !nextquestionset['save_drive']!.contains(sim)) {
              select = sim;
              nextquestionset['save_drive']!.add(select);
              break;
            }
          }
          if (select == -1) {
            for (int sim in similarityList) {
              if (!nextquestionset['save_drive']!.contains(sim)) {
                select = sim;
                nextquestionset['save_drive']!.add(select);
                break;
              }
            }
          }
          await dbHelper.insertNextSetTable(index+1,select, 'save_drive');
        }
        else if (index >= 22 && index <= 28) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int sim in similarityList) {
            if (!doneTableData['manners_and_conscience']!.contains(sim) && !nextquestionset['manners_and_conscience']!.contains(sim)) {
              select = sim;
              nextquestionset['manners_and_conscience']!.add(select);
              break;
            }
          }
          if (select == -1) {
            for (int sim in similarityList) {
              if (!nextquestionset['manners_and_conscience']!.contains(sim)) {
                select = sim;
                nextquestionset['manners_and_conscience']!.add(select);
                break;
              }
            }
          }
          await dbHelper.insertNextSetTable(index+1,select, 'manners_and_conscience');
        }
        else if (index >= 29 && index <= 32) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int sim in similarityList) {
            if (!doneTableData['warning_sign']!.contains(sim) && !nextquestionset['warning_sign']!.contains(sim)) {
              select = sim;
              nextquestionset['warning_sign']!.add(select);
              break;
            }
          }
          if (select == -1) {
            for (int sim in similarityList) {
              if (!nextquestionset['warning_sign']!.contains(sim)) {
                select = sim;
                nextquestionset['warning_sign']!.add(select);
                break;
              }
            }
          }
          await dbHelper.insertNextSetTable(index+1,select, 'warning_sign');
        }
        else if (index >= 33 && index <= 35) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int sim in similarityList) {
            if (!doneTableData['mandatory_sign']!.contains(sim) && !nextquestionset['mandatory_sign']!.contains(sim)) {
              select = sim;
              nextquestionset['mandatory_sign']!.add(select);
              break;
            }
          }
          if (select == -1) {
            for (int sim in similarityList) {
              if (!nextquestionset['mandatory_sign']!.contains(sim)) {
                select = sim;
                nextquestionset['mandatory_sign']!.add(select);
                break;
              }
            }
          }
          await dbHelper.insertNextSetTable(index+1,select, 'mandatory_sign');
        }
        else if (index == 36) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int sim in similarityList) {
            if (!doneTableData['dangerous_situations']!.contains(sim) && !nextquestionset['dangerous_situations']!.contains(sim)) {
              select = sim;
              nextquestionset['dangerous_situations']!.add(select);
              break;
            }
          }
          if (select == -1) {
            for (int sim in similarityList) {
              if (!nextquestionset['dangerous_situations']!.contains(sim)) {
                select = sim;
                nextquestionset['dangerous_situations']!.add(select);
                break;
              }
            }
          }
          await dbHelper.insertNextSetTable(index+1,select, 'dangerous_situations');
        }
        else if (index >= 37 && index <= 39) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int sim in similarityList) {
            if (!doneTableData['law_land_traffic']!.contains(sim) && !nextquestionset['law_land_traffic']!.contains(sim)) {
              select = sim;
              nextquestionset['law_land_traffic']!.add(select);
              break;
            }
          }
          if (select == -1) {
            for (int sim in similarityList) {
              if (!nextquestionset['law_land_traffic']!.contains(sim)) {
                select = sim;
                nextquestionset['law_land_traffic']!.add(select);
                break;
              }
            }
          }
          await dbHelper.insertNextSetTable(index+1,select, 'law_land_traffic');
        }
        else if (index >= 40 && index <= 45) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int sim in similarityList) {
            if (!doneTableData['law_automobile']!.contains(sim) && !nextquestionset['law_automobile']!.contains(sim)) {
              select = sim;
              nextquestionset['law_automobile']!.add(select);
              break;
            }
          }
          if (select == -1) {
            for (int sim in similarityList) {
              if (!nextquestionset['law_automobile']!.contains(sim)) {
                select = sim;
                nextquestionset['law_automobile']!.add(select);
                break;
              }
            }
          }
          await dbHelper.insertNextSetTable(index+1,select, 'law_automobile');
        }
        else if (index >= 46 && index <= 50) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int sim in similarityList) {
            if (!doneTableData['law_commercial_and_criminal']!.contains(sim) && !nextquestionset['law_commercial_and_criminal']!.contains(sim)) {
              select = sim;
              nextquestionset['law_commercial_and_criminal']!.add(select);
              break;
            }
          }
          if (select == -1) {
            for (int sim in similarityList) {
              if (!nextquestionset['law_commercial_and_criminal']!.contains(sim)) {
                select = sim;
                nextquestionset['law_commercial_and_criminal']!.add(select);
                break;
              }
            }
          }
          await dbHelper.insertNextSetTable(index+1,select, 'law_commercial_and_criminal');
        }
      } else {
        if (index >= 0 && index <= 7) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int i = similarityList.length - 1; i >= 0; i--) {
            int sim = similarityList[i];
            if (!doneTableData['car_maintenance']!.contains(sim) && !nextquestionset['car_maintenance']!.contains(sim)) {
              select = sim;
              nextquestionset['car_maintenance']!.add(select);
              break;
            }
          }
          if (select == -1) {
            for (int i = similarityList.length - 1; i >= 0; i--) {
              int sim = similarityList[i];
              if (!nextquestionset['car_maintenance']!.contains(sim)) {
                select = sim;
                nextquestionset['car_maintenance']!.add(select);
                break;
              }
            }
          }
          await dbHelper.insertNextSetTable(index+1,select, 'car_maintenance');
        }
        else if (index >= 8 && index <= 21) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int i = similarityList.length - 1; i >= 0; i--) {
            int sim = similarityList[i];
            if (!doneTableData['save_drive']!.contains(sim) && !nextquestionset['save_drive']!.contains(sim)) {
              select = sim;
              nextquestionset['save_drive']!.add(select);
              break;
            }
          }
          if (select == -1) {
            for (int i = similarityList.length - 1; i >= 0; i--) {
              int sim = similarityList[i];
              if (!nextquestionset['save_drive']!.contains(sim)) {
                select = sim;
                nextquestionset['save_drive']!.add(select);
                break;
              }
            }
          }
          await dbHelper.insertNextSetTable(index+1,select, 'save_drive');
        }
        else if (index >= 22 && index <= 28) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int i = similarityList.length - 1; i >= 0; i--) {
            int sim = similarityList[i];
            if (!doneTableData['manners_and_conscience']!.contains(sim) && !nextquestionset['manners_and_conscience']!.contains(sim)) {
              select = sim;
              nextquestionset['manners_and_conscience']!.add(select);
              break;
            }
          }
          if (select == -1) {
            for (int i = similarityList.length - 1; i >= 0; i--) {
              int sim = similarityList[i];
              if (!nextquestionset['manners_and_conscience']!.contains(sim)) {
                select = sim;
                nextquestionset['manners_and_conscience']!.add(select);
                break;
              }
            }
          }
          await dbHelper.insertNextSetTable(index+1,select, 'manners_and_conscience');
        }
        else if (index >= 29 && index <= 32) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int i = similarityList.length - 1; i >= 0; i--) {
            int sim = similarityList[i];
            if (!doneTableData['warning_sign']!.contains(sim) && !nextquestionset['warning_sign']!.contains(sim)) {
              select = sim;
              nextquestionset['warning_sign']!.add(select);
              break;
            }
          }
          if (select == -1) {
            for (int i = similarityList.length - 1; i >= 0; i--) {
              int sim = similarityList[i];
              if (!nextquestionset['warning_sign']!.contains(sim)) {
                select = sim;
                nextquestionset['warning_sign']!.add(select);
                break;
              }
            }
          }
          await dbHelper.insertNextSetTable(index+1,select, 'warning_sign');
        }
        else if (index >= 33 && index <= 35) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int i = similarityList.length - 1; i >= 0; i--) {
            int sim = similarityList[i];
            if (!doneTableData['mandatory_sign']!.contains(sim) && !nextquestionset['mandatory_sign']!.contains(sim)) {
              select = sim;
              nextquestionset['mandatory_sign']!.add(select);
              break;
            }
          }
          if (select == -1) {
            for (int i = similarityList.length - 1; i >= 0; i--) {
              int sim = similarityList[i];
              if (!nextquestionset['mandatory_sign']!.contains(sim)) {
                select = sim;
                nextquestionset['mandatory_sign']!.add(select);
                break;
              }
            }
          }
          await dbHelper.insertNextSetTable(index+1,select, 'mandatory_sign');
        }
        else if (index == 36) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int i = similarityList.length - 1; i >= 0; i--) {
            int sim = similarityList[i];
            if (!doneTableData['dangerous_situations']!.contains(sim) && !nextquestionset['dangerous_situations']!.contains(sim)) {
              select = sim;
              nextquestionset['dangerous_situations']!.add(select);
              break;
            }
          }
          if (select == -1) {
            for (int i = similarityList.length - 1; i >= 0; i--) {
              int sim = similarityList[i];
              if (!nextquestionset['dangerous_situations']!.contains(sim)) {
                select = sim;
                nextquestionset['dangerous_situations']!.add(select);
                break;
              }
            }
          }
          await dbHelper.insertNextSetTable(index+1,select, 'dangerous_situations');
        }
        else if (index >= 37 && index <= 39) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int i = similarityList.length - 1; i >= 0; i--) {
            int sim = similarityList[i];
            if (!doneTableData['law_land_traffic']!.contains(sim) && !nextquestionset['law_land_traffic']!.contains(sim)) {
              select = sim;
              nextquestionset['law_land_traffic']!.add(select);
              break;
            }
          }
          if (select == -1) {
            for (int i = similarityList.length - 1; i >= 0; i--) {
              int sim = similarityList[i];
              if (!nextquestionset['law_land_traffic']!.contains(sim)) {
                select = sim;
                nextquestionset['law_land_traffic']!.add(select);
                break;
              }
            }
          }
          await dbHelper.insertNextSetTable(index+1,select, 'law_land_traffic');
        }
        else if (index >= 40 && index <= 45) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int i = similarityList.length - 1; i >= 0; i--) {
            int sim = similarityList[i];
            if (!doneTableData['law_automobile']!.contains(sim) && !nextquestionset['law_automobile']!.contains(sim)) {
              select = sim;
              nextquestionset['law_automobile']!.add(select);
              break;
            }
          }
          if (select == -1) {
            for (int i = similarityList.length - 1; i >= 0; i--) {
              int sim = similarityList[i];
              if (!nextquestionset['law_automobile']!.contains(sim)) {
                select = sim;
                nextquestionset['law_automobile']!.add(select);
                break;
              }
            }
          }
          await dbHelper.insertNextSetTable(index+1,select, 'law_automobile');
        }
        else if (index >= 46 && index <= 50) {
          List<int> similarityList = json.decode(question['similarity']).cast<int>();
          int select = -1;
          for (int i = similarityList.length - 1; i >= 0; i--) {
            int sim = similarityList[i];
            if (!doneTableData['law_commercial_and_criminal']!.contains(sim) && !nextquestionset['law_commercial_and_criminal']!.contains(sim)) {
              select = sim;
              nextquestionset['law_commercial_and_criminal']!.add(select);
              break;
            }
          }
          if (select == -1) {
            for (int i = similarityList.length - 1; i >= 0; i--) {
              int sim = similarityList[i];
              if (!nextquestionset['law_commercial_and_criminal']!.contains(sim)) {
                select = sim;
                nextquestionset['law_commercial_and_criminal']!.add(select);
                break;
              }
            }
          }
          await dbHelper.insertNextSetTable(index+1,select, 'law_commercial_and_criminal');
        }
      }
    }
  }


  String _getCategory(int index) {
    if (index >= 0 && index <= 7) return 'car_maintenance';
    if (index >= 8 && index <= 21) return 'save_drive';
    if (index >= 22 && index <= 28) return 'manners_and_conscience';
    if (index >= 29 && index <= 32) return 'warning_sign';
    if (index >= 33 && index <= 35) return 'mandatory_sign';
    if (index == 36) return 'dangerous_situations';
    if (index >= 37 && index <= 39) return 'law_land_traffic';
    if (index >= 40 && index <= 45) return 'law_automobile';
    return 'law_commercial_and_criminal';
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
        automaticallyImplyLeading: false,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'ผลการทำข้อสอบ',
          ),
        ),
        backgroundColor: Color(0xFF92CA68),
        actions: [
          IconButton(
            onPressed: handleClickHome,
            icon: Icon(Icons.home),
          ),
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
                    'ข้อที่ ${index + 1}: ${question['question_text'] ?? ''}',
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
