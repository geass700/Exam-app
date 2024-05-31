import 'package:flutter/material.dart';
import 'catagory.dart';
import 'lib/database_helper.dart';

class RandomTestPage extends StatefulWidget {
  @override
  _RandomTestPageState createState() => _RandomTestPageState();
}

class _RandomTestPageState extends State<RandomTestPage> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> questions = [];
  Map<int, int> answers = {}; // Question ID to selected option
  Map<int, int> scores = {}; // Category ID to score
  List<Category> cats = [
    Category(
        Name: 'การบำรุงรักษารถ',
        Id: 1,
        data: 'car_maintenance.db'
    ),
    Category(
        Name: 'เทคนิคการขับขี่อย่างปลอดภัย',
        Id: 2,
        data: 'save_drive.db'
    ),
    Category(
        Name: 'มารยาทและจิตสำนึก',
        Id: 3,
        data: 'manners_and_conscience.db'
    ),
    Category(
        Name: 'ป้ายเตือน',
        Id: 4,
        data: 'warning_sign.db'
    ),
    Category(
        Name: 'ป้ายบังคับ',
        Id: 5,
        data: 'mandatory_sign.db'
    ),
    Category(
        Name: 'การรับรู้สถานการณ์อันตราย',
        Id: 6,
        data: 'dangerous_situations.db'
    ),
    Category(
        Name: 'กฎหมายว่าด้วยการจราจรทางบก',
        Id: 7,
        data: 'law_land_traffic.db'
    ),
    Category(
        Name: 'กฎหมายว่าด้วยรถยนต์',
        Id: 8,
        data: 'law_automobile.db'
    ),
    Category(
        Name: 'หมวดกฎหมายแพ่งพาณิชย์และกฎหมายอาญา',
        Id: 9,
        data: 'law_commercial_and_criminal.db'
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialQuestions();
  }

  void _loadInitialQuestions() async {
    List<int> categoryIds = cats.map((cat) => cat.Id).toList();
    Map<int, int> lastQuestions = await dbHelper.getLastQuestionsByCategory(categoryIds);
    Map<int, List<int>> selectedQuestions = {
      1: [1, 120, 106, 44, 10, 72, 57, 83],
      2: [1, 86, 203, 160, 4, 134, 205, 184, 1775, 49, 120, 43, 89, 140],
      3: [1, 30, 103, 60, 19, 85, 2],
      4: [1, 11, 9, 40],
      5: [1, 33, 24],
      6: [1],
      7: [1, 46, 50],
      8: [1, 10, 8, 60, 36, 65],
      9: [1, 8, 24, 40, 62]
    };

    Map<int, List<int>> newQuestions = {};

    for (var category in cats) {
      if (lastQuestions.containsKey(category.Id)) {
        List<int> similarity = await dbHelper.getSimilarityQuestions(category.data, lastQuestions[category.Id]!);
        for (int id in similarity) {
          bool answeredCorrectly = await dbHelper.wasQuestionAnsweredCorrectly(id);
          if (!answeredCorrectly) {
            newQuestions[category.Id] = [id];
            break;
          }
        }
        if (!newQuestions.containsKey(category.Id)) {
          newQuestions[category.Id] = [similarity.last];
        }
      } else {
        newQuestions[category.Id] = selectedQuestions[category.Id]!;
      }
    }

    List<Map<String, dynamic>> newQuestionsList = [];
    for (var entry in newQuestions.entries) {
      List<Map<String, dynamic>> questionsFromDb = await dbHelper.getSpecificQuestions(cats.firstWhere((cat) => cat.Id == entry.key).data, entry.value);
      newQuestionsList.addAll(questionsFromDb);
    }

    setState(() {
      questions = newQuestionsList;
    });
  }

  void _submitAnswer(int questionId, int selectedOption) async {
    // Find the question's category
    int categoryId = cats.firstWhere((cat) => questions.any((q) => q['id'] == questionId && q['category_id'] == cat.Id)).Id;

    // Check the correctness of the answer
    bool isCorrect = questions.any((q) => q['id'] == questionId && q['correct_option'] == selectedOption);

    // Update scores
    scores[categoryId] = (scores[categoryId] ?? 0) + (isCorrect ? 1 : 0);

    // Insert into quiz history
    await dbHelper.insertQuizHistory(categoryId, questionId, selectedOption.toString(), isCorrect ? 1 : 0);

    // Update the state
    setState(() {
      answers[questionId] = selectedOption;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random Test'),
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          return QuestionTile(
            question: question,
            questionIndex: index + 1,
            onAnswerSelected: (int selectedOption) {
              _submitAnswer(question['id'], selectedOption);
            },
          );
        },
      ),
    );
  }
}

class QuestionTile extends StatelessWidget {
  final Map<String, dynamic> question;
  final int questionIndex;
  final ValueChanged<int> onAnswerSelected;

  QuestionTile({
    required this.question,
    required this.questionIndex,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    var options = [
      question['choice_1'],
      question['choice_2'],
      question['choice_3'],
      question['choice_4'],
    ];

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${questionIndex}: ${question['question_text']}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...List.generate(options.length, (index) {
              return ListTile(
                title: Text(options[index]),
                leading: Radio<int>(
                  value: index + 1,
                  groupValue: question['selected_option'] as int?,
                  onChanged: (int? value) {
                    if (value != null) {
                      onAnswerSelected(value);
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

