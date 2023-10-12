// To parse this JSON data, do
//
//     final replayOffsetModel = replayOffsetModelFromJson(jsonString);

import 'dart:convert';

ReplayOffsetModel replayOffsetModelFromJson(String str) =>
    ReplayOffsetModel.fromJson(json.decode(str));

String replayOffsetModelToJson(ReplayOffsetModel data) =>
    json.encode(data.toJson());

class ReplayOffsetModel {
  List<RunTime>? runTime;

  ReplayOffsetModel({
    this.runTime,
  });

  factory ReplayOffsetModel.fromJson(Map<String, dynamic> json) =>
      ReplayOffsetModel(
        runTime: json["run_time"] == null
            ? []
            : List<RunTime>.from(
                json["run_time"]!.map((x) => RunTime.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "run_time": runTime == null
            ? []
            : List<dynamic>.from(runTime!.map((x) => x.toJson())),
      };
}

class RunTime {
  int? time;
  double? x;
  double? y;

  RunTime({
    this.time,
    this.x,
    this.y,
  });

  factory RunTime.fromJson(Map<String, dynamic> json) => RunTime(
        time: json["time"],
        x: json["x"]?.toDouble(),
        y: json["y"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "time": time,
        "x": x,
        "y": y,
      };
}
