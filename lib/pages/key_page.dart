import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'main_page.dart';
import 'lib/database_helper.dart';

void main() {
  runApp(KeyTile());
}

class KeyTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  @override
  void initState() {
    super.initState();
    _loadQuestions(currentDatabase);
  }

  void _loadQuestions(String dbName) async {
    questions = await dbHelper.getQuestions(dbName);
    setState(() {});
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
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question['question_text'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RadioListTile(
                              title: Text(question['choice_1']),
                              value: question['choice_1'],
                              groupValue: question['correct_answer'],
                              onChanged: (value) {},
                            ),
                            RadioListTile(
                              title: Text(question['choice_2']),
                              value: question['choice_2'],
                              groupValue: question['correct_answer'],
                              onChanged: (value) {},
                            ),
                            RadioListTile(
                              title: Text(question['choice_3']),
                              value: question['choice_3'],
                              groupValue: question['correct_answer'],
                              onChanged: (value) {},
                            ),
                            RadioListTile(
                              title: Text(question['choice_4']),
                              value: question['choice_4'],
                              groupValue: question['correct_answer'],
                              onChanged: (value) {},
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Correct Answer: ${question['correct_answer']}',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
