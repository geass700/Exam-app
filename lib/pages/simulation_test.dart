import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database_helper.dart';
import 'selcet_tset_result_page.dart';
import 'simulation_result_page.dart';

class SimulationTest extends StatefulWidget {
  @override
  _SimulationTestState createState() => _SimulationTestState();
}

class _SimulationTestState extends State<SimulationTest> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> questions = [];
  final Map<int, String> answers = {};

  final Map<String, List<int>> databaseQuestions = {
    'car_maintenance.db': [1, 120, 106, 44, 10, 72, 57, 83],
    'save_drive.db': [1, 86, 203, 160, 4, 134, 205, 184, 175, 49, 120, 43, 89, 140],
    'manners_and_conscience.db': [1, 30, 103, 60, 19, 85, 2],
    'warning_sign.db': [1, 11, 9, 40],
    'mandatory_sign.db': [1, 33, 24],
    'dangerous_situations.db': [1],
    'law_land_traffic.db': [1, 46, 50],
    'law_automobile.db': [1, 10, 8, 60, 36, 65],
    'law_commercial_and_criminal.db': [1, 8, 24, 40]
  };

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() async {
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

  Future<void> _saveCorrectAnswer(String dbName, int questionId) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'correct_answers_$dbName';
    List<String> correctAnswers = prefs.getStringList(key) ?? [];

    if (!correctAnswers.contains(questionId.toString())) {
      correctAnswers.add(questionId.toString());
    }

    await prefs.setStringList(key, correctAnswers);
  }

  Future<List<int>> _loadCorrectAnswers(String dbName) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'correct_answers_$dbName';
    List<String> correctAnswers = prefs.getStringList(key) ?? [];
    return correctAnswers.map((id) => int.parse(id)).toList();
  }

  void _submitAnswers() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Simulation_ResultPage(
          answers: answers,
          questions: questions,
        ),
      ),
    );
    // print("Submitted Answers: $answers");
    // for (var question in questions) {
    //   final int questionId = question['question_id'];
    //   final String dbName = question['database_name'];
    //   final String correctAnswer = question['correct_answer'];
    //
    //   if (questionId != null && dbName != null && correctAnswer != null) {
    //     if (answers.containsKey(questionId) &&
    //         answers[questionId] == correctAnswer) {
    //       await _saveCorrectAnswer(dbName, questionId); // Correct answer
    //     }
    //   } else {
    //     print(
    //         "Error: questionId, dbName, or correctAnswer is null for question: $question");
    //   }
    // }
  }

  Future<void> _printStoredCorrectAnswers() async {
    for (String dbName in databaseQuestions.keys) {
      List<int> correctAnswers = await _loadCorrectAnswers(dbName);
      print('Correct answers for $dbName: $correctAnswers');
    }
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
          IconButton(
            icon: Icon(Icons.print),
            onPressed: _printStoredCorrectAnswers,
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

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Color(0xFFE4F3D8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${widget.questionIndex}: ${question['question_text']}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
