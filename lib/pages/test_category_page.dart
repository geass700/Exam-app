import 'package:flutter/material.dart';
import 'lib/database_helper.dart';
import 'selcet_tset_result_page.dart';

class Test_Category extends StatefulWidget {
  final String test_selected;
  Test_Category({required this.test_selected});

  @override
  _Test_CategoryState createState() => _Test_CategoryState();
}

class _Test_CategoryState extends State<Test_Category> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> questions = [];
  final Map<int, String> answers = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions(widget.test_selected);
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
