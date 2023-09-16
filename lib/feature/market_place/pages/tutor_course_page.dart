import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/models/user_model.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/feature/calendar/constants/assets_manager.dart';
import 'package:solve_student/feature/market_place/model/course_live_model.dart';
import 'package:solve_student/feature/market_place/model/course_market_model.dart';
import 'package:solve_student/feature/market_place/pages/market_course_detail_page.dart';
import 'package:solve_student/feature/market_place/service/tutor_course_controller.dart';

class TutorCoursePage extends StatefulWidget {
  TutorCoursePage(this.tutor, {super.key});
  UserModel tutor;
  @override
  State<TutorCoursePage> createState() => _TutorCoursePageState();
}

class _TutorCoursePageState extends State<TutorCoursePage> {
  TutorCourseController? controller;

  @override
  void initState() {
    controller = TutorCourseController(context, tutor: widget.tutor);
    controller!.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<TutorCourseController>(builder: (context, con, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: Text(
              "เกี่ยวกับติวเตอร์ ",
              style: TextStyle(
                color: appTextPrimaryColor,
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.keyboard_arrow_left,
                color: Colors.black,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          body: Container(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Builder(builder: (context) {
                            if (con.tutor.image?.isEmpty ?? false) {
                              return FittedBox(
                                child: Image.asset(
                                  "assets/images/image35.png",
                                ),
                              );
                            }
                            return Image.network(
                              con.tutor.image ?? "",
                              errorBuilder: (context, error, stackTrace) {
                                return FittedBox(
                                  child: Image.asset(
                                    "assets/images/image35.png",
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              con.tutor.name ?? "",
                              style: TextStyle(
                                color: appTextPrimaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              con.tutor.about ?? "",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              "100 คะแนน",
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "คอร์สทั้งหมด",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder(
                      future: con.getCourseList(),
                      builder: (context, snapshot) {
                        try {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                CourseMarketModel only = snapshot.data![index];
                                return GestureDetector(
                                  onTap: () {
                                    var route = MaterialPageRoute(
                                        builder: (context) =>
                                            MarketCourseDetailPage(
                                                courseId: only.id ?? ""));
                                    Navigator.push(context, route);
                                  },
                                  child: Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    alignment: Alignment.center,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.grey.shade50,
                                            ),
                                            height: 150,
                                            width: 200,
                                            child: Image.network(
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
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "${only.courseName ?? ""} ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "${only.detailsText ?? ""}",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              tutorWidget(con),
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
                            );
                          }
                          return Text("nodata");
                        } catch (e) {
                          return Text("error");
                        }
                      })
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget subjectWidget(TutorCourseController con, CourseMarketModel only) {
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

  Widget levelWidget(TutorCourseController con, CourseMarketModel only) {
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

  Widget tutorWidget(TutorCourseController con) {
    return Container(
      child: Text(
        con.tutor.name ?? "",
        style: const TextStyle(
          fontSize: 14,
          color: primaryColor,
        ),
      ),
    );
  }
}
