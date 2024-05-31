import 'package:flutter/material.dart';
import 'package:test2/pages/simulation_test.dart';
import 'key_page.dart';
import 'random_test_page.dart';
import 'selectKey_pages.dart';
import 'selectTest_pages.dart';
import 'stat_pages.dart';
import 'testTile.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key});

  @override
  State<MainPage> createState() => _State();
}

class _State extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            color: Colors.lightGreen[200],
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'แอปพลิเคชั่นฝึกฝนการทำข้อสอบใบขับขี่',
                style: TextStyle(fontSize: 40),
                textAlign: TextAlign.center,
              ),
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
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFDAFAFA)),
                    ),
                    child: Text('ฝึกทำข้อสอบเสมือนจริง',style: TextStyle(fontSize: 20),),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: handleClickTest2,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFDAFAFA)),
                    ),
                    child: Text('ฝึกทำข้อสอบเฉพาะหมวด',style: TextStyle(fontSize: 20),),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: handleClickKey,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFDAFAFA)),
                    ),
                    child: Text('คลังข้อสอบ',style: TextStyle(fontSize: 20),),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: handleClickStat,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFDAFAFA)),
                    ),
                    child: Text('สถิติ',style: TextStyle(fontSize: 20),),
                  )
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
      MaterialPageRoute(builder: (context) => SimulationTest()),
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
