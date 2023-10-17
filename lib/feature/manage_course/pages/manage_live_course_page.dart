import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/feature/market_place/pages/market_home_page.dart';
import 'package:solve_student/feature/my_course/pages/my_course_page.dart';
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
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: Responsive.isMobile(context) ? 200 : 230,
                        margin: const EdgeInsets.fromLTRB(30, 30, 15, 0),
                        padding: Responsive.isMobile(context)
                            ? const EdgeInsets.all(15)
                            : const EdgeInsets.all(30),
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
                                builder: (context) => const MaintenancePage(),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  child: Image.asset(
                                    "assets/images/calendar.png",
                                    fit: BoxFit.contain,
                                  ),
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
                                            "Hybrid Solution",
                                            style: TextStyle(
                                              color: appTextPrimaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  Responsive.isMobile(context)
                                                      ? 14
                                                      : 16,
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
                                            "คอร์สเรียน Hybrid ของคุณ",
                                            style: TextStyle(
                                              color: appTextSecondaryColor,
                                              fontSize:
                                                  Responsive.isMobile(context)
                                                      ? 13
                                                      : 14,
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
                    ),
                    Expanded(
                      child: Container(
                        height: Responsive.isMobile(context) ? 200 : 230,
                        margin: const EdgeInsets.fromLTRB(15, 30, 30, 0),
                        padding: Responsive.isMobile(context)
                            ? const EdgeInsets.all(15)
                            : const EdgeInsets.all(30),
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
                                builder: (context) => const MaintenancePage(),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  child: Image.asset(
                                    "assets/images/graph.png",
                                    fit: BoxFit.contain,
                                  ),
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
                                            "การใช้งาน",
                                            style: TextStyle(
                                              color: appTextPrimaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  Responsive.isMobile(context)
                                                      ? 14
                                                      : 16,
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
                                            "ดูรายการค่าใช้จ่ายคอร์สสอนสด",
                                            style: TextStyle(
                                              color: appTextSecondaryColor,
                                              fontSize:
                                                  Responsive.isMobile(context)
                                                      ? 13
                                                      : 14,
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
                    ),
                  ],
                ),
                if (!Responsive.isMobile(context))
                  GridView.count(
                    shrinkWrap: true,
                    primary: false,
                    padding: const EdgeInsets.all(30),
                    crossAxisSpacing: 30,
                    mainAxisSpacing: 30,
                    crossAxisCount: Sizer(context).w <= 600 ? 1 : 3,
                    children: <Widget>[
                      gridCard(
                        context,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyCoursePage(),
                            ),
                          );
                        },
                        image: 'assets/images/menu_my_course.png',
                        title: "คอร์ส SOLVE course ของฉัน",
                        content: "คอร์สที่คุณซื้อจาก Marketplace",
                      ),
                      gridCard(
                        context,
                        onTap: () async {},
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
                if (Responsive.isMobile(context))
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: Responsive.isMobile(context) ? 200 : 230,
                          margin: const EdgeInsets.fromLTRB(30, 30, 15, 0),
                          padding: Responsive.isMobile(context)
                              ? const EdgeInsets.all(15)
                              : const EdgeInsets.all(30),
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
                                  builder: (context) => const MyCoursePage(),
                                ),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    child: Image.asset(
                                      "assets/images/menu_my_course.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "My SOLVE course",
                                              style: TextStyle(
                                                color: appTextPrimaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    Responsive.isMobile(context)
                                                        ? 14
                                                        : 16,
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
                                              "คอร์สที่คุณซื้อจาก Marketplace",
                                              style: TextStyle(
                                                color: appTextSecondaryColor,
                                                fontSize:
                                                    Responsive.isMobile(context)
                                                        ? 13
                                                        : 14,
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
                      ),
                      Expanded(
                        child: Container(
                          height: Responsive.isMobile(context) ? 200 : 230,
                          margin: const EdgeInsets.fromLTRB(15, 30, 30, 0),
                          padding: Responsive.isMobile(context)
                              ? const EdgeInsets.all(15)
                              : const EdgeInsets.all(30),
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
                                  builder: (context) => const MaintenancePage(),
                                ),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    child: Image.asset(
                                      "assets/images/menu_create_sheet.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "My SOLVE live",
                                              style: TextStyle(
                                                color: appTextPrimaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    Responsive.isMobile(context)
                                                        ? 14
                                                        : 16,
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
                                              "คอร์สเรียนสดของคุณ",
                                              style: TextStyle(
                                                color: appTextSecondaryColor,
                                                fontSize:
                                                    Responsive.isMobile(context)
                                                        ? 13
                                                        : 14,
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
                      ),
                    ],
                  ),
                if (Responsive.isMobile(context))
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: Responsive.isMobile(context) ? 200 : 230,
                          margin: const EdgeInsets.fromLTRB(30, 30, 15, 0),
                          padding: Responsive.isMobile(context)
                              ? const EdgeInsets.all(15)
                              : const EdgeInsets.all(30),
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
                                  builder: (context) => const MarketHomePage(),
                                ),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    child: Image.asset(
                                      "assets/images/menu_qa.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Marketplace",
                                              style: TextStyle(
                                                color: appTextPrimaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    Responsive.isMobile(context)
                                                        ? 14
                                                        : 16,
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
                                              "้นหาคอร์สเรียนที่ถูกสร้างด้วยเทคโนโลยี SOLVEPad",
                                              style: TextStyle(
                                                color: appTextSecondaryColor,
                                                fontSize:
                                                    Responsive.isMobile(context)
                                                        ? 13
                                                        : 14,
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
                      ),
                    ],
                  ),
                const SizedBox(height: 70),
              ],
            ),
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
        padding: const EdgeInsets.all(30),
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
            Expanded(
              child: SizedBox(
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                ),
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
                            fontSize: 16,
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
