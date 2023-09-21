import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/feature/calendar/constants/assets_manager.dart';
import 'package:solve_student/feature/calendar/widgets/format_date.dart';
import 'package:solve_student/feature/chat/models/chat_model.dart';
import 'package:solve_student/feature/chat/pages/chat_room_page.dart';
import 'package:solve_student/feature/market_place/pages/tutor_course_page.dart';
import 'package:solve_student/feature/market_place/model/course_market_model.dart';
import 'package:solve_student/feature/market_place/model/lesson_market_model.dart';
import 'package:solve_student/feature/market_place/service/market_course_detail_controller.dart';
import 'package:solve_student/feature/my_course/model/review_model.dart';
import 'package:solve_student/feature/order/model/order_class_model.dart';
import 'package:solve_student/widgets/sizer.dart';

class MarketCourseDetailPage extends StatefulWidget {
  MarketCourseDetailPage({super.key, required this.courseId});
  String courseId;
  @override
  State<MarketCourseDetailPage> createState() => _MarketCourseDetailPageState();
}

class _MarketCourseDetailPageState extends State<MarketCourseDetailPage> {
  MarketCourseDetailController? courseDetailProvider;

  @override
  void initState() {
    courseDetailProvider =
        MarketCourseDetailController(context, widget.courseId);
    courseDetailProvider!.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: courseDetailProvider,
      child: Consumer<MarketCourseDetailController>(builder: (context, con, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              "รายละเอียดคอร์ส ",
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
            width: Sizer(context).w,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: Sizer(context).w,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                    ),
                    child: ClipRRect(
                      child: Builder(builder: (context) {
                        if (con.courseDetail?.thumbnailUrl == null ||
                            con.courseDetail?.thumbnailUrl == "") {
                          return const Center(
                            child: Icon(
                              Icons.image,
                              size: 100,
                              color: Colors.grey,
                            ),
                          );
                        }
                        return Image.network(
                          con.courseDetail?.thumbnailUrl ?? "",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    con.courseDetail?.courseName ?? "",
                                    // "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
                                    style: TextStyle(
                                      color: appTextPrimaryColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    con.courseDetail?.recommendText ?? "",
                                    // "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
                                    style: TextStyle(
                                      color: appTextPrimaryColor,
                                      fontSize: 18,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        margin: const EdgeInsets.fromLTRB(
                                            5, 0, 5, 0),
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 0, 5, 0),
                                        child: Text(
                                          con.subject,
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        margin: const EdgeInsets.fromLTRB(
                                            5, 0, 5, 0),
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 0, 5, 0),
                                        child: Text(
                                          con.level,
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                // OrderClassModel orderNew =
                                //     await order.createOrder(widget.classDetail);
                                // //-----
                                // ChatModel? data =
                                //     await order.createChat(orderNew, widget.user);
                                // var route = MaterialPageRoute(
                                //   builder: (_) => ChatRoomPage(
                                //     chat: data!,
                                //     order: orderNew,
                                //   ),
                                // );
                                // Navigator.push(context, route);
                              },
                              child: Container(
                                width: Sizer(context).w * 0.3,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: greyColor2,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Wrap(
                                  spacing: 2,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "10,000 บาท",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                        Container(
                                          width: 100,
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 0, 5, 0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            border:
                                                Border.all(color: primaryColor),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.list,
                                                color: primaryColor,
                                              ),
                                              SizedBox(width: 5),
                                              const Text(
                                                "แบ่งชำระ",
                                                style: TextStyle(
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Row(
                                    //   children: [
                                    //     Expanded(
                                    //       child: Text(
                                    //         "10,000 บาท",
                                    //         style: TextStyle(
                                    //           fontSize: 20,
                                    //           fontWeight: FontWeight.bold,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //     Container(
                                    //       padding:
                                    //           const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    //       decoration: BoxDecoration(
                                    //         color: Colors.white,
                                    //         borderRadius: BorderRadius.circular(50),
                                    //         border: Border.all(color: primaryColor),
                                    //       ),
                                    //       child: Row(
                                    //         mainAxisAlignment:
                                    //             MainAxisAlignment.center,
                                    //         children: [
                                    //           Icon(
                                    //             Icons.list,
                                    //             color: primaryColor,
                                    //           ),
                                    //           SizedBox(width: 5),
                                    //           const Text(
                                    //             "แบ่งชำระ",
                                    //             style: TextStyle(
                                    //               color: primaryColor,
                                    //             ),
                                    //           ),
                                    //         ],
                                    //       ),
                                    //     )
                                    //   ],
                                    // ),
                                    const SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: () async {
                                        if (!con.isLoading) {
                                          OrderClassModel orderNew =
                                              await con.createMarketOrder(
                                            widget.courseId,
                                            con.courseDetail?.courseName ?? "",
                                            con.courseDetail?.detailsText ?? "",
                                            con.courseDetail?.createUser ?? "",
                                          );
                                          ChatModel? data =
                                              await con.createMarketChat(
                                            widget.courseId,
                                            con.courseDetail?.createUser ?? "",
                                          );
                                          var route = MaterialPageRoute(
                                            builder: (_) => ChatRoomPage(
                                              chat: data!,
                                              order: orderNew,
                                            ),
                                          );
                                          Navigator.push(context, route);
                                        }
                                      },
                                      onDoubleTap: () {},
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.chat,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              "แชท",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: () async {
                                        // OrderClassModel orderNew =
                                        //     await order.createMarketOrder(
                                        //   widget.courseId,
                                        //   con.courseName ?? "",
                                        //   con.detailsText ?? "",
                                        //   con.tutorId ?? "",
                                        // );
                                        // var route = MaterialPageRoute(
                                        //   builder: (_) => PaymentPage(
                                        //     orderDetailId: orderNew.id ?? "",
                                        //   ),
                                        // );
                                        // Navigator.push(context, route);
                                      },
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.shopping_cart,
                                              color: primaryColor,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              "ซื้อเลย",
                                              style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Row(
                        //   children: [
                        //     const Icon(Icons.account_circle_outlined),
                        //     const SizedBox(width: 5),
                        //     Text("143"),
                        //     Container(
                        //       height: 30,
                        //       child: const VerticalDivider(color: Colors.black),
                        //     ),
                        //     starRateFromNumWidget(4),
                        //     const SizedBox(width: 5),
                        //     Text(
                        //       "3,324 ratings",
                        //       style: TextStyle(
                        //         color: primaryColor,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        Row(
                          children: [
                            Text(
                              "เรียบเรียงโดย : ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              con.tutor?.name ?? "",
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "แก้ไขครั้งล่าสุด ${FormatDate.dt(con.courseDetail?.updateTime)}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Builder(builder: (context) {
                          if (con.courseDetail?.lessons?.isEmpty ?? false) {
                            return const SizedBox();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "รายการเนื้อหา",
                                style: TextStyle(
                                  color: appTextPrimaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    con.courseDetail?.lessons?.length ?? 0,
                                itemBuilder: (context, index) {
                                  Lesson only =
                                      con.courseDetail!.lessons![index];
                                  return GestureDetector(
                                    onTap: () {
                                      log("click");
                                    },
                                    child: Container(
                                      width: Sizer(context).w,
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 10, 10, 10),
                                      margin:
                                          const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                      decoration: BoxDecoration(
                                        color: greyColor2,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.video_camera_back,
                                            color: greyColor,
                                          ),
                                          SizedBox(width: 5),
                                          Text("${only.lessonName ?? ""}"),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        }),
                        Text(
                          "รายละเอียดคอร์ส",
                          style: TextStyle(
                            color: appTextPrimaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          con.courseDetail?.detailsText ?? "",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Builder(builder: (context) {
                          if (con.recommendCourse.isEmpty) {
                            return const SizedBox();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "นอกจากนี้ผู้เรียนยังดู",
                                style: TextStyle(
                                  color: appTextPrimaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: (con.recommendCourse.length) >= 3
                                    ? 3
                                    : con.recommendCourse.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  CourseMarketModel only =
                                      con.recommendCourse[index];
                                  return GestureDetector(
                                    onTap: () {
                                      var route = MaterialPageRoute(
                                          builder: (context) =>
                                              MarketCourseDetailPage(
                                                  courseId: only.id ?? ""));
                                      Navigator.push(context, route)
                                          .then((value) {
                                        con.init();
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 10, 0, 0),
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
                                                errorBuilder: (context, error,
                                                    stackTrace) {
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
                                                  maxLines: 2,
                                                ),
                                                Text(
                                                  "${only.detailsText ?? ""}",
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () {
                            var route = MaterialPageRoute(
                                builder: (context) =>
                                    TutorCoursePage(con.tutor!));
                            Navigator.push(context, route);
                          },
                          child: Container(
                            width: Sizer(context).w,
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
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
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.network(
                                          con.tutor?.image ?? "",
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return FittedBox(
                                              child: Image.asset(
                                                "assets/images/image35.png",
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Builder(builder: (context) {
                                            return const Text(
                                              "ติวเตอร์",
                                              style: TextStyle(
                                                color: appTextPrimaryColor,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          }),
                                          Text(
                                            con.tutor?.name ?? "",
                                            style: const TextStyle(
                                              color: primaryColor,
                                              fontSize: 18,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            con.tutor?.about ?? "",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          FutureBuilder(
                                            future: con.getCourseTotalTutor(),
                                            builder: (context, snap) {
                                              return Row(children: [
                                                Expanded(
                                                  child: Text(
                                                    "คอร์สทั้งหมด : ${snap.data}",
                                                    style: TextStyle(
                                                      color: greyColor,
                                                      fontSize: 15,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ]);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          "รีวิวจากผู้เรียน",
                          style: TextStyle(
                            color: appTextPrimaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          // padding: EdgeInsets.all(10),
                          width: Sizer(context).w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "${con.avgReview}",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                height: 40,
                                child: starRateWidget(),
                              ),
                              Text(
                                " ${con.totalReview} รีวิว",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Builder(builder: (context) {
                              double percent = con.calculatePercent(5);
                              return Row(
                                children: [
                                  LinearPercentIndicator(
                                    width: 200,
                                    lineHeight: 20,
                                    percent: percent / 100,
                                    padding: EdgeInsets.zero,
                                    progressColor: Colors.orange,
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                  const SizedBox(width: 10),
                                  starRateFromNumWidget(5),
                                  const SizedBox(width: 10),
                                  Text(
                                    "$percent %",
                                    style: const TextStyle(
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              );
                            }),
                            const SizedBox(height: 10),
                            Builder(builder: (context) {
                              double percent = con.calculatePercent(4);
                              return Row(
                                children: [
                                  LinearPercentIndicator(
                                    width: 200,
                                    lineHeight: 20,
                                    percent: percent / 100,
                                    padding: EdgeInsets.zero,
                                    progressColor: Colors.orange,
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                  const SizedBox(width: 10),
                                  starRateFromNumWidget(4),
                                  const SizedBox(width: 10),
                                  Text(
                                    "$percent %",
                                    style: const TextStyle(
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              );
                            }),
                            const SizedBox(height: 10),
                            Builder(builder: (context) {
                              double percent = con.calculatePercent(3);
                              return Row(
                                children: [
                                  LinearPercentIndicator(
                                    width: 200,
                                    lineHeight: 20,
                                    percent: percent / 100,
                                    padding: EdgeInsets.zero,
                                    progressColor: Colors.orange,
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                  const SizedBox(width: 10),
                                  starRateFromNumWidget(3),
                                  const SizedBox(width: 10),
                                  Text(
                                    "$percent %",
                                    style: const TextStyle(
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              );
                            }),
                            const SizedBox(height: 10),
                            Builder(builder: (context) {
                              double percent = con.calculatePercent(2);
                              return Row(
                                children: [
                                  LinearPercentIndicator(
                                    width: 200,
                                    lineHeight: 20,
                                    percent: percent / 100,
                                    padding: EdgeInsets.zero,
                                    progressColor: Colors.orange,
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                  const SizedBox(width: 10),
                                  starRateFromNumWidget(2),
                                  const SizedBox(width: 10),
                                  Text(
                                    "$percent %",
                                    style: const TextStyle(
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              );
                            }),
                            const SizedBox(height: 10),
                            Builder(builder: (context) {
                              double percent = con.calculatePercent(1);
                              return Row(
                                children: [
                                  LinearPercentIndicator(
                                    width: 200,
                                    lineHeight: 20,
                                    percent: percent / 100,
                                    padding: EdgeInsets.zero,
                                    progressColor: Colors.orange,
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                  const SizedBox(width: 10),
                                  starRateFromNumWidget(1),
                                  const SizedBox(width: 10),
                                  Text(
                                    "$percent %",
                                    style: const TextStyle(
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              );
                            }),
                            const SizedBox(height: 10),
                          ],
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: Sizer(context).w,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: con.reviewList.length > 5
                                    ? 5
                                    : con.reviewList.length,
                                itemBuilder: (context, index) {
                                  ReviewModel only = con.reviewList[index];
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          FutureBuilder(
                                            future: con
                                                .getUserInfo(only.userId ?? ""),
                                            builder: (context, snap) {
                                              return Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${snap.data?.name ?? ""} ",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              );
                                            },
                                          ),
                                          starRateFromNumWidget(only.rate ?? 0),
                                          Container(
                                            width: Sizer(context).w * 0.9,
                                            child: Text(
                                              only.reviewMessage ?? "",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Builder(builder: (context) {
                                            var outputFormat =
                                                DateFormat('dd/MM/yyyy');
                                            var outputDate = outputFormat
                                                .format(only.createdAt ??
                                                    DateTime.now());
                                            return Text(
                                              "${outputDate} ",
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            );
                                          }),
                                          SizedBox(height: 15),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),

                              SizedBox(height: 10),
                              // ElevatedButton(
                              //   onPressed: () {
                              //     // var route = MaterialPageRoute(
                              //     //     builder: (context) => ReviewPage());
                              //     // Navigator.push(context, route);
                              //   },
                              //   style: ButtonStyle(
                              //     backgroundColor:
                              //         MaterialStateProperty.all(Colors.white),
                              //     elevation: MaterialStateProperty.all(0),
                              //     shape: MaterialStateProperty.all(
                              //       RoundedRectangleBorder(
                              //         side: BorderSide(
                              //           color: primaryColor,
                              //           width: 2,
                              //           style: BorderStyle.solid,
                              //         ),
                              //         borderRadius: BorderRadius.circular(8.0),
                              //       ),
                              //     ),
                              //   ),
                              //   child: Container(
                              //     width: Sizer(context).w,
                              //     height: 45,
                              //     alignment: Alignment.center,
                              //     child: Text(
                              //       "ดูรีวิวทั้งหมด",
                              //       style: TextStyle(
                              //         color: primaryColor,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget starRateWidget() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: 5,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        if (double.parse(index.toString()) < 5) {
          return Icon(
            Icons.star_rate_rounded,
            color: Colors.orange,
          );
        } else {
          return Icon(
            Icons.star_border_purple500_rounded,
            color: Colors.grey,
          );
        }
      },
    );
  }

  Widget starRateFromNumWidget(int num) {
    return Container(
      height: 30,
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: 5,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (double.parse(index.toString()) < num) {
            return Icon(
              CupertinoIcons.star_fill,
              color: Colors.orange,
              size: 20,
            );
          } else {
            return Icon(
              CupertinoIcons.star,
              color: Colors.grey,
              size: 20,
            );
          }
        },
      ),
    );
  }

  Widget subjectWidget(
      MarketCourseDetailController con, CourseMarketModel only) {
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

  Widget levelWidget(MarketCourseDetailController con, CourseMarketModel only) {
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

  Widget tutorWidget(MarketCourseDetailController con) {
    return Container(
      child: Text(
        con.tutor?.name ?? "",
        style: const TextStyle(
          fontSize: 14,
          color: primaryColor,
        ),
      ),
    );
  }
}
