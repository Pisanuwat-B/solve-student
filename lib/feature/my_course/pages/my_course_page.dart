import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:slove_student/authentication/service/auth_provider.dart';
import 'package:slove_student/constants/theme.dart';
import 'package:slove_student/feature/class/pages/class_list_page.dart';
import 'package:slove_student/feature/profile/pages/profile_page.dart';
import 'package:slove_student/widgets/dialogs.dart';
import 'package:slove_student/widgets/show_my_id_widget.dart';
import 'package:slove_student/widgets/sizer.dart';

class MyCoursePage extends StatefulWidget {
  const MyCoursePage({super.key});

  @override
  State<MyCoursePage> createState() => _MyCoursePageState();
}

class _MyCoursePageState extends State<MyCoursePage> {
  AuthProvider? authprovider;
  @override
  Widget build(BuildContext context) {
    authprovider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'คอร์สของฉัน',
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
      body: Container(
        width: Sizer(context).w,
        height: Sizer(context).h,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Container(
                  width: 110,
                  height: 50,
                  child: Image.asset('assets/images/slove1.png')),
              Text(
                "ติวพิเศษผ่านคอร์สออนไลน์",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "ติวพิเศษ ด้วยคอร์สออนไลน์แบบบันทึกวิดีโอ (วิชาทั่วไป)",
                style: TextStyle(
                  fontSize: 14,
                  color: appTextSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(30, 30, 30, 0),
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
                  children: [
                    const Text(
                      "รหัสนักเรียนของฉัน",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ShowMyIdWidget(authprovider: authprovider),
                  ],
                ),
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
                    onTap: () {},
                    image: 'assets/images/my_course1.png',
                    title: "คอร์สของฉัน",
                    content:
                        "สร้างคอร์สสอนพิเศษของคุณ เพื่อลงขายใน Market Place ของเรา",
                  ),
                  gridCard(
                    context,
                    onTap: () {},
                    image: 'assets/images/graph1.png',
                    title: "ผลการเรียน",
                    content:
                        "Lorem ipsum dolor sit amet consectetur. Facilisi quis pharetra dictum.",
                  ),
                  gridCard(
                    context,
                    onTap: () {},
                    image: 'assets/images/my_course2.png',
                    title: "ค้นหาคอร์ส",
                    content:
                        "Lorem ipsum dolor sit amet consectetur. Facilisi quis pharetra dictum.",
                  ),
                  gridCard(
                    context,
                    onTap: () {},
                    image: 'assets/images/my_course3.png',
                    title: "ค่าสมาชิก",
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
