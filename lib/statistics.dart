import 'dart:convert';
import 'dart:io';

import 'package:floorball_track/period_type.dart';
import 'package:floorball_track/stat_ballpossession_type.dart';
import 'package:floorball_track/stat_type.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

abstract class Stat {
  String name;
  DateTime created = DateTime.now();
  DateTime modified = DateTime.now();
  StatType statType;

  Stat({required this.name, required this.statType});

  Map<String, dynamic> toJson();

  String toJsonString();

  void save();
}

class BallPossessionStat extends Stat {
  BallPossessionStat({required String name})
      : super(name: name, statType: StatType.ballPossession);

  List<BallPossessionRecord> ballPossessionList = [];

  BallPossessionStat.fromJson(Map<String, dynamic> json)
      : super(name: json['name'], statType: StatType.ballPossession) {
    super.created = DateTime.parse(json['created']);
    super.modified = DateTime.parse(json['modified']);
    // Konvertiere die Liste von JSON-Objekten in eine Liste von BallPossessionRecord-Objekten
    ballPossessionList = (json['ballPossessionList'] as List<dynamic>)
        .map((recordJson) => BallPossessionRecord.fromJson(recordJson))
        .toList();
  }

  Stat jsonToStat(String path) {
    Stat resStat;
    String jsonString = File(path).readAsStringSync();
    Map<String, dynamic> json = jsonDecode(jsonString);
    String type = json['statType'];
    switch (type) {
      case 'StatType.ballPossession':
        resStat = BallPossessionStat.fromJson(json);
        break;
      default:
        resStat = BallPossessionStat(name: 'default');
    }
    return resStat;
  }

  void addBallPossessionTime(PeriodType period,
      StatBallPossessionType ballPossessionType, int startTime, int endTime) {
    ballPossessionList.add(BallPossessionRecord(
        period: period,
        ballPossessionType: ballPossessionType,
        startTime: startTime,
        endTime: endTime));
  }

  int getAllTime() {
    int res = 0;
    for (BallPossessionRecord b in ballPossessionList) {
      res += b.endTime - b.startTime;
    }
    return res;
  }

  int getTimeByPeriod(PeriodType? periodType) {
    int res = 0;
    for (BallPossessionRecord b in ballPossessionList) {
      if (b.ballPossessionType != StatBallPossessionType.paused) {
        if (periodType == null) {
          res += b.endTime - b.startTime;
        } else if (b.period == periodType) {
          res += b.endTime - b.startTime;
        }
      }
    }
    return res;
  }

  int getTimeByBallPossession(StatBallPossessionType ballPossession) {
    int res = 0;
    for (BallPossessionRecord b in ballPossessionList) {
      if (b.ballPossessionType == ballPossession) {
        res += b.endTime - b.startTime;
      }
    }
    return res;
  }

  int getTimeByPeriodAndBallPossession(
      PeriodType? periodType, StatBallPossessionType ballPossession) {
    int res = 0;
    for (BallPossessionRecord b in ballPossessionList) {
      if (  b.ballPossessionType == ballPossession) {
        if(periodType==null){
          res += b.endTime - b.startTime;
        }else if (b.period == periodType){
          res += b.endTime - b.startTime;
        }
      }
    }
    return res;
  }

  int getPercentByPeriodAndBallPossession(
      PeriodType? periodType, StatBallPossessionType ballPossession) {
    int totalPeriod = getTimeByPeriod(periodType);
    if (totalPeriod == 0) {
      return 0;
    } else {
      return (getTimeByPeriodAndBallPossession(periodType, ballPossession) /
              totalPeriod *
              100)
          .round();
    }
  }

  @override
  String toJsonString() {
    return jsonEncode(toJson());
  }

  @override
  Future<void> save() async {
    Future<String> getFilePath() async {
      Directory futDir = await getApplicationDocumentsDirectory();
      String dir = futDir.path;
      dir = '$dir/stats';
      print(dir);
      Directory directory = Directory(dir);
      if (!directory.existsSync()) {
        directory.createSync();
      }
      return '${directory.path}/${DateFormat('yy_MM_dd').format(created)}_$name.json';
    }

    print('file path ${await getFilePath()}');
    File(await getFilePath()).writeAsStringSync(toJsonString());
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'created': created.toIso8601String(),
      'modified': modified.toIso8601String(),
      'statType': statType.toString(),
      'ballPossessionList':
          ballPossessionList.map((record) => record.toJson()).toList(),
    };
  }
}

class BallPossessionRecord {
  final PeriodType period;
  final StatBallPossessionType ballPossessionType;
  final int startTime, endTime;

  BallPossessionRecord(
      {required this.period,
      required this.ballPossessionType,
      required this.startTime,
      required this.endTime});

  BallPossessionRecord.fromJson(Map<String, dynamic> json)
      : period = periodFromString(json['period']),
        ballPossessionType =
            ballPossessionTypeFromString(json['ballPossessionType']),
        startTime = json['startTime'],
        endTime = json['endTime'];

  // Hilfsmethoden für die Konvertierung von Strings in Enum-Werte
  static PeriodType periodFromString(String periodString) {
    return PeriodType.values
        .firstWhere((type) => type.toString() == periodString);
  }

  static StatBallPossessionType ballPossessionTypeFromString(
      String ballPossessionTypeString) {
    return StatBallPossessionType.values
        .firstWhere((type) => type.toString() == ballPossessionTypeString);
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period.toString(),
      'ballPossessionType': ballPossessionType.toString(),
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
