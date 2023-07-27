import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solve_student/feature/calendar/pages/student_screen.dart';
import 'package:solve_student/feature/chat/pages/chat_list_page.dart';
import 'package:solve_student/feature/class/pages/class_list_page.dart';
import 'package:solve_student/feature/course_live/pages/course_live_page.dart';
import 'package:solve_student/feature/home/pages/home_page.dart';
import 'package:solve_student/feature/my_course/pages/my_course_page.dart';
import 'package:solve_student/feature/profile/pages/profile_page.dart';

import 'authentication/service/auth_provider.dart';
import 'feature/class/pages/find_class_page.dart';

class Nav extends StatefulWidget {
  Nav({super.key, this.index = 0});
  int index;
  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> with TickerProviderStateMixin {
  TabController? tabController;
  // double sizeCenterButton = 30;
  bool bigCenterButton = true;
  int currentIndex = 0;
  List<Widget> pages = [
    // const MyCoursePage(),
    // StudentScreen(),
    // const CourseLivePage(),
    // const ChatListPage(),
    // const Center(child: Text("Notification")),
    StudentScreen(),
    ClassListPage(),
    const ChatListPage(),
    const Center(child: Text("Notification")),
    const ProfilePage(),
  ];

  tab(int value) {
    currentIndex = value;
    tabController!.animateTo(value);
    bigCenterButton = true;
    if (value == 0 || value == 1) {
      bigCenterButton = false;
    }
    setState(() {});
  }

  // FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  // final notifications = FlutterLocalNotificationsPlugin();
  // FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  // init() {
  //   firebaseMessaging.getToken().then((String? token) async {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     log("device token = $token");
  //     await prefs.setString('device_token', token!);
  //   });
  //   final FirebaseMessaging = FCM();
  // }

  @override
  void initState() {
    super.initState();
    tabController =
        TabController(length: pages.length, vsync: this); // initialise it here
    currentIndex = widget.index;
    tabController!.animateTo(currentIndex);
    // init();
  }

  @override
  void dispose() {
    tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages.map<Widget>((e) => e).toList(),
      ),
      extendBody: true,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Colors.grey.shade50,
        // notchMargin: 8,
        // clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(
          elevation: 0,
          onTap: (value) {
            tab(value);
          },
          selectedLabelStyle: GoogleFonts.kanit(),
          unselectedLabelStyle: GoogleFonts.kanit(),
          // selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                activeIcon: Icon(Icons.calendar_month),
                icon: Icon(Icons.calendar_month_outlined),
                label: "ตารางเรียน"),
            BottomNavigationBarItem(
                activeIcon: Icon(Icons.find_in_page),
                icon: Icon(Icons.find_in_page_outlined),
                label: "ค้นหาติวเตอร์"),
            BottomNavigationBarItem(
                activeIcon: Icon(CupertinoIcons.chat_bubble_2),
                icon: Icon(CupertinoIcons.chat_bubble_2),
                label: "แชท"),
            BottomNavigationBarItem(
                activeIcon: Icon(Icons.notifications),
                icon: Icon(Icons.notifications_outlined),
                label: "แจ้งเตือน"),
            BottomNavigationBarItem(
                activeIcon: Icon(Icons.account_circle),
                icon: Icon(Icons.account_circle_outlined),
                label: "ตั้งค่า"),
          ],
        ),
      ),
    );
  }
}
