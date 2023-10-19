import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:solve_student/feature/replay/mock/replay_mock.dart';
import 'package:solve_student/feature/replay/models/replay_model.dart';
import 'package:solve_student/feature/replay/models/replay_model.dart'
    as replay;

class ReplayController extends ChangeNotifier {
  ReplayController(this.context);
  BuildContext context;

  ReplayModel? replayData;
  Timer? timer;
  int start = 0;
  num totalTime = 20;
  Offset? offsetPlay;
  List<Offset?> offsetBuild = [];

  init() async {
    // startTimer();
    await setReplay();
  }

  setReplay() {
    log("click");
    start = 0;
    offsetBuild = [];
    replayData = ReplayModel.fromJson(replayMock);
    // totalTime = 3000;
    totalTime = replayData?.actions?.last.time ?? 1;
    startTimer();
    notifyListeners();
  }

  void startTimer() {
    const oneSec = Duration(milliseconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (start >= totalTime) {
          timer.cancel();
          notifyListeners();
        } else {
          replay.Action? findAction = replayData?.actions?.where((element) {
            if (element.type == "drawing") {
              DataClass setPoint = DataClass.fromJson(element.data);
              for (var i = 0; i < setPoint.points!.length; i++) {
                replay.Datum onlyPoint = setPoint.points![i];
                if (onlyPoint.time == start) {
                  log("point run : ${onlyPoint.toJson()}");
                  offsetPlay = Offset(
                    onlyPoint.x?.toDouble() ?? 0,
                    onlyPoint.y?.toDouble() ?? 0,
                  );
                  offsetBuild.add(offsetPlay);
                  notifyListeners();
                  return true;
                }
              }
            }
            return false;
          }).firstOrNull;
          // log("action this time :$start");
          if (findAction == null) {
            offsetPlay = null;
          }
          start = start + 1;
          notifyListeners();
        }
      },
    );
  }
}
