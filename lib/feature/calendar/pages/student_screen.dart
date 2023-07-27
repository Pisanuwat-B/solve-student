import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/feature/calendar/constants/constants.dart';
import 'package:solve_student/feature/calendar/controller/create_course_live_controller.dart';
import 'package:solve_student/feature/calendar/controller/student_controller.dart';
import 'package:solve_student/feature/calendar/helper/utility_helper.dart';
import 'package:solve_student/feature/calendar/model/show_course.dart';
import 'package:solve_student/feature/calendar/pages/utils.dart';
import 'package:solve_student/feature/calendar/widgets/alert_overlay.dart';
import 'package:solve_student/feature/calendar/widgets/format_date.dart';
import 'package:solve_student/feature/calendar/widgets/sizebox.dart';
import 'package:table_calendar/table_calendar.dart';

class StudentScreen extends StatefulWidget {
  StudentScreen({super.key, this.studentId});
  String? studentId;
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen>
    with TickerProviderStateMixin {
  static final _util = UtilityHelper();
  TabController? tabController;
  int indexTab = 0;
  var studentController = StudentController();
  var courseController = CourseLiveController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  //calendar
  ValueNotifier<List<Event>>? _selectedEvents;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    studentController = Provider.of<StudentController>(context, listen: false);
    courseController =
        Provider.of<CourseLiveController>(context, listen: false);
    // tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    getInit();
  }

  getInit() async {
    getCalendarList();
    getTableCalendarList();
    await courseController.getLevels();
    await courseController.getSubjects();
    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
    //   await Alert.showOverlay(
    //     loadingWidget: Alert.getOverlayScreen(),
    //     asyncFunction: () async {
    //
    //       await studentController.getCourseToday(widget.studentId ?? '');
    //       await studentController
    //           .getCalendarListForStudentById(widget.studentId ?? '');
    //       await studentController
    //           .getDataCalendarList(studentController.calendarClassList);
    //       if (_util.isTablet()) {
    //         getDateAll();
    //         getDate(1);
    //       } else {
    //         getDate(7);
    //       }
    //     },
    //     context: context,
    //   );
    //   setState(() {});
    // });
  }

  Future<void> getCalendarList() async {
    await studentController.getCourseToday(widget.studentId ?? '');
    if (_util.isTablet()) {
      getDateAll();
      getDate(1);
    } else {
      getDate(7);
    }
    // setState(() {});
  }

  Future<void> getTableCalendarList() async {
    await studentController
        .getCalendarListForStudentById(widget.studentId ?? '');
    await studentController
        .getDataCalendarList(studentController.calendarClassList);
    setState(() {});
  }

