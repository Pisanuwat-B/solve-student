import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/feature/calendar/constants/constants.dart';
import 'package:solve_student/feature/calendar/controller/create_course_live_controller.dart';
import 'package:solve_student/feature/calendar/controller/student_controller.dart';
import 'package:solve_student/feature/calendar/helper/utility_helper.dart';
import 'package:solve_student/feature/calendar/model/show_course.dart';
import 'package:solve_student/feature/calendar/widgets/format_date.dart';
import 'package:solve_student/feature/calendar/widgets/sizebox.dart';

import '../../../authentication/service/auth_provider.dart';
import '../../live_classroom/page/review_lesson.dart';

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
  List<ShowCourseStudent> reviewList = [];
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
  }

  Future<List<ShowCourseStudent>> getCoursesWithReviewFile(
      String studentId) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('course_live')
        .where('student_list', arrayContains: studentId)
        .get();

    List<ShowCourseStudent> showCourseStudents = [];

    for (final document in querySnapshot.docs) {
      List<dynamic> calendar = document.get('calendar') as List<dynamic>;
      final studentsWithReviewFile = calendar
          .where((item) =>
              (item as Map<String, dynamic>).containsKey('review_file'))
          .map((item) =>
              ShowCourseStudent.fromJson(item as Map<String, dynamic>))
          .toList();
      showCourseStudents.addAll(studentsWithReviewFile);
    }
    return showCourseStudents;
  }

  Future<void> getCalendarList() async {
    var courseList = await getCoursesWithReviewFile(authProvider!.user!.id!);
    setState(() {
      studentController.showCourseStudentFilterToday = courseList;
    });
    if (_util.isTablet()) {
      getDateAll();
      getDate(1);
    } else {
      getDate(7);
    }
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

  var indexListCalendar = 0;

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
    reviewList.clear();
    for (var day in studentController.showCourseStudentToday) {
      if (day.start?.weekday == daySelected) {
        reviewList.add(day);
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
      if (reviewList.isEmpty) ...[
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
        children: List.generate(reviewList.length, (index) {
          var filterSubjectId = courseController.subjects
              .where((e) => e.id == reviewList[index].subjectId)
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
                      '${FormatDate.timeOnlyNumber(reviewList[index].start)} น. - ${FormatDate.timeOnlyNumber(reviewList[index].end)} น.',
                      style: CustomStyles.blod16gray878787
                          .copyWith(color: Colors.black),
                    ),
                    Text(
                      FormatDate.dayOnly(reviewList[index].start),
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
                        imageUrl: reviewList[index].thumbnailUrl ?? '',
                      ),
                    ),
                    S.w(10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reviewList[index].courseName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CustomStyles.bold16Black363636,
                          ),
                          Text(
                            reviewList[index].detailsText ?? '',
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
                      reviewList[index].tutorId ?? '',
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
        if (reviewList.isEmpty) ...[
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
          children: List.generate(reviewList.length, (index) {
            var filterLevelId = courseController.levels
                .where((e) => e.id == reviewList[index].levelId)
                .toList();
            var filterSubjectId = courseController.subjects
                .where((e) => e.id == reviewList[index].subjectId)
                .toList();

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewLesson(
                      courseId: reviewList[index].courseId!,
                      courseName: reviewList[index].courseName!,
                      file: reviewList[index].file!,
                      tutorId: reviewList[index].tutorId!,
                      docId: reviewList[index].documentId!,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                            '${FormatDate.timeOnlyNumber(reviewList[index].start)} น. - ${FormatDate.timeOnlyNumber(reviewList[index].end)} น.'),
                        S.w(50),
                        SizedBox(
                          height: 48,
                          width: 85,
                          child: reviewList[index]
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
                                      reviewList[index].thumbnailUrl ?? '',
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                      color:
                                          const Color.fromRGBO(29, 41, 57, 1),
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
                                reviewList[index].courseName ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: CustomStyles.bold14Black363636,
                              ),
                              Text(
                                reviewList[index].detailsText ?? '',
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
                                reviewList[index].tutorId ?? '',
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
                              FormatDate.dayOnly(reviewList[index].start),
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
