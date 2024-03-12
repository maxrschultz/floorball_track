import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:floorball_track/const.dart';
import 'package:floorball_track/period_type.dart';
import 'package:floorball_track/stat_ballpossession_type.dart';
import 'package:floorball_track/statistics.dart';
import 'package:floorball_track/toast_messages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BallPossessionMainPage extends StatefulWidget {
  final BallPossessionStat ballPossStat;

  const BallPossessionMainPage({super.key, required this.ballPossStat});

  @override
  State<StatefulWidget> createState() => _BallPossessionMainPage();
}

class _BallPossessionMainPage extends State<BallPossessionMainPage> {
  StatBallPossessionType timerState = StatBallPossessionType.paused;
  PeriodType period = PeriodType.firstThird;
  int totalTime = 0;
  int lastStateStart = 0;
  late Timer timer;
  HashMap<PeriodType, HashMap<StatBallPossessionType, int>> timeMap =
      HashMap<PeriodType, HashMap<StatBallPossessionType, int>>();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 100), updateTimer);
    timeMap.putIfAbsent(PeriodType.firstThird, () => HashMap());
    timeMap.putIfAbsent(PeriodType.secondThird, () => HashMap());
    timeMap.putIfAbsent(PeriodType.thirdThird, () => HashMap());
    timeMap.putIfAbsent(PeriodType.overtime, () => HashMap());
    timeMap.forEach((period, bpMap) {
      bpMap.putIfAbsent(StatBallPossessionType.myTeam, () => 0);
      bpMap.putIfAbsent(StatBallPossessionType.enemyTeam, () => 0);
      bpMap.putIfAbsent(StatBallPossessionType.unclear, () => 0);
      bpMap.putIfAbsent(StatBallPossessionType.paused, () => 0);
    });
  }

  void updateTimer(Timer timer) {
    setState(() {
      totalTime++;
      timeMap[period]![timerState] = timeMap[period]![timerState]! + 1;
    });
  }

  int getLength(PeriodType? period, StatBallPossessionType bpType) {
    if (period == null) {
      int length = 0;
      timeMap.forEach((per, bpMap) {
        if (bpType != StatBallPossessionType.paused) {
          length += bpMap[bpType]!;
        }
      });
      return length;
    } else {
      return timeMap[period]![bpType]!;
    }
  }

  int getPercentOf(PeriodType? period, StatBallPossessionType bpType) {
    int toInvest = getLength(period, bpType);
    int sumPeriod = 0;
    for (StatBallPossessionType bp in StatBallPossessionType.values) {
      if (bp != StatBallPossessionType.paused) {
        sumPeriod += getLength(period, bp);
      }
    }
    if (sumPeriod == 0) {
      return 0;
    } else {
      return (toInvest / sumPeriod * 100).round();
    }
  }

  String formatTime(int deciSeconds) {
    int seconds = deciSeconds ~/ 10;
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: blue3,
          appBar: AppBar(
            backgroundColor: blue1,
            toolbarHeight: MediaQuery.of(context).size.width / 100 * 15,
            title: Text(
                'vs ${widget.ballPossStat.name} ${DateFormat('dd.MM.yy').format(widget.ballPossStat.created)}'),
            leading: Icon(Icons.timer_outlined),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 100 * 88,
                height: MediaQuery.of(context).size.width / 100 * 40,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: blue2,
                ),
                child: Center(
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Center(
                              child: Text('period',
                                  style: TextStyle(color: white2))),
                        ),
                        Center(
                            child: Text('my team',
                                style: TextStyle(
                                    color: (timerState ==
                                            StatBallPossessionType.myTeam)
                                        ? white1
                                        : white2))),
                        Center(
                            child: Text('enemy',
                                style: TextStyle(
                                    color: (timerState ==
                                            StatBallPossessionType.enemyTeam)
                                        ? white1
                                        : white2))),
                        Center(
                            child: Text('unclear',
                                style: TextStyle(
                                    color: (timerState ==
                                            StatBallPossessionType.unclear)
                                        ? white1
                                        : white2))),
                      ]),
                      addTableRow('1. period', PeriodType.firstThird),
                      addTableRow('2. period', PeriodType.secondThird),
                      addTableRow('3. period', PeriodType.thirdThird),
                      addTableRow('overtime', PeriodType.overtime),
                      addTableRow('total', null),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (period != PeriodType.overtime)
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 100 * 41,
                      height: MediaQuery.of(context).size.height / 100 * 10,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            if (timerState != StatBallPossessionType.paused) {
                              widget.ballPossStat.addBallPossessionTime(period,
                                  timerState, lastStateStart, totalTime);
                              lastStateStart = totalTime;
                            }
                            period = PeriodType.values[period.index + 1];
                            timerState = StatBallPossessionType.paused;
                          });
                        },
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(5),
                            backgroundColor: blue1,
                            foregroundColor: white1,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        child: Text('start next period'),
                      ),
                    ),
                  SizedBox(
                    width: (period != PeriodType.overtime)
                        ? MediaQuery.of(context).size.width / 100 * 41
                        : MediaQuery.of(context).size.width / 100 * 88,
                    height: MediaQuery.of(context).size.height / 100 * 10,
                    child: TextButton(
                      onPressed: (timerState == StatBallPossessionType.paused)
                          ? () {
                              setState(() {
                                widget.ballPossStat.modified = DateTime.now();
                                widget.ballPossStat.save();
                                showToast('stat saved');
                              });
                            }
                          : null,
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(5),
                          backgroundColor: blue1,
                          foregroundColor: white1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: Text('save statistics'),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  addTimeBtn(StatBallPossessionType.myTeam, 'my team'),
                  addTimeBtn(StatBallPossessionType.enemyTeam, 'enemy team'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  addTimeBtn(StatBallPossessionType.unclear, 'unclear'),
                  addTimeBtn(StatBallPossessionType.paused, 'paused'),
                ],
              )
            ],
          )),
    );
  }

  TableRow addTableRow(String name, PeriodType? period) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Center(
            child: Text(name,
                style: TextStyle(
                    color: (period == this.period) ? white1 : white2))),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('${getPercentOf(period, StatBallPossessionType.myTeam)}%',
              style: TextStyle(
                  color: (period == this.period &&
                          timerState == StatBallPossessionType.myTeam)
                      ? white1
                      : white2)),
          Text(formatTime(getLength(period, StatBallPossessionType.myTeam)),
              style: TextStyle(
                  color: (period == this.period &&
                          timerState == StatBallPossessionType.myTeam)
                      ? white1
                      : white2)),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('${getPercentOf(period, StatBallPossessionType.enemyTeam)}%',
              style: TextStyle(
                  color: (period == this.period &&
                          timerState == StatBallPossessionType.enemyTeam)
                      ? white1
                      : white2)),
          Text(formatTime(getLength(period, StatBallPossessionType.enemyTeam)),
              style: TextStyle(
                  color: (period == this.period &&
                          timerState == StatBallPossessionType.enemyTeam)
                      ? white1
                      : white2)),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('${getPercentOf(period, StatBallPossessionType.unclear)}%',
              style: TextStyle(
                  color: (period == this.period &&
                          timerState == StatBallPossessionType.unclear)
                      ? white1
                      : white2)),
          Text(formatTime(getLength(period, StatBallPossessionType.unclear)),
              style: TextStyle(
                  color: (period == this.period &&
                          timerState == StatBallPossessionType.unclear)
                      ? white1
                      : white2)),
        ],
      ),
    ]);
  }

  Widget addTimeBtn(StatBallPossessionType type, String text) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 100 * 41,
      height: MediaQuery.of(context).size.height / 100 * 20,
      child: TextButton(
          onPressed: () {
            setState(() {
              if (timerState != type) {
                widget.ballPossStat.addBallPossessionTime(
                    period, timerState, lastStateStart, totalTime);
                lastStateStart = totalTime;
                timerState = type;
              }
            });
          },
          style: TextButton.styleFrom(
              padding: EdgeInsets.all(5),
              backgroundColor: (type == timerState) ? blue1 : blue2,
              foregroundColor: white1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15))),
          child: Text(text)),
    );
  }
}
