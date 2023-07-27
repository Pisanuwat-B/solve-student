// import 'dart:collection';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:solve_student/feature/calendar/constants/constants.dart';
// import 'package:solve_student/feature/calendar/controller/student_controller.dart';
// import 'package:solve_student/feature/calendar/model/course_model.dart';
// import 'package:solve_student/feature/calendar/pages/utils.dart';
// import 'package:solve_student/feature/calendar/widgets/alert_overlay.dart';
// import 'package:solve_student/feature/calendar/widgets/format_date.dart';
// import 'package:solve_student/feature/calendar/widgets/sizebox.dart';
// import 'package:table_calendar/table_calendar.dart';

// class StudentCalendar extends StatefulWidget {
//   StudentCalendar({
//     Key? key,
//     // required this.courseModel,
//     required this.studentId,
//   }) : super(key: key);
//   // CourseModel courseModel;
//   String studentId;
//   @override
//   _StudentCalendarState createState() => _StudentCalendarState();
// }

// class _StudentCalendarState extends State<StudentCalendar> {
//   late final ValueNotifier<List<Event>> _selectedEvents;
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
//       .toggledOff; // Can be toggled on/off by longpressing a date
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   CourseModel? courseModel;
//   var studentController = StudentController();
//   DateTime? startTime;
//   DateTime? endTime;
//   List<DateTime> dateList = [];

//   @override
//   void initState() {
//     super.initState();
//     studentController = Provider.of<StudentController>(context, listen: false);
//     getCalendar();
//   }

//   void getCalendar() async {
//     _selectedDay = _focusedDay;
//     _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
//     SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
//       await Alert.showOverlay(
//         loadingWidget: Alert.getOverlayScreen(),
//         asyncFunction: () async {
//           await studentController
//               .getCalendarListForStudentById(widget.studentId);
//           await studentController
//               .getDataCalendarList(studentController.calendarClassList);
//         },
//         context: context,
//       );
//       setState(() {});
//       print(studentController.calendarClassList);
//     });
//   }

//   @override
//   void dispose() {
//     _selectedEvents.dispose();
//     studentController.calendarClassList.clear();
//     super.dispose();
//   }

//   List<Event> _getEventsForDay(DateTime day) {
//     return studentController.kEvents?[day] ?? [];
//   }

//   List<Event> _getEventsForRange(DateTime start, DateTime end) {
//     // Implementation example
//     final days = daysInRange(start, end);

//     return [
//       for (final d in days) ..._getEventsForDay(d),
//     ];
//   }

//   void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
//     _selectedEvents.value = _getEventsForDay(selectedDay);
//     if (_selectedEvents.value.isNotEmpty) {
//       // setState(() {
//       _selectedDay = selectedDay;
//       _focusedDay = focusedDay;
//       _rangeSelectionMode = RangeSelectionMode.toggledOff;
//       // });
//     }
//   }

//   void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
//     setState(() {
//       _selectedDay = null;
//       _focusedDay = focusedDay;

//       _rangeSelectionMode = RangeSelectionMode.toggledOn;
//     });

//     // `start` or `end` could be null
//     if (start != null && end != null) {
//       _selectedEvents.value = _getEventsForRange(start, end);
//     } else if (start != null) {
//       _selectedEvents.value = _getEventsForDay(start);
//     } else if (end != null) {
//       _selectedEvents.value = _getEventsForDay(end);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Text(courseController.calendarClassList.toString()),
//               // Text(widget.courseModel.calendars.toString()),
//               S.h(20),

