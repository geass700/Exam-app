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
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'การทำข้อสอบเฉพาะหมวด',
          ),
        ),
        backgroundColor: Color(0xFF92CA68),
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
                child: Text('ส่งคำตอบ'),
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
            SizedBox(height: 8),
            if (imagePath != null) // Display the image if it exists
              Image.asset(imagePath),
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
