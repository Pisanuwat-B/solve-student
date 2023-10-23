import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:videosdk/videosdk.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../authentication/service/auth_provider.dart';
import '../../../nav.dart';
import '../../calendar/constants/custom_styles.dart';
import '../../calendar/controller/create_course_live_controller.dart';
import '../../calendar/widgets/sizebox.dart';
import '../components/close_dialog.dart';
import '../components/divider.dart';
import '../components/divider_vertical.dart';
import '../components/leaderboard.dart';
import '../../calendar/constants/assets_manager.dart';
import '../../calendar/constants/custom_colors.dart';
import '../components/room_loading_screen.dart';
import '../solvepad/solve_watch.dart';
import '../solvepad/solvepad_drawer.dart';
import '../solvepad/solvepad_stroke_model.dart';
import '../quiz/quiz_model.dart';
import '../utils/responsive.dart';

class StudentLiveClassroom extends StatefulWidget {
  final String meetingId, userId, token, displayName, courseId;
  final bool micEnabled, camEnabled, chatEnabled, isHost, isMock;
  final int startTime;
  const StudentLiveClassroom({
    Key? key,
    required this.meetingId,
    required this.userId,
    required this.token,
    required this.displayName,
    required this.isHost,
    required this.courseId,
    required this.startTime,
    this.micEnabled = true,
    this.camEnabled = false,
    this.chatEnabled = false,
    this.isMock = false,
  }) : super(key: key);

  @override
  State<StudentLiveClassroom> createState() => _StudentLiveClassroomState();
}

class _StudentLiveClassroomState extends State<StudentLiveClassroom> {
  // Conference
  bool isRecordingOn = false;
  bool showChatSnackbar = false;
  String recordingState = "RECORDING_STOPPED";
  late Room meeting;
  bool _joined = false;
  Stream? shareStream;
  Stream? videoStream;
  Stream? audioStream;
  Stream? remoteParticipantShareStream;

  // WSS
  WebSocketChannel? channel;
  final dataTextController = TextEditingController();
  List<dynamic> data = [];
  bool allowSending = true;

  // ---------- VARIABLE: Solve Pad data
  late List<String> _pages = [];
  final List<List<SolvepadStroke?>> _penPoints = [[]];
  final List<List<SolvepadStroke?>> _laserPoints = [[]];
  final List<List<SolvepadStroke?>> _highlighterPoints = [[]];
  final List<List<SolvepadStroke?>> _hostPenPoints = [[]];
  final List<List<SolvepadStroke?>> _hostLaserPoints = [[]];
  final List<List<SolvepadStroke?>> _hostHighlighterPoints = [[]];
  final List<Offset> _eraserPoints = [const Offset(-100, -100)];
  final List<Offset> _hostEraserPoints = [const Offset(-100, -100)];
  final SolveStopwatch stopwatch = SolveStopwatch();
  DrawingMode _mode = DrawingMode.drag;
  DrawingMode _hostMode = DrawingMode.pen;
  Size hostSolvepadSize = const Size(1059.0, 547.0);
  Size? mySolvepadSize;
  double hostImageRatio = 0.7373;
  double hostImageWidth = 0;
  double hostExtraSpaceX = 0;
  double myImageWidth = 0;
  double myExtraSpaceX = 0;
  double scaleImageX = 0;
  double scaleX = 0;
  double scaleY = 0;

  // ---------- VARIABLE: Solve Pad features
  int? activePointerId;
  bool _isPrevBtnActive = false;
  bool _isNextBtnActive = true;

  // ---------- VARIABLE: page control
  final PageController _pageController = PageController();
  final List<TransformationController> _transformationController = [];
  String _formattedElapsedTime = ' 00 : 00 : 00 ';
  String _currentScrollZoom = '';
  String _currentHostScrollZoom = '';
  Timer? _laserTimer;
  Timer? _hostLaserTimer;
  Timer? _meetingTimer;
  int _currentPage = 0;
  int _currentHostPage = 0;
  int _hostColorIndex = 0;
  int _hostStrokeWidthIndex = 0;

  bool _switchValue = true;
  bool micEnable = false;
  bool displayEnable = false;
  bool selected = false;
  bool selectedTools = false;
  bool openColors = false;
  bool openLines = false;
  bool openMore = false;
  bool enableDisplay = true;
  bool fullScreen = false;
  bool isHostRequestShareScreen = false;
  bool isAllowSharingScreen = false;
  bool isHostFocus = false;
  bool isChecked = false;
  bool tabFollowing = true;
  bool tabFreestyle = false;
  bool statusShare = false;
  int _selectedIndexTools = 0;
  int _selectedIndexColors = 0;
  int _selectedIndexLines = 0;
  late bool isSelected;
  final List _listLines = [
    {
      "image_active": ImageAssets.line1Active,
      "image_dis": ImageAssets.line1Dis,
    },
    {
      "image_active": ImageAssets.line2Active,
      "image_dis": ImageAssets.line2Dis,
    },
    {
      "image_active": ImageAssets.line3Active,
      "image_dis": ImageAssets.line3Dis,
    },
  ];
  final List _listColors = [
    {"color": ImageAssets.pickRed},
    {"color": ImageAssets.pickBlack},
    {"color": ImageAssets.pickGreen},
    {"color": ImageAssets.pickYellow}
  ];
  final List _listTools = [
    {
      "image_active": ImageAssets.handActive,
      "image_dis": ImageAssets.handDis,
    },
    {
      "image_active": ImageAssets.pencilActive,
      "image_dis": ImageAssets.pencilDis,
    },
    {
      "image_active": ImageAssets.highlightActive,
      "image_dis": ImageAssets.highlightDis,
    },
    {
      "image_active": ImageAssets.rubberActive,
      "image_dis": ImageAssets.rubberDis,
    },
    // {
    //   "image_active": ImageAssets.laserPenActive,
    //   "image_dis": ImageAssets.laserPenDis,
    // }
  ];
  final List _listToolsDisable = [
    {"image": "assets/images/hand-tran.png"},
    {"image": ImageAssets.pencilTran},
    {"image": ImageAssets.highlightTran},
    {"image": ImageAssets.rubberTran},
    {"image": ImageAssets.laserPenTran}
  ];
  final List _strokeColors = [
    Colors.red,
    Colors.black,
    Colors.green,
    Colors.yellow,
  ];
  final List _strokeWidths = [1.0, 2.0, 5.0];
  List students = [];
  List studentsDisplay = [];
  List<SelectQuizModel> quizList = [
    SelectQuizModel("ชุดที่#1 สมการเชิงเส้นตัวแปรเดียว", "1 ข้อ", false),
    SelectQuizModel("ชุดที่#2 สมการเชิงเส้น 2 ตัวแปร", "10 ข้อ", false),
    SelectQuizModel("ชุดที่#3  สมการจำนวนเชิงซ้อน", "5 ข้อ", false),
    SelectQuizModel("ชุดที่#4 สมการเชิงเส้นตัวแปรเดียว", "5 ข้อ", false),
    SelectQuizModel("ชุดที่#5 สมการเชิงเส้นตัวแปรเดียว", "5 ข้อ", false),
  ];
  late Map<String, Function(String)> handlers;

  late AuthProvider authProvider;

