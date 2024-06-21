import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import 'new_simulation_result_page.dart';
import 'selcet_tset_result_page.dart';
import 'simulation_result_page.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import 'userdatahandle.dart';

class New_SimulationTest extends StatefulWidget {
  @override
  _New_SimulationTestState createState() => _New_SimulationTestState();
}

class _New_SimulationTestState extends State<New_SimulationTest> {
  final UserdataHandle UserHelper = UserdataHandle.instance;
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> questions = [];
  final Map<int, String> answers = {};
  Database? nextquestion;
  String loadednextquestionStr ='';

  Map<String, List<int>> databaseQuestions = {
    'car_maintenance': [1, 120, 106, 44, 10, 72, 57, 83],
    'save_drive': [1, 86, 203, 160, 4, 134, 205, 184, 175, 49, 120, 43, 89, 140],
    'manners_and_conscience': [1, 30, 103, 60, 19, 85, 2],
    'warning_sign': [1, 11, 9, 40],
    'mandatory_sign': [1, 33, 24],
    'dangerous_situations': [1],
    'law_land_traffic': [1, 46, 50],
    'law_automobile': [1, 10, 8, 60, 36, 65],
    'law_commercial_and_criminal': [1, 8, 24, 40]
  };

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }


  Future<void> _loadQuestions() async {
    Map<String, List<int>> nextSetTableData = await UserHelper.getNextSetTableData();
    print(nextSetTableData);
    print(nextSetTableData.isEmpty);
    if(nextSetTableData.isNotEmpty){
      databaseQuestions = nextSetTableData;
    }
    List<Map<String, dynamic>> allQuestions = [];
    for (String dbName in databaseQuestions.keys) {
      var questionIds = databaseQuestions[dbName]!;
      var questionsFromDb =
      await dbHelper.getSpecificQuestions(dbName, questionIds);
      allQuestions.addAll(questionsFromDb);
    }
    setState(() {
      questions = allQuestions;
    });
  }


  void _submitAnswers() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => New_Simulation_ResultPage(
          answers: answers,
          questions: questions,
        ),
      ),
    );
  }


  void _demoSelectAnswers() {
    setState(() {
      for (int i = 0; i < questions.length; i++) {
        answers[i] = questions[i]['choice_1'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('การทำข้อสอบเสมือนจริง'),
        backgroundColor: Color(0xFF92CA68),
        actions: [
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: _demoSelectAnswers,
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFC8E6B2),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final selectedAnswer = answers[index] ?? '';
                  return QuestionTile(
                    question: question,
                    questionIndex: index + 1,
                    selectedAnswer: selectedAnswer,
                    onAnswerSelected: (String answer) {
                      setState(() {
                        answers[index] = answer;
                      });
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _submitAnswers,
                child: Text('Submit Answers'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionTile extends StatefulWidget {
  final Map<String, dynamic> question;
  final int questionIndex;
  final String selectedAnswer;
  final ValueChanged<String> onAnswerSelected;

  QuestionTile({
    required this.question,
    required this.questionIndex,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  _QuestionTileState createState() => _QuestionTileState();
}

class _QuestionTileState extends State<QuestionTile> {
  @override
  Widget build(BuildContext context) {
    var question = widget.question;
    var selectedAnswer = widget.selectedAnswer;
    String? imagePath;

    // Check if 'image_number' is not null and set the image path
    if (question['image_number'] != null) {
      String imageNumber = question['image_number'];
      String jpgPath = 'assets/testpic/$imageNumber.jpg';
      String pngPath = 'assets/testpic/$imageNumber.png';

      // Check if the JPG image exists
      if (AssetImage(jpgPath).assetName.isNotEmpty) {
        imagePath = jpgPath;
      }
      // Check if the PNG image exists
      else if (AssetImage(pngPath).assetName.isNotEmpty) {
        imagePath = pngPath;
      }
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Color(0xFFE4F3D8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ข้อที่ ${widget.questionIndex}: ${question['question_text']}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (imagePath != null) // Display the image if it exists
              Image.asset(imagePath),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                4,
                    (index) {
                  String option = question['choice_${index + 1}'];
                  bool isSelected = selectedAnswer == option;
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: selectedAnswer,
                    onChanged: (value) {
                      setState(() {
                        widget.onAnswerSelected(value!);
                      });
                    },
                    selected: isSelected,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}