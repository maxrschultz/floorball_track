import 'package:floorball_track/archive_main.dart';
import 'package:floorball_track/change_main.dart';
import 'package:floorball_track/const.dart';
import 'package:floorball_track/statistics.dart';
import 'package:floorball_track/toast_messages.dart';
import 'package:flutter/material.dart';

import 'ballpossession_main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget with RouteAware {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'floorball stats',
      theme: ThemeData(
          backgroundColor: blue3,
          primaryColor: white1,
          fontFamily: 'Varela',
          textTheme: TextTheme(
            bodyText1: TextStyle(fontSize: 20),
            bodyText2: TextStyle(fontSize: 15, color: white1),
          )),
      home: const MyHomePage(title: 'floorball stats'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController tec = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: blue3,
        appBar: AppBar(
          backgroundColor: blue1,
          toolbarHeight: MediaQuery.of(context).size.height / 100 * 7,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              addButton(Icons.add, Icons.timer_outlined, 'ball possession stat',() {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('name your ball possession stat'),
                      content: TextField(
                        controller: tec,
                        decoration: const InputDecoration(
                          hintText: 'Name',
                          icon: Icon(Icons.timer_outlined),
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BallPossessionMainPage(
                                        ballPossStat: BallPossessionStat(
                                            name: tec.text),
                                      )),
                            );
                          },
                          child: const Text('submit'),
                        ),
                      ],
                    );
                  },
                );
              },),
              addButton(Icons.add, Icons.compare_arrows, 'change stat', () {
                showToast("not available yet");
              }),
              addButton(Icons.add, Icons.gps_fixed, 'shooting stat', () {
                showToast("not available yet");
              }),
              addButton(Icons.keyboard_double_arrow_right, Icons.archive_outlined, 'archive', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArchiveMainPage()),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget addButton(IconData icon1, IconData icon2, String text, Function() function){
    return  SizedBox(
      width: MediaQuery.of(context).size.width/100*88,
      height: MediaQuery.of(context).size.height/100*15,
      child: TextButton(
        style: TextButton.styleFrom(
            padding: EdgeInsets.all(5),
            backgroundColor: blue1 ,
            foregroundColor: white1,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
        onPressed: function,
        child: Row(
          children: [
            Icon(icon1),
            Icon(icon2),
            Expanded(child: Center(child: Text(text)))
          ],
        ),
      ),
    );
  }
}