//               _calendar()
//             ],
//             // ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _calendar() {
//     var now = DateTime.now();
//     return TableCalendar<Event>(
//       availableGestures: AvailableGestures.horizontalSwipe,
//       locale: 'en_US',
//       firstDay: now,
//       lastDay: now.add(const Duration(days: 60)),
//       focusedDay: now,
//       // selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//       // rangeStartDay: _rangeStart,
//       // rangeEndDay: _rangeEnd,
//       calendarFormat: _calendarFormat,
//       availableCalendarFormats: const {
//         CalendarFormat.month: 'Month',
//       },
//       rangeSelectionMode: _rangeSelectionMode,
//       eventLoader: _getEventsForDay,
//       startingDayOfWeek: StartingDayOfWeek.monday,
//       daysOfWeekHeight: 56,
//       rowHeight: 128.4,
//       daysOfWeekStyle: DaysOfWeekStyle(
//         weekendStyle: CustomStyles.med16Black363636,
//         weekdayStyle: CustomStyles.med16Black363636,
//       ),
//       calendarStyle: const CalendarStyle(
//         // Use `CalendarStyle` to customize the UI
//         outsideDaysVisible: true,
//         tableBorder: TableBorder(
//             horizontalInside:
//                 BorderSide(width: 1, color: CustomColors.grayCFCFCF),
//             verticalInside:
//                 BorderSide(width: 1, color: CustomColors.grayCFCFCF),
//             left: BorderSide(width: 1, color: CustomColors.grayCFCFCF),
//             right: BorderSide(width: 1, color: CustomColors.grayCFCFCF),
//             top: BorderSide(width: 1, color: CustomColors.grayCFCFCF),
//             bottom: BorderSide(
//               width: 1,
//             ),
//             borderRadius: BorderRadius.all(Radius.circular(8.0))),
//       ),
//       onDaySelected: _onDaySelected,
//       onRangeSelected: _onRangeSelected,
//       onFormatChanged: (format) {
//         if (_calendarFormat != format) {
//           setState(() {
//             _calendarFormat = format;
//           });
//         }
//       },
//       onPageChanged: (focusedDay) {
//         _focusedDay = focusedDay;
//       },
//       calendarBuilders: CalendarBuilders(
//         todayBuilder: (context, day, focusedDay) {
//           return TextButton(
//             onPressed: () {},
//             child: Container(
//               padding: const EdgeInsets.only(left: 20, top: 20),
//               alignment: Alignment.topLeft,
//               child: Text(
//                 day.day.toString(),
//                 style: CustomStyles.med16Black363636
//                     .copyWith(fontWeight: FontWeight.bold),
//               ),
//             ),
//           );
//         },
//         outsideBuilder: (context, day, event) {
//           return Container(
//               decoration: const BoxDecoration(
//                 shape: BoxShape.rectangle,
//                 color: CustomColors.grayF3F3F3,
//               ),
//               padding: const EdgeInsets.only(left: 20, top: 20),
//               alignment: Alignment.topCenter,
//               child: Text(
//                 day.day.toString(),
//                 style: CustomStyles.med16Black363636.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: CustomColors.gray878787),
//               ));
//         },
//         disabledBuilder: (context, day, focusedDay) {
//           return Container(
//               decoration: const BoxDecoration(
//                   shape: BoxShape.rectangle, color: CustomColors.grayF3F3F3),
//               padding: const EdgeInsets.only(left: 20, top: 20),
//               alignment: Alignment.topLeft,
//               child: Text(
//                 day.day.toString(),
//                 style: CustomStyles.med16Black363636.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: CustomColors.gray878787),
//               ));
//         },
//         defaultBuilder: (context, day, event) {
//           return TextButton(
//             onPressed: () {},
//             child: Container(
//               padding: const EdgeInsets.only(left: 20, top: 20),
//               alignment: Alignment.topLeft,
//               child: Text(
//                 day.day.toString(),
//                 style: CustomStyles.med16Black363636
//                     .copyWith(fontWeight: FontWeight.bold),
//               ),
//             ),
//           );
//         },
//         selectedBuilder: (context, day, focusedDay) {
//           return Container(
//             padding: const EdgeInsets.only(left: 20, top: 20),
//             height: 200,
//             width: 200,
//             color: CustomColors.green125924,
//             alignment: Alignment.topLeft,
//           );
//         },
//         markerBuilder: (context, day, event) {
//           if (event.isNotEmpty && day.isAfter(DateTime.now())) {
//             return SingleChildScrollView(
//               child: Column(
//                 children: [
//                   S.h(0),
//                   if (event.isNotEmpty) ...[
//                     InkWell(
//                       onTap: () async {},
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 5.0, vertical: 0.0),
//                         margin: const EdgeInsets.symmetric(horizontal: 8.0),
//                         decoration: BoxDecoration(
//                             border: Border.all(
//                               color: CustomColors.gray878787,
//                               width: 1,
//                             ),
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(20.0)),
//                             shape: BoxShape.rectangle,
//                             color: CustomColors.greenPrimary),
//                         alignment: Alignment.center,
//                         child: Text(
//                           event.first.title,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: CustomStyles.med12GreenPrimary
//                               .copyWith(color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ],
//                   S.h(5),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 5.0, vertical: 0.0),
//                     margin: const EdgeInsets.symmetric(horizontal: 8.0),
//                     decoration: BoxDecoration(
//                         border: Border.all(
//                           color: CustomColors.gray878787,
//                           width: 1,
//                         ),
//                         borderRadius:
//                             const BorderRadius.all(Radius.circular(20.0)),
//                         shape: BoxShape.rectangle,
//                         color: CustomColors.white),
//                     alignment: Alignment.center,
//                     child: Column(
//                       children: [
//                         InkWell(
//                           onTap: () async {
//                             await showDialog(
//                                 context: context,
//                                 builder: (context) => _eventList(day, event));
//                           },
//                           child: Text(
//                             '+${event.length} รายการ',
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: CustomStyles.med12GreenPrimary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   S.h(5),
//                 ],
//               ),
//             );
//           } else {
//             return const SizedBox();
//           }
//         },
//       ),
//     );
//   }

//   Widget _eventList(DateTime day, List<Event>? event) {
//     event?.sort((a, b) => a.start.compareTo(b.start));
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: AlertDialog(
//         title: Text(
//           'ช่วงเวลาวันนี ${FormatDate.dayOnly(day)}',
//           style: CustomStyles.bold22Black363636,
//         ),
//         actions: [
//           Align(
//             alignment: Alignment.center,
//             child: ElevatedButton(
//               onPressed: () async {
//                 Navigator.of(context).pop();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: CustomColors.white,
//                 shape: RoundedRectangleBorder(
//                     side: const BorderSide(
//                       color: CustomColors.grayE5E6E9,
//                     ),
//                     borderRadius: BorderRadius.circular(10.0)),
//               ),
//               child: Text(
//                 "ปิดหน้านี้",
//                 style: CustomStyles.med14Gray878787,
//               ),
//             ),
//           )
//         ],
//         content: StatefulBuilder(
//             builder: (BuildContext context, StateSetter setState) {
//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 if (event?.isEmpty == true) ...[
//                   const Center(
//                     child: SizedBox(
//                       child: Text('ไม่พบตารางเรียน'),
//                     ),
//                   )
//                 ],
//                 S.h(10),
//                 for (Event i in event ?? [] as List<Event>) ...[
//                   Card(
//                     elevation: 5,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: ListTile(
//                         dense: true,
//                         leading: const Icon(
//                           Icons.check_circle_outlined,
//                           color: CustomColors.greenPrimary,
//                           size: 40,
//                         ),
//                         title: Text(
//                           i.courseName,
//                           style: CustomStyles.blod16gray878787,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         subtitle: Text(
//                           i.title,
//                           overflow: TextOverflow.ellipsis,
//                           style: CustomStyles.blod16gray878787,
//                         ),
//                       ),
//                     ),
//                   )
//                 ],
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
