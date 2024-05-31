import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_page.dart';

class Select_ResultPage extends StatefulWidget {
  final Map<int, String> answers;
  final List<Map<String, dynamic>> questions;

  Select_ResultPage({required this.answers, required this.questions});

  @override
  _Select_ResultPageState createState() => _Select_ResultPageState();
}

class _Select_ResultPageState extends State<Select_ResultPage> {
  int score = 0;

  @override
  void initState() {
    super.initState();
    _calculateScore();
    _storeCorrectAnswers();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showScoreDialog());
  }

  void _calculateScore() {
    score = 0;
    widget.questions.asMap().forEach((index, question) {
      if (widget.answers[index] == question['correct_answer']) {
        score++;
        _storeCorrectAnswers();
      }
    });
  }

  Future<void> _storeCorrectAnswers() async {
    final prefs = await SharedPreferences.getInstance();

    for (var question in widget.questions) {
      final int questionId = question['id'];
      final String dbName = question['database_name'];
      final String correctAnswer = question['correct_answer'];

      if (questionId != null && dbName != null && correctAnswer != null) {
        if (widget.answers.containsKey(questionId) &&
            widget.answers[questionId] == correctAnswer) {
          String key = 'correct_answers_$dbName';
          List<String> correctAnswers = prefs.getStringList(key) ?? [];
          if (!correctAnswers.contains(questionId.toString())) {
            correctAnswers.add(questionId.toString());
            await prefs.setStringList(key, correctAnswers);
            print('Stored correct answer for $dbName: $questionId');
          }
        }
      }
    }
  }

  Future<void> _printStoredCorrectAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> databaseNames = [
      'car_maintenance.db',
      'save_drive.db',
      'manners_and_conscience.db',
      'warning_sign.db',
      'mandatory_sign.db',
      'dangerous_situations.db',
      'law_land_traffic.db',
      'law_automobile.db',
      'law_commercial_and_criminal.db'
    ];

    for (String dbName in databaseNames) {
      String key = 'correct_answers_$dbName';
      List<String> correctAnswers = prefs.getStringList(key) ?? [];
      print('Correct answers for $dbName: $correctAnswers');
    }
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
            onPressed: _printStoredCorrectAnswers,
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
