import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:test2/pages/main_page.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
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
                child: Text(dbName.replaceAll('.db', '')),
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
