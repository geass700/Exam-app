import 'package:flutter/material.dart';
import 'key_page.dart';
import 'selectKey_pages.dart';
import 'selectTest_pages.dart';
import 'stat_pages.dart';
import 'testTile.dart';
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _State();
}

class _State extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Text(
              'แอปพลิเคชั่นฝึกฝนการทำข้อสอบใบขับขี่',
              style: TextStyle(fontSize: 60),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  ElevatedButton(
                      onPressed: handleClickTest,
                      child: Text('ฝึกทำข้อสอบเสมือนจริง')),
                  SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: handleClickTest2,
                      child: Text('ฝึกทำข้อสอบเฉพาะหมวด')),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: handleClickKey, child: Text('คลังข้อสอบ')),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: handleClickStat, child: Text('สถิติ'))
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  void handleClickTest() {
    print('เจ้าได้เลือกแล้ว');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TestTile()),
    );
  }

  void handleClickTest2() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectTestCategoryPage()),
    );
  }

  void handleClickKey() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => KeyTile()),
    );
  }

  void handleClickStat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StatPage()),
    );
  }
}
