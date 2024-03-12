import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:floorball_track/period_type.dart';
import 'package:floorball_track/stat_ballpossession_type.dart';
import 'package:floorball_track/statistics.dart';
import 'package:floorball_track/toast_messages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'const.dart';

class ArchiveMainPage extends StatefulWidget {
  const ArchiveMainPage({Key? key}) : super(key: key);

  @override
  State<ArchiveMainPage> createState() => _ArchiveMainPageState();
}

class _ArchiveMainPageState extends State<ArchiveMainPage> {
  late Future<List<String>> fileNamesFut;
  late List<Stat> stats = [];
  List<Widget> statWidgets = [];

  @override
  void initState() {
    super.initState();
    fileNamesFut = getFilesInFolder();
    fileNamesFut.then((fileNames) {
      fileNames.forEach((fileName) {
        stats.add(BallPossessionStat.fromJson(
            jsonDecode(File(fileName).readAsStringSync())));
        setState(() {
          statWidgets.add(StatWidget(stat: stats.last));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: blue3,
        appBar: AppBar(
          backgroundColor: blue1,
          toolbarHeight: MediaQuery.of(context).size.width / 100 * 15,
          title: const Text('stat archive'),
          leading: Icon(Icons.archive_outlined),
        ),
        body: ListView(children: [
          ...statWidgets,
        ]),
      ),
    );
  }

  Future<List<String>> getFilesInFolder() async {
    Directory directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files =
        Directory('${directory.path}/stats').listSync();
    List<String> fileNames = files.map((file) => file.path).toList();
    return fileNames;
  }
}

class StatWidget extends StatefulWidget {
  const StatWidget({super.key, required this.stat});

  final Stat stat;

  @override
  State<StatefulWidget> createState() => StatWidgetState();
}

class StatWidgetState extends State<StatWidget> {
  bool visible = false;
  bool percent = true;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 100 * 88,
          height: MediaQuery.of(context).size.height / 100 * 1,
        ),
        Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 100 * 88,
              height: MediaQuery.of(context).size.height / 100 * 8,
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      visible = !visible;
                    });
                  },
                  style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      backgroundColor: blue1,
                      foregroundColor: white1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.timer_outlined),
                        Text(
                            '${widget.stat.name} (${DateFormat('dd.MM.yy').format(widget.stat.created)})'),
                        IconButton(
                            onPressed: () async {

                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('delete stat'),
                                    content: Text('do you want to delete \'${widget.stat.name}\' from ${DateFormat('dd.MM.yy').format(widget.stat.created)}?', softWrap: true,),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('no'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          Directory directory =
                                              await getApplicationDocumentsDirectory();
                                          File file = File(
                                              '${directory.path}/stats/${DateFormat('yy_MM_dd').format(widget.stat.created)}_${widget.stat.name}.json');
                                          print(file.path);
                                          if (file.existsSync()) {
                                            file.deleteSync();
                                          }
                                          Navigator.pushReplacement(context,MaterialPageRoute(builder: ((context) => ArchiveMainPage())));
                                          showToast('deleted ${widget.stat.name}');
                                        },
                                        child: const Text('yes'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.delete_forever))
                      ])),
            ),
            Visibility(
              //TODO aufklappbare infos
              visible: visible,
              child: Container(
                width: MediaQuery.of(context).size.width/100*80,
                decoration: BoxDecoration(
                  color: blue2,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15) )
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TextButton(onPressed: (){
                        setState(() {
                          percent=!percent;
                        });
                      }, child: Text((percent)?'show time':'show percent'),style: TextButton.styleFrom(
                          backgroundColor: blue1,
                          foregroundColor: white1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))
                      ), ),
                      Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          const TableRow(
                            children: [
                          Padding(padding: EdgeInsets.all(2), child: Center(child: Text('period'))),
                              Center(child: Text('my team')),
                              Center(child: Text('enemy')),
                              Center(child: Text('unclear')),
                            ]
                          ),
                          addTableRow('1.', PeriodType.firstThird),
                          addTableRow('2.', PeriodType.secondThird),
                          addTableRow('3.', PeriodType.thirdThird),
                          if((widget.stat as BallPossessionStat).getTimeByPeriod(PeriodType.overtime)!=0) addTableRow('overtime', PeriodType.overtime),
                          addTableRow('total', null),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ),
          ],
        ),
      ],
    );
  }

  TableRow addTableRow(String name, PeriodType? period){
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all( 2),
        child: Center(
            child: Text(name)),
      ),
      Center(child: Text((percent)?'${(widget.stat as BallPossessionStat).getPercentByPeriodAndBallPossession(period, StatBallPossessionType.myTeam)}%':formatDuration((widget.stat as BallPossessionStat).getTimeByPeriodAndBallPossession(period, StatBallPossessionType.myTeam)))),
      Center(child: Text((percent)?'${(widget.stat as BallPossessionStat).getPercentByPeriodAndBallPossession(period, StatBallPossessionType.enemyTeam)}%':formatDuration((widget.stat as BallPossessionStat).getTimeByPeriodAndBallPossession(period, StatBallPossessionType.enemyTeam)))),
      Center(child: Text((percent)?'${(widget.stat as BallPossessionStat).getPercentByPeriodAndBallPossession(period, StatBallPossessionType.unclear)}%':formatDuration((widget.stat as BallPossessionStat).getTimeByPeriodAndBallPossession(period, StatBallPossessionType.unclear)))),
    ]);
  }

  String formatDuration(int deciseconds) {
    int seconds = deciseconds ~/ 10;
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    return '${twoDigits(minutes)}:${twoDigits(remainingSeconds)}';
  }

  String twoDigits(int n) {
    if (n >= 10) {
      return "$n";
    }
    return "0$n";
  }
}
