import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/models/user_model.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/feature/calendar/widgets/format_date.dart';
import 'package:solve_student/feature/chat/models/chat_model.dart';
import 'package:solve_student/feature/chat/pages/chat_room_page.dart';
import 'package:solve_student/feature/chat/service/chat_provider.dart';
import 'package:solve_student/feature/market_place/service/market_home_provider.dart';
import 'package:solve_student/feature/market_place/model/course_market_model.dart';
import 'package:solve_student/feature/market_place/model/lesson_market_model.dart';
import 'package:solve_student/feature/market_place/service/market_place_provider.dart';
import 'package:solve_student/feature/order/model/order_class_model.dart';
import 'package:solve_student/feature/order/pages/payment_page.dart';
import 'package:solve_student/feature/order/service/order_mock_provider.dart';
import 'package:solve_student/widgets/sizer.dart';

class MarketCourseDetailPage extends StatefulWidget {
  MarketCourseDetailPage({super.key, required this.courseId});
  String courseId;
  @override
  State<MarketCourseDetailPage> createState() => _MarketCourseDetailPageState();
}

class _MarketCourseDetailPageState extends State<MarketCourseDetailPage> {
  late AuthProvider auth;
  late OrderMockProvider order;
  late ChatProvider chat;
  MarketHomeProvider? home;
  RoleType me = RoleType.student;

  CourseMarketModel? course;
  getCourseData() async {
    try {
      course = await MarketPlaceProvider().getCourseInfo(widget.courseId);
      setState(() {});
    } catch (e) {
      log("e : $e");
    }
  }

  UserModel? tutor;
  getTutorData() async {
    try {
      tutor = await MarketPlaceProvider()
          .getTutorInfo("ycUqg7FDtGemeTyVIJE1OH4sLiQ2");
      setState(() {});
    } catch (e) {
      log("e : $e");
    }
  }

  String subject = 'ไม่พบข้อมูล';
  getSubjectData() async {
    try {
      subject =
          await MarketPlaceProvider().getSubjectInfo(course?.subjectId ?? "");
      setState(() {});
    } catch (e) {
      log("e : $e");
    }
  }

  String level = 'ไม่พบข้อมูล';
  getLevelData() async {
    try {
      level = await MarketPlaceProvider().getLevelInfo(course?.levelId ?? "");
      setState(() {});
    } catch (e) {
      log("e : $e");
    }
  }

