import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/feature/calendar/pages/student_screen.dart';
import 'package:solve_student/feature/class/pages/class_list_page.dart';
import 'package:solve_student/feature/profile/pages/profile_page.dart';
import 'package:solve_student/widgets/sizer.dart';

class CourseLivePage extends StatefulWidget {
  const CourseLivePage({super.key});

  @override
  State<CourseLivePage> createState() => _CourseLivePageState();
}

class _CourseLivePageState extends State<CourseLivePage> {
  AuthProvider? authProvider;
  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'ห้องเรียนสอนสด',
          style: TextStyle(
            color: appTextPrimaryColor,
          ),
        ),
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
                  if (authProvider?.user?.image != null) {
                    return ClipRRect(
                      borderRadius:
                          BorderRadius.circular(Sizer(context).h * .1),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: authProvider?.user?.image ?? "",
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
      body: SizedBox(
        width: Sizer(context).w,
        height: Sizer(context).h,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(
                width: 110,
                height: 50,
                child: Image.asset(
                  'assets/images/solve2.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              const Text(
                "ติวผ่านห้องเรียนสอนสด",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "ติวออนไลน์ วิชาทั่วไป ติวเตอร์สอนสดผ่าน Live (แบบกลุ่ม)",
                style: TextStyle(
                  fontSize: 14,
                  color: appTextSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
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
                    onTap: () {
                      var route = MaterialPageRoute(
                          builder: (context) => StudentScreen(
                                studentId: authProvider?.uid ?? "",
                              ));
                      Navigator.push(context, route);
                    },
                    image: 'assets/images/live1.png',
                    title: "ตารางเรียน",
                    content:
                        "Lorem ipsum dolor sit amet consectetur. Facilisi quis pharetra dictum.",
                  ),
                  gridCard(
                    context,
                    onTap: () {},
                    image: 'assets/images/live2.png',
                    title: "คอร์สเรียนสดทั้งหมด",
                    content: "ดูคอร์สทั้งหมดที่คุณเคยลงทะเบียนเรียน",
                  ),
                  gridCard(
                    context,
                    onTap: () {},
                    image: 'assets/images/live3.png',
                    title: "ทบทวนบทเรียน",
                    content: "ดูเอกสารประกอบการเรียน ชีทที่ติวเตอร์สอนย้อนหลัง",
                  ),
                  gridCard(
                    context,
                    onTap: () {
                      var route = MaterialPageRoute(
                          builder: (context) => ClassListPage());
                      Navigator.push(context, route);
                    },
                    image: 'assets/images/live4.png',
                    title: "ค้นหาติวเตอร์",
                    content:
                        "Lorem ipsum dolor sit amet consectetur. Facilisi quis pharetra dictum.",
                  ),
                  gridCard(
                    context,
                    onTap: () {
                      var route = MaterialPageRoute(
                          builder: (context) => ClassListPage(
                                tabSelected: 1,
                              ));
                      Navigator.push(context, route);
                    },
                    image: 'assets/images/live5.png',
                    title: "ประกาศหาติวเตอร์",
                    content:
                        "ประกาศหาติวเตอร์ตามที่คุณต้องการ แชทติวเตอรเพื่อตกลงราคาค่าเรียน",
                  ),
                  gridCard(
                    context,
                    onTap: () {},
                    image: 'assets/images/live6.png',
                    title: "จ่ายเงิน/ใบเสร็จค่าเรียน",
                    content:
                        "Lorem ipsum dolor sit amet consectetur. Facilisi quis pharetra dictum.",
                  ),
                ],
              ),
              const SizedBox(height: 50),
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
    required String content,
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
                  Text(
                    title,
                    style: const TextStyle(
                      color: appTextPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    content,
                    style: const TextStyle(
                      color: appTextSecondaryColor,
                      fontSize: 14,
                    ),
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
