import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:solve_student/feature/replay/models/replay_offset_model.dart';

class ReplayController extends ChangeNotifier {
  ReplayController(this.context);
  BuildContext context;

  init() {
    startTimer();
  }

  Timer? timer;
  int start = 0;
  int totalTime = 20;
  Offset? offsetPlay;

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
          RunTime? thisTime = mock.where((element) {
            return element.time == start;
          }).firstOrNull;
          if (thisTime != null) {
            offsetPlay = Offset(thisTime.x!, thisTime.y!);
          }
          start = start + 1;
          notifyListeners();
        }
      },
    );
  }
}

var mock = [
  RunTime(time: 1, x: 324.4, y: 158.4),
  RunTime(time: 2, x: 324.6, y: 158.4),
  RunTime(time: 3, x: 324.9, y: 158.9),
  RunTime(time: 4, x: 325.1, y: 159.1),
  RunTime(time: 5, x: 325.3, y: 159.4),
  RunTime(time: 6, x: 325.6, y: 159.8),
  RunTime(time: 7, x: 325.8, y: 161.2),
  RunTime(time: 8, x: 326.3, y: 163.1),
  RunTime(time: 9, x: 327.0, y: 165.5),
  RunTime(time: 10, x: 327.9, y: 167.6),
  RunTime(time: 11, x: 329.1, y: 170.4),
  RunTime(time: 12, x: 330.5, y: 173.5),
  RunTime(time: 13, x: 331.9, y: 176.5),
  RunTime(time: 14, x: 333.3, y: 179.4),
  RunTime(time: 15, x: 335.0, y: 181.9),
  RunTime(time: 16, x: 336.6, y: 185.0),
  RunTime(time: 17, x: 338.0, y: 187.8)
];