  List<Event> _getEventsForDay(DateTime day) {
    return studentController.kEvents?[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (_selectedEvents?.value.isNotEmpty == true) {
      setState(() {
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
        _selectedEvents?.value = _getEventsForDay(selectedDay);
      });
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents?.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents?.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents?.value = _getEventsForDay(end);
    }
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
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
          'คอร์สเรียนสดของฉัน',
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
                  _listCalss(),
                  const SizedBox(
                    height: 50,
                  ),
                  _calendar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _listCalss() {
    return SingleChildScrollView(child: Consumer<CourseLiveController>(
      builder: (_, student, child) {
        return student.isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('กำลังโหลด...'),
                  ),
                ],
              )
            : Column(
                children: [
                  if (_util.isTablet() == false) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _historyText(),
                        Expanded(child: Container()),
                        _buildButtonSearch(),
                        S.w(10),
                        _buildButtonAddCourse(),
                      ],
                    )
                  ],
                  // if (studentController
                  //     .showCourseStudentFilterToday.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _topicText('วันนี้'),
                      if (_util.isTablet()) ...[
                        _historyText(),
                      ] else ...[
                        _sellAll(),
                      ]
                    ],
                  ),
                  studentController.isLoadingCourseToday
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text('กำลังโหลด...'),
                            ),
                          ],
                        )
                      : studentController
                              .showCourseStudentFilterToday.isNotEmpty
                          ? SizedBox(
                              height: _util.isTablet() ? 367 : 240,
                              width: double.infinity,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: studentController
                                            .showCourseStudentFilterToday
                                            .length <=
                                        10
                                    ? studentController
                                        .showCourseStudentFilterToday.length
                                    : 10,
                                itemBuilder: (context, index) =>
                                    _util.isTablet()
                                        ? cardTablet(
                                            showCourseStudent: studentController
                                                    .showCourseStudentFilterToday[
                                                index],
                                            onTap: () {},
                                          )
                                        : cardMobile(
                                            showCourseStudent: studentController
                                                    .showCourseStudentFilterToday[
                                                index],
                                            onTap: () {},
                                          ),
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 20),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'ไม่มีการเรียนการสอน',
                                  style: CustomStyles.bold14Gray878787,
                                ),
                              ),
                            ),
                ],
                // ],
              );
      },
    ));
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

  Widget cardTablet(
      {required ShowCourseStudent showCourseStudent, required Function onTap}) {
    var filterLevelId = courseController.levels
        .where((e) => e.id == showCourseStudent.levelId)
        .toList();
    var filterSubjectId = courseController.subjects
        .where((e) => e.id == showCourseStudent.subjectId)
        .toList();
    return InkWell(
      onTap: () => onTap(),
      child: SizedBox(
        height: 367,
        width: 367,
        child: Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(8.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showCourseStudent.thumbnailUrl?.isNotEmpty == true) ...[
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CachedNetworkImage(
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
                            colorFilter: ColorFilter.mode(
                                joinReady(showCourseStudent.start ??
                                        DateTime.now())
                                    ? Colors.black.withOpacity(0.6)
                                    : Colors.transparent,
                                BlendMode.screen),
                          ),
                        ),
                      ),
                      height: 180,
                      imageUrl: showCourseStudent.thumbnailUrl ?? '',
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    if (joinReady(
                        showCourseStudent.start ?? DateTime.now())) ...[
                      const Text(
                        '- ยังไม่ถึงเวลาเข้าเรียน -',
                        style: TextStyle(color: Colors.white),
                      )
                    ]
                  ],
                ),
              ] else ...[
                Image.asset(
                  ImageAssets.emptyCourse,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.fitHeight,
                ),
              ],
              S.h(8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    S.h(8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _tagTime(
                            '${FormatDate.timeOnlyNumber(showCourseStudent.start)} น. - ${FormatDate.timeOnlyNumber(showCourseStudent.end)} น.'),
                        Row(
                          children: [
                            _tagType(
                                '${filterLevelId.isNotEmpty ? filterLevelId.first.name : ''}'),
                            S.w(10),
                            _tagType(
                                '${filterSubjectId.isNotEmpty ? filterSubjectId.first.name : ''}'),
                          ],
                        )
                      ],
                    ),
                    S.h(8),
                    Text(
                      showCourseStudent.courseName ?? '',
                      maxLines: 1,
                      style: CustomStyles.bold16Black363636,
                    ),
                    Text(
                      showCourseStudent.detailsText ?? '',
                      maxLines: 1,
                      style: CustomStyles.med14Black363636Overflow,
                    ),
                    S.h(8),
                    _buttonCard(showCourseStudent),
                  ],
                ),
              ),
              S.h(8),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardMobile(
      {required ShowCourseStudent showCourseStudent, required Function onTap}) {
    var filterLevelId = courseController.levels
        .where((e) => e.id == showCourseStudent.levelId)
        .toList();
    var filterSubjectId = courseController.subjects
        .where((e) => e.id == showCourseStudent.subjectId)
        .toList();
    return InkWell(
      onTap: () => onTap(),
      child: SizedBox(
        height: 230,
        width: 160,
        child: Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(8.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showCourseStudent.thumbnailUrl?.isNotEmpty == true) ...[
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CachedNetworkImage(
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
                            colorFilter: ColorFilter.mode(
                                joinReady(showCourseStudent.start ??
                                        DateTime.now())
                                    ? Colors.black.withOpacity(0.6)
                                    : Colors.transparent,
                                BlendMode.screen),
                          ),
                        ),
                      ),
                      height: 90,
                      imageUrl: showCourseStudent.thumbnailUrl ?? '',
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    if (joinReady(
                        showCourseStudent.start ?? DateTime.now())) ...[
                      Text(
                        '- ยังไม่ถึงเวลาเข้าเรียน -',
                        style: CustomStyles.med14White,
                      )
                    ]
                  ],
                ),
              ] else ...[
                Image.asset(
                  ImageAssets.emptyCourse,
                  height: 90,
                  width: double.infinity,
                  fit: BoxFit.fitHeight,
                ),
              ],
              S.h(8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    S.h(8),
                    Text(
                      showCourseStudent.courseName ?? '',
                      maxLines: 1,
                      style: CustomStyles.bold16Black363636,
                    ),
                    Text(
                      showCourseStudent.detailsText ?? '',
                      maxLines: 1,
                      style: CustomStyles.med14Black363636Overflow,
                    ),
                    S.h(8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _tagTime(
                            '${FormatDate.timeOnlyNumber(showCourseStudent.start)} น. - ${FormatDate.timeOnlyNumber(showCourseStudent.end)} น.'),
                      ],
                    ),
                    S.h(8),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<bool> _isSelected = [true, false];
  Widget _swicth() {
    return ToggleButtons(
      isSelected: _isSelected,
      borderColor: Colors.grey,
      selectedBorderColor: Colors.grey,
      fillColor: CustomColors.greenPrimary.withOpacity(0.2),
      selectedColor: CustomColors.greenPrimary,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      onPressed: (int index) {
        var set = _isSelected.map((e) => e = false).toList();
        _isSelected = set;
        _isSelected[index] = true;
        setState(() {});
      },
      children: (_util.isTablet())
          ? <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month),
                    S.w(10),
                    const Text('Calendar')
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.list),
                    S.w(10),
                    const Text('List')
                  ],
                ),
              )
            ]
          : <Widget>[
              const Icon(Icons.list),
              const Icon(Icons.calendar_month),
            ],
    );
  }

  Widget _calendar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_topicText('ตารางเรียนสอนชองฉัน'), _swicth()],
        ),
        if (_isSelected.last == true) ...[
          if (_util.isTablet()) ...[
            listCalendarTablet()
          ] else ...[
            listCalendarMobile()
          ]
        ],
        if (_isSelected.first == true) ...[
          if (_util.isTablet()) ...[
            tableCalendarTablet(),
          ] else ...[
            tableCalendarMobile(),
          ],
        ],
      ],
    );
  }

  var indexListCalendar = 0;

  List<ShowCourseStudent> listCelendarTab = [];
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
    listCelendarTab.clear();
    for (var day in studentController.showCourseStudentToday) {
      if (day.start?.weekday == daySelected) {
        listCelendarTab.add(day);
      }
    }
    print(studentController.showCourseStudentToday);
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
      if (listCelendarTab.isEmpty) ...[
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
        children: List.generate(listCelendarTab.length, (index) {
          var filterLevelId = courseController.levels
              .where((e) => e.id == listCelendarTab[index].levelId)
              .toList();
          var filterSubjectId = courseController.subjects
              .where((e) => e.id == listCelendarTab[index].subjectId)
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
                      '${FormatDate.timeOnlyNumber(listCelendarTab[index].start)} น. - ${FormatDate.timeOnlyNumber(listCelendarTab[index].end)} น.',
                      style: CustomStyles.blod16gray878787
                          .copyWith(color: Colors.black),
                    ),
                    Text(
                      FormatDate.dayOnly(listCelendarTab[index].start),
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
                        imageUrl: listCelendarTab[index].thumbnailUrl ?? '',
                      ),
                    ),
                    S.w(10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listCelendarTab[index].courseName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CustomStyles.bold16Black363636,
                          ),
                          Text(
                            listCelendarTab[index].detailsText ?? '',
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
                      listCelendarTab[index].tutorId ?? '',
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
            )),
          ),
        ),
        S.h(20),
        if (listCelendarTab.isEmpty) ...[
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
          children: List.generate(listCelendarTab.length, (index) {
            var filterLevelId = courseController.levels
                .where((e) => e.id == listCelendarTab[index].levelId)
                .toList();
            var filterSubjectId = courseController.subjects
                .where((e) => e.id == listCelendarTab[index].subjectId)
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
                          '${FormatDate.timeOnlyNumber(listCelendarTab[index].start)} น. - ${FormatDate.timeOnlyNumber(listCelendarTab[index].end)} น.'),
                      S.w(50),
                      SizedBox(
                        height: 48,
                        width: 85,
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
                          imageUrl: listCelendarTab[index].thumbnailUrl ?? '',
                        ),
                      ),
                      S.w(10),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listCelendarTab[index].courseName ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: CustomStyles.bold14Black363636,
                            ),
                            Text(
                              listCelendarTab[index].detailsText ?? '',
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
                              listCelendarTab[index].tutorId ?? '',
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
                            FormatDate.dayOnly(listCelendarTab[index].start),
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

  Widget tableCalendarTablet() {
    var now = DateTime.now();
    return TableCalendar<Event>(
      availableGestures: AvailableGestures.horizontalSwipe,
      locale: 'en_US',
      firstDay: now,
      lastDay: courseController.kEvents?.isNotEmpty == true
          ? courseController.kEvents?.keys.last ??
              DateTime(now.year, now.month + 1, now.day)
          : DateTime(now.year, now.month + 1, now.day),
      focusedDay: now,
      calendarFormat: _calendarFormat,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      rangeSelectionMode: _rangeSelectionMode,
      eventLoader: _getEventsForDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      daysOfWeekHeight: 56,
      rowHeight: 128.4,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: CustomStyles.med16Black363636,
        weekdayStyle: CustomStyles.med16Black363636,
      ),
      calendarStyle: const CalendarStyle(
        // Use `CalendarStyle` to customize the UI
        outsideDaysVisible: false, cellPadding: EdgeInsets.all(16),
        tableBorder: TableBorder(
            horizontalInside:
                BorderSide(width: 1, color: CustomColors.grayCFCFCF),
            verticalInside:
                BorderSide(width: 1, color: CustomColors.grayCFCFCF),
            left: BorderSide(width: 1, color: CustomColors.grayCFCFCF),
            right: BorderSide(width: 1, color: CustomColors.grayCFCFCF),
            top: BorderSide(width: 1, color: CustomColors.grayCFCFCF),
            bottom: BorderSide(
              width: 1,
            ),
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
      ),
      onDaySelected: _onDaySelected,
      onRangeSelected: _onRangeSelected,
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarBuilders: CalendarBuilders(
        todayBuilder: (context, day, focusedDay) {
          return TextButton(
            onPressed: () {},
            child: Container(
              padding: const EdgeInsets.only(left: 20, top: 20),
              alignment: Alignment.topLeft,
              child: Text(
                day.day.toString(),
                style: CustomStyles.med16Black363636
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
        outsideBuilder: (context, day, event) {
          return Container(
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                color: CustomColors.grayF3F3F3,
              ),
              padding: const EdgeInsets.only(left: 20, top: 20),
              alignment: Alignment.topLeft,
              child: Text(
                day.day.toString(),
                style: CustomStyles.med16Black363636.copyWith(
                    fontWeight: FontWeight.bold,
                    color: CustomColors.gray878787),
              ));
        },
        disabledBuilder: (context, day, focusedDay) {
          return TextButton(
            onPressed: () {},
            child: Container(
              padding: const EdgeInsets.only(left: 20, top: 20),
              alignment: Alignment.topLeft,
              child: Text(
                day.day.toString(),
                style: CustomStyles.med16Black363636
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
        defaultBuilder: (context, day, event) {
          return TextButton(
            onPressed: () {},
            child: Container(
              padding: const EdgeInsets.only(left: 20, top: 20),
              alignment: Alignment.topLeft,
              child: Text(
                day.day.toString(),
                style: CustomStyles.med16Black363636
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
        selectedBuilder: (context, day, focusedDay) {
          // return Container(
          //   padding: const EdgeInsets.only(left: 20, top: 20),
          //   height: 200,
          //   width: 200,
          //   color: CustomColors.green125924,
          //   alignment: Alignment.topLeft,
          // );
        },
        markerBuilder: (context, day, event) {
          if (event.isNotEmpty && day.isAfter(DateTime.now())) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  S.h(0),
                  if (event.isNotEmpty) ...[
                    InkWell(
                      onTap: () async {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 0.0),
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: CustomColors.gray878787,
                              width: 1,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20.0)),
                            shape: BoxShape.rectangle,
                            color: CustomColors.greenPrimary),
                        alignment: Alignment.center,
                        child: Text(
                          event.first.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CustomStyles.med12GreenPrimary
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                  S.h(5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 0.0),
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: CustomColors.gray878787,
                          width: 1,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20.0)),
                        shape: BoxShape.rectangle,
                        color: CustomColors.white),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            await showDialog(
                                context: context,
                                builder: (context) => _eventList(day, event));
                          },
                          child: Text(
                            '+${event.length} รายการ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CustomStyles.med12GreenPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  S.h(5),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Widget tableCalendarMobile() {
    var now = DateTime.now();
    return TableCalendar<Event>(
      availableGestures: AvailableGestures.horizontalSwipe,
      locale: 'en_US',
      firstDay: now,
      lastDay: studentController.kEvents?.keys.last ??
          DateTime(now.year, now.month + 3, now.day),
      focusedDay: now,
      calendarFormat: _calendarFormat,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      calendarStyle: const CalendarStyle(
        // Use `CalendarStyle` to customize the UI
        outsideDaysVisible: false,
        cellPadding: EdgeInsets.all(0),
        tableBorder: TableBorder(
            horizontalInside:
                BorderSide(width: 1, color: CustomColors.grayCFCFCF),
            left: BorderSide(width: 1, color: CustomColors.grayCFCFCF),
            right: BorderSide(width: 1, color: CustomColors.grayCFCFCF),
            top: BorderSide(width: 1, color: CustomColors.grayCFCFCF),
            bottom: BorderSide(width: 1, color: CustomColors.grayCFCFCF),
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
      ),
      daysOfWeekHeight: 50,
      rowHeight: 50,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      rangeSelectionMode: _rangeSelectionMode,
      eventLoader: _getEventsForDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      onDaySelected: _onDaySelected,
      onRangeSelected: _onRangeSelected,
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarBuilders: CalendarBuilders(
        disabledBuilder: (context, day, focusedDay) => SizedBox(
          child: Center(
            child: Text(
              day.day.toString(),
              style: CustomStyles.med16Black363636.copyWith(
                  fontWeight: FontWeight.bold, color: CustomColors.gray878787),
            ),
          ),
        ),
        todayBuilder: (context, day, focusedDay) => SizedBox(
          child: Center(
            child: Text(
              day.day.toString(),
              style: CustomStyles.med16Black363636.copyWith(
                  fontWeight: FontWeight.bold, color: CustomColors.gray878787),
            ),
          ),
        ),
        defaultBuilder: (context, day, focusedDay) => SizedBox(
          child: Center(
            child: Text(
              day.day.toString(),
              style: CustomStyles.med16Black363636.copyWith(
                  fontWeight: FontWeight.normal, color: CustomColors.black),
            ),
          ),
        ),
        markerBuilder: (context, day, event) {
          if (event.isNotEmpty && day.isAfter(DateTime.now())) {
            return InkWell(
              onTap: () async {
                await showDialog(
                    context: context,
                    builder: (context) => _eventList(day, event));
              },
              child: Column(
                children: [
                  if (event.isNotEmpty) ...[
                    Expanded(child: Container()),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            event.length,
                            (index) => Container(
                                  height: 7,
                                  width: 7,
                                  decoration: const BoxDecoration(
                                    color: CustomColors.greenPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                )),
                      ),
                    ),
                  ],
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _eventList(DateTime day, List<Event>? event) {
    event?.sort((a, b) => a.start.compareTo(b.start));
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AlertDialog(
        title: Text(
          'วันที่ ${FormatDate.dayOnly(day)}',
          style: CustomStyles.bold22Black363636,
        ),
        actions: [
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.white,
                shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: CustomColors.grayE5E6E9,
                    ),
                    borderRadius: BorderRadius.circular(10.0)),
              ),
              child: Text(
                "ปิดหน้านี้",
                style: CustomStyles.med14Gray878787,
              ),
            ),
          )
        ],
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (event?.isEmpty == true) ...[
                    const Center(
                      child: SizedBox(
                        child: Text('ไม่พบตารางเรียน'),
                      ),
                    )
                  ],
                  S.h(10),
                  for (Event i in event ?? [] as List<Event>) ...[
                    Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.check_circle_outlined,
                            color: CustomColors.greenPrimary,
                            size: 40,
                          ),
                          title: Text(
                            i.courseName,
                            style: CustomStyles.blod16gray878787,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            i.title,
                            overflow: TextOverflow.ellipsis,
                            style: CustomStyles.blod16gray878787,
                          ),
                          // trailing: i.courseId ==
                          //         studentController.courseData?.id
                          //     ? TextButton(
                          //         onPressed: () async {
                          //           var result2 = courseController
                          //               .courseData?.calendars
                          //               ?.where((element) =>
                          //                   element.courseId ==
                          //                       courseController
                          //                           .courseData?.id &&
                          //                   element.start?.compareTo(i.start) ==
                          //                       0 &&
                          //                   element.end?.compareTo(i.end) == 0)
                          //               .toList();
                          //           if (result2?.isNotEmpty == true) {
                          //             for (var i in result2 ?? []) {
                          //               courseController.courseData?.calendars
                          //                   ?.remove(i);
                          //               courseController.calendarListAll
                          //                   .remove(i);
                          //             }
                          //             event?.remove(i);
                          //             setState(() {});
                          //           }
                          //         },
                          //         child: Text(
                          //           'ลบ',
                          //           textAlign: TextAlign.center,
                          //           style: CustomStyles.blod16gray878787
                          //               .copyWith(color: Colors.red),
                          //         ),
                          //       )
                          //     : const SizedBox()
                        ),
                      ),
                    )
                  ],
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  bool joinReady(DateTime start) {
    return DateTime.now().isBefore(start);
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

  Widget _learned() {
    // if (tag.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: CustomColors.orangeFFE0B2,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        'เรียนแล้ว: 5 / 50',
        style: CustomStyles.med12gray878787.copyWith(
          color: CustomColors.orangeCC6700,
        ),
      ),
    );
  }

  Widget _topicText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: CustomStyles.bold22Black363636,
        ),
      ),
    );
  }

  Widget _historyText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.history,
          color: CustomColors.greenPrimary,
        ),
        Text(
          'ประวัติการเรียน',
          style:
              CustomStyles.bold16Green.copyWith(fontWeight: FontWeight.normal),
        ),
      ],
    );
  }

  Widget _sellAll() {
    return Text('ดูเพิ่มเติม', style: CustomStyles.bold16Green);
  }

  Widget _buttonCard(ShowCourseStudent showCourseStudent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/student_view.png',
          scale: 4,
        ),
        S.w(5),
        Text(
          // '${showCourseTutor.subjectId?.length ?? 0}',
          '${0}',
          style: CustomStyles.med12gray878787,
        ),
      ],
    );
  }
}
