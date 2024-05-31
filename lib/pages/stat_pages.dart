import 'package:flutter/material.dart';
import 'testTile.dart';
import 'main_page.dart';
import 'catagory.dart';
class StatPage extends StatefulWidget {
  const StatPage({super.key});

  @override
  State<StatPage> createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {

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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed:handleClickBack),
          title: Text('สถิติ'),
          backgroundColor: Color(0xFF92CA68),),
        body: ListView.builder(
            itemCount: cats.length, itemBuilder: (context, int index) {
          var cat = cats[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(cat.Name),
                  Text('คุณทำข้อสอบไปแล้ว 50 ข้อ จาก 150 ข้อ คิดเป็น 33%'),
                  Text('อัตราการทำข้อสอบถูก  35%'),
                ],
              ),
            ),
          );
        }));
  }
  void handleClickBack(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }
}

