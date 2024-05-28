import 'package:flutter/material.dart';
import 'main_page.dart';

class KeyTile extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  KeyTile({required this.questions});

  @override
  Widget build(BuildContext context) {
    void handleClickBack() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: handleClickBack,
        ),
        title: Text('แอปพลิเคชั่นฝึกฝนการทำข้อสอบใบขับขี่'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Text('คะแนนที่ได้ 40/50', style: TextStyle(fontSize: 25)),
            ...questions.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> question = entry.value;
              return QuestionTile(
                question: question,
                questionIndex: index,
              );
            }).toList(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class QuestionTile extends StatefulWidget {
  final Map<String, dynamic> question;
  final int questionIndex;

  QuestionTile({required this.question, required this.questionIndex});

  @override
  _QuestionTileState createState() => _QuestionTileState();
}

class _QuestionTileState extends State<QuestionTile> {
  String? _selectedAnswer;

  @override
  Widget build(BuildContext context) {
    var question = widget.question;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${widget.questionIndex + 1}: ${question['question_text']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                4,
                    (index) {
                  String option = question['choice_${index + 1}'];
                  bool isCorrect = option == question['correct_answer'];
                  return RadioListTile(
                    title: Row(
                      children: [
                        Text(option),
                        if (isCorrect) Icon(Icons.check, color: Colors.green),
                      ],
                    ),
                    value: option,
                    groupValue: _selectedAnswer,
                    onChanged: (value) {
                      setState(() {
                        _selectedAnswer = value.toString();
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
