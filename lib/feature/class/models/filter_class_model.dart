class FilterClassModel {
  FilterClassModel(
      {required this.schoolSubject,
      required this.classLevel,
      required this.startDate,
      required this.startTime});
  String schoolSubject;
  String classLevel;
  String startDate;
  String startTime;

  Map<String, dynamic> toJson() => {
        "schoolSubject": schoolSubject,
        "classLevel": classLevel,
        "startDate": startDate,
        "startTime": startTime,
      };
}
