import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slove_student/constants/theme.dart';
import 'package:slove_student/feature/standby_study/models/user_state_study_model.dart';
import 'package:slove_student/feature/standby_study/pages/ready_study_page.dart';
import 'package:slove_student/feature/standby_study/pages/waiting_study_page.dart';
import 'package:slove_student/feature/standby_study/service/state_study_provider.dart';
import 'package:slove_student/widgets/sizer.dart';

class StandbyStudyPage extends StatefulWidget {
  StandbyStudyPage({super.key, required this.courseId});
  String courseId;
  @override
  State<StandbyStudyPage> createState() => _StateStudyPageState();
}

class _StateStudyPageState extends State<StandbyStudyPage> {
  String roomId = '';
  UserStandbyStudy user = UserStandbyStudy(id: "00", name: "aa");
  // UserStandbyStudy user = UserStandbyStudy(id: "01", name: "bb");
  // UserStandbyStudy user = UserStandbyStudy(id: "02", name: "cc");

  bool isClassReady = false;
  bool isLoading = true;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      roomId = await stateStudy!.goToRoomState("index${widget.courseId}", user);
      isLoading = false;
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    stateStudy!.removeUserInRoomState(roomId, "index${widget.courseId}", user);
    super.dispose();
  }

  StandbyStudyProvider? stateStudy;
  @override
  Widget build(BuildContext context) {
    stateStudy = Provider.of<StandbyStudyProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'ตั้งค่าเสียงและวิดิโอ',
            style: TextStyle(
              color: appTextPrimaryColor,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.chevron_left,
              color: Colors.black,
            ),
          ),
        ),
        body: Container(
          width: Sizer(context).w,
          height: Sizer(context).h,
          child: Builder(
            builder: (context) {
              if (roomId != '') {
                if (isClassReady) {
                  return ReadyStudyPage(roomId);
                } else {
                  return WaitingStudyPage(roomId);
                }
              } else if (isLoading) {
                return const Center(child: Text("Loading..."));
              } else {
                return const Center(child: Text("Error"));
              }
            },
          ),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ElevatedButton(
            //   onPressed: () {
            //     UserStateStudy user = UserStateStudy(id: "00", name: "aa");
            //     // UserStateStudy user = UserStateStudy(id: "01", name: "bb");
            //     // UserStateStudy user = UserStateStudy(id: "02", name: "cc");
            //     stateStudy!.removeUserInRoomState(
            //         'bd0fdacc-e40f-45a5-88c1-cd6e3428ad15',
            //         "index${widget.courseId}",
            //         user);
            //   },
            //   child: Text("Mock Remove"),
            // ),
            // ElevatedButton(
            //   onPressed: () {
            //     stateStudy!.goToRoomState("index${widget.courseId}", "111");
            //   },
            //   child: Text("Mock Add"),
            // ),
            ElevatedButton(
              onPressed: () {
                isClassReady = !isClassReady;
                setState(() {});
              },
              child: Text("Mock"),
            ),
          ],
        ),
      ),
    );
  }
}
