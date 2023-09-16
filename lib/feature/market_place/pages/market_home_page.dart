import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/constants/school_subject_constants.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/feature/calendar/constants/constants.dart';
import 'package:solve_student/feature/class/pages/class_list_page.dart';
import 'package:solve_student/feature/market_place/model/course_market_model.dart';
import 'package:solve_student/feature/market_place/pages/market_course_detail_page.dart';
import 'package:solve_student/feature/market_place/pages/market_search_page.dart';
import 'package:solve_student/feature/market_place/service/market_home_provider.dart';
import 'package:solve_student/feature/profile/pages/profile_page.dart';
import 'package:solve_student/widgets/sizer.dart';

class MarketHomePage extends StatefulWidget {
  const MarketHomePage({super.key});

  @override
  State<MarketHomePage> createState() => _HomePageState();
}

class _HomePageState extends State<MarketHomePage> {
  List<String> bannerList = [
    'assets/images/banner1.png',
    'assets/images/banner1.png',
    'assets/images/banner1.png',
    'assets/images/banner1.png',
    'assets/images/banner1.png',
  ];

  List<Map<String, String>> subjectList = [
    {"ภาษาไทย": 'assets/images/s1.png'},
    {"สังคม": 'assets/images/s2.png'},
    {"อังกฤษ": 'assets/images/s3.png'},
    {"คณิตศาสตร์": 'assets/images/s4.png'},
    {"ฟิสิกส์": 'assets/images/s5.png'},
    {"เคมี": 'assets/images/s6.png'},
    {"ชีววิทยา": 'assets/images/s7.png'},
  ];
  int currentIndex = 0;
  AuthProvider? authprovider;
  MarketHomeProvider? homeProvider;
  @override
  Widget build(BuildContext context) {
    authprovider = Provider.of<AuthProvider>(context);
    homeProvider = Provider.of<MarketHomeProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Image.asset("assets/images/solve1.png"),
        actions: [
          GestureDetector(
            onTap: () {
              var route =
                  MaterialPageRoute(builder: (context) => const ProfilePage());
              Navigator.push(context, route);
            },
            child: Container(
              width: 45,
              height: 45,
              margin: const EdgeInsets.fromLTRB(5, 5, 15, 5),
              child: Builder(
                builder: (context) {
                  if (authprovider?.user?.image != null) {
                    return ClipRRect(
                      borderRadius:
                          BorderRadius.circular(Sizer(context).h * .1),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: authprovider?.user?.image ?? "",
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                                child: Icon(CupertinoIcons.person)),
                      ),
                    );
                  }
                  return Image.asset("assets/images/profile2.png");
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          width: Sizer(context).w,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 400.0,
                  child: Stack(
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 400.0,
                          viewportFraction: 1,
                          onPageChanged: (index, reason) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                        ),
                        items: bannerList.map((String item) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                decoration:
                                    const BoxDecoration(color: Colors.white),
                                child: Image.asset(
                                  item,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.grey.withOpacity(0.5),
                              ],
                              stops: [0.1, 0.9],
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              tileMode: TileMode.repeated,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: DotsIndicator(
                          dotsCount: bannerList.length,
                          position: currentIndex,
                          decorator: DotsDecorator(
                            color: Colors.white,
                            size: const Size(10, 9.0),
                            activeSize: const Size(30, 9.0),
                            activeShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "คอร์สเรียนใหม่",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              var route = MaterialPageRoute(
                                  builder: (context) => MarketSearchPage());
                              Navigator.push(context, route);
                            },
                            child: const Text("ดูเพิ่มเติม"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                FutureBuilder(
                    future: homeProvider!.getCourseList(),
                    builder: (context, snapshot) {
                      try {
                        if (snapshot.hasData) {
                          List<CourseMarketModel>? dataSet = snapshot.data;
                          return Container(
                            height: 320,
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: dataSet?.length ?? 0,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                CourseMarketModel only = dataSet![index];
                                return GestureDetector(
                                  onTap: () {
                                    var route = MaterialPageRoute(
                                      builder: (context) =>
                                          MarketCourseDetailPage(
                                        courseId: only.id ?? "",
                                      ),
                                    );
                                    Navigator.push(context, route);
                                  },
                                  onDoubleTap: () {},
                                  child: Container(
                                    height: 300,
                                    width: 300,
                                    margin: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 7,
                                          offset: const Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 180,
                                              width: double.infinity,
                                              decoration: const BoxDecoration(),
                                              child:
                                                  Builder(builder: (context) {
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
                                                  fit: BoxFit.fitWidth,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Image.asset(
                                                      ImageAssets.emptyCourse,
                                                      height: 200,
                                                      width: double.infinity,
                                                      fit: BoxFit.fitHeight,
                                                    );
                                                  },
                                                );
                                              }),
                                            ),
                                            Container(
                                              // color: Colors.green,
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    only.courseName ?? "",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    only.detailsText ?? "",
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Row(
                                                    children: [
                                                      tutorWidget(only),
                                                      const Spacer(),
                                                      levelWidget(only),
                                                      const SizedBox(width: 5),
                                                      subjectWidget(only),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        '9999 : 80',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        return Text("No data ");
                      } catch (e) {
                        return const Text("Data Error");
                      }
                    }),
                Container(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "ค้นหาจากหมวดหมู่",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text("ดูเพิ่มเติม"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Container(
                  height: 160,
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: subjectList.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      Map<String, String> only = subjectList[index];
                      return GestureDetector(
                        onTap: () {
                          // var route = MaterialPageRoute(
                          //     builder: (context) => ClassListPage(
                          //           filterInit: true,
                          //           filSubject: only.keys.first,
                          //         ));
                          var route = MaterialPageRoute(
                              builder: (context) => MarketSearchPage(
                                    filter: true,
                                    subject: only.keys.first,
                                  ));
                          Navigator.push(context, route);
                        },
                        child: Container(
                          height: 150,
                          width: 100,
                          margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 110,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(),
                                  child: Image.asset(
                                    only.values.first,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                                Text(
                                  only.keys.first,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "คอร์สเรียนตามระดับการศึกษา",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text("ดูเพิ่มเติม"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Container(
                  height: 160,
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: Wrap(
                    children: [
                      ...SchoolSubjectConstants.schoolClassLevel
                          .map<Widget>((item) {
                        return GestureDetector(
                          onTap: () {
                            // var route = MaterialPageRoute(
                            //     builder: (context) => ClassListPage(
                            //           filterInit: true,
                            //           filterClass: item,
                            //         ));
                            // Navigator.push(context, route);
                            var route = MaterialPageRoute(
                                builder: (context) => MarketSearchPage(
                                      filter: true,
                                      level: item,
                                    ));
                            Navigator.push(context, route);
                          },
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            decoration: BoxDecoration(
                              color: greyColor2,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(item),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                  // child: ListView.builder(
                  //   shrinkWrap: true,
                  //   itemCount: subjectList.length,
                  //   scrollDirection: Axis.horizontal,
                  //   itemBuilder: (context, index) {
                  //     Map<String, String> only = subjectList[index];
                  //     return GestureDetector(
                  //       onTap: () {
                  //         var route = MaterialPageRoute(
                  //             builder: (context) => ClassListPage(
                  //                   filterInit: true,
                  //                   filSubject: only.keys.first,
                  //                 ));
                  //         Navigator.push(context, route);
                  //       },
                  //       child: Container(
                  //         height: 150,
                  //         width: 100,
                  //         margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                  //         decoration: const BoxDecoration(
                  //           color: Colors.transparent,
                  //         ),
                  //         child: ClipRRect(
                  //           borderRadius: BorderRadius.circular(10),
                  //           child: Column(
                  //             // crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Container(
                  //                 height: 110,
                  //                 width: double.infinity,
                  //                 decoration: const BoxDecoration(),
                  //                 child: Image.asset(
                  //                   only.values.first,
                  //                   fit: BoxFit.fitWidth,
                  //                 ),
                  //               ),
                  //               Text(
                  //                 only.keys.first,
                  //                 style: const TextStyle(
                  //                   fontSize: 18,
                  //                   fontWeight: FontWeight.bold,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget subjectWidget(CourseMarketModel only) {
    return FutureBuilder(
        future: homeProvider!.getSubjectInfo(only.subjectId ?? ""),
        builder: (context, sanp) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: ShapeDecoration(
              color: Colors.grey.shade300,
              shape: const StadiumBorder(),
            ),
            child: Text(
              sanp.data ?? "",
              style: const TextStyle(fontSize: 12),
            ),
          );
        });
  }

  Widget levelWidget(CourseMarketModel only) {
    return FutureBuilder(
        future: homeProvider!.getLevelInfo(only.levelId ?? ""),
        builder: (context, sanp) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: ShapeDecoration(
              color: Colors.grey.shade300,
              shape: const StadiumBorder(),
            ),
            child: Text(
              sanp.data ?? "",
              style: const TextStyle(fontSize: 12),
            ),
          );
        });
  }

  Widget tutorWidget(CourseMarketModel only) {
    return FutureBuilder(
        future: homeProvider!.getTutorInfo(only.tutorId ?? ""),
        builder: (context, snap) {
          return Container(
            child: Text(
              snap.data?.name ?? "",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: primaryColor,
              ),
            ),
          );
        });
  }
}
