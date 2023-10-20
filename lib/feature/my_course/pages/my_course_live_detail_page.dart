import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/feature/calendar/constants/assets_manager.dart';
import 'package:solve_student/feature/calendar/widgets/format_date.dart';
import 'package:solve_student/feature/chat/models/chat_model.dart';
import 'package:solve_student/feature/chat/pages/chat_room_page.dart';
import 'package:solve_student/feature/market_place/model/course_live_model.dart';
import 'package:solve_student/feature/market_place/model/course_market_model.dart';
import 'package:solve_student/feature/market_place/pages/market_course_detail_page.dart';
import 'package:solve_student/feature/market_place/pages/tutor_course_page.dart';
import 'package:solve_student/feature/market_place/model/lesson_market_model.dart';
import 'package:solve_student/feature/my_course/controller/my_course_live_detail_controller.dart';
import 'package:solve_student/feature/my_course/model/review_model.dart';
import 'package:solve_student/feature/order/model/order_class_model.dart';
import 'package:solve_student/widgets/sizer.dart';

class MyCourseLiveDetailPage extends StatefulWidget {
  MyCourseLiveDetailPage({super.key, required this.courseId});
  String courseId;
  @override
  State<MyCourseLiveDetailPage> createState() => _MyCourseDetailPageState();
}

class _MyCourseDetailPageState extends State<MyCourseLiveDetailPage> {
  MyCourseLiveDetailController? controller;

  @override
  void initState() {
    controller =
        MyCourseLiveDetailController(context, courseId: widget.courseId);
    controller!.init();
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<MyCourseLiveDetailController>(builder: (context, con, _) {
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
                        const SizedBox(height: 10),
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
                        const SizedBox(height: 10),
                        Builder(builder: (context) {
                          if (con.courseDetail?.calendar?.isEmpty ?? false) {
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
                                    con.courseDetail?.calendar?.length ?? 0,
                                itemBuilder: (context, index) {
                                  Calendar only =
                                      con.courseDetail!.calendar![index];
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
                                          Text(
                                              "เริ่ม ${con.dateTimeFromTimeStamp(only.start?.toInt() ?? 0)} - สิ้นสุด ${con.dateTimeFromTimeStamp(only.end?.toInt() ?? 0)}"),
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

                              // Expanded(
                              //   child: Container(
                              //     decoration: BoxDecoration(
                              //         // color: Colors.green,
                              //         ),
                              //     child: GridView.count(
                              //       primary: false,
                              //       shrinkWrap: true,
                              //       physics: NeverScrollableScrollPhysics(),
                              //       padding: EdgeInsets.all(5),
                              //       crossAxisSpacing: 10,
                              //       mainAxisSpacing: 10,
                              //       crossAxisCount: 3,
                              //       childAspectRatio: 2,
                              //       children: <Widget>[
                              //         GestureDetector(
                              //           onTap: () {
                              //             setState(() {
                              //               rateSelected = 0;
                              //             });
                              //           },
                              //           child: Container(
                              //             alignment: Alignment.center,
                              //             decoration: rateSelected == 0
                              //                 ? BoxDecoration(
                              //                     border: Border.all(
                              //                       color: primaryColor,
                              //                     ),
                              //                     borderRadius:
                              //                         BorderRadius.circular(10),
                              //                   )
                              //                 : BoxDecoration(
                              //                     color: Colors.grey.shade100,
                              //                     borderRadius:
                              //                         BorderRadius.circular(10),
                              //                   ),
                              //             padding:
                              //                 EdgeInsets.fromLTRB(5, 0, 5, 0),
                              //             child: Text(
                              //               "ทั้งหมด (0)",
                              //               textScaleFactor: scaleSize,
                              //               style: TextStyle(
                              //                 color: rateSelected == 0
                              //                     ? primaryColor
                              //                     : Colors.grey,
                              //                 fontSize: 12,
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //         // selectedStarRate(5),
                              //         // selectedStarRate(4),
                              //         // selectedStarRate(3),
                              //         // selectedStarRate(2),
                              //         // selectedStarRate(1),
                              //       ],
                              //     ),
                              //   ),
                              // ),
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
                        const Divider(),
                        const SizedBox(height: 10),
                        FutureBuilder(
                            future: con.checkMeReviewed(),
                            builder: (context, snap) {
                              if (snap.data ?? false) {
                                return const SizedBox();
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "ให้คะแนนรีวิว",
                                    style: TextStyle(
                                      color: appTextPrimaryColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      starSelectWidget(1, con),
                                      starSelectWidget(2, con),
                                      starSelectWidget(3, con),
                                      starSelectWidget(4, con),
                                      starSelectWidget(5, con),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    // height: 50,
                                    child: TextFormField(
                                      controller: con.reviewMessage,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        hintText: "ข้อความ",
                                        contentPadding:
                                            EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: BorderSide(
                                            color: primaryColor,
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: Colors.red,
                                            width: 2.0,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: Colors.red,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                      onFieldSubmitted: (value) {
                                        con.updateReviewMessage(value);
                                      },
                                      onEditingComplete: () {
                                        FocusScope.of(context).unfocus();
                                      },
                                      validator: (String? value) {
                                        if (value == null || value.isEmpty) {
                                          return "กรุณาระบุ";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      con.createReview();
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.white),
                                      elevation: MaterialStateProperty.all(0),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: primaryColor,
                                            width: 2,
                                            style: BorderStyle.solid,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                    child: Container(
                                      width: Sizer(context).w,
                                      height: 45,
                                      alignment: Alignment.center,
                                      child: Text(
                                        "รีวิวคอร์สนี้",
                                        style: TextStyle(
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget subjectWidget(
      MyCourseLiveDetailController con, CourseMarketModel only) {
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

  Widget levelWidget(MyCourseLiveDetailController con, CourseMarketModel only) {
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

  Widget tutorWidget(MyCourseLiveDetailController con) {
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

  Widget starSelectWidget(int selectedStar, MyCourseLiveDetailController con) {
    return GestureDetector(
      onTap: () {
        con.updateRateSelected(selectedStar);
      },
      child: con.rateSelected >= selectedStar
          ? const Icon(
              Icons.star_sharp,
              color: Colors.orange,
              size: 30.0,
            )
          : const Icon(
              Icons.star_border,
              color: Colors.grey,
              size: 30.0,
            ),
    );
  }
}
