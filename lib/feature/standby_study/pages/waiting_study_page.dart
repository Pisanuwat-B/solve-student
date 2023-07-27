import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/feature/standby_study/models/user_state_study_model.dart';
import 'package:solve_student/feature/standby_study/service/state_study_provider.dart';
import 'package:solve_student/widgets/sizer.dart';

class WaitingStudyPage extends StatefulWidget {
  WaitingStudyPage(this.roomId, {super.key});
  String roomId;
  @override
  State<WaitingStudyPage> createState() => _WaitingStudyPageState();
}

class _WaitingStudyPageState extends State<WaitingStudyPage> {
  bool micOn = true;
  bool screenShare = true;
  StandbyStudyProvider? standbyStudy;
  @override
  Widget build(BuildContext context) {
    standbyStudy = Provider.of<StandbyStudyProvider>(context);
    return Scaffold(
      backgroundColor: backgroundColor,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   centerTitle: true,
      //   title: const Text(
      //     'ตั้งค่าเสียงและวิดิโอ',
      //     style: TextStyle(
      //       color: appTextPrimaryColor,
      //     ),
      //   ),
      //   leading: IconButton(
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     icon: const Icon(
      //       Icons.chevron_left,
      //       color: Colors.black,
      //     ),
      //   ),
      // ),
      body: Container(
        width: Sizer(context).w,
        height: Sizer(context).h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // const SizedBox(height: 50),
            // Image.asset(
            //   'assets/images/study_time_1.png',
            //   width: 100,
            //   height: 100,
            // ),
            const SizedBox(height: 170),
            Container(
              width: 260,
              child: Column(
                children: [
                  const Text(
                    "TGAT ENG by KruDew",
                    style: TextStyle(
                      color: appTextPrimaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    "พิชิต GAT Eng ไปกับครูดิว ติวครบทุกเนื้อหา พร้อมตัวอย่างข้อสอบจริง จบ ครบในคอร์สเดียว",
                    style: TextStyle(
                      color: appTextSecondaryColor,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_circle_outlined,
                      ),
                      const SizedBox(width: 5),
                      StreamBuilder(
                        stream: standbyStudy!.getUserCountInRoom(widget.roomId),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<UserStandbyStudy> oldList =
                                userStateStudyFromJson(
                                    json.encode(snapshot.data!.get('userIn')));
                            return Text(
                              "${oldList.length}",
                              style: const TextStyle(
                                color: appTextSecondaryColor,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            );
                          }
                          return const Text(
                            "0",
                            style: TextStyle(
                              color: appTextSecondaryColor,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: warningColor2,
                  ),
                  child: Text(
                    "เรียนครั้งที่: 5 / 50",
                    style: TextStyle(
                      color: warningColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "01/01/2023  8.00 น. - 12.00 น.",
                  style: TextStyle(
                    color: appTextPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    micOn = !micOn;
                    setState(() {});
                  },
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          child: FittedBox(
                            child: Builder(builder: (context) {
                              if (!micOn) {
                                return Image.asset(
                                  'assets/images/study_mic_2.png',
                                );
                              }
                              return Image.asset(
                                'assets/images/study_mic_1.png',
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "เปิดไมค์",
                          style: TextStyle(
                            color: appTextSecondaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  width: 2,
                  color: borderColor,
                ),
                GestureDetector(
                  onTap: () {
                    screenShare = !screenShare;
                    setState(() {});
                  },
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          child: FittedBox(
                            child: Builder(builder: (context) {
                              if (!screenShare) {
                                return Image.asset(
                                  'assets/images/study_screen_2.png',
                                );
                              }
                              return Image.asset(
                                'assets/images/study_screen_1.png',
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "แชร์ชีทที่สอน",
                          style: TextStyle(
                            color: appTextSecondaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: 320,
              child: TextFormField(
                // controller: txtCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  hintText: 'โน้ตของคุณ...',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                    color: Colors.grey,
                  )),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                    color: Colors.grey,
                  )),
                  errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                    color: Colors.red,
                  )),
                ),
                validator: (value) {
                  return null;
                },
                onTap: () {},
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "ติวเตอร์:",
                  style: TextStyle(
                    color: appTextSecondaryColor,
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  height: 40,
                  width: 40,
                  child: Image.asset(
                    'assets/images/image35.png',
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 45,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  decoration: BoxDecoration(
                    color: greyColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "ยังไม่ถึงเวลาสอน",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