  bool isLoading = true;
  init() async {
    await getCourseData();
    await getTutorData();
    await getSubjectData();
    await getLevelData();
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    auth = Provider.of<AuthProvider>(context, listen: false);
    order = Provider.of<OrderMockProvider>(context, listen: false);
    chat = Provider.of<ChatProvider>(context, listen: false);
    home = Provider.of<MarketHomeProvider>(context, listen: false);
    me = auth.user!.getRoleType();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      order.init(auth: auth);
      await init();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Image.network(
                    course?.thumbnailUrl ?? "",
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
                  ),
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
                                course?.courseName ?? "",
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
                                course?.recommendText ?? "",
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
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    margin:
                                        const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    child: Text(
                                      subject,
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
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    margin:
                                        const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    child: Text(
                                      level,
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
                                      padding:
                                          const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(color: primaryColor),
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
                                    if (!isLoading) {
                                      OrderClassModel orderNew =
                                          await order.createMarketOrder(
                                        widget.courseId,
                                        course?.courseName ?? "",
                                        course?.detailsText ?? "",
                                        course?.tutorId ?? "",
                                      );
                                      ChatModel? data =
                                          await order.createMarketChat(
                                              widget.courseId,
                                              course?.tutorId ?? "");
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
                                      borderRadius: BorderRadius.circular(10),
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
                                    OrderClassModel orderNew =
                                        await order.createMarketOrder(
                                      widget.courseId,
                                      course?.courseName ?? "",
                                      course?.detailsText ?? "",
                                      course?.tutorId ?? "",
                                    );
                                    var route = MaterialPageRoute(
                                      builder: (_) => PaymentPage(
                                        orderDetailId: orderNew.id ?? "",
                                      ),
                                    );
                                    Navigator.push(context, route);
                                  },
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
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
                          tutor?.name ?? "",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "แก้ไขครั้งล่าสุด ${FormatDate.dt(course?.updateTime)}",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "ตารางเรียน",
                      style: TextStyle(
                        color: appTextPrimaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "ระยะเวลาเรียน: ${FormatDate.dt(course?.firstDay)} - ${FormatDate.dt(course?.lastDay)}",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "สอนเป็นครั้ง: 20 ครั้ง (ตกลงเวลาเรียนกับนักเรียนภายหลัง)",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "ดูแบบละเอียดในปฏิทิน",
                      style: TextStyle(fontSize: 15, color: primaryColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 30),
                    Builder(builder: (context) {
                      if (course?.lessons?.isEmpty ?? false) {
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
                            itemCount: course?.lessons?.length ?? 0,
                            itemBuilder: (context, index) {
                              Lesson only = course!.lessons![index];
                              return GestureDetector(
                                onTap: () {
                                  log("click");
                                },
                                child: Container(
                                  width: Sizer(context).w,
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
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
                        ],
                      );
                    }),

                    const SizedBox(height: 30),
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
                      course?.detailsText ?? "",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // const SizedBox(height: 30),
                    // Text(
                    //   "นอกจากนี้ผู้เรียนยังดู",
                    //   style: TextStyle(
                    //     color: appTextPrimaryColor,
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                    // ListView.builder(
                    //   shrinkWrap: true,
                    //   itemCount: 3,
                    //   physics: NeverScrollableScrollPhysics(),
                    //   itemBuilder: (context, index) {
                    //     return Container(
                    //       margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    //       child: Row(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Container(
                    //             width: 200,
                    //             height: 150,
                    //             decoration: BoxDecoration(
                    //               color: Colors.grey.shade200,
                    //             ),
                    //             child: ClipRRect(
                    //               child: Image.network(
                    //                 "",
                    //                 fit: BoxFit.cover,
                    //                 errorBuilder: (context, error, stackTrace) {
                    //                   return const Center(
                    //                     child: Icon(
                    //                       Icons.image,
                    //                       size: 50,
                    //                       color: Colors.grey,
                    //                     ),
                    //                   );
                    //                 },
                    //               ),
                    //             ),
                    //           ),
                    //           const SizedBox(width: 10),
                    //           Column(
                    //             mainAxisAlignment: MainAxisAlignment.start,
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               Text(
                    //                 "สรุปสูตร 6 สูตรต้องรู้ ! อนุกรมเลขคณิต อนุกรมเรขาคณิต | ม.5",
                    //                 style: TextStyle(
                    //                   color: Colors.black,
                    //                   fontSize: 15,
                    //                   fontWeight: FontWeight.bold,
                    //                 ),
                    //                 textAlign: TextAlign.start,
                    //                 maxLines: 1,
                    //               ),
                    //               Text(
                    //                 "สรุปเนื้อหา อนุกรม โดยมีเนื้อหาทั้ง อนุกรมเรขาคณิต และ อนุกรมเลขคณิต สรุปสั้น...",
                    //                 style: TextStyle(
                    //                   color: Colors.black,
                    //                   fontSize: 15,
                    //                 ),
                    //                 textAlign: TextAlign.start,
                    //                 maxLines: 1,
                    //               ),
                    //               Text(
                    //                 "เจียมพจน์ ปิ่นแก้ว",
                    //                 style: TextStyle(
                    //                   color: primaryColor,
                    //                   fontSize: 15,
                    //                 ),
                    //                 textAlign: TextAlign.start,
                    //                 maxLines: 1,
                    //               ),
                    //               Row(
                    //                 children: [
                    //                   const Icon(
                    //                     Icons.account_circle_outlined,
                    //                     color: greyColor,
                    //                   ),
                    //                   const SizedBox(width: 5),
                    //                   Text(
                    //                     "143",
                    //                     style: TextStyle(
                    //                       color: greyColor,
                    //                     ),
                    //                   ),
                    //                   Container(
                    //                     height: 30,
                    //                     child: const VerticalDivider(
                    //                         color: Colors.black),
                    //                   ),
                    //                   Icon(
                    //                     CupertinoIcons.star_fill,
                    //                     color: Colors.orange,
                    //                     size: 20,
                    //                   ),
                    //                   const SizedBox(width: 5),
                    //                   Text(
                    //                     "(10)",
                    //                     style: TextStyle(
                    //                       color: greyColor,
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //               Row(
                    //                 children: [
                    //                   Container(
                    //                     decoration: BoxDecoration(
                    //                       color: Colors.grey.shade300,
                    //                       borderRadius:
                    //                           BorderRadius.circular(10),
                    //                     ),
                    //                     margin: const EdgeInsets.fromLTRB(
                    //                         0, 5, 0, 5),
                    //                     padding: const EdgeInsets.fromLTRB(
                    //                         5, 0, 5, 0),
                    //                     child: Text(
                    //                       "คณิต",
                    //                       style: TextStyle(
                    //                         fontSize: 15,
                    //                       ),
                    //                       maxLines: 1,
                    //                       overflow: TextOverflow.ellipsis,
                    //                     ),
                    //                   ),
                    //                   Container(
                    //                     decoration: BoxDecoration(
                    //                       color: Colors.grey.shade300,
                    //                       borderRadius:
                    //                           BorderRadius.circular(10),
                    //                     ),
                    //                     padding: const EdgeInsets.fromLTRB(
                    //                         5, 0, 5, 0),
                    //                     child: Text(
                    //                       "มัธยม 4",
                    //                       style: TextStyle(
                    //                         fontSize: 15,
                    //                       ),
                    //                       maxLines: 1,
                    //                       overflow: TextOverflow.ellipsis,
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ],
                    //           ),
                    //         ],
                    //       ),
                    //     );
                    //   },
                    // ),
                    const SizedBox(height: 30),
                    Container(
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
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    tutor?.image ?? "",
                                    errorBuilder: (context, error, stackTrace) {
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      tutor?.name ?? "",
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 18,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "รับสอนพิเศษวิชาคณิตศาสตร์ ทุกระดับชั้น",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(children: [
                                      Expanded(
                                        child: Text(
                                          "คอร์สทั้งหมด : 6 | จำนวนผู้เรียน : 220 | จำนวนรีวิว : 500",
                                          style: TextStyle(
                                            color: greyColor,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
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
}
