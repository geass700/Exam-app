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
    WidgetsBinding.instance.addPostFrameCallback((_) => _showScoreDialog());
  }

  void _calculateScore() {
    score = 0;
    widget.questions.asMap().forEach((index, question) {
      if (widget.answers[index] == question['correct_answer']) {
        score++;

      }
    });
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
        automaticallyImplyLeading: false,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'ผลการทำข้อสอบ',
          ),
        ),
        backgroundColor: Color(0xFF92CA68),
        actions: [
          IconButton(
            onPressed: handleClickHome,
            icon: Icon(Icons.home),
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
                    'ข้อที่ ${index + 1}: ${question['question_text'] ?? ''}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (imagePath != null) // Display the image if it exists
                    Image.asset(imagePath),
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
