import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'key_page.dart';
import 'testTile.dart';
import 'main_page.dart';
import 'catagory.dart';
import 'test_category_page.dart';
class SelectKeyCategoryPage extends StatefulWidget {
  const SelectKeyCategoryPage({super.key});

  @override
  State<SelectKeyCategoryPage> createState() => _SelectKeyCategoryPageState();
}

class _SelectKeyCategoryPageState extends State<SelectKeyCategoryPage> {

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
        appBar: AppBar(leading: BackButton(onPressed:handleClickBack),title: Text('เลือกหมวดหมู่ข้อสอบที่ต้องการเฉลย'),),
        body: ListView.builder(
            itemCount: cats.length, itemBuilder: (context, int index) {
          var cat = cats[index];
          return Card(
            child: InkWell(
              onTap: () => handleClickSelect(cat.data),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(cat.Name)
                  ],
                ),
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
  void handleClickSelect(String databaseName){
    Navigator.push(

      context,
      MaterialPageRoute(builder: (context) => Test_Category()),
    );
  }
}

