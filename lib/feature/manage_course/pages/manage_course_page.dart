import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/feature/manage_course/pages/manage_live_course_page.dart';

import '../../live_classroom/utils/responsive.dart';

class ManageCoursePage extends StatefulWidget {
  const ManageCoursePage({super.key});

  @override
  State<ManageCoursePage> createState() => _ManageCoursePageState();
}

class _ManageCoursePageState extends State<ManageCoursePage>
    with TickerProviderStateMixin {
  AuthProvider? auth;
  TabController? _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: DefaultTabController(
          length: _tabController!.length,
          child: Builder(builder: (context) {
            return Column(
              children: <Widget>[
                if (Responsive.isMobile(context) ||
                    Responsive.isTablet(context)) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                      width: 110,
                      height: 50,
                      child: Image.asset('assets/images/big_solve_logo.png')),
                  const Text(
                    "เทคโนโลยีใหม่ในการสอนออนไลน์",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "เปลี่ยนวิธีการสอนออนไลน์แบบเดิม ด้วยการสอนผ่านแอป SOLVE\nให้นักเรียนของคุณสามารถเรียนได้จากทุกที่ผ่านมือถือ หรือ Tablet",
                    style: TextStyle(
                      fontSize: 14,
                      color: appTextSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                ],
                if (Responsive.isDesktop(context) || !(Responsive.isMobile(context) ||
                    Responsive.isTablet(context))) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 32.0),
                        child: SizedBox(
                            width: 110,
                            height: 50,
                            child: Image.asset(
                                'assets/images/big_solve_logo.png')),
                      ),
                      const Column(
                        children: [
                          Text(
                            "เทคโนโลยีใหม่ในการสอนออนไลน์",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "เปลี่ยนวิธีการสอนออนไลน์แบบเดิม ด้วยการสอนผ่านแอป SOLVE\nให้นักเรียนของคุณสามารถเรียนได้จากทุกที่ผ่านมือถือ หรือ Tablet",
                            style: TextStyle(
                              fontSize: 14,
                              color: appTextSecondaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ],
                  )
                ],
                if (Responsive.isMobileLandscape(context)) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: SizedBox(
                            width: 110,
                            height: 50,
                            child: Image.asset(
                                'assets/images/big_solve_logo.png')),
                      ),
                      const Column(
                        children: [
                          Text(
                            "เทคโนโลยีใหม่ในการสอนออนไลน์",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "เปลี่ยนวิธีการสอนออนไลน์แบบเดิม ด้วยการสอนผ่านแอป SOLVE\nให้นักเรียนของคุณสามารถเรียนได้จากทุกที่ผ่านมือถือ หรือ Tablet",
                            style: TextStyle(
                              fontSize: 14,
                              color: appTextSecondaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      ManageLiveCoursePage(),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        // TODO: reconsider this when U want campaign
        // floatingActionButton: Container(
        //   width: Sizer(context).w,
        //   height: 80,
        //   padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        //   alignment: Alignment.center,
        //   decoration: const BoxDecoration(
        //     color: primaryColor,
        //   ),
        //   child: Row(
        //     children: [
        //       Container(
        //         width: 50,
        //         height: 50,
        //         padding: const EdgeInsets.all(5),
        //         decoration: BoxDecoration(
        //           shape: BoxShape.circle,
        //           color: Colors.white.withOpacity(0.8),
        //         ),
        //         child: Image.asset("assets/images/share.png"),
        //       ),
        //       const SizedBox(width: 10),
        //       const Expanded(
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Row(
        //               children: [
        //                 Expanded(
        //                   child: Text(
        //                     "แนะนำเพื่อนรับเงินคืน",
        //                     style: TextStyle(
        //                       color: Colors.white,
        //                       fontWeight: FontWeight.bold,
        //                       fontSize: 18,
        //                     ),
        //                     maxLines: 1,
        //                     overflow: TextOverflow.ellipsis,
        //                   ),
        //                 ),
        //               ],
        //             ),
        //             Row(
        //               children: [
        //                 Expanded(
        //                   child: Text(
        //                     "ส่ง Link แนะนำเเพื่อนให้มาใช้บริการแอป SLOVE วันนี้ ได้รับเงินคืนทันทีเมื่อเพื่อนใช้บริการครั้งแรก",
        //                     style: TextStyle(
        //                       color: Colors.white,
        //                     ),
        //                     maxLines: 2,
        //                     overflow: TextOverflow.ellipsis,
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ],
        //         ),
        //       ),
        //       const SizedBox(width: 10),
        //       Container(
        //         width: 100,
        //         height: 45,
        //         alignment: Alignment.center,
        //         padding: const EdgeInsets.all(5),
        //         decoration: BoxDecoration(
        //           borderRadius: BorderRadius.circular(10),
        //           color: Colors.white,
        //         ),
        //         child: Text(
        //           "เข้าร่วม",
        //           style: TextStyle(
        //             color: Colors.grey,
        //             fontWeight: FontWeight.bold,
        //             fontSize: 18,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
