import 'package:flutter/material.dart';
import 'lib/database_helper.dart';
import 'selcet_tset_result_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      home: Test_Category(),
    );
  }
}

class Test_Category extends StatefulWidget {
  @override
  _Test_CategoryState createState() => _Test_CategoryState();
}

class _Test_CategoryState extends State<Test_Category> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> questions = [];
  String currentDatabase = 'car_maintenance.db';
  final List<String> databases = [
    'car_maintenance.db',
    'dangerous_situations.db',
    'law_automobile.db',
    'law_commercial_and_criminal.db',
    'law_land_traffic.db',
    'mandatory_sign.db',
    'manners_and_conscience.db',
    'save_drive.db',
    'warning_sign.db'
  ];

  final Map<String, String> databaseNames = {
    'car_maintenance.db': 'การบำรุงรักษารถ',
    'dangerous_situations.db': 'การรับรู้สถานการณ์อันตราย',
    'law_automobile.db': 'กฎหมายว่าด้วยรถยนต์',
    'law_commercial_and_criminal.db': 'กฎหมายแพ่งพาณิชย์และกฎหมายอาญา',
    'law_land_traffic.db': 'กฎหมายว่าด้วยการจราจรทางบก',
    'mandatory_sign.db': 'ป้ายบังคับ',
    'manners_and_conscience.db': 'มารยาทและจิตสำนึก',
    'save_drive.db': 'เทคนิคการขับขี่อย่างปลอดภัย',
    'warning_sign.db': 'ป้ายเตือน'
  };

  Map<int, String> answers = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions(currentDatabase);
  }

  void _loadQuestions(String dbName) async {
    questions = await dbHelper.getQuestions(dbName);
    setState(() {});
  }

  void _submitAnswers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Select_ResultPage(
          answers: answers,
          questions: questions,
        ),
      ),
    );
    print("Submitted Answers: $answers");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: currentDatabase,
            items: databases.map((String dbName) {
              return DropdownMenuItem<String>(
                value: dbName,
                child: Text(databaseNames[dbName] ?? dbName),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  currentDatabase = newValue;
                  answers.clear();
                  _loadQuestions(currentDatabase);
                });
              }
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return QuestionTile(
                  question: question,
                  questionIndex: index + 1, // ปรับ index ให้เริ่มที่ 1
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
    );
  }
}

class QuestionTile extends StatefulWidget {
  final Map<String, dynamic> question;
  final int questionIndex;
  final ValueChanged<String> onAnswerSelected;

  QuestionTile({
    required this.question,
    required this.questionIndex,
    required this.onAnswerSelected,
  });

  @override
  _QuestionTileState createState() => _QuestionTileState();
}

class _QuestionTileState extends State<QuestionTile> {
  String? _selectedAnswer;

  @override
  Widget build(BuildContext context) {
    var question = widget.question;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _selectedAnswer,
                    onChanged: (value) {
                      setState(() {
                        _selectedAnswer = value;
                        widget.onAnswerSelected(value!);
                      });
                    },
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
