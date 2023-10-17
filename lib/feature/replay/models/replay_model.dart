// To parse this JSON data, do
//
//     final replayModel = replayModelFromJson(jsonString);

import 'dart:convert';

ReplayModel replayModelFromJson(String str) =>
    ReplayModel.fromJson(json.decode(str));

String replayModelToJson(ReplayModel data) => json.encode(data.toJson());

class ReplayModel {
  String? version;
  double? solvepadWidth;
  double? solvepadHeight;
  Metadata? metadata;
  List<Action>? actions;

  ReplayModel({
    this.version,
    this.solvepadWidth,
    this.solvepadHeight,
    this.metadata,
    this.actions,
  });

  factory ReplayModel.fromJson(Map<String, dynamic> json) => ReplayModel(
        version: json["version"],
        solvepadWidth: json["solvepadWidth"]?.toDouble(),
        solvepadHeight: json["solvepadHeight"]?.toDouble(),
        metadata: json["metadata"] == null
            ? null
            : Metadata.fromJson(json["metadata"]),
        actions: json["actions"] == null
            ? []
            : List<Action>.from(
                json["actions"]!.map((x) => Action.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "version": version,
        "solvepadWidth": solvepadWidth,
        "solvepadHeight": solvepadHeight,
        "metadata": metadata?.toJson(),
        "actions": actions == null
            ? []
            : List<dynamic>.from(actions!.map((x) => x.toJson())),
      };
}

class Action {
  num? time;
  String? type;
  num? page;
  double? scrollX;
  num? scrollY;
  num? scale;
  dynamic data;

  Action({
    this.time,
    this.type,
    this.page,
    this.scrollX,
    this.scrollY,
    this.scale,
    this.data,
  });

  factory Action.fromJson(Map<String, dynamic> json) => Action(
        time: json["time"],
        type: json["type"],
        page: json["page"],
        scrollX: json["scrollX"]?.toDouble(),
        scrollY: json["scrollY"],
        scale: json["scale"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "time": time,
        "type": type,
        "page": page,
        "scrollX": scrollX,
        "scrollY": scrollY,
        "scale": scale,
        "data": data,
      };
}

class Datum {
  num? x;
  num? y;
  num? scale;
  num? time;

  Datum({
    this.x,
    this.y,
    this.scale,
    this.time,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        x: json["x"]?.toDouble(),
        y: json["y"]?.toDouble(),
        scale: json["scale"]?.toDouble(),
        time: json["time"],
      );

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
        "scale": scale,
        "time": time,
      };
}

class DataClass {
  String? tool;
  String? color;
  num? strokeWidth;
  List<Datum>? points;

  DataClass({
    this.tool,
    this.color,
    this.strokeWidth,
    this.points,
  });

  factory DataClass.fromJson(Map<String, dynamic> json) => DataClass(
        tool: json["tool"],
        color: json["color"],
        strokeWidth: json["strokeWidth"],
        points: json["points"] == null
            ? []
            : List<Datum>.from(json["points"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "tool": tool,
        "color": color,
        "strokeWidth": strokeWidth,
        "points": points == null
            ? []
            : List<dynamic>.from(points!.map((x) => x.toJson())),
      };
}

class Metadata {
  String? courseId;
  String? tutorId;
  num? duration;

  Metadata({
    this.courseId,
    this.tutorId,
    this.duration,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        courseId: json["courseId"],
        tutorId: json["tutorId"],
        duration: json["duration"],
      );

  Map<String, dynamic> toJson() => {
        "courseId": courseId,
        "tutorId": tutorId,
        "duration": duration,
      };
}
