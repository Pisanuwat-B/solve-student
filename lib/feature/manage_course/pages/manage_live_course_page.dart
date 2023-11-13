import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/feature/market_place/pages/market_home_page.dart';
import 'package:solve_student/feature/my_course/pages/my_course_live_page.dart';
import 'package:solve_student/feature/my_course/pages/my_course_solvepad_page.dart';
import 'package:solve_student/widgets/sizer.dart';

import '../../live_classroom/utils/responsive.dart';
import '../../maintenance/maintenance.dart';

class ManageLiveCoursePage extends StatefulWidget {
  const ManageLiveCoursePage({super.key});

  @override
  State<ManageLiveCoursePage> createState() => _ManageLiveCoursePageState();
}

class _ManageLiveCoursePageState extends State<ManageLiveCoursePage> {
  AuthProvider? auth;
  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: Sizer(context).w,
          height: Sizer(context).h,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (!Responsive.isMobileLandscape(context)) ...[
                  Row(
                    children: [
                      mobileCard(
                        'assets/images/calendar.png',
                        'Hybrid Solution',
                        'คอร์สเรียน Hybrid ของคุณ',
                        'left',
                        const MaintenancePage(),
                      ),
                      mobileCard(
                        'assets/images/graph.png',
                        'การใช้งาน',
                        'ดูรายการค่าใช้จ่ายคอร์สสอนสด',
                        'right',
                        const MaintenancePage(),
                      ),
                    ],
                  ),
                ],
                if (Responsive.isMobileLandscape(context)) ...[
                  Row(
                    children: [
                      mobileCard(
                        'assets/images/calendar.png',
                        'Hybrid Solution',
                        'คอร์สเรียน Hybrid ของคุณ',
                        'tightLeft',
                        const MaintenancePage(),
                      ),
                      mobileCard(
                        'assets/images/graph.png',
                        'การใช้งาน',
                        'ดูรายการค่าใช้จ่ายคอร์สสอนสด',
                        'tight',
                        const MaintenancePage(),
                      ),
                      mobileCard(
                        'assets/images/menu_my_course.png',
                        'My SOLVE course',
                        'คอร์สที่คุณซื้อจาก Marketplace',
                        'tight',
                        const MyCourseSolvepadPage(),
                      ),
                      mobileCard(
                        'assets/images/menu_create_sheet.png',
                        'My SOLVE live',
                        'คอร์สเรียนสดของคุณ',
                        'tight',
                        const MyCourseLivePage(),
                      ),
                      mobileCard(
                        'assets/images/menu_qa.png',
                        'Marketplace',
                        'ค้นหาคอร์สเรียน แบบ Solvepad',
                        'tightRight',
                        const MyCourseSolvepadPage(),
                      ),
                    ],
                  ),
                ],
                if (Responsive.isMobile(context)) ...[
                  Row(
                    children: [
                      mobileCard(
                        'assets/images/menu_my_course.png',
                        'My SOLVE course',
                        'คอร์สที่คุณซื้อจาก Marketplace',
                        'left',
                        const MyCourseSolvepadPage(),
                      ),
                      mobileCard(
                        'assets/images/menu_create_sheet.png',
                        'My SOLVE live',
                        'คอร์สเรียนสดของคุณ',
                        'right',
                        const MyCourseLivePage(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      mobileCard(
                        'assets/images/menu_qa.png',
                        'Marketplace',
                        'ค้นหาคอร์สเรียนที่ถูกสร้างด้วยเทคโนโลยี Solvepad',
                        'left',
                        const MyCourseSolvepadPage(),
                      ),
                    ],
                  ),
                ],
                if (Responsive.isTablet(context)) ...[
                  GridView.count(
                    shrinkWrap: true,
                    primary: false,
                    padding: const EdgeInsets.all(30),
                    crossAxisSpacing: 30,
                    mainAxisSpacing: 30,
                    crossAxisCount: 3,
                    children: <Widget>[
                      gridCard(
                        context,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MyCourseSolvepadPage(),
                            ),
                          );
                        },
                        image: 'assets/images/menu_my_course.png',
                        title: "คอร์ส SOLVE course ของฉัน",
                        content: "คอร์สที่คุณซื้อจาก Marketplace",
                      ),
                      gridCard(
                        context,
                        onTap: () async {
                          var route = MaterialPageRoute(
                              builder: (context) => const MyCourseLivePage());
                          Navigator.push(context, route);
                        },
                        image: 'assets/images/menu_create_sheet.png',
                        title: "คอร์ส SOLVE live ของฉัน",
                        content: "คอร์สเรียนสดของคุณ",
                      ),
                      gridCard(
                        context,
                        onTap: () {
                          var route = MaterialPageRoute(
                              builder: (context) => const MarketHomePage());
                          Navigator.push(context, route);
                        },
                        image: 'assets/images/menu_qa.png',
                        title: "Marketplace",
                        content:
                            "ค้นหาคอร์สเรียนที่ถูกสร้างด้วยเทคโนโลยี SOLVEPad",
                      ),
                    ],
                  ),
                ],
                if (Responsive.isDesktop(context)) ...[
                  Row(
                    children: [
                      mobileCard(
                        'assets/images/menu_my_course.png',
                        'My SOLVE course',
                        'คอร์สที่คุณซื้อจาก Marketplace',
                        'left',
                        const MyCourseSolvepadPage(),
                      ),
                      mobileCard(
                        'assets/images/menu_create_sheet.png',
                        'My SOLVE live',
                        'คอร์สเรียนสดของคุณ',
                        'mid',
                        const MyCourseLivePage(),
                      ),
                      mobileCard(
                        'assets/images/menu_qa.png',
                        'Marketplace',
                        'ค้นหาคอร์สเรียนที่ถูกสร้างด้วยเทคโนโลยี Solvepad',
                        'right',
                        const MyCourseSolvepadPage(),
                      ),
                    ],
                  ),
                ],
                if (!Responsive.isMobileLandscape(context) &&
                    !Responsive.isDesktop(context))
                  const SizedBox(height: 70),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget mobileCard(
      String img, String title, String desc, String position, Widget link) {
    EdgeInsets cardPosition;
    if (position == 'left') {
      cardPosition = const EdgeInsets.fromLTRB(30, 25, 15, 0);
    } else if (position == 'right') {
      cardPosition = const EdgeInsets.fromLTRB(15, 25, 30, 0);
    } else if (position == 'mid') {
      cardPosition = const EdgeInsets.fromLTRB(15, 25, 15, 0);
    } else if (position == 'tight') {
      cardPosition = const EdgeInsets.fromLTRB(7, 5, 7, 0);
    } else if (position == 'tightLeft') {
      cardPosition = const EdgeInsets.fromLTRB(14, 5, 7, 0);
    } else if (position == 'tightRight') {
      cardPosition = const EdgeInsets.fromLTRB(7, 5, 14, 0);
    } else {
      cardPosition = const EdgeInsets.fromLTRB(15, 25, 15, 0);
    }
    return Expanded(
      child: Container(
        height: Responsive.isTablet(context) ? 230 : 185,
        margin: cardPosition,
        padding: Responsive.isTablet(context)
            ? const EdgeInsets.all(30)
            : const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => link,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 60,
                child: Image.asset(
                  img,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: appTextPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.isMobile(context) ? 14 : 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            desc,
                            style: TextStyle(
                              color: appTextSecondaryColor,
                              fontSize: Responsive.isMobile(context) ? 13 : 16,
                            ),
                            maxLines: 2,
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
        ),
      ),
    );
  }

  Widget gridCard(
    BuildContext context, {
    required Function()? onTap,
    required String image,
    required String title,
    String? content,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 60,
              child: Image.asset(
                image,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: appTextPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          content ?? "",
                          style: const TextStyle(
                            color: appTextSecondaryColor,
                            fontSize: 14,
                          ),
                          maxLines: 2,
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
      ),
    );
  }
}
