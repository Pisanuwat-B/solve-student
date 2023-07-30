import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/feature/calendar/constants/constants.dart';
import 'package:solve_student/feature/calendar/controller/create_course_live_controller.dart';
import 'package:solve_student/feature/calendar/controller/student_controller.dart';
import 'package:solve_student/feature/calendar/helper/utility_helper.dart';
import 'package:solve_student/feature/calendar/model/show_course.dart';
import 'package:solve_student/feature/calendar/pages/utils.dart';
import 'package:solve_student/feature/calendar/widgets/format_date.dart';
import 'package:solve_student/feature/calendar/widgets/sizebox.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../authentication/service/auth_provider.dart';

class CourseHistory extends StatefulWidget {
  const CourseHistory({super.key, this.studentId});
  final String? studentId;
  @override
  State<CourseHistory> createState() => _CourseHistoryState();
}

class _CourseHistoryState extends State<CourseHistory>
    with TickerProviderStateMixin {
  static final _util = UtilityHelper();
  TabController? tabController;
  int indexTab = 0;
  var studentController = StudentController();
  var courseController = CourseLiveController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  AuthProvider? authProvider;

  @override
  void initState() {
    super.initState();
    studentController = Provider.of<StudentController>(context, listen: false);
    courseController =
        Provider.of<CourseLiveController>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    getInit();
  }

  getInit() async {
    getCalendarList();
    getTableCalendarList();
    await courseController.getLevels();
    await courseController.getSubjects();
  }

  Future<void> getCalendarList() async {
    await studentController.getCourseToday(authProvider?.user?.id ?? '');
    if (_util.isTablet()) {
      getDateAll();
      getDate(1);
    } else {
      getDate(7);
    }
  }

  Future<void> getTableCalendarList() async {
    await studentController
        .getCalendarListForStudentById(authProvider?.uid ?? '');
    await studentController
        .getDataCalendarList(studentController.calendarClassList);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: CustomColors.whitePrimary,
        elevation: 6,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: Text(
          'ประวัติการเรียนของฉัน',
          style: CustomStyles.bold22Black363636,
        ),
        actions: [
          if (_util.isTablet()) ...[
            _buildButtonSearch(),
            _buildButtonAddCourse()
          ]
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () async {
            // await courseController.getCourseTutorToday(widget.s);
            await Future.delayed(const Duration(seconds: 1));
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  if (_util.isTablet()) ...[
                    listCalendarTablet()
                  ] else ...[
                    listCalendarMobile()
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonAddCourse() {
    return _util.isTablet()
        ? Container(
            margin: const EdgeInsets.all(8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: Text(
                'เพิ่มคอร์สเรียน',
                style: CustomStyles.med14White.copyWith(
                  color: CustomColors.white,
                ),
              ),
              onPressed: () async {},
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.greenPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: const BoxDecoration(
              color: CustomColors.greenPrimary,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          );
  }

  Widget _buildButtonSearch() {
    if (_util.isTablet()) {
      return Container(
        margin: const EdgeInsets.all(8),
        child: ElevatedButton.icon(
          icon: const Icon(
            Icons.search,
            color: CustomColors.gray363636,
          ),
          label: Text(
            'ค้นหาติวเตอร์',
            style: CustomStyles.med14White.copyWith(
              color: CustomColors.gray363636,
            ),
          ),
          onPressed: () async {},
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Text(
          'ค้นหาติวเตอร์',
          style: CustomStyles.bold16Green,
        ),
      );
    }
  }

  var indexListCalendar = 0;

  List<ShowCourseStudent> listCalendarTab = [];
  void getDateAll() {
    studentController.daysForTablet.map((e) => e.sum = 0).toList();
    for (var day in studentController.showCourseStudentToday) {
      studentController.daysForTablet.map((element) {
        if (element.id == day.start?.weekday) {
          element.sum += 1;
        }
      }).toList();
    }
    setState(() {});
  }

  void getDate(int daySelected) {
    listCalendarTab.clear();
    for (var day in studentController.showCourseStudentToday) {
      if (day.start?.weekday == daySelected) {
        listCalendarTab.add(day);
      }
    }
    setState(() {});
  }

  Widget listCalendarMobile() {
    return Column(children: [
      S.h(20),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              courseController.days.length,
              (index) => InkWell(
                onTap: () {
                  indexListCalendar = index;
                  getDate(studentController.days[index].id);
                  setState(() {});
                },
                child: Text(
                  courseController.daysDD[index].day,
                  style: CustomStyles.blod16gray878787.copyWith(
                    color: indexListCalendar != index
                        ? Colors.black
                        : CustomColors.greenPrimary,
                  ),
                ),
              ),
            )),
      ),
      S.h(20),
      if (listCalendarTab.isEmpty) ...[
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Center(
            child: Text(
              'ไม่พบข้อมูล',
              style: CustomStyles.bold12Black363636,
            ),
          ),
        ),
      ],
      Column(
        children: List.generate(listCalendarTab.length, (index) {
          var filterSubjectId = courseController.subjects
              .where((e) => e.id == listCalendarTab[index].subjectId)
              .toList();

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${FormatDate.timeOnlyNumber(listCalendarTab[index].start)} น. - ${FormatDate.timeOnlyNumber(listCalendarTab[index].end)} น.',
                      style: CustomStyles.blod16gray878787
                          .copyWith(color: Colors.black),
                    ),
                    Text(
                      FormatDate.dayOnly(listCalendarTab[index].start),
                      style: CustomStyles.reg16gray878787,
                    )
                  ],
                ),
                S.h(10),
                Row(
                  children: [
                    SizedBox(
                      height: 74,
                      width: 131,
                      child: CachedNetworkImage(
                        width: double.infinity,
                        fit: BoxFit.cover,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        imageUrl: listCalendarTab[index].thumbnailUrl ?? '',
                      ),
                    ),
                    S.w(10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listCalendarTab[index].courseName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CustomStyles.bold16Black363636,
                          ),
                          Text(
                            listCalendarTab[index].detailsText ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: CustomStyles.med14Black363636Overflow,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                S.h(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      listCalendarTab[index].tutorId ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: CustomStyles.reg16Green,
                    ),
                    Row(
                      children: [
                        _tagType(
                            '${filterSubjectId.isNotEmpty ? filterSubjectId.first.name : ''}'),
                        S.w(4.0),
                        // _learned()
                      ],
                    )
                  ],
                )
              ],
            ),
          );
        }),
      )
    ]);
  }

  Widget listCalendarTablet() {
    return DefaultTabController(
      length: 7, // กำหนดจำนวน tab
      child: Column(children: [
        S.h(20),
        TabBar(
          labelColor: CustomColors.greenPrimary,
          labelStyle: CustomStyles.med14Black363636,
          unselectedLabelColor: Colors.grey,
          indicatorColor: CustomColors.greenPrimary,
          labelPadding: const EdgeInsets.symmetric(horizontal: 0),
          onTap: (index) async {
            getDate(studentController.daysForTablet[index].id);
            setState(() {});
          },
          tabs: List.generate(
            studentController.daysForTablet.length,
            (index) => Tab(
              child: Text(
                '${studentController.daysForTablet[index].day} (${studentController.daysForTablet[index].sum})',
                maxLines: 1,
              ),
            ),
          ),
        ),
        S.h(20),
        if (listCalendarTab.isEmpty) ...[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                'ไม่พบข้อมูล',
                style: CustomStyles.bold12Black363636,
              ),
            ),
          ),
        ],
        Column(
          children: List.generate(listCalendarTab.length, (index) {
            var filterLevelId = courseController.levels
                .where((e) => e.id == listCalendarTab[index].levelId)
                .toList();
            var filterSubjectId = courseController.subjects
                .where((e) => e.id == listCalendarTab[index].subjectId)
                .toList();

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _tagTime(
                          '${FormatDate.timeOnlyNumber(listCalendarTab[index].start)} น. - ${FormatDate.timeOnlyNumber(listCalendarTab[index].end)} น.'),
                      S.w(50),
                      SizedBox(
                        height: 48,
                        width: 85,
                        child: listCalendarTab[index]
                                    .thumbnailUrl
                                    .toString()
                                    .isNotEmpty ==
                                true
                            ? CachedNetworkImage(
                                width: double.infinity,
                                fit: BoxFit.cover,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                imageUrl:
                                    listCalendarTab[index].thumbnailUrl ?? '',
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: const Color.fromRGBO(29, 41, 57, 1),
                                    width: 0.5,
                                  ),
                                ),
                                height: 48,
                                width: 85,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    ImageAssets.emptyCourse,
                                    width: double.infinity,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ),
                      ),
                      S.w(10),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listCalendarTab[index].courseName ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: CustomStyles.bold14Black363636,
                            ),
                            Text(
                              listCalendarTab[index].detailsText ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: CustomStyles.med14Black363636Overflow,
                            ),
                          ],
                        ),
                      ),
                      S.w(50),
                      Row(
                        children: [
                          _tagType(
                              '${filterLevelId.isNotEmpty ? filterLevelId.first.name : ''}'),
                          S.w(10),
                          _tagType(
                              '${filterSubjectId.isNotEmpty ? filterSubjectId.first.name : ''}'),
                        ],
                      ),
                    ],
                  ),
                  S.h(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/tutor_icon.png',
                              scale: 4,
                            ),
                            S.w(10),
                            Text(
                              listCalendarTab[index].tutorId ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: CustomStyles.reg16Green,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            FormatDate.dayOnly(listCalendarTab[index].start),
                            style: CustomStyles.bold14Black363636,
                          ),
                          S.w(10),
                          // _learned(),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            );
          }),
        )
      ]),
    );
  }

  Widget _tagTime(String tag) {
    if (tag.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: CustomColors.grayF3F3F3,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        tag,
        style: CustomStyles.med12gray878787.copyWith(color: Colors.black),
      ),
    );
  }

  Widget _tagType(String tag) {
    if (tag.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: CustomColors.grayF3F3F3,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        tag,
        style: CustomStyles.med12gray878787.copyWith(color: Colors.black),
      ),
    );
  }
}
