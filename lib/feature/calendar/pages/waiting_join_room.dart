import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/feature/calendar/constants/custom_colors.dart';
import 'package:solve_student/feature/calendar/constants/custom_styles.dart';
import 'package:solve_student/feature/calendar/controller/document_controller.dart';
import 'package:solve_student/feature/calendar/helper/utility_helper.dart';
import 'package:solve_student/feature/calendar/model/show_course.dart';
import 'package:solve_student/feature/calendar/widgets/format_date.dart';
import 'package:solve_student/feature/calendar/widgets/sizebox.dart';
import 'package:solve_student/widgets/sizer.dart';

import '../../../firebase/database.dart';
import '../../live_classroom/page/live_classroom_student.dart';
import '../../live_classroom/utils/api.dart';
import '../../live_classroom/utils/toast.dart';
import '../constants/assets_manager.dart';

class WaitingJoinRoom extends StatefulWidget {
  const WaitingJoinRoom({super.key, required this.course});
  final ShowCourseStudent course;
  @override
  State<WaitingJoinRoom> createState() => _WaitingJoinRoomState();
}

class _WaitingJoinRoomState extends State<WaitingJoinRoom>
    with TickerProviderStateMixin {
  var documentController = DocumentController();
  static final _util = UtilityHelper();
  late AuthProvider authProvider;
  late AnimationController _controller;
  late StreamSubscription<DocumentSnapshot>? listener;
  FirebaseService dbService = FirebaseService();
  String tutorName = 'ติวเตอร์';
  String tutorImage = '';
  late String meetingCode;
  late double ratio;

  // VideoSDK
  String _token = "";
  bool isActive = false;
  bool isMicOn = true;
  bool? isJoinMeetingSelected;
  bool? isCreateMeetingSelected;

  @override
  void initState() {
    // Timer(
    //   const Duration(seconds: 3),
    //   () {
    //     setState(() {
    //       isActive = true;
    //     });
    //   },
    // );
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();
    initDB();
    startMeetingCodeListener();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await fetchToken(context);
      setState(() => _token = token);
    });
  }

  void initDB() async {
    var user = await dbService.getUserById(widget.course.tutorId);
    setState(() {
      tutorName = user['name'];
      tutorImage = user['image'];
    });
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    listener?.cancel();
    super.dispose();
  }

  void startMeetingCodeListener() {
    listener = FirebaseFirestore.instance
        .collection('course_live')
        .doc(widget.course.courseId)
        .snapshots()
        .listen((snapshot) {
      if ((snapshot.data() != null) &&
          snapshot.data()!.containsKey('currentMeetingCode')) {
        String snapMeetingCode = snapshot.data()!['currentMeetingCode'];
        if (snapMeetingCode != '') {
          setState(() {
            meetingCode = snapMeetingCode;
            isActive = true;
          });
        }
      }
    });
  }

  Future<void> joinMeeting(displayName, meetingId) async {
    if (meetingId.isEmpty) {
      showSnackBarMessage(message: "Invalid Meeting ID", context: context);
      return;
    }
    if(widget.course.courseType == 'live'){
      var validMeeting = await validateMeeting(_token, meetingId);
      if (validMeeting) {
        if (mounted) {
          print('JOIN ROOM');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  StudentLiveClassroom(
                    token: _token,
                    userId: authProvider.uid!,
                    courseId: widget.course.courseId!,
                    startTime: widget.course.start!.millisecondsSinceEpoch,
                    meetingId: meetingId,
                    displayName: displayName,
                    isHost: false,
                    micEnabled: isMicOn,
                    camEnabled: false,
                  ),
            ),
          );
        }
      } else {
        if (mounted) {
          showSnackBarMessage(message: "Invalid Meeting ID", context: context);
        }
      }
    }else{
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              StudentLiveClassroom(
                token: _token,
                userId: authProvider.uid!,
                courseId: widget.course.courseId!,
                startTime: widget.course.start!.millisecondsSinceEpoch,
                meetingId: meetingId,
                displayName: displayName,
                isHost: false,
                micEnabled: isMicOn,
                camEnabled: false,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: CustomColors.whitePrimary,
        elevation: 6,
        leading: InkWell(
          onTap: () {
            isActive = false;
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.close,
            color: Colors.black,
          ),
        ),
        title: Text(
          'รอเข้าห้องเรียน',
          style: CustomStyles.bold22Black363636,
        ),
      ),
      persistentFooterButtons: [
        _util.isTablet() ? const SizedBox() : _footBar()
      ],
      backgroundColor: Colors.white,
      body: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  // setState(() {
                  //   isActive = !isActive;
                  // });
                },
                child: Image.asset(
                  'assets/images/time.png',
                  height: _util.isTablet() ? 72 : 32,
                ),
              ),
              S.h(_util.isTablet() ? 20 : 5),
              S.h(10),
              SizedBox(
                width: 300,
                child: Text(
                  widget.course.courseName ?? '',
                  textAlign: TextAlign.center,
                  style: CustomStyles.bold22Black363636,
                ),
              ),
              S.h(10),
              SizedBox(
                width: 300,
                child: Text(
                  widget.course.detailsText ?? '',
                  textAlign: TextAlign.center,
                  style: CustomStyles.med14Black363636,
                ),
              ),
              if (_util.isTablet()) ...[
                S.h(10),
                _timeJoin(),
                S.h(10),
                widget.course.courseType == 'live' ? SizedBox(height: 100, child: _microphone()) : const SizedBox(),
                widget.course.courseType == 'live' ? S.h(10) : const SizedBox(),
                _tutorTitle(),
                S.h(30),

                /// TODO: make Countdown widget change active status
                isActive
                    ? S.h(30)
                    : Countdown(courseStart: widget.course.start!),
                S.h(10),
                isActive ? _buttonJoinRoom() : _buttonNotYet(),
                S.h(20),
              ] else ...[
                widget.course.courseType == 'live' ? SizedBox(height: 70, child: _microphone()) : const SizedBox(),
                widget.course.courseType == 'live' ? S.h(10) : const SizedBox(),
                if (!isActive) Countdown(courseStart: widget.course.start!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeJoin() {
    return Text(
      '${FormatDate.dayOnly(widget.course.start)}  ${FormatDate.timeOnlyNumber(widget.course.start)} น. - ${FormatDate.timeOnlyNumber(widget.course.end)} น.',
      style: _util.isTablet()
          ? CustomStyles.bold18Black363636
          : CustomStyles.med14Black363636,
    );
  }

  Widget _microphone() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        width: (_util.isTablet() ? 100 : 70),
        child: AnimatedBuilder(
          animation:
              CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
          builder: (context, child) {
            return Stack(alignment: Alignment.center, children: <Widget>[
              !isMicOn
                  ? const SizedBox()
                  : _buildContainer(
                      (_util.isTablet() ? 100 : 70) * _controller.value),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isMicOn = !isMicOn;
                    if (isMicOn) {
                      _controller = AnimationController(
                        vsync: this,
                        lowerBound: 0.5,
                        duration: const Duration(milliseconds: 1000),
                      )..repeat();
                    } else {
                      _controller.stop();
                    }
                    setState(() {});
                  });
                },
                child: Container(
                  padding: _util.isTablet()
                      ? const EdgeInsets.all(16.0)
                      : const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: !isMicOn ? Colors.redAccent : Colors.white,
                    border: Border.all(
                      color: !isMicOn
                          ? Colors.redAccent
                          : CustomColors.greenPrimary,
                      width: 2.5,
                    ),
                  ),
                  child: !isMicOn
                      ? Icon(
                          Icons.mic_off_outlined,
                          size: _util.isTablet() ? 24 : 25,
                          color: CustomColors.white,
                        )
                      : Icon(
                          Icons.mic_none,
                          size: _util.isTablet() ? 24 : 25,
                          color: CustomColors.greenPrimary,
                        ),
                ),
              ),
            ]);
          },
        ),
      ),
      Text(
        'เปิด/ปิด ไมโครโฟน',
        style: CustomStyles.bold18Black363636.copyWith(
          color: CustomColors.gray878787,
        ),
      ),
    ]);
  }

  Widget _tutorTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ติวเตอร์:',
          style: CustomStyles.bold18Black363636.copyWith(
            color: CustomColors.gray878787,
          ),
        ),
        const SizedBox(width: 10),
        tutorImage == ''
            ? ClipRRect(
                borderRadius: BorderRadius.circular(Sizer(context).h * .1),
                child: Image.asset('assets/images/profile2.png',
                    width: Sizer(context).h * .15,
                    height: Sizer(context).h * .15,
                    fit: BoxFit.cover))
            : ClipRRect(
                borderRadius: BorderRadius.circular(Sizer(context).h * .1),
                child: CachedNetworkImage(
                  width: _util.isTablet()
                      ? Sizer(context).h / 14
                      : Sizer(context).h * .100,
                  height: _util.isTablet()
                      ? Sizer(context).h / 14
                      : Sizer(context).h * .100,
                  fit: BoxFit.cover,
                  imageUrl: tutorImage,
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
        const SizedBox(width: 10),
        Text(
          tutorName,
          style: CustomStyles.med12GreenPrimary.copyWith(
            fontSize: _util.addMinusFontSize(16),
          ),
        ),
      ],
    );
  }

  Widget _buttonJoinRoom() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Material(
        child: InkWell(
          onTap: () async {
            print('tap join');
            joinMeeting(authProvider.user?.name ?? '', meetingCode);
          },
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              color: CustomColors.green20B153,
            ),
            padding: _util.isTablet()
                ? const EdgeInsets.symmetric(vertical: 20, horizontal: 10.0)
                : const EdgeInsets.symmetric(vertical: 10, horizontal: 5.0),
            child: Row(
              children: [
                S.w(10),
                Text(
                  "เริ่มเรียน",
                  style: CustomStyles.bold14White.copyWith(
                    fontSize: _util.addMinusFontSize(18),
                  ),
                ),
                S.w(10),
                Image.asset(
                  'assets/images/join.png',
                  scale: 3,
                ),
                S.w(10),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buttonNotYet() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      InkWell(
        onTap: () async {},
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            color: CustomColors.grayE5E6E9,
          ),
          padding: _util.isTablet()
              ? const EdgeInsets.symmetric(vertical: 20, horizontal: 10.0)
              : const EdgeInsets.symmetric(vertical: 10, horizontal: 5.0),
          child: Row(
            children: [
              S.w(10),
              Text(
                "ยังไม่ถึงเวลาเรียน",
                style: CustomStyles.bold14White.copyWith(
                  fontSize: _util.addMinusFontSize(18),
                ),
              ),
              S.w(10),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green.withOpacity(1 - _controller.value),
      ),
    );
  }

  Widget _footBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _timeJoin(),
          _tutorTitle(),
          isActive ? _buttonJoinRoom() : _buttonNotYet(),
        ],
      ),
    );
  }
}

class Countdown extends StatefulWidget {
  final DateTime courseStart;

  const Countdown({super.key, required this.courseStart});

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  late Timer _timer;
  Duration _timeUntilStart = Duration.zero;
  static final _util = UtilityHelper();

  @override
  void initState() {
    super.initState();
    _timeUntilStart = widget.courseStart.difference(DateTime.now());
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  void _getTime() {
    setState(() {
      _timeUntilStart = widget.courseStart.difference(DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (_timeUntilStart.inMilliseconds > 0)
        ? Text(
            "คอร์สจะเริ่มในอีก ${_timeUntilStart.inHours} : ${(_timeUntilStart.inMinutes % 60).toString().padLeft(2, '0')} : ${(_timeUntilStart.inSeconds % 60).toString().padLeft(2, '0')}",
            style: _util.isTablet()
                ? CustomStyles.bold18Black363636
                : CustomStyles.med14Black363636,
          )
        : Container();
  }
}
