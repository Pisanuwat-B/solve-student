import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:solve_student/feature/calendar/model/course_model.dart';
import 'package:solve_student/feature/calendar/model/show_course.dart';
import 'package:solve_student/feature/calendar/pages/utils.dart';
import 'package:solve_student/feature/calendar/service/student_service.dart';
import 'package:solve_student/feature/calendar/widgets/format_date.dart';
import 'package:table_calendar/table_calendar.dart';

import '../model/days.dart';

class StudentController with ChangeNotifier {
  var isLoading = false;
  var isLoadingCourseToday = false;
  List<CalendarDate> calendarClassList = [];
  List<ShowCourseStudent> showCourseStudentFilterToday = [];
  List<ShowCourseStudent> showCourseStudentToday = [];
  List<ShowCourseStudent> showCourseStudentPast = [];
  Map<DateTime, List<Event>>? kEventSource;
  LinkedHashMap<DateTime, List<Event>>? kEvents;
  List<Days> days = [
    Days(id: 7, day: 'อา'),
    Days(id: 1, day: 'จ'),
    Days(id: 2, day: 'อ'),
    Days(id: 3, day: 'พ'),
    Days(id: 4, day: 'พฤ'),
    Days(id: 5, day: 'ศ'),
    Days(id: 6, day: 'ส'),
  ];
  List<Days> daysForTablet = [
    Days(id: 1, day: 'จันทร์'),
    Days(id: 2, day: 'อังคาร'),
    Days(id: 3, day: 'พุธ'),
    Days(id: 4, day: 'พฤหัสบดี'),
    Days(id: 5, day: 'ศุกร์'),
    Days(id: 6, day: 'เสาร์'),
    Days(id: 7, day: 'อาทิตย์'),
  ];

  getDataCalendarList(List<CalendarDate> list) {
    List<CalendarDate> dateNotRepeat = [];

    var date = dateNotRepeat.map((element) => DateTime(
          element.start?.year ?? 0,
          element.start?.month ?? 0,
          element.start?.day ?? 0,
        ));

    for (var i in list) {
      if (date.contains(DateTime(
        i.start?.year ?? 0,
        i.start?.month ?? 0,
        i.start?.day ?? 0,
      ))) {
      } else {
        dateNotRepeat.add(i);
      }
    }
    List<CalendarDate> df(item) => list
        .where((element) =>
            DateTime(
              element.start?.year ?? 0,
              element.start?.month ?? 0,
              element.start?.day ?? 0,
            ).compareTo(DateTime(
              dateNotRepeat[item].start?.year ?? 0,
              dateNotRepeat[item].start?.month ?? 0,
              dateNotRepeat[item].start?.day ?? 0,
            )) ==
            0)
        .toList();
    kEventSource = {
      for (var item in List.generate(dateNotRepeat.length, (index) => index))
        DateTime.utc(
          dateNotRepeat[item].start?.year ?? 0,
          dateNotRepeat[item].start?.month ?? 0,
          dateNotRepeat[item].start?.day ?? 0,
        ): List.generate(
          df(item).length,
          (index) => Event(
              title:
                  '${FormatDate.timeOnlyNumber(df(item)[index].start)} - ${FormatDate.timeOnlyNumber(df(item)[index].end)}',
              start: df(item)[index].start ?? DateTime.now(),
              end: df(item)[index].end ?? DateTime.now(),
              courseId: df(item)[index].courseId ?? '',
              courseName: df(item)[index].courseName ?? ''),
        )
    };

    kEvents = LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(kEventSource ?? {});
  }

  Future<void> getCalendarListForStudentById(String studentId) async {
    try {
      calendarClassList =
          await StudentService().getCalendarListForStudentById(studentId);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getCourseToday(String studentId) async {
    try {
      var now = DateTime.now();
      var today = DateTime(now.year, now.month, now.day);
      isLoadingCourseToday = true;
      showCourseStudentToday = await StudentService().getCourseToday(studentId);
      showCourseStudentFilterToday = showCourseStudentToday.where((element) {
        final aDate = DateTime(element.start?.year ?? 0,
            element.start?.month ?? 0, element.start?.day ?? 0);
        if (aDate == today) {
          return true;
        } else {
          return false;
        }
      }).toList();
      isLoadingCourseToday = false;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getCoursePast(String studentId) async {
    try {
      isLoading = true;
      showCourseStudentPast = await StudentService().getCoursePast(studentId);
      isLoading = false;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> refreshCourseListByStudentId(String studentId) async {
    var now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);
    isLoading = true;
    notifyListeners();
    showCourseStudentToday = await StudentService().getCourseToday(studentId);
    showCourseStudentFilterToday = showCourseStudentToday.where((element) {
      final aDate = DateTime(element.start?.year ?? 0,
          element.start?.month ?? 0, element.start?.day ?? 0);
      if (aDate == today) {
        return true;
      } else {
        return false;
      }
    }).toList();
    showCourseStudentPast = await StudentService().getCoursePast(studentId);
    isLoading = false;
    notifyListeners();
  }
}
