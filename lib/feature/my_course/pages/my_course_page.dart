import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/feature/calendar/constants/assets_manager.dart';
import 'package:solve_student/feature/market_place/model/course_live_model.dart';
import 'package:solve_student/feature/market_place/model/course_market_model.dart';
import 'package:solve_student/feature/my_course/controller/my_course_controller.dart';
import 'package:solve_student/feature/my_course/pages/my_course_detail_page.dart';

class MyCoursePage extends StatefulWidget {
  const MyCoursePage({super.key});

  @override
  State<MyCoursePage> createState() => _MyCoursePageState();
}

class _MyCoursePageState extends State<MyCoursePage> {
  MyCourseController? controller;

  @override
  void initState() {
    controller = MyCourseController(context);
    controller!.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<MyCourseController>(builder: (context, con, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: Text(
              "คอร์สของฉัน ",
              style: TextStyle(
                color: appTextPrimaryColor,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          body: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: con.myCourseList.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      CourseMarketModel only = con.myCourseList[index];
                      return GestureDetector(
                        onTap: () {
                          var route = MaterialPageRoute(
                              builder: (context) =>
                                  MyCourseDetailPage(courseId: only.id ?? ""));
                          Navigator.push(context, route);
                        },
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          alignment: Alignment.center,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey.shade50,
                                  ),
                                  height: 150,
                                  width: 200,
                                  child: Builder(builder: (context) {
                                    if (only.thumbnailUrl == null ||
                                        only.thumbnailUrl == "") {
                                      return Image.asset(
                                        ImageAssets.emptyCourse,
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.fitHeight,
                                      );
                                    }
                                    return Image.network(
                                      only.thumbnailUrl ?? "",
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          ImageAssets.emptyCourse,
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.fitHeight,
                                        );
                                      },
                                    );
                                  }),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${only.courseName ?? ""} ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                    ),
                                    Text(
                                      "${only.detailsText ?? ""}",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    tutorWidget(con, only),
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.account_circle,
                                          color: Colors.grey,
                                        ),
                                        VerticalDivider(),
                                        Icon(
                                          Icons.star,
                                          color: Colors.orange,
                                        ),
                                        Text(
                                          "5",
                                          style: TextStyle(
                                            color: Colors.orange,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Text("(0)"),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        subjectWidget(con, only),
                                        levelWidget(con, only),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget subjectWidget(MyCourseController con, CourseMarketModel only) {
    return FutureBuilder(
      future: con.getSubjectInfo(only.subjectId ?? ""),
      builder: (context, snap) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: Text(
            snap.data ?? "",
            style: TextStyle(
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  Widget levelWidget(MyCourseController con, CourseMarketModel only) {
    return FutureBuilder(
      future: con.getLevelInfo(only.levelId ?? ""),
      builder: (context, snap) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: Text(
            snap.data ?? "",
            style: TextStyle(
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  Widget tutorWidget(MyCourseController con, CourseMarketModel only) {
    return FutureBuilder(
      future: con.getTutorInfo(only.tutorId ?? ""),
      builder: (context, snap) {
        return Container(
          child: Text(
            snap.data?.name ?? "",
            style: const TextStyle(
              fontSize: 14,
              color: primaryColor,
            ),
          ),
        );
      },
    );
  }
}
