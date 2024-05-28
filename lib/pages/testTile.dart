import 'package:flutter/material.dart';
import 'package:test2/pages/result_page.dart';
import 'main_page.dart';
import 'key_page.dart';
class TestTile extends StatelessWidget {
  final List<Map<String, dynamic>> questions = List.generate(
    50,
        (index) => {
      'question': 'Question ${index + 1}?',
      'options': ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
      'correctAnswer': 'Option 1',
    },
  );

  @override
  Widget build(BuildContext context) {
    void handleClickBack(){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('คุณแน่ใจว่าต้องการออกจากการทำข้อสอบ?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('ไม่'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                  );
                },
                child: Text('ใช่'),
              ),
            ],
          );
        },
      );
    }

    void handleClickSubmit() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Result_page()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: handleClickBack,),title: Text('แอปพลิเคชั่นฝึกฝนการทำข้อสอบใบขับขี่'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ...questions.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> question = entry.value;
              return QuestionTile(
                question: question,
                questionIndex: index,
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('ยืนยันการส่งคำตอบ?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('ยกเลิก'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            handleClickSubmit();
                          },
                          child: Text('ยืนยัน'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('ส่งคำตอบ'),
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
              'Question ${widget.questionIndex + 1}: ${question['question']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                question['options'].length,
                    (index) => RadioListTile(
                  title: Text(question['options'][index]),
                  value: question['options'][index],
                  groupValue: _selectedAnswer,
                  onChanged: (value) {
                    setState(() {
                      _selectedAnswer = value.toString();
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