  var courseController = CourseLiveController();
  late String courseName;
  bool isCourseLoaded = false;
  bool showHeader = false;
  bool isStudentLeave = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.bottom,
    ]);
    SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
      await Future.delayed(const Duration(seconds: 3));
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
        SystemUiOverlay.bottom,
      ]);
    });
    initTimer();
    initPagingBtn();
    if (!widget.isMock) {
      initPagesData();
      initMessageHandler();
      initConference();
    } else {
      _joined = true;
      mockInitPageData();
    }
    authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  void mockInitPageData() {
    setState(() {
      _pages = [
        'https://firebasestorage.googleapis.com/v0/b/solve-f1778.appspot.com/o/test(gun)%2FexampleSheet1.jpg?alt=media&token=27676570-4031-4c6b-b6bc-4280fbbcd116',
        'https://firebasestorage.googleapis.com/v0/b/solve-f1778.appspot.com/o/test(gun)%2FexampleSheet2.jpg?alt=media&token=8ec3a135-85a6-4cac-abdd-b8d0df094ce3',
      ];
      for (int i = 1; i < 2; i++) {
        _addPage();
      }
      courseName = 'Mockup Test';
      micEnable = false;
      isCourseLoaded = true;
    });
  }

  Future<void> initPagesData() async {
    await courseController.getCourseById(widget.courseId);
    setState(() {
      if (courseController.courseData?.document?.data?.docFiles == null) {
        _pages = [
          'https://firebasestorage.googleapis.com/v0/b/solve-f1778.appspot.com/o/default_image%2Fa4.png?alt=media&token=01e0d9ac-15ed-4a62-886d-288c60ec1ee6',
          'https://firebasestorage.googleapis.com/v0/b/solve-f1778.appspot.com/o/default_image%2Fa4.png?alt=media&token=01e0d9ac-15ed-4a62-886d-288c60ec1ee6',
          'https://firebasestorage.googleapis.com/v0/b/solve-f1778.appspot.com/o/default_image%2Fa4.png?alt=media&token=01e0d9ac-15ed-4a62-886d-288c60ec1ee6',
          'https://firebasestorage.googleapis.com/v0/b/solve-f1778.appspot.com/o/default_image%2Fa4.png?alt=media&token=01e0d9ac-15ed-4a62-886d-288c60ec1ee6',
          'https://firebasestorage.googleapis.com/v0/b/solve-f1778.appspot.com/o/default_image%2Fa4.png?alt=media&token=01e0d9ac-15ed-4a62-886d-288c60ec1ee6',
        ];
        for (int i = 1; i < 5; i++) {
          _addPage();
        }
      } else {
        _pages = courseController.courseData!.document!.data!.docFiles!;
        updateRatio(_pages[0]);
        for (int i = 1; i < _pages.length; i++) {
          _addPage();
        }
      }
      courseName = courseController.courseData!.courseName!;
      micEnable = widget.micEnabled;
      isCourseLoaded = true;
    });
  }

  void initTimer() {
    stopwatch.start();
    _meetingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _formattedElapsedTime = _formatElapsedTime(stopwatch.elapsed);
      });
    });
  }

  void initPagingBtn() {
    if (_pages.length == 1) {
      _isPrevBtnActive = false;
      _isNextBtnActive = false;
    } else {
      _pageController.addListener(() {
        _isPrevBtnActive = (_pageController.page! > 0);
        _isNextBtnActive = _pageController.page! < (_pages.length - 1);
        setState(() {});
      });
    }
  }

  void initVariableSetup(double solvepadWidth, double solvepadHeight) {
    hostImageWidth = hostSolvepadSize.height * hostImageRatio;
    hostExtraSpaceX = (hostSolvepadSize.width - hostImageWidth) / 2;
    mySolvepadSize = Size(solvepadWidth, solvepadHeight);
    myImageWidth = mySolvepadSize!.height * hostImageRatio;
    myExtraSpaceX = (mySolvepadSize!.width - myImageWidth) / 2;
    scaleImageX = myImageWidth / hostImageWidth;
    scaleX = mySolvepadSize!.width / hostSolvepadSize.width;
    scaleY = mySolvepadSize!.height / hostSolvepadSize.height;
  }

  void initConference() {
    Room room = VideoSDK.createRoom(
        roomId: widget.meetingId,
        token: widget.token,
        displayName: widget.displayName,
        micEnabled: widget.micEnabled,
        camEnabled: false,
        maxResolution: 'hd',
        multiStream: true,
        defaultCameraIndex: 1,
        notification: const NotificationInfo(
          title: "Video SDK",
          message: "Video SDK is sharing screen in the meeting",
          icon: "notification_share", // drawable icon name
        ),
        mode: Mode.CONFERENCE);
    registerMeetingEvents(room);
    room.join();
  }

  StreamSubscription? _webSocketSubscription;
  void initWss() {
    channel = WebSocketChannel.connect(
      Uri.parse(
          'ws://34.143.240.238:3000/${widget.courseId}/${widget.startTime}'),
    );
    log('connect to WSS');
    sendMessage('RequestSolvepadSize');

    _webSocketSubscription = channel?.stream.listen((message) {
      if (!mounted) return;
      setState(() {
        var decodedMessage = json.decode(message);
        log('json message');
        log(decodedMessage.toString());

        for (int i = 0; i < decodedMessage.length; i++) {
          var item = decodedMessage[i];
          var data = item['data'];
          var uid = item['uid'];
          if (data.startsWith('RequestScreenShare') ||
              data.startsWith('FocusStudentScreen') ||
              data.startsWith('HostLeaveScreen') ||
              data.startsWith('EndMeeting')) {
            for (var entry in handlers.entries) {
              if (data.startsWith(entry.key)) {
                entry.value(data);
                break;
              }
            }
          } //
          else if (uid != widget.userId &&
              uid == courseController.courseData!.tutorId) {
            if (!isHostRequestShareScreen) {
              for (var entry in handlers.entries) {
                if (data.startsWith(entry.key)) {
                  entry.value(data);
                  break;
                }
              }
            } else {
              if (isAllowSharingScreen && isHostFocus) {
                for (var entry in handlers.entries) {
                  if (data.startsWith(entry.key)) {
                    entry.value(data);
                    break;
                  }
                }
              }
            }
          }
        }
      });
    });
  }

  void initMessageHandler() {
    handlers = {
      'Offset': handleMessageOffset,
      'Erase': handleMessageErase,
      'null': handleMessageNull,
      'DrawingMode': handleMessageDrawingMode,
      'StrokeColor': handleMessageStrokeColor,
      'StrokeWidth': handleMessageStrokeWidth,
      'ScrollZoom': handleMessageScrollZoom,
      'ChangePage': handleMessageChangePage,
      'RequestScreenShare': handleMessageRequestScreenShare,
      'FocusStudentScreen': handleMessageFocusStudentScreen,
      'HostLeaveScreen': handleMessageHostLeaveScreen,
      'EndMeeting': handleMessageEndMeeting,
      'SetSolvepad': handleMessageSetSolvepad,
    };
  }

  void handleMessageOffset(String data) {
    var offset = convertToOffset(data);
    Color strokeColor = _strokeColors[_hostColorIndex];
    double strokeWidth = _strokeWidths[_hostStrokeWidthIndex];
    switch (_hostMode) {
      case DrawingMode.drag:
        break;
      case DrawingMode.pen:
        _hostPenPoints[_currentHostPage]
            .add(SolvepadStroke(offset, strokeColor, strokeWidth));
        break;
      case DrawingMode.laser:
        _hostLaserPoints[_currentHostPage]
            .add(SolvepadStroke(offset, strokeColor, strokeWidth));
        _hostLaserDrawing();
        break;
      case DrawingMode.highlighter:
        _hostHighlighterPoints[_currentHostPage]
            .add(SolvepadStroke(offset, strokeColor, strokeWidth));
        break;
      case DrawingMode.eraser:
        _hostEraserPoints[_currentHostPage] = offset;
        break;
      default:
        break;
    }
  }

  void handleMessageErase(String data) {
    var parts = data.split('.');
    var index = int.parse(parts.last);
    if (data.startsWith('Erase.pen')) {
      removePointStack(_hostPenPoints[_currentHostPage], index);
    } // pen
    else if (data.startsWith('Erase.high')) {
      removePointStack(_hostHighlighterPoints[_currentHostPage], index);
    } // highlighter
  }

  void handleMessageNull(String data) {
    switch (_hostMode) {
      case DrawingMode.drag:
        break;
      case DrawingMode.pen:
        _hostPenPoints[_currentHostPage].add(null);
        break;
      case DrawingMode.laser:
        _hostLaserPoints[_currentHostPage].add(null);
        _hostLaserTimer =
            Timer(const Duration(milliseconds: 1500), _hostStopLaserDrawing);
        break;
      case DrawingMode.highlighter:
        _hostHighlighterPoints[_currentHostPage].add(null);
        break;
      case DrawingMode.eraser:
        _hostEraserPoints[_currentHostPage] = const Offset(-100, -100);
        break;
      default:
        break;
    }
  }

  void handleMessageDrawingMode(String data) {
    String modeString = data.replaceAll('DrawingMode.', '');
    DrawingMode drawingMode = DrawingMode.values.firstWhere(
        (e) => e.toString() == 'DrawingMode.$modeString',
        orElse: () => DrawingMode.drag);
    _hostMode = drawingMode;
  }

  void handleMessageStrokeColor(String data) {
    var parts = data.split('.');
    var index = int.parse(parts.last);
    _hostColorIndex = index;
  }

  void handleMessageStrokeWidth(String data) {
    var parts = data.split('.');
    var index = int.parse(parts.last);
    _hostStrokeWidthIndex = index;
  }

  void handleMessageScrollZoom(String data) {
    var parts = data.split(':');
    var scrollX = double.parse(parts[1]);
    var scrollY = double.parse(parts[2]);
    var zoom = double.parse(parts.last);
    var scaledX = scaleScrollX(scrollX);
    _currentHostScrollZoom = '${parts[1]}:${parts[2]}:${parts[3]}';
    if (tabFreestyle) return;
    _transformationController[_currentPage].value = Matrix4.identity()
      ..translate(scaledX, scaleScrollY(scrollY))
      ..scale(zoom);
  }

  void handleMessageChangePage(String data) {
    var parts = data.split(':');
    var pageNumber = int.parse(parts.last);
    setState(() {
      _currentHostPage = pageNumber;
    });
    if (tabFreestyle) return;
    if (_currentPage != pageNumber) {
      _pageController.animateToPage(
        pageNumber,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void handleMessageRequestScreenShare(String data) {
    var parts = data.split(':');
    var requestAction = parts[1];
    if (requestAction == 'true') {
      isHostRequestShareScreen = true;
    } else if (requestAction == 'false') {
      isHostRequestShareScreen = false;
      isHostFocus = false;
      isAllowSharingScreen = false;
    }
  }

  void handleMessageFocusStudentScreen(String data) {
    var parts = data.split(':');
    var userId = parts[1];
    if (widget.userId == userId) {
      isHostFocus = true;
      List encodedPen = _penPoints[_currentPage].map((item) {
        if (item == null) {
          return null;
        } else {
          return item.toJson();
        }
      }).toList();
      String jsonPen = jsonEncode(encodedPen);
      List encodedHighlight = _highlighterPoints[_currentPage].map((item) {
        if (item == null) {
          return null;
        } else {
          return item.toJson();
        }
      }).toList();
      String jsonHigh = jsonEncode(encodedHighlight);

      for (int i = 0; i <= 2; i++) {
        switch (_mode) {
          case DrawingMode.drag:
            sendMessage('DrawingMode.drag');
            break;
          case DrawingMode.pen:
            sendMessage('DrawingMode.pen');
            break;
          case DrawingMode.highlighter:
            sendMessage('DrawingMode.highlighter');
            break;
          case DrawingMode.laser:
            sendMessage('DrawingMode.laser');
            break;
          case DrawingMode.eraser:
            sendMessage('DrawingMode.eraser');
            break;
        }
        sendMessage('StrokeColor.$_selectedIndexColors');
        sendMessage('StrokeWidth.$_selectedIndexLines');
      }

      sendMessage(
          'InstantArt|$_currentPage|$_currentScrollZoom|$jsonPen|$jsonHigh');
    } else {
      isHostFocus = false;
    }
  }

  void handleMessageHostLeaveScreen(String data) {
    var parts = data.split(':');
    var userId = parts[1];
    if (userId == widget.userId) {
      isHostFocus = false;
    }
  }

  void handleMessageEndMeeting(String data) async {
    meeting.leave();
    if (!mounted) return;
    if (isStudentLeave) return;
    await saveReviewNote();
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void handleMessageSetSolvepad(String data) {
    var parts = data.split(':');
    setState(() {
      hostSolvepadSize = Size(double.parse(parts[1]), double.parse(parts[2]));
      initVariableSetup(mySolvepadSize!.width, mySolvepadSize!.height);
    });
  }

  Offset convertToOffset(String offsetString) {
    final matched = RegExp(r'Offset\((.*), (.*)\)').firstMatch(offsetString);
    final dx = double.tryParse(matched!.group(1)!);
    final dy = double.tryParse(matched.group(2)!);
    return scaleOffset(Offset(dx!, dy!));
  }

  Offset scaleOffset(Offset offset) {
    return Offset((offset.dx - hostExtraSpaceX) * scaleImageX + myExtraSpaceX,
        offset.dy * scaleY);
  }

  double scaleScrollX(double scrollX) => scrollX * scaleX;
  double scaleScrollY(double scrollY) => scrollY * scaleY;

  Future<void> saveReviewNote() async {
    // Convert the data to JSON format
    Map<String, dynamic> data = {
      'penPoints': _penPoints
          .map((list) => list.map((stroke) => stroke?.toJson()).toList())
          .toList(),
      'laserPoints': _laserPoints
          .map((list) => list.map((stroke) => stroke?.toJson()).toList())
          .toList(),
      'highlighterPoints': _highlighterPoints
          .map((list) => list.map((stroke) => stroke?.toJson()).toList())
          .toList(),
    };
    String jsonString = jsonEncode(data);

    // 1. Save data to a text file
    final directory = await getApplicationDocumentsDirectory();
    final File file =
        File('${directory.path}/${widget.courseId}-${widget.startTime}.txt');
    await file.writeAsString(jsonString);

    // 2. Upload the text file to Firebase Storage
    final Reference storageReference = FirebaseStorage.instance.ref().child(
        'self_review_note/${widget.userId}-${widget.courseId}-${widget.startTime}.txt');
    final UploadTask uploadTask = storageReference.putFile(file);
    await uploadTask.whenComplete(() async {
      // 3. Get the returned URL
      final String downloadUrl = await storageReference.getDownloadURL();

      // 4. Write to Firestore database
      final CollectionReference reviewNotes =
          FirebaseFirestore.instance.collection('review_note');
      await reviewNotes.add({
        'course_id': widget.courseId,
        'note_file': downloadUrl,
        'session_start': widget.startTime,
        'student_id': widget.userId,
        'update_time': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  dispose() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    // ]);
    _pageController.dispose();
    _meetingTimer?.cancel();
    log('somehow I disposed');
    closeChanel();
    meeting.leave();
    super.dispose();
  }

  // ---------- FUNCTION: WSS
  void closeChanel() {
    log('close Chanel');
    channel?.sink.close();
    _webSocketSubscription?.cancel();
  }

  void sendMessage(dynamic data) {
    if (widget.isMock) return;
    try {
      final message = json.encode({'uid': widget.userId, 'data': data});
      channel?.sink.add(message);
    } catch (e) {
      log('Error sending message: $e');
    }
  }

  void sendCatchupMessage() {
    if (widget.isMock) return;
    try {
      final message = json.encode({'uid': widget.userId, 'type': 'catch_up'});
      log('catch-up message');
      log(message);
      channel?.sink.add(message);
    } catch (e) {
      log('Error sending message: $e');
    }
  }

  // ---------- FUNCTION: conference
  void registerMeetingEvents(Room _meeting) {
    // Called when joined in meeting
    _meeting.on(
      Events.roomJoined,
      () {
        setState(() {
          meeting = _meeting;
          _joined = true;
          initWss();
        });
      },
    );

    // Called when meeting is ended
    _meeting.on(Events.roomLeft, (String? errorMsg) {
      if (errorMsg != null) {
        log("Meeting left due to $errorMsg !!");
      }
      // Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(builder: (context) => const JoinScreen()),
      //     (route) => false);
    });

    // Called when recording is started
    _meeting.on(Events.recordingStateChanged, (String status) {
      log('Conference Recording start');

      setState(() {
        recordingState = status;
      });
    });

    // Called when stream is enabled
    _meeting.localParticipant.on(Events.streamEnabled, (Stream _stream) {
      if (_stream.kind == 'video') {
        setState(() {
          videoStream = _stream;
        });
      } else if (_stream.kind == 'audio') {
        setState(() {
          audioStream = _stream;
        });
      } else if (_stream.kind == 'share') {
        setState(() {
          shareStream = _stream;
        });
      }
    });

    // Called when stream is disabled
    _meeting.localParticipant.on(Events.streamDisabled, (Stream _stream) {
      if (_stream.kind == 'video' && videoStream?.id == _stream.id) {
        setState(() {
          videoStream = null;
        });
      } else if (_stream.kind == 'audio' && audioStream?.id == _stream.id) {
        setState(() {
          audioStream = null;
        });
      } else if (_stream.kind == 'share' && shareStream?.id == _stream.id) {
        setState(() {
          shareStream = null;
        });
      }
    });

    // Called when presenter is changed
    _meeting.on(Events.presenterChanged, (_activePresenterId) {
      Participant? activePresenterParticipant =
          _meeting.participants[_activePresenterId];

      // Get Share Stream
      Stream? _stream = activePresenterParticipant?.streams.values
          .singleWhere((e) => e.kind == "share");

      setState(() => remoteParticipantShareStream = _stream);
    });

    _meeting.on(
        Events.error,
        (error) =>
            {log(error['name'].toString()), log(error['message'].toString())});
  }

  Future<bool> _onWillPopScope() async {
    log('somehow I pop');
    if (widget.isMock) {
      Navigator.pop(context);
    }
    closeChanel();
    meeting.leave();
    return true;
  }

  void updateRatio(String url) {
    Image image = Image.network(url);
    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      double ratio = info.image.width / info.image.height;
      hostImageRatio = ratio;
    }));
  }

  // ---------- FUNCTION: solve pad feature
  double square(double x) => x * x;
  double sqrDistanceBetween(Offset p1, Offset p2) =>
      square(p1.dx - p2.dx) + square(p1.dy - p2.dy);

  void doErase(int index, DrawingMode mode) {
    List<SolvepadStroke?> pointStack;
    if (mode == DrawingMode.pen) {
      pointStack = _penPoints[_currentPage];
      removePointStack(pointStack, index);
      if (isAllowSharingScreen && isHostFocus) {
        sendMessage('Erase.pen.$index');
      }
    } else if (mode == DrawingMode.highlighter) {
      pointStack = _highlighterPoints[_currentPage];
      removePointStack(pointStack, index);
      if (isAllowSharingScreen && isHostFocus) {
        sendMessage('Erase.high.$index');
      }
    }
  }

  void removePointStack(List<SolvepadStroke?> pointStack, int index) {
    int prevNullIndex = -1;
    int nextNullIndex = -1;
    for (int i = index; i >= 0; i--) {
      if (pointStack[i]?.offset == null) {
        prevNullIndex = i;
        break;
      }
      if (i == 0) prevNullIndex = i;
    }
    for (int i = index; i < pointStack.length; i++) {
      if (pointStack[i]?.offset == null) {
        nextNullIndex = i;
        break;
      }
    }
    if (prevNullIndex != -1 && nextNullIndex != -1) {
      setState(() {
        pointStack.removeRange(prevNullIndex, nextNullIndex);
      });
    }
  }

  void _laserDrawing() {
    _laserTimer?.cancel();
  }

  void _stopLaserDrawing() {
    setState(() {
      _laserPoints[_currentPage].clear();
    });
  }

  void _hostLaserDrawing() {
    _hostLaserTimer?.cancel();
  }

  void _hostStopLaserDrawing() {
    setState(() {
      _hostLaserPoints[_currentPage].clear();
    });
  }

  void snapFollow() {
    _pageController.animateToPage(
      _currentHostPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    var parts = _currentHostScrollZoom.split(':');
    var scrollX = double.parse(parts[0]);
    var scrollY = double.parse(parts[1]);
    var zoom = double.parse(parts.last);
    if (_currentHostScrollZoom != '') {
      _transformationController[_currentHostPage].value = Matrix4.identity()
        ..translate(scaleScrollX(scrollX), scaleScrollY(scrollY))
        ..scale(zoom);
    }
  }

  // ---------- FUNCTION: page control
  void _addPage() {
    setState(() {
      _penPoints.add([]);
      _laserPoints.add([]);
      _highlighterPoints.add([]);
      _eraserPoints.add(const Offset(-100, -100));
      _hostPenPoints.add([]);
      _hostLaserPoints.add([]);
      _hostHighlighterPoints.add([]);
      _hostEraserPoints.add(const Offset(-100, -100));
    });
  }

  void _onPageViewChange(int page) {
    setState(() {
      for (var point in _laserPoints) {
        point.clear();
      }
      _currentPage = page;
      _penPoints[_currentPage].add(null);
    });
  }

  String _formatElapsedTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return ' $hours : $minutes : $seconds ';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: _joined && isCourseLoaded
          ? Scaffold(
              backgroundColor: CustomColors.grayCFCFCF,
              body: !Responsive.isMobile(context)
                  ? _buildTablet()
                  : fullScreen
                      ? _buildMobileFullScreen()
                      : _buildMobile(),
            )
          : const LoadingScreen(),
    );
  }

  Widget _buildTablet() {
    return Scaffold(
      backgroundColor: CustomColors.grayCFCFCF,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                headerLayer1(),
                const DividerLine(),
                headerLayer2(),
                const DividerLine(),

                //Body Layout
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tabFreestyle ? tools() : toolsDisable(),
                      solvePad(),
                    ],
                  ),
                ),
              ],
            ),

            /// Status ShareScreen

            Positioned(
              top: 145,
              right: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isAllowSharingScreen && isHostFocus)
                    statusShareNowScreen(
                      "กำลังแชร์หน้าจอ",
                      ImageAssets.shareGreen,
                    ),
                  if ((isHostRequestShareScreen && !isAllowSharingScreen) ||
                      (isHostRequestShareScreen &&
                          isAllowSharingScreen &&
                          !isHostFocus))
                    statusScreen(
                      "ติวเตอร์ขอดูจอคุณ",
                      ImageAssets.shareGreen,
                      'green',
                    ),
                ],
              ),
            ),
            if (openColors)
              Positioned(
                left: 150,
                bottom: 50,
                child: Container(
                  width: 55,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: CustomColors.grayCFCFCF,
                      style: BorderStyle.solid,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(64),
                    color: CustomColors.whitePrimary,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _listColors.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedIndexColors = index;
                                      openColors = !openColors;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Image.asset(
                                      _listColors[index]['color'],
                                    ),
                                  ),
                                ),
                                S.h(4)
                              ],
                            );
                          })
                    ],
                  ),
                ),
              ),
            if (openLines)
              Positioned(
                left: 150,
                bottom: 50,
                child: Container(
                  width: 55,
                  height: 220,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: CustomColors.grayCFCFCF,
                      style: BorderStyle.solid,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(64),
                    color: CustomColors.whitePrimary,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _listLines.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                                onTap: () {
                                  setState(() {
                                    setState(() {
                                      _selectedIndexLines = index;
                                      openLines = !openLines;
                                    });
                                  });
                                },
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Image.asset(
                                        _selectedIndexLines == index
                                            ? _listLines[index]['image_active']
                                            : _listLines[index]['image_dis'],
                                      ),
                                    ),
                                    S.h(8)
                                  ],
                                ));
                          })
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),

      /// TODO: wait for Quiz ready
      // floatingActionButton:
      //     Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      //   if (tabFreestyle)
      //     Stack(
      //       children: [
      //         InkWell(
      //           onTap: () {
      //             shareQuizModal();
      //           },
      //           child: Image.asset(
      //             ImageAssets.icQaFloat,
      //             width: 72,
      //           ),
      //         ),
      //         Positioned(
      //           top: 1,
      //           right: 1,
      //           child: Align(
      //             alignment: Alignment.topRight,
      //             child: Container(
      //               decoration: const BoxDecoration(
      //                   color: CustomColors.orangeCC6700,
      //                   shape: BoxShape.circle),
      //               width: 25,
      //               height: 25,
      //               child: Center(
      //                 child: Text(
      //                   "12",
      //                   style: CustomStyles.bold11White,
      //                 ),
      //               ),
      //             ),
      //           ),
      //         )
      //       ],
      //     ),
      //   if (tabFreestyle) S.h(20),
      //   if (tabFreestyle)
      //     InkWell(
      //       onTap: () {
      //         setState(() {
      //           statusShare = !statusShare;
      //         });
      //       },
      //       child: Image.asset(
      //         statusShare
      //             ? ImageAssets.icDisplayFloat
      //             : ImageAssets.icDisplayGray,
      //         width: 72,
      //       ),
      //     ),
      // ]),
    );
  }

  Widget _buildMobile() {
    return Scaffold(
      backgroundColor: CustomColors.grayCFCFCF,
      body: GestureDetector(
        onTap: () {
          setState(() {
            showHeader = false;
          });
        },
        child: Stack(
          children: [
            Column(
              children: [
                headerLayer2Mobile(),
                const DividerLine(),
                solvePad(),
              ],
            ),
            if (!selectedTools) toolsUndoMobile(),
            if (!selectedTools) toolsMobile(),
            if (selectedTools) toolsActiveMobile(),
            Positioned(
              top: 55,
              right: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if ((isHostRequestShareScreen && !isAllowSharingScreen) ||
                      (isHostRequestShareScreen &&
                          isAllowSharingScreen &&
                          !isHostFocus))
                    statusScreen(
                      "ติวเตอร์ขอดูจอคุณ",
                      ImageAssets.shareGreen,
                      'green',
                    ),
                  if (isAllowSharingScreen && isHostFocus)
                    statusScreen(
                      "ติวเตอร์กำลังดูจอคุณ",
                      ImageAssets.displayBlue,
                      'blue',
                    ),
                ],
              ),
            ),
            AnimatedPositioned(
              top: showHeader ? 0 : -50, // slide-down animation
              left: 0,
              right: 0,
              duration: const Duration(milliseconds: 100),
              child: GestureDetector(
                onTap: () {},
                child: headerLayer1Mobile(),
              ),
            ),
            toolsControlMobile()
          ],
        ),
      ),
    );
  }

  Widget _buildMobileFullScreen() {
    return Scaffold(
      backgroundColor: CustomColors.grayCFCFCF,
      body: Stack(
        children: [
          Column(
            children: [
              // sheetFullLayer(),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 40, bottom: 45),
              child: InkWell(
                onTap: () {
                  setState(() {
                    fullScreen = !fullScreen;
                  });
                },
                child: Image.asset(
                  ImageAssets.icHideFullFloat,
                  width: 44,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget solvePad() {
    return Expanded(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        double solvepadWidth = constraints.maxWidth;
        double solvepadHeight = constraints.maxHeight;
        if (mySolvepadSize?.width != solvepadWidth) {
          initVariableSetup(solvepadWidth, solvepadHeight);
          _currentScrollZoom =
              '${(-1 * solvepadWidth / 2).toStringAsFixed(2)}|0|2';
        }
        return Stack(children: [
          PageView.builder(
            onPageChanged: _onPageViewChange,
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              if (index >= _transformationController.length) {
                _transformationController.add(TransformationController());
                _transformationController[index].value = Matrix4.identity()
                  ..scale(2.0)
                  ..translate(-1 * solvepadWidth / 4, 0);
              }
              return IgnorePointer(
                ignoring: tabFollowing,
                child: InteractiveViewer(
                  transformationController: _transformationController[index],
                  alignment: const Alignment(-1, -1),
                  minScale: 1.0,
                  maxScale: 4.0,
                  onInteractionUpdate: (ScaleUpdateDetails details) {
                    var translation =
                        _transformationController[index].value.getTranslation();
                    double scale = _transformationController[index]
                        .value
                        .getMaxScaleOnAxis();
                    double originalTranslationY = translation.y;
                    double originalTranslationX = translation.x;
                    if (_mode == DrawingMode.drag) {
                      _currentScrollZoom =
                          '${originalTranslationX.toStringAsFixed(2)}|${originalTranslationY.toStringAsFixed(2)}|$scale';
                      // if (isAllowSharingScreen && isHostFocus) {
                      //   sendMessage(
                      //       'ScrollZoom:$_currentScrollZoom');
                      // }
                    }
                  },
                  child: Stack(
                    children: [
                      Center(
                        child: Image.network(
                          _pages[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          ignoring: _mode == DrawingMode.drag,
                          child: GestureDetector(
                            onPanDown: (_) {},
                            child: Listener(
                              onPointerDown: (details) {
                                if (activePointerId != null) return;
                                activePointerId = details.pointer;
                                if (isAllowSharingScreen && isHostFocus) {
                                  sendMessage(details.localPosition.toString());
                                }
                                switch (_mode) {
                                  case DrawingMode.pen:
                                    _penPoints[_currentPage].add(
                                      SolvepadStroke(
                                          details.localPosition,
                                          _strokeColors[_selectedIndexColors],
                                          _strokeWidths[_selectedIndexLines]),
                                    );
                                    break;
                                  case DrawingMode.laser:
                                    _laserPoints[_currentPage].add(
                                      SolvepadStroke(
                                          details.localPosition,
                                          _strokeColors[_selectedIndexColors],
                                          _strokeWidths[_selectedIndexLines]),
                                    );
                                    _laserDrawing();
                                    break;
                                  case DrawingMode.highlighter:
                                    _highlighterPoints[_currentPage].add(
                                      SolvepadStroke(
                                          details.localPosition,
                                          _strokeColors[_selectedIndexColors],
                                          _strokeWidths[_selectedIndexLines]),
                                    );
                                    break;
                                  case DrawingMode.eraser:
                                    _eraserPoints[_currentPage] =
                                        details.localPosition;
                                    int penHit = _penPoints[_currentPage]
                                        .indexWhere((point) =>
                                            (point?.offset != null) &&
                                            sqrDistanceBetween(point!.offset,
                                                    details.localPosition) <=
                                                100);
                                    int highlightHit =
                                        _highlighterPoints[_currentPage]
                                            .indexWhere((point) =>
                                                (point?.offset != null) &&
                                                sqrDistanceBetween(
                                                        point!.offset,
                                                        details
                                                            .localPosition) <=
                                                    100);
                                    if (penHit != -1) {
                                      doErase(penHit, DrawingMode.pen);
                                    }
                                    if (highlightHit != -1) {
                                      doErase(highlightHit,
                                          DrawingMode.highlighter);
                                    }
                                    break;
                                  default:
                                    break;
                                }
                              },
                              onPointerMove: (details) {
                                if (activePointerId != details.pointer) return;
                                activePointerId = details.pointer;
                                if (isAllowSharingScreen && isHostFocus) {
                                  sendMessage(details.localPosition.toString());
                                }
                                switch (_mode) {
                                  case DrawingMode.pen:
                                    setState(() {
                                      _penPoints[_currentPage].add(
                                          SolvepadStroke(
                                              details.localPosition,
                                              _strokeColors[
                                                  _selectedIndexColors],
                                              _strokeWidths[
                                                  _selectedIndexLines]));
                                    });
                                    break;
                                  case DrawingMode.laser:
                                    setState(() {
                                      _laserPoints[_currentPage].add(
                                        SolvepadStroke(
                                            details.localPosition,
                                            _strokeColors[_selectedIndexColors],
                                            _strokeWidths[_selectedIndexLines]),
                                      );
                                    });
                                    _laserDrawing();
                                    break;
                                  case DrawingMode.highlighter:
                                    setState(() {
                                      _highlighterPoints[_currentPage].add(
                                        SolvepadStroke(
                                            details.localPosition,
                                            _strokeColors[_selectedIndexColors],
                                            _strokeWidths[_selectedIndexLines]),
                                      );
                                    });
                                    break;
                                  case DrawingMode.eraser:
                                    setState(() {
                                      _eraserPoints[_currentPage] =
                                          details.localPosition;
                                    });
                                    int penHit = _penPoints[_currentPage]
                                        .indexWhere((point) =>
                                            (point?.offset != null) &&
                                            sqrDistanceBetween(point!.offset,
                                                    details.localPosition) <=
                                                100);
                                    int highlightHit =
                                        _highlighterPoints[_currentPage]
                                            .indexWhere((point) =>
                                                (point?.offset != null) &&
                                                sqrDistanceBetween(
                                                        point!.offset,
                                                        details
                                                            .localPosition) <=
                                                    500);
                                    if (penHit != -1) {
                                      doErase(penHit, DrawingMode.pen);
                                    }
                                    if (highlightHit != -1) {
                                      doErase(highlightHit,
                                          DrawingMode.highlighter);
                                    }
                                    break;
                                  default:
                                    break;
                                }
                              },
                              onPointerUp: (details) {
                                if (activePointerId != details.pointer) return;
                                activePointerId = null;
                                if (isAllowSharingScreen && isHostFocus) {
                                  for (int i = 0; i <= 2; i++) {
                                    sendMessage('null');
                                  }
                                }
                                switch (_mode) {
                                  case DrawingMode.pen:
                                    _penPoints[_currentPage].add(null);
                                    break;
                                  case DrawingMode.laser:
                                    _laserPoints[_currentPage].add(null);
                                    _laserTimer = Timer(
                                        const Duration(milliseconds: 1500),
                                        _stopLaserDrawing);
                                    break;
                                  case DrawingMode.highlighter:
                                    _highlighterPoints[_currentPage].add(null);
                                    break;
                                  case DrawingMode.eraser:
                                    setState(() {
                                      _eraserPoints[_currentPage] =
                                          Offset(-100, -100);
                                    });
                                    break;
                                  default:
                                    break;
                                }
                              },
                              onPointerCancel: (details) {
                                if (activePointerId != details.pointer) return;
                                activePointerId = null;
                                if (isAllowSharingScreen && isHostFocus) {
                                  for (int i = 0; i <= 2; i++) {
                                    sendMessage('null');
                                  }
                                }
                                switch (_mode) {
                                  case DrawingMode.pen:
                                    _penPoints[_currentPage].add(null);
                                    break;
                                  case DrawingMode.laser:
                                    _laserPoints[_currentPage].add(null);
                                    _laserTimer = Timer(
                                        const Duration(milliseconds: 1500),
                                        _stopLaserDrawing);
                                    break;
                                  case DrawingMode.highlighter:
                                    _highlighterPoints[_currentPage].add(null);
                                    break;
                                  case DrawingMode.eraser:
                                    setState(() {
                                      _eraserPoints[_currentPage] =
                                          Offset(-100, -100);
                                    });
                                    break;
                                  default:
                                    break;
                                }
                              },
                              child: CustomPaint(
                                painter: SolvepadDrawer(
                                  _penPoints[index],
                                  _eraserPoints[index],
                                  _laserPoints[index],
                                  _highlighterPoints[index],
                                  _hostPenPoints[index],
                                  _hostLaserPoints[index],
                                  _hostHighlighterPoints[index],
                                  _hostEraserPoints[index],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (isAllowSharingScreen)
            IgnorePointer(
              ignoring: true,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: (isAllowSharingScreen && !isHostFocus)
                        ? Colors.green
                        : isHostFocus
                            ? Colors.blue
                            : Colors.transparent,
                    width: 4.0, // choose the width of the border
                  ),
                ),
              ),
            ),
        ]);
      }),
    );
  }

  Widget headerLayer1() {
    return Container(
      height: 60,
      color: CustomColors.whitePrimary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          S.w(Responsive.isTablet(context) ? 5 : 24),
          if (Responsive.isTablet(context))
            Expanded(
              flex: 3,
              child: Text(
                "คอร์สปรับพื้นฐานคณิตศาสตร์ ก่อนขึ้น ม.4  - 01 ม.ค. 2023",
                style: CustomStyles.bold16Black363636Overflow,
                maxLines: 1,
              ),
            ),
          if (Responsive.isDesktop(context))
            Expanded(
              flex: 4,
              child: Text(
                courseName,
                style: CustomStyles.bold16Black363636Overflow,
                maxLines: 1,
              ),
            ),
          if (Responsive.isMobile(context))
            Expanded(
              flex: 2,
              child: Text(
                "คอร์สปรับพื้นฐานคณิตศาสตร์ ก่อนขึ้น ม.4  - 01 ม.ค. 2023",
                style: CustomStyles.bold16Black363636Overflow,
                maxLines: 1,
              ),
            ),
          Expanded(
            flex: Responsive.isDesktop(context) ? 3 : 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Container(
                //   height: 32,
                //   width: 145,
                //   // margin: EdgeInsets.only(top: defaultPadding),
                //   // padding: EdgeInsets.all(defaultPadding),
                //   decoration: const BoxDecoration(
                //     color: CustomColors.pinkFFCDD2,
                //     borderRadius: BorderRadius.all(
                //       Radius.circular(defaultPadding),
                //     ),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Image.asset(
                //         ImageAssets.lowSignal,
                //         height: 22,
                //         width: 18,
                //       ),
                //       S.w(10),
                //       Flexible(
                //         child: Text(
                //           "สัญญาณอ่อน",
                //           style: CustomStyles.bold14redB71C1C,
                //           maxLines: 1,
                //           overflow: TextOverflow.ellipsis,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                S.w(16.0),
                Container(
                  height: 11,
                  width: 11,
                  decoration: BoxDecoration(
                      color: CustomColors.redF44336,
                      borderRadius: BorderRadius.circular(100)
                      //more than 50% of width makes circle
                      ),
                ),
                S.w(4.0),
                InkWell(
                  onTap: () {
                    log(hostSolvepadSize.toString());
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Live Time: ',
                      style: CustomStyles.med14redFF4201,
                      children: <TextSpan>[
                        TextSpan(
                          text: _formattedElapsedTime,
                          style: CustomStyles.med14Gray878787,
                        ),
                      ],
                    ),
                  ),
                ),
                S.w(16.0),
                InkWell(
                  onTap: () {
                    showCloseDialog(context, () async {
                      if (!widget.isMock) meeting.leave();
                      isStudentLeave = true;
                      await saveReviewNote();
                      if (!mounted) return;
                      Navigator.push(
                          context, MaterialPageRoute(builder: (_) => Nav()));
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding * 1,
                      vertical: defaultPadding / 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: CustomColors.redF44336,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "ออกห้อง",
                          style: CustomStyles.bold14White,
                        ),
                      ],
                    ),
                  ),
                ),
                S.w(Responsive.isTablet(context) ? 5 : 24),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget headerLayer2() {
    return Container(
      height: 70,
      decoration: BoxDecoration(color: CustomColors.whitePrimary, boxShadow: [
        BoxShadow(
            color: CustomColors.gray878787.withOpacity(.1),
            offset: const Offset(0.0, 6),
            blurRadius: 10,
            spreadRadius: 1)
      ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          S.w(Responsive.isTablet(context) ? 5 : 12),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: CustomColors.grayCFCFCF,
                          style: BorderStyle.solid,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: CustomColors.whitePrimary,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Image.asset(
                          //   ImageAssets.allPages,
                          //   height: 30,
                          //   width: 32,
                          // ),
                          // if (Responsive.isDesktop(context)) S.w(8),
                          // if (Responsive.isDesktop(context))
                          //   Container(
                          //     width: 1,
                          //     height: 24,
                          //     color: CustomColors.grayCFCFCF,
                          //   ),
                          InkWell(
                            onTap: () {
                              if (_pageController.hasClients &&
                                  _pageController.page!.toInt() != 0 &&
                                  !tabFollowing) {
                                if (isAllowSharingScreen && isHostFocus) {
                                  for (int i = 0; i <= 2; i++) {
                                    sendMessage(
                                        'ChangePage:${_currentPage - 1}');
                                  }
                                }
                                _pageController.animateToPage(
                                  _pageController.page!.toInt() - 1,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                ImageAssets.backDis,
                                height: 16,
                                width: 17,
                                color: _isPrevBtnActive
                                    ? CustomColors.activePagingBtn
                                    : CustomColors.inactivePagingBtn,
                              ),
                            ),
                          ),
                          if (Responsive.isDesktop(context)) S.w(8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: CustomColors.grayCFCFCF,
                                style: BorderStyle.solid,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              color: CustomColors.whitePrimary,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text("Page ${_currentPage + 1}",
                                    style: CustomStyles.bold14greenPrimary),
                              ],
                            ),
                          ),
                          S.w(8.0),
                          Text("/ ${_pages.length}",
                              style: CustomStyles.med14Gray878787),
                          InkWell(
                            onTap: () {
                              if (_pages.length > 1 && !tabFollowing) {
                                if (_pageController.hasClients &&
                                    _pageController.page!.toInt() !=
                                        _pages.length - 1) {
                                  if (isAllowSharingScreen && isHostFocus) {
                                    for (int i = 0; i <= 2; i++) {
                                      sendMessage(
                                          'ChangePage:${_currentPage + 1}');
                                    }
                                  }
                                  _pageController.animateToPage(
                                    _pageController.page!.toInt() + 1,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                ImageAssets.forward,
                                height: 16,
                                width: 17,
                                color: _isNextBtnActive
                                    ? CustomColors.activePagingBtn
                                    : CustomColors.inactivePagingBtn,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  S.w(defaultPadding),
                  const DividerVer(),
                  S.w(defaultPadding),
                  InkWell(
                    onTap: () {
                      // sendCatchupMessage();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: CustomColors.greenPrimary,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child:
                          Text("ไปหน้าที่สอน", style: CustomStyles.bold14White),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      if (tabFreestyle == true) {
                        tabFollowing = !tabFollowing;
                        tabFreestyle = false;
                        snapFollow();
                      }
                    });
                  },
                  child: Container(
                    height: 50,
                    width: 120,
                    decoration: BoxDecoration(
                      color: tabFollowing
                          ? CustomColors.greenE5F6EB
                          : CustomColors.whitePrimary,
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: CustomColors.grayCFCFCF,
                        style: BorderStyle.solid,
                        width: 1.0,
                      ),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(50.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          tabFollowing
                              ? ImageAssets.avatarMe
                              : ImageAssets.avatarDisMe,
                          width: 32,
                        ),
                        S.w(8),
                        Text("เรียนรู้",
                            style: tabFollowing
                                ? CustomStyles.bold14greenPrimary
                                : CustomStyles.bold14grayCFCFCF),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      if (tabFollowing == true) {
                        tabFreestyle = !tabFreestyle;
                        tabFollowing = false;
                      }
                    });
                  },
                  child: Container(
                    height: 50,
                    width: 120,
                    decoration: BoxDecoration(
                      color: tabFreestyle
                          ? CustomColors.greenE5F6EB
                          : CustomColors.whitePrimary,
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: CustomColors.grayCFCFCF,
                        style: BorderStyle.solid,
                        width: 1.0,
                      ),
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(50.0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          tabFreestyle
                              ? ImageAssets.pencilActive
                              : ImageAssets.penDisTab,
                          width: 32,
                        ),
                        S.w(8),
                        Text("เขียนอิสระ",
                            style: tabFreestyle
                                ? CustomStyles.bold14greenPrimary
                                : CustomStyles.bold14grayCFCFCF),
                      ],
                    ),
                  ),
                ),
                // S.w(8),
                // Container(
                //   width: 1,
                //   height: 32,
                //   color: CustomColors.grayCFCFCF,
                // ),
                // S.w(8),
                // InkWell(
                //   onTap: () {},
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 6,
                //       vertical: 10,
                //     ),
                //     decoration: BoxDecoration(
                //       color: CustomColors.greenPrimary,
                //       borderRadius: BorderRadius.circular(8.0),
                //     ),
                //     child:
                //         Text("ไปหน้าที่สอน", style: CustomStyles.bold14White),
                //   ),
                // ),
              ],
            ),
          ),

          /// Statistics
          // Expanded(
          //   flex: 2,
          //   child: Align(
          //     alignment: Alignment.centerRight,
          //     child: InkWell(
          //       onTap: () {
          //         log('Go to Statistics');
          //         showLeader(context);
          //       },
          //       child: Container(
          //         decoration: BoxDecoration(
          //           border: Border.all(
          //             color: CustomColors.grayCFCFCF,
          //             style: BorderStyle.solid,
          //             width: 1.0,
          //           ),
          //           borderRadius: BorderRadius.circular(8),
          //           color: CustomColors.whitePrimary,
          //         ),
          //         padding:
          //             const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
          //         child: Padding(
          //           padding: const EdgeInsets.all(6.0),
          //           child: Row(
          //             mainAxisSize: MainAxisSize.min,
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: <Widget>[
          //               Image.asset(
          //                 ImageAssets.leaderboard,
          //                 height: 23,
          //                 width: 25,
          //               ),
          //               S.w(8),
          //               Container(
          //                 width: 1,
          //                 height: 24,
          //                 color: CustomColors.grayCFCFCF,
          //               ),
          //               S.w(8),
          //               Image.asset(
          //                 ImageAssets.checkTrue,
          //                 height: 18,
          //                 width: 18,
          //               ),
          //               if (!Responsive.isTablet(context)) S.w(8.0),
          //               Text("7", style: CustomStyles.bold14Gray878787),
          //               if (!Responsive.isTablet(context)) S.w(8.0),
          //               Image.asset(
          //                 ImageAssets.x,
          //                 height: 18,
          //                 width: 18,
          //               ),
          //               if (!Responsive.isTablet(context)) S.w(8.0),
          //               Text("5", style: CustomStyles.bold14Gray878787),
          //               if (!Responsive.isTablet(context)) S.w(8.0),
          //               Image.asset(
          //                 ImageAssets.icQa,
          //                 height: 18,
          //                 width: 18,
          //               ),
          //               if (!Responsive.isTablet(context)) S.w(8.0),
          //               Text("0", style: CustomStyles.bold14Gray878787),
          //               if (!Responsive.isTablet(context)) S.w(8.0),
          //               Image.asset(
          //                 ImageAssets.arrowNextCircle,
          //                 width: 21,
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Material(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          micEnable = !micEnable;
                        });
                        if (micEnable && !widget.isMock) {
                          meeting.unmuteMic();
                        } else {
                          meeting.muteMic();
                        }
                      },
                      child: Image.asset(
                        micEnable ? ImageAssets.micEnable : ImageAssets.micDis,
                        height: 44,
                        width: 44,
                      ),
                    ),
                  ),
                  S.w(defaultPadding),
                  const DividerVer(),
                  S.w(defaultPadding),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isHostRequestShareScreen
                            ? Colors.blue
                            : Colors.grey,
                        style: BorderStyle.solid,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(100),
                      color: CustomColors.whitePrimary,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Transform.scale(
                          scale: 0.7,
                          child: CupertinoSwitch(
                            trackColor: Colors.blue.withOpacity(0.1),
                            activeColor: Colors.blue,
                            value: isAllowSharingScreen,
                            onChanged: (bool value) {
                              if (isHostRequestShareScreen) {
                                setState(() {
                                  isAllowSharingScreen = !isAllowSharingScreen;
                                });
                                if (isAllowSharingScreen) {
                                  // sendMessage('TEST_MESSAGE');
                                  setState(() {
                                    tabFollowing = false;
                                    tabFreestyle = true;
                                  });
                                  sendMessage(
                                      'StudentShareScreen:enable:${mySolvepadSize?.width.toStringAsFixed(2)}:${mySolvepadSize?.height.toStringAsFixed(2)}');
                                } else {
                                  sendMessage('StudentShareScreen:disable');
                                }
                              } else {
                                log('host not request');
                              }
                            },
                          ),
                        ),
                        Text("อนุญาตแชร์จอ",
                            textAlign: TextAlign.center,
                            style: isHostRequestShareScreen
                                ? CustomStyles.bold14bluePrimary
                                : CustomStyles.reg14Gray878787),
                        S.w(4)
                      ],
                    ),
                  ),
                  S.w(32),
                ],
              ),
            ),
          ),
          S.w(Responsive.isTablet(context) ? 5 : 24),
        ],
      ),
    );
  }

  Widget headerLayer1Mobile() {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 50,
            color: CustomColors.whitePrimary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                S.w(defaultPadding),
                if (Responsive.isMobile(context))
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            showHeader = false;
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: CustomColors.gray878787,
                              size: 24,
                            ),
                          ),
                        ),
                        S.w(8),
                        Flexible(
                          child: Text(
                            courseName,
                            style: CustomStyles.bold16Black363636Overflow,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      S.w(16.0),
                      Container(
                        height: 11,
                        width: 11,
                        decoration: BoxDecoration(
                            color: CustomColors.redF44336,
                            borderRadius: BorderRadius.circular(100)
                            //more than 50% of width makes circle
                            ),
                      ),
                      S.w(4.0),
                      RichText(
                        text: TextSpan(
                          text: 'Live Time: ',
                          style: CustomStyles.med14redFF4201,
                          children: <TextSpan>[
                            TextSpan(
                              text: _formattedElapsedTime,
                              style: CustomStyles.med14Gray878787,
                            ),
                          ],
                        ),
                      ),
                      S.w(defaultPadding),
                    ],
                  ),
                )
              ],
            ),
          ),
          const DividerLine(),
        ],
      ),
    );
  }

  Widget headerLayer2Mobile() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: CustomColors.whitePrimary,
        boxShadow: [
          BoxShadow(
            color: CustomColors.gray878787.withOpacity(.1),
            offset: const Offset(0.0, 6),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 38,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: CustomColors.grayCFCFCF,
                      style: BorderStyle.solid,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: CustomColors.whitePrimary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          showHeader = true;
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            top: 4,
                            bottom: 4,
                          ),
                          child: Image.asset(
                            ImageAssets.iconInfoPage,
                            height: 24,
                            width: 24,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 32,
                        color: CustomColors.grayCFCFCF,
                      ),
                      S.w(8),
                      Image.asset(
                        ImageAssets.allPages,
                        height: 24,
                        width: 24,
                      ),
                      S.w(8),
                      // Container(
                      //   width: 1,
                      //   height: 32,
                      //   color: CustomColors.grayCFCFCF,
                      // ),
                      // S.w(8),
                      // Transform.scale(
                      //   scale: 0.6,
                      //   child: CupertinoSwitch(
                      //     trackColor: Colors.orange,
                      //     value: tabFollowing,
                      //     onChanged: (bool value) {
                      //       setState(() {
                      //         tabFollowing = value;
                      //         tabFreestyle = !value;
                      //         if (tabFollowing) {
                      //           snapFollow();
                      //         }
                      //       });
                      //     },
                      //   ),
                      // ),
                      // Text(
                      //     tabFollowing
                      //         ? "เลื่อนหน้าตามติวเตอร์"
                      //         : "เลื่อนหน้าอิสระ",
                      //     style: CustomStyles.bold12gray878787),
                      // S.w(16.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      if (tabFreestyle == true) {
                        tabFollowing = !tabFollowing;
                        tabFreestyle = false;
                        snapFollow();
                      }
                    });
                  },
                  child: Container(
                    height: 40,
                    width: 110,
                    decoration: BoxDecoration(
                      color: tabFollowing
                          ? CustomColors.greenE5F6EB
                          : CustomColors.whitePrimary,
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: CustomColors.grayCFCFCF,
                        style: BorderStyle.solid,
                        width: 1.0,
                      ),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(40.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          tabFollowing
                              ? ImageAssets.avatarMe
                              : ImageAssets.avatarDisMe,
                          width: 32,
                        ),
                        S.w(8),
                        Text("เรียนรู้",
                            style: tabFollowing
                                ? CustomStyles.bold14greenPrimary
                                : CustomStyles.bold14grayCFCFCF),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      if (tabFollowing == true) {
                        tabFreestyle = !tabFreestyle;
                        tabFollowing = false;
                      }
                    });
                  },
                  child: Container(
                    height: 40,
                    width: 110,
                    decoration: BoxDecoration(
                      color: tabFreestyle
                          ? CustomColors.greenE5F6EB
                          : CustomColors.whitePrimary,
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: CustomColors.grayCFCFCF,
                        style: BorderStyle.solid,
                        width: 1.0,
                      ),
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(40.0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          tabFreestyle
                              ? ImageAssets.pencilActive
                              : ImageAssets.penDisTab,
                          width: 32,
                        ),
                        S.w(8),
                        Text("เขียนอิสระ",
                            style: tabFreestyle
                                ? CustomStyles.bold14greenPrimary
                                : CustomStyles.bold14grayCFCFCF),
                      ],
                    ),
                  ),
                ),
                // S.w(8),
                // Container(
                //   width: 1,
                //   height: 32,
                //   color: CustomColors.grayCFCFCF,
                // ),
                // S.w(8),
                // InkWell(
                //   onTap: () {},
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 6,
                //       vertical: 10,
                //     ),
                //     decoration: BoxDecoration(
                //       color: CustomColors.greenPrimary,
                //       borderRadius: BorderRadius.circular(8.0),
                //     ),
                //     child:
                //         Text("ไปหน้าที่สอน", style: CustomStyles.bold14White),
                //   ),
                // ),
              ],
            ),
          ),
          const Expanded(
            child: SizedBox(),
          ),
          // Expanded(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: [
          //       ClipRRect(
          //         borderRadius: BorderRadius.circular(32),
          //         child: Image.network(
          //           authProvider.user!.image!,
          //           height: 32,
          //           width: 32,
          //         ),
          //       ),
          //       S.w(8),
          //
          //       /// TODO: revise this when Quiz is ready
          //       // Container(
          //       //   height: 32,
          //       //   decoration: BoxDecoration(
          //       //     border: Border.all(
          //       //       color: CustomColors.grayCFCFCF,
          //       //       style: BorderStyle.solid,
          //       //       width: 1.0,
          //       //     ),
          //       //     borderRadius: BorderRadius.circular(8),
          //       //     color: CustomColors.whitePrimary,
          //       //   ),
          //       //   child: Row(
          //       //     mainAxisAlignment: MainAxisAlignment.center,
          //       //     children: <Widget>[
          //       //       S.w(8),
          //       //       InkWell(
          //       //         onTap: () {
          //       //           showLeader(context);
          //       //         },
          //       //         child: Image.asset(
          //       //           ImageAssets.leaderboard,
          //       //           height: 24,
          //       //           width: 24,
          //       //         ),
          //       //       ),
          //       //       S.w(8),
          //       //     ],
          //       //   ),
          //       // ),
          //       // S.w(defaultPadding),
          //       InkWell(
          //         onTap: () {
          //           log('tap catch-up');
          //           // sendCatchupMessage();
          //         },
          //         child: Container(
          //           height: 32,
          //           padding: const EdgeInsets.symmetric(
          //             horizontal: 6,
          //             vertical: 10,
          //           ),
          //           decoration: BoxDecoration(
          //             color: CustomColors.greenPrimary,
          //             borderRadius: BorderRadius.circular(8.0),
          //           ),
          //           child:
          //               Text("ไปหน้าที่สอน", style: CustomStyles.bold11White),
          //         ),
          //       ),
          //       S.w(28),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  void updateDataHistory(dynamic updateMode) {
    setState(() {
      _mode = updateMode;
    });
  }

  /// Tools
  Widget tools() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (Responsive.isDesktop(context)) S.w(10),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
              height: selectedTools ? 350 : MediaQuery.of(context).size.height,
              width: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: CustomColors.grayCFCFCF,
                  style: BorderStyle.solid,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(64),
                color: CustomColors.whitePrimary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  S.h(16),
                  selectedTools
                      ? Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  _listTools[_selectedIndexTools]
                                      ['image_active'],
                                  width: 10.w,
                                )
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          flex: 4,
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: _listTools.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    S.h(8),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedIndexTools = index;
                                        });
                                        if (index == 0) {
                                          updateDataHistory(DrawingMode.drag);
                                          if (isAllowSharingScreen &&
                                              isHostFocus) {
                                            for (int i = 0; i <= 2; i++) {
                                              sendMessage('DrawingMode.drag');
                                            }
                                          }
                                        } else if (index == 1) {
                                          updateDataHistory(DrawingMode.pen);
                                          if (isAllowSharingScreen &&
                                              isHostFocus) {
                                            for (int i = 0; i <= 2; i++) {
                                              sendMessage('DrawingMode.pen');
                                            }
                                          }
                                        } else if (index == 2) {
                                          updateDataHistory(
                                              DrawingMode.highlighter);
                                          if (isAllowSharingScreen &&
                                              isHostFocus) {
                                            for (int i = 0; i <= 2; i++) {
                                              sendMessage(
                                                  'DrawingMode.highlighter');
                                            }
                                          }
                                        } else if (index == 3) {
                                          updateDataHistory(DrawingMode.eraser);
                                          if (isAllowSharingScreen &&
                                              isHostFocus) {
                                            for (int i = 0; i <= 2; i++) {
                                              sendMessage('DrawingMode.eraser');
                                            }
                                          }
                                        } else if (index == 4) {
                                          updateDataHistory(DrawingMode.laser);
                                          if (isAllowSharingScreen &&
                                              isHostFocus) {
                                            for (int i = 0; i <= 2; i++) {
                                              sendMessage('DrawingMode.laser');
                                            }
                                          }
                                        }
                                      },
                                      child: Image.asset(
                                        _selectedIndexTools == index
                                            ? _listTools[index]['image_active']
                                            : _listTools[index]['image_dis'],
                                        width: 10.w,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                  Container(
                      height: 2, width: 80, color: CustomColors.grayF3F3F3),
                  Expanded(
                    flex: selectedTools ? 1 : 2,
                    child: Column(
                      children: [
                        S.h(defaultPadding),
                        if (!selectedTools)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 1),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            log("Choose Color");
                                            setState(() {
                                              if (openLines ||
                                                  openMore == true) {
                                                openLines = false;
                                                openMore = false;
                                              }
                                              openColors = !openColors;
                                            });
                                          },
                                          child: Image.asset(
                                            _listColors[_selectedIndexColors]
                                                ['color'],
                                            width: 38,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            log("Pick Line");

                                            setState(() {
                                              if (openColors ||
                                                  openMore == true) {
                                                openColors = false;
                                                openMore = false;
                                              }
                                              openLines = !openLines;
                                            });
                                          },
                                          child: Image.asset(
                                            ImageAssets.pickLine,
                                            width: 38,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Expanded(
                                  //   child: Row(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.spaceEvenly,
                                  //     children: [
                                  //       InkWell(
                                  //         onTap: () {
                                  //           log("Clear");
                                  //         },
                                  //         child: Image.asset(
                                  //           ImageAssets.bin,
                                  //           width: 38,
                                  //         ),
                                  //       ),
                                  //       InkWell(
                                  //         onTap: () {
                                  //           log("More");
                                  //
                                  //           setState(() {
                                  //             if (openColors ||
                                  //                 openLines == true) {
                                  //               openColors = false;
                                  //               openLines = false;
                                  //             }
                                  //             openMore = !openMore;
                                  //           });
                                  //         },
                                  //         child: Image.asset(
                                  //           ImageAssets.more,
                                  //           width: 38,
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedTools = !selectedTools;
                                        });
                                      },
                                      child: Image.asset(
                                        selectedTools
                                            ? ImageAssets.arrowDownDouble
                                            : ImageAssets.arrowTopDouble,
                                        width: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (selectedTools)
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedTools = !selectedTools;
                                });
                              },
                              child: Image.asset(
                                selectedTools
                                    ? ImageAssets.arrowDownDouble
                                    : ImageAssets.arrowTopDouble,
                                width: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget toolsDisable() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (Responsive.isDesktop(context)) S.w(10),
        InkWell(
          onTap: () {
            final snackBar = SnackBar(
              content: Text(
                'เปลี่ยนเป็นโหมด “เขียนอิสระ” ก่อนเพื่อใช้ปากกา',
                style: CustomStyles.bold16whitePrimary,
              ),
              action: SnackBarAction(
                label: 'ไปที่โหมดเขียนอิสระ',
                textColor: CustomColors.greenPrimary,
                onPressed: () {
                  // Some code to undo the change.
                },
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedContainer(
                duration: const Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
                height:
                    selectedTools ? 270 : MediaQuery.of(context).size.height,
                width: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CustomColors.grayCFCFCF,
                    style: BorderStyle.solid,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(64),
                  color: CustomColors.whitePrimary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    S.h(16),
                    // Expanded(
                    //   flex: 1,
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: defaultPadding, vertical: 1),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //       children: [
                    //         Image.asset(
                    //           ImageAssets.undoTran,
                    //           width: 38,
                    //         ),
                    //         Image.asset(
                    //           ImageAssets.redoTran,
                    //           width: 38,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // Container(
                    //     height: 2, width: 80, color: CustomColors.grayF3F3F3),
                    Expanded(
                      flex: 4,
                      child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _listToolsDisable.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                S.h(8),
                                Image.asset(
                                  _listToolsDisable[index]['image'],
                                  width: 10.w,
                                ),
                              ],
                            );
                          }),
                    ),
                    Container(
                        height: 2, width: 80, color: CustomColors.grayF3F3F3),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          S.h(defaultPadding),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 1),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Image.asset(
                                          ImageAssets.pickGreenTran,
                                          width: 38,
                                        ),
                                        Image.asset(
                                          ImageAssets.pickLineTran,
                                          width: 38,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Image.asset(
                                          'assets/images/clear_tran.png',
                                          width: 38,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget toolsControlMobile() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                showCloseDialog(context, () async {
                  if (!widget.isMock) meeting.leave();
                  isStudentLeave = true;
                  await saveReviewNote();
                  if (!mounted) return;
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => Nav()));
                });
              },
              child: Image.asset(
                ImageAssets.iconOut,
                width: 44,
              ),
            ),
            S.h(8),

            /// TODO: Wait for Quiz ready
            // Stack(
            //   children: [
            //     InkWell(
            //       onTap: () {
            //         shareQuizModal();
            //       },
            //       child: Image.asset(
            //         ImageAssets.icQaFloat,
            //         height: 44,
            //         width: 44,
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.only(left: 24),
            //       child: Container(
            //         decoration: const BoxDecoration(
            //             color: CustomColors.black363636,
            //             shape: BoxShape.circle),
            //         width: 25,
            //         height: 25,
            //         child: Center(
            //           child: Text(
            //             "12",
            //             style: CustomStyles.bold11White,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // S.h(8),
            InkWell(
              onTap: () {
                if (isHostRequestShareScreen) {
                  setState(() {
                    isAllowSharingScreen = !isAllowSharingScreen;
                  });
                  if (isAllowSharingScreen) {
                    // sendMessage('TEST_MESSAGE');
                    setState(() {
                      tabFollowing = false;
                      tabFreestyle = true;
                    });
                    sendMessage(
                        'StudentShareScreen:enable:${mySolvepadSize?.width.toStringAsFixed(2)}:${mySolvepadSize?.height.toStringAsFixed(2)}');
                  } else {
                    sendMessage('StudentShareScreen:disable');
                  }
                } else {
                  log('host not request');
                }
              },
              child: ColorFiltered(
                colorFilter: isHostRequestShareScreen
                    ? const ColorFilter.mode(
                        Colors.transparent, BlendMode.multiply)
                    : const ColorFilter.matrix(<double>[
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                child: Image.asset(
                  ImageAssets.icDisplayFloat,
                  width: 44,
                ),
              ),
            ),
            S.h(8),
            InkWell(
              onTap: () {
                setState(() {
                  micEnable = !micEnable;
                });
                if (micEnable && !widget.isMock) {
                  meeting.unmuteMic();
                } else {
                  meeting.muteMic();
                }
              },
              child: Image.asset(
                micEnable ? ImageAssets.micEnable : ImageAssets.micDis,
                width: 44,
              ),
            ),
            S.h(8),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Select Audio Device"),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SingleChildScrollView(
                          reverse: true,
                          child: Column(
                            children: meeting
                                .getAudioOutputDevices()
                                .map(
                                  (device) => ElevatedButton(
                                    child: Text(device.label),
                                    onPressed: () => {
                                      meeting.switchAudioDevice(device),
                                      Navigator.pop(context)
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                    color: CustomColors.redFF4201, shape: BoxShape.circle),
                child: const Icon(
                  Icons.audiotrack,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),

            /// TODO: Reconsider fullscreen option
            // InkWell(
            //   onTap: () {
            //     setState(() {
            //       fullScreen = !fullScreen;
            //     });
            //   },
            //   child: Image.asset(
            //     ImageAssets.icFullFloat,
            //     width: 44,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget toolsMobile() {
    return Positioned(
      left: 15,
      bottom: 5,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Column(
          children: [
            if (openColors)
              Container(
                height: 55,
                width: 260,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CustomColors.grayCFCFCF,
                    style: BorderStyle.solid,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(64),
                  color: CustomColors.whitePrimary,
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: ListView.builder(
                      padding: const EdgeInsets.only(left: 1, right: 1),
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _listColors.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedIndexColors = index;
                                  openColors = !openColors;
                                });
                                if (isAllowSharingScreen && isHostFocus) {
                                  for (int i = 0; i <= 2; i++) {
                                    sendMessage('StrokeColor.$index');
                                  }
                                }
                              },
                              child: Image.asset(_listColors[index]['color'],
                                  width: 48),
                            ),
                            S.w(4)
                          ],
                        );
                      }),
                ),
              ),
            if (openLines)
              Container(
                height: 55,
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CustomColors.grayCFCFCF,
                    style: BorderStyle.solid,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(64),
                  color: CustomColors.whitePrimary,
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: ListView.builder(
                      padding: const EdgeInsets.only(left: 1, right: 1),
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _listLines.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  setState(() {
                                    _selectedIndexLines = index;
                                    openLines = !openLines;
                                  });
                                  if (isAllowSharingScreen && isHostFocus) {
                                    for (int i = 0; i <= 2; i++) {
                                      sendMessage('StrokeWidth.$index');
                                    }
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  Image.asset(
                                    _selectedIndexLines == index
                                        ? _listLines[index]['image_active']
                                        : _listLines[index]['image_dis'],
                                    width: 46,
                                  ),
                                  S.h(8)
                                ],
                              ),
                            ),
                            S.w(4)
                          ],
                        );
                      }),
                ),
              ),
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
              height: 65,
              // TODO: change to 430 when laser ready
              width: selectedTools ? 0 : 380,
              decoration: BoxDecoration(
                border: Border.all(
                  color: CustomColors.grayCFCFCF,
                  style: BorderStyle.solid,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(64),
                color: CustomColors.whitePrimary,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  S.h(8),
                  selectedTools
                      ? Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  _listTools[_selectedIndexTools]
                                      ['image_active'],
                                  width: 10.w,
                                )
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          // flex: 2,
                          child: Row(
                            children: [
                              ListView.builder(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  physics: const NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: _listTools.length,
                                  itemBuilder: (context, index) {
                                    return Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _selectedIndexTools = index;
                                              selectedTools = !selectedTools;
                                            });
                                            if (index == 0) {
                                              updateDataHistory(
                                                  DrawingMode.drag);
                                              if (isAllowSharingScreen &&
                                                  isHostFocus) {
                                                for (int i = 0; i <= 2; i++) {
                                                  sendMessage(
                                                      'DrawingMode.drag');
                                                }
                                              }
                                            } else if (index == 1) {
                                              updateDataHistory(
                                                  DrawingMode.pen);
                                              if (isAllowSharingScreen &&
                                                  isHostFocus) {
                                                for (int i = 0; i <= 2; i++) {
                                                  sendMessage(
                                                      'DrawingMode.pen');
                                                }
                                              }
                                            } else if (index == 2) {
                                              updateDataHistory(
                                                  DrawingMode.highlighter);
                                              if (isAllowSharingScreen &&
                                                  isHostFocus) {
                                                for (int i = 0; i <= 2; i++) {
                                                  sendMessage(
                                                      'DrawingMode.highlighter');
                                                }
                                              }
                                            } else if (index == 3) {
                                              updateDataHistory(
                                                  DrawingMode.eraser);
                                              if (isAllowSharingScreen &&
                                                  isHostFocus) {
                                                for (int i = 0; i <= 2; i++) {
                                                  sendMessage(
                                                      'DrawingMode.eraser');
                                                }
                                              }
                                            } else if (index == 4) {
                                              updateDataHistory(
                                                  DrawingMode.laser);
                                              if (isAllowSharingScreen &&
                                                  isHostFocus) {
                                                for (int i = 0; i <= 2; i++) {
                                                  sendMessage(
                                                      'DrawingMode.laser');
                                                }
                                              }
                                            }
                                          },
                                          child: Image.asset(
                                            _selectedIndexTools == index
                                                ? _listTools[index]
                                                    ['image_active']
                                                : _listTools[index]
                                                    ['image_dis'],
                                            width: 48,
                                          ),
                                        ),
                                        S.w(8),
                                      ],
                                    );
                                  }),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (openLines || openMore == true) {
                                      openLines = false;
                                      openMore = false;
                                    }
                                    openColors = !openColors;
                                  });
                                },
                                child: Image.asset(
                                  _listColors[_selectedIndexColors]['color'],
                                  width: 28,
                                ),
                              ),
                              S.w(defaultPadding),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (openColors || openMore == true) {
                                      openColors = false;
                                      openMore = false;
                                    }
                                    openLines = !openLines;
                                  });
                                },
                                child: Image.asset(
                                  ImageAssets.pickLine,
                                  width: 38,
                                ),
                              ),
                              // TODO: Do we need clear btn ?
                              // S.w(defaultPadding),
                              // InkWell(
                              //   onTap: () {
                              //     log("Clear");
                              //   },
                              //   child: Image.asset(
                              //     ImageAssets.bin,
                              //     width: 38,
                              //   ),
                              // ),
                              S.w(4),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedTools = !selectedTools;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset(
                                    ImageAssets.arrowLeftDouble,
                                    width: 14,
                                  ),
                                ),
                              ),
                            ],
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

  Widget toolsUndoMobile() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 45),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                if (_pageController.hasClients &&
                    _pageController.page!.toInt() != 0) {
                  if (isAllowSharingScreen && isHostFocus) {
                    for (int i = 0; i <= 2; i++) {
                      sendMessage('ChangePage:${_currentPage - 1}');
                    }
                    _currentHostPage = _currentPage - 1;
                  }
                  _pageController.animateToPage(
                    _pageController.page!.toInt() - 1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(90)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 10, bottom: 14),
                  child: Image.asset(
                    ImageAssets.arrowUp,
                    width: 20,
                    color: _isPrevBtnActive
                        ? CustomColors.activePagingBtn
                        : CustomColors.inactivePagingBtn,
                  ),
                ),
              ),
            ),
            S.h(8),
            InkWell(
              onTap: () {
                if (_pages.length > 1) {
                  if (_pageController.hasClients &&
                      _pageController.page!.toInt() != _pages.length - 1) {
                    if (isAllowSharingScreen && isHostFocus) {
                      for (int i = 0; i <= 2; i++) {
                        sendMessage('ChangePage:${_currentPage + 1}');
                      }
                      _currentHostPage = _currentPage + 1;
                    }
                    _pageController.animateToPage(
                      _pageController.page!.toInt() + 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                }
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(90)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 14, bottom: 10),
                  child: Image.asset(
                    ImageAssets.arrowDown,
                    width: 20,
                    color: _isNextBtnActive
                        ? CustomColors.activePagingBtn
                        : CustomColors.inactivePagingBtn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget toolsActiveMobile() {
    return Positioned(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: CustomColors.greenPrimary,
                borderRadius: BorderRadius.only(topRight: Radius.circular(90)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTools = !selectedTools;
                  });
                },
                child: Image.asset(
                  _listTools[_selectedIndexTools]['image_active'],
                  height: 70,
                  width: 70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TODO: status widget should be merge

  Widget statusShareScreen(String txt, String img) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: CustomColors.greenB9E7C9,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          S.w(16),
          Image.asset(
            img,
            width: 22,
          ),
          S.w(12),
          Text(
            txt,
            style: CustomStyles.bold14greenPrimary,
          ),
          S.w(10),
          // Container(
          //   width: 1,
          //   height: 16,
          //   color: CustomColors.greenPrimary,
          // ),
          // S.w(10),
          // InkWell(
          //   onTap: () {
          //     setState(() {
          //       tabFreestyle = true;
          //       tabFollowing = false;
          //     });
          //   },
          //   child: Text(
          //     'ออก',
          //     style: CustomStyles.bold14greenPrimaryUnderline,
          //   ),
          // ),
          // S.w(16),
        ],
      ),
    );
  }

  Widget statusShareNowScreen(String txt, String img) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: CustomColors.blueCFE8FC,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          S.w(16),
          Image.asset(
            img,
            width: 22,
            color: CustomColors.blue0D47A1,
          ),
          S.w(12),
          Text(
            txt,
            style: CustomStyles.bold14blue0D47A1,
          ),
          S.w(10),
          Container(
            width: 1,
            height: 16,
            color: CustomColors.blue0D47A1,
          ),
          S.w(10),
          InkWell(
            onTap: () {
              setState(() {
                statusShare = !statusShare;
                // tabFreestyle = true;
                // tabLearning = false;
              });
            },
            child: Text(
              'ออก',
              style: CustomStyles.bold14blue0D47A1Line,
            ),
          ),
          S.w(16),
        ],
      ),
    );
  }

  Widget statusScreen(String txt, String img, String color) {
    Color statusColor = CustomColors.greenB9E7C9;
    var textStyle = CustomStyles.bold14greenPrimary;
    if (color == 'green') {
      statusColor = CustomColors.greenB9E7C9;
      textStyle = CustomStyles.bold14greenPrimary;
    } else if (color == 'blue') {
      statusColor = CustomColors.blueCFE8FC;
      textStyle = CustomStyles.bold14bluePrimaryLine;
    }
    return Container(
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: statusColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          S.w(16),
          Image.asset(
            img,
            width: 22,
          ),
          S.w(12),
          Text(
            txt,
            style: textStyle,
          ),
          S.w(16),
        ],
      ),
    );
  }

  Future<void> shareQuizModal() {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                ///Header1
                if (!Responsive.isMobile(context))
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      height: 60,
                      color: CustomColors.whitePrimary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          S.w(Responsive.isTablet(context) ? 5 : 24),
                          if (Responsive.isTablet(context))
                            Expanded(
                              flex: 3,
                              child: Text(
                                "คอร์สปรับพื้นฐานคณิตศาสตร์ ก่อนขึ้น ม.4  - 01 ม.ค. 2023",
                                style: CustomStyles.bold16Black363636Overflow,
                                maxLines: 1,
                              ),
                            ),
                          if (Responsive.isDesktop(context))
                            Expanded(
                              flex: 4,
                              child: Text(
                                "คอร์สปรับพื้นฐานคณิตศาสตร์ ก่อนขึ้น ม.4  - 01 ม.ค. 2023",
                                style: CustomStyles.bold16Black363636Overflow,
                                maxLines: 1,
                              ),
                            ),
                          if (Responsive.isMobile(context))
                            Expanded(
                              flex: 2,
                              child: Text(
                                "คอร์สปรับพื้นฐานคณิตศาสตร์ ก่อนขึ้น ม.4  - 01 ม.ค. 2023",
                                style: CustomStyles.bold16Black363636Overflow,
                                maxLines: 1,
                              ),
                            ),
                          Expanded(
                            flex: Responsive.isDesktop(context) ? 3 : 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 32,
                                  width: 145,
                                  // margin: EdgeInsets.only(top: defaultPadding),
                                  // padding: EdgeInsets.all(defaultPadding),
                                  decoration: const BoxDecoration(
                                    color: CustomColors.pinkFFCDD2,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(defaultPadding),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        ImageAssets.lowSignal,
                                        height: 22,
                                        width: 18,
                                      ),
                                      S.w(10),
                                      Flexible(
                                        child: Text(
                                          "สัญญาณอ่อน",
                                          style: CustomStyles.bold14redB71C1C,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                S.w(16.0),
                                Container(
                                  height: 11,
                                  width: 11,
                                  decoration: BoxDecoration(
                                      color: CustomColors.redF44336,
                                      borderRadius: BorderRadius.circular(100)
                                      //more than 50% of width makes circle
                                      ),
                                ),
                                S.w(4.0),
                                RichText(
                                  text: TextSpan(
                                    text: 'Live Time: ',
                                    style: CustomStyles.med14redFF4201,
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: '01 : 59 : 59',
                                        style: CustomStyles.med14Gray878787,
                                      ),
                                    ],
                                  ),
                                ),
                                S.w(16.0),
                                InkWell(
                                  onTap: () {
                                    log('close something');
                                    // modalCloseClass(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: defaultPadding * 1,
                                      vertical: defaultPadding / 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: CustomColors.redF44336,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "ออกห้อง",
                                          style: CustomStyles.bold14White,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                S.w(Responsive.isTablet(context) ? 5 : 24),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                if (!Responsive.isMobile(context))
                  Material(
                    // color: Colors.transparent,
                    child: Container(
                      width: double.infinity,
                      height: 1,
                      color: CustomColors.grayCFCFCF,
                    ),
                  ),

                ///Header2
                if (!Responsive.isMobile(context))
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                          color: CustomColors.whitePrimary,
                          boxShadow: [
                            BoxShadow(
                                color: CustomColors.gray878787.withOpacity(.1),
                                offset: const Offset(0.0, 6),
                                blurRadius: 10,
                                spreadRadius: 1)
                          ]),
                      child: Row(
                        children: [
                          S.w(Responsive.isTablet(context) ? 5 : 12),
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: CustomColors.grayCFCFCF,
                                      style: BorderStyle.solid,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: CustomColors.whitePrimary,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        ImageAssets.allPages,
                                        height: 30,
                                        width: 32,
                                      ),
                                      if (Responsive.isDesktop(context)) S.w(8),
                                      if (Responsive.isDesktop(context))
                                        Container(
                                          width: 1,
                                          height: 24,
                                          color: CustomColors.grayCFCFCF,
                                        ),
                                      if (Responsive.isDesktop(context)) S.w(8),
                                      InkWell(
                                        onTap: () {
                                          log('Back page');
                                        },
                                        child: Image.asset(
                                          ImageAssets.backDis,
                                          height: 16,
                                          width: 17,
                                        ),
                                      ),
                                      if (Responsive.isDesktop(context)) S.w(8),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: CustomColors.grayCFCFCF,
                                            style: BorderStyle.solid,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color: CustomColors.whitePrimary,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text("Page 20",
                                                style: CustomStyles
                                                    .bold14greenPrimary),
                                          ],
                                        ),
                                      ),
                                      S.w(8.0),
                                      Text("/ 149",
                                          style: CustomStyles.med14Gray878787),
                                      if (Responsive.isDesktop(context))
                                        S.w(defaultPadding),
                                      InkWell(
                                        onTap: () {
                                          log("next page");
                                        },
                                        child: Image.asset(
                                          ImageAssets.forward,
                                          height: 16,
                                          width: 17,
                                        ),
                                      ),
                                      S.w(6.0),
                                      Container(
                                        width: 1,
                                        height: 24,
                                        color: CustomColors.grayCFCFCF,
                                      ),
                                      Transform.scale(
                                        scale: 0.6,
                                        child: CupertinoSwitch(
                                          value: _switchValue,
                                          onChanged: (bool value) {
                                            setState(() {
                                              _switchValue = value;
                                            });
                                            log(value.toString());
                                          },
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("เลื่อนหน้า",
                                              style: CustomStyles
                                                  .bold12gray878787),
                                          Text("ตามติวเตอร์",
                                              style: CustomStyles
                                                  .bold12gray878787),
                                        ],
                                      ),
                                      S.w(8.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (tabFreestyle == true) {
                                        tabFollowing = !tabFollowing;
                                        tabFreestyle = false;
                                      }
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: tabFollowing
                                          ? CustomColors.greenE5F6EB
                                          : CustomColors.whitePrimary,
                                      shape: BoxShape.rectangle,
                                      border: Border.all(
                                        color: CustomColors.grayCFCFCF,
                                        style: BorderStyle.solid,
                                        width: 1.0,
                                      ),
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                        left: Radius.circular(50.0),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          tabFollowing
                                              ? ImageAssets.avatarMe
                                              : ImageAssets.avatarDisMe,
                                          width: 32,
                                        ),
                                        S.w(8),
                                        Text("เรียนรู้",
                                            style: tabFollowing
                                                ? CustomStyles
                                                    .bold14greenPrimary
                                                : CustomStyles
                                                    .bold14grayCFCFCF),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (tabFollowing == true) {
                                        tabFreestyle = !tabFreestyle;
                                        tabFollowing = false;
                                      }
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: tabFreestyle
                                          ? CustomColors.greenE5F6EB
                                          : CustomColors.whitePrimary,
                                      shape: BoxShape.rectangle,
                                      border: Border.all(
                                        color: CustomColors.grayCFCFCF,
                                        style: BorderStyle.solid,
                                        width: 1.0,
                                      ),
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                        right: Radius.circular(50.0),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          tabFreestyle
                                              ? ImageAssets.pencilActive
                                              : ImageAssets.penDisTab,
                                          width: 32,
                                        ),
                                        S.w(8),
                                        Text("เขียนอิสระ",
                                            style: tabFreestyle
                                                ? CustomStyles
                                                    .bold14greenPrimary
                                                : CustomStyles
                                                    .bold14grayCFCFCF),
                                      ],
                                    ),
                                  ),
                                ),
                                S.w(8),
                                Container(
                                  width: 1,
                                  height: 32,
                                  color: CustomColors.grayCFCFCF,
                                ),
                                S.w(8),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: CustomColors.greenPrimary,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Text("ไปหน้าที่สอน",
                                        style: CustomStyles.bold14White),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// Statistics
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () {
                                  log('Go to Statistics');
                                  showLeader(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: CustomColors.grayCFCFCF,
                                      style: BorderStyle.solid,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: CustomColors.whitePrimary,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1, vertical: 6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          ImageAssets.leaderboard,
                                          height: 23,
                                          width: 25,
                                        ),
                                        S.w(8),
                                        Container(
                                          width: 1,
                                          height: 24,
                                          color: CustomColors.grayCFCFCF,
                                        ),
                                        S.w(8),
                                        Image.asset(
                                          ImageAssets.checkTrue,
                                          height: 18,
                                          width: 18,
                                        ),
                                        if (!Responsive.isTablet(context))
                                          S.w(8.0),
                                        Text("7",
                                            style:
                                                CustomStyles.bold14Gray878787),
                                        if (!Responsive.isTablet(context))
                                          S.w(8.0),
                                        Image.asset(
                                          ImageAssets.x,
                                          height: 18,
                                          width: 18,
                                        ),
                                        if (!Responsive.isTablet(context))
                                          S.w(8.0),
                                        Text("5",
                                            style:
                                                CustomStyles.bold14Gray878787),
                                        if (!Responsive.isTablet(context))
                                          S.w(8.0),
                                        Image.asset(
                                          ImageAssets.icQa,
                                          height: 18,
                                          width: 18,
                                        ),
                                        if (!Responsive.isTablet(context))
                                          S.w(8.0),
                                        Text("0",
                                            style:
                                                CustomStyles.bold14Gray878787),
                                        if (!Responsive.isTablet(context))
                                          S.w(8.0),
                                        Image.asset(
                                          ImageAssets.arrowNextCircle,
                                          width: 21,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          S.w(Responsive.isTablet(context) ? 5 : 24),
                        ],
                      ),
                    ),
                  ),

                ///Modal Share Quiz

                Expanded(
                  child: Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 0,
                    backgroundColor: CustomColors.whitePrimary,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CustomColors.greenPrimary),
                                    child: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 16,
                                      color: CustomColors.whitePrimary,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text('ชุดที่#1 สมการเชิงเส้นตัวแปรเดียว',
                                          style:
                                              CustomStyles.bold22Black363636),
                                      Text(
                                        '2 ข้อ',
                                        style: CustomStyles.med16gray878787,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CustomColors.greenPrimary),
                                    child: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: CustomColors.whitePrimary,
                                    ),
                                  ),
                                ],
                              ),
                              S.h(12),
                              AspectRatio(
                                aspectRatio: 16 / 4,
                                child: SingleChildScrollView(
                                  child: Container(
                                    color:
                                        CustomColors.pinkFFCDD2.withOpacity(.6),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Text("Mockup"),
                                          Text("Mockup"),
                                          Text("Mockup"),
                                          Text("Mockup"),
                                          Text("Mockup"),
                                          Text("Mockup"),
                                          Text("Mockup"),
                                          Text("Mockup"),
                                          Text("Mockup"),
                                          Text("Mockup"),
                                          Text("Mockup"),
                                          Text("Mockup"),
                                          Text("Mockup"),
                                          Text("Mockup"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              S.h(18),
                              Center(
                                child: SizedBox(
                                  width: 185,
                                  height: 40,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          CustomColors.greenPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8.0), // <-- Radius
                                      ), // NEW
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.arrow_back,
                                          color: CustomColors.whitePrimary,
                                          size: 20.0,
                                        ),
                                        S.w(4),
                                        Text('กลับไปที่ห้องเรียน',
                                            style: CustomStyles.bold14White)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
