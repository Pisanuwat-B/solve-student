import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:solve_student/feature/replay/mock/replay_mock.dart';
import 'package:solve_student/feature/replay/models/replay_model.dart';
import 'package:solve_student/feature/replay/models/replay_offset_model.dart';

class ReplayController extends ChangeNotifier {
  ReplayController(this.context);
  BuildContext context;

  ReplayModel? replayData;
  Timer? timer;
  int start = 0;
  num totalTime = 20;
  Offset? offsetPlay;

  init() async {
    // startTimer();
    await setReplay();
  }

  setReplay() {
    replayData = ReplayModel.fromJson(replayMock);
    totalTime = 3000;
    // totalTime = replayData?.actions?.last.time ?? 1;
    startTimer();
    notifyListeners();
  }

  void startTimer() {
    const oneSec = Duration(milliseconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        log("run :$start");
        if (start >= totalTime) {
          timer.cancel();
          notifyListeners();
        } else {
          // RunTime? thisTime = mock.where((element) {
          //   return element.time == start;
          // }).firstOrNull;
          // if (thisTime != null) {
          //   offsetPlay = Offset(thisTime.x!, thisTime.y!);
          // }
          start = start + 1;
          notifyListeners();
        }
      },
    );
  }
}
