import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:speech_balloon/speech_balloon.dart';

import '../../calendar/constants/assets_manager.dart';
import '../../calendar/constants/custom_colors.dart';
import '../../calendar/constants/custom_styles.dart';
import '../../calendar/widgets/format_date.dart';
import '../../calendar/widgets/sizebox.dart';
import '../components/close_dialog.dart';
import '../components/divider.dart';
import '../components/room_loading_screen.dart';
import '../quiz/quiz_model.dart';
import '../solvepad/solve_watch.dart';
import '../solvepad/solvepad_drawer.dart';
import '../solvepad/solvepad_stroke_model.dart';
import '../utils/responsive.dart';
import 'ask_tutor_live.dart';

class ReviewLesson extends StatefulWidget {
  final String courseId, courseName, file, tutorId, userId, docId;
  final String? audio;
  final int start;
  final DateTime end;
  const ReviewLesson({
    Key? key,
    required this.courseId,
    required this.courseName,
    required this.file,
    required this.audio,
    required this.tutorId,
    required this.userId,
    required this.docId,
    required this.start,
    required this.end,
  }) : super(key: key);

  @override
  State<ReviewLesson> createState() => _ReviewLessonState();
}

class _ReviewLessonState extends State<ReviewLesson>
    with SingleTickerProviderStateMixin {
  bool micEnable = false;
  bool displayEnable = false;
  bool selected = false;
  bool selectedTools = false;
  bool openColors = false;
  bool openLines = false;
  bool openMore = false;
  bool enableDisplay = true;
  int _selectedIndexTools = 0;
  int _selectedIndexColors = 0;
  int _selectedIndexLines = 0;
  late bool isSelected;
  bool isChecked = false;
  bool _switchValue = true;
  bool fullScreen = false;
  bool openShowDisplay = false;
  bool showSpeechBalloon = true;
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
    {"image": ImageAssets.handTran},
    {"image": ImageAssets.pencilTran},
    {"image": ImageAssets.highlightTran},
    {"image": ImageAssets.rubberTran},
    // {"image": ImageAssets.laserPenTran}
  ];
  final List _strokeColors = [
    Colors.red,
    Colors.black,
    Colors.green,
    Colors.yellow,
  ];
  final List _strokeWidths = [1.0, 2.0, 5.0];
  List<SelectQuizModel> quizList = [
    SelectQuizModel("ชุดที่#1 สมการเชิงเส้นตัวแปรเดียว", "1 ข้อ", false),
    SelectQuizModel("ชุดที่#2 สมการเชิงเส้น 2 ตัวแปร", "10 ข้อ", false),
    SelectQuizModel("ชุดที่#3  สมการจำนวนเชิงซ้อน", "5 ข้อ", false),
    SelectQuizModel("ชุดที่#4 สมการเชิงเส้นตัวแปรเดียว", "5 ข้อ", false),
    SelectQuizModel("ชุดที่#5 สมการเชิงเส้นตัวแปรเดียว", "5 ข้อ", false),
  ];
  int _tutorColorIndex = 0;
  int _tutorStrokeWidthIndex = 0;

  // ---------- VARIABLE: Solve Pad data
  late List<String> _pages = [];
  final List<List<SolvepadStroke?>> _penPoints = [[]];
  final List<List<SolvepadStroke?>> _laserPoints = [[]];
  final List<List<SolvepadStroke?>> _highlighterPoints = [[]];
  final List<Offset> _eraserPoints = [const Offset(-100, -100)];
  final List<List<SolvepadStroke?>> _replayPenPoints = [[]];
  final List<List<SolvepadStroke?>> _replayLaserPoints = [[]];
  final List<List<SolvepadStroke?>> _replayHighlighterPoints = [[]];
  final List<Offset> _replayEraserPoints = [const Offset(-100, -100)];
  final List<List<Offset?>> _replayPoints = [[]];
  DrawingMode _mode = DrawingMode.drag;
  String _tutorCurrentScrollZoom = '';
  final SolveStopwatch solveStopwatch = SolveStopwatch();

  // ---------- VARIABLE: Solve Size
  Size mySolvepadSize = const Size(1059.0, 547.0);
  Size tutorSolvepadSize = const Size(1059.0, 547.0);
  double sheetImageRatio = 0.708;
  double tutorImageWidth = 0;
  double tutorExtraSpaceX = 0;
  double myImageWidth = 0;
  double myExtraSpaceX = 0;
  double scaleImageX = 0;
  double scaleX = 0;
  double scaleY = 0;

  // ---------- VARIABLE: Solve Pad features
  bool _isReplaying = false;
  bool _isPrevBtnActive = false;
  bool _isNextBtnActive = true;
  int? activePointerId;
  bool _isPageReady = false;
  bool _isSolvepadDataReady = false;
  bool _isHasReviewNote = false;
  bool _isStylusActive = false;
  int replayIndex = 0;

  // ---------- VARIABLE: page control
  Timer? _laserTimer;
  Timer? _tutorLaserTimer;
  int _currentPage = 0;
  int _tutorCurrentPage = 0;
  final PageController _pageController = PageController();
  final List<TransformationController> _transformationController = [];
  late Map<String, Function(String)> handlers;
  List<dynamic> downloadedSolvepad = [];
  bool tabFollowing = true;
  bool tabFreestyle = false;
  late AnimationController progressController;
  late Animation<double> animation;
  bool isCourseLoaded = false;
  bool isReplaying = false;
  bool isReplayEnd = true;

  // ---------- VARIABLE: sound
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  bool _isAudioReady = false;
  Uint8List? audioBuffer;
  int initialAudioTime = 0;
  int audioIndex = 0;
  int audioDelay = 0;

  // ---------- VARIABLE: tutor solvepad data
  late Map<String, dynamic> _data;
  String jsonData = '';
  List<StrokeStamp> currentStroke = [];
  List<ScrollZoomStamp> currentScrollZoom = [];
  int currentReplayIndex = 0;
  int currentReplayPointIndex = 0;
  int currentReplayScrollIndex = 0;
  double currentScale = 2.0;
  double currentScrollX = 0;
  double currentScrollY = 0;
  Timer? _sliderTimer;
  double replayProgress = 0;
  int replayDuration = 100;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    fetchReviewNote();
    initPagesData();
    initPagingBtn();
    initDownloadSolvepad();
    initAudioBuffer();
    initAudioPlayer();
  }

  void fetchReviewNote() async {
    // Reference to Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Query the 'review_note' collection
    QuerySnapshot querySnapshot = await firestore
        .collection('review_note')
        .where('student_id', isEqualTo: widget.userId)
        .where('course_id', isEqualTo: widget.courseId)
        .where('session_start', isEqualTo: widget.start)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot document = querySnapshot.docs.first;
      String? noteFileUrl = document.get('note_file');
      if (noteFileUrl != null && noteFileUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(noteFileUrl));
        log('load review note complete');
        if (response.statusCode == 200) {
          populateReviewNote(response.body);
        } else {
          throw Exception('Failed to load review note');
        }
      } // note_file exists
      else {
        log('No review note');
      } // Note note exist
    } // Check if a document exists
    else {
      log('No review note');
    } // Note not exist
  }

  void initPagesData() async {
    if (widget.docId == '') {
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
      _isPageReady = true;
      return;
    }
    var sheet = await getDocFiles(widget.tutorId, widget.docId);
    _isPageReady = true;
    setCourseLoadState();
    setState(() {
      _pages = sheet;
    });
    for (int i = 1; i < _pages.length; i++) {
      _addPage();
    }
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

  void initDownloadSolvepad() async {
    String url = widget.file;
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      _data = jsonDecode(response.body);
      _isSolvepadDataReady = true;
      setCourseLoadState();
      setState(() {
        tutorSolvepadSize =
            Size(_data['solvepadWidth'], _data['solvepadHeight']);
        replayDuration = _data['metadata']['duration'];
      });
    } // success
    else {
      log('Failed to download file');
    }
  }

  void initAudioBuffer() async {
    if (widget.audio == null) return;
    audioBuffer = await downloadAudio(widget.audio!);
    _isAudioReady = true;
    setCourseLoadState();
  }

  void initAudioPlayer() async {
    if (widget.audio == null) return;
    _audioPlayer.openPlayer();
  }

  void populateReviewNote(String jsonString) {
    // Decode the JSON string
    Map<String, dynamic> jsonData = jsonDecode(jsonString);

    // Helper function to convert a list of maps to a list of SolvepadStroke objects
    List<SolvepadStroke?> convertToStrokeList(List<dynamic> list) {
      return list.map((item) {
        if (item == null) {
          return null;
        }
        return SolvepadStroke.fromJson(item as Map<String, dynamic>);
      }).toList();
    }

    // Populate _penPoints
    List<dynamic> penPointsData = jsonData['penPoints'];
    _penPoints.clear();
    for (var list in penPointsData) {
      _penPoints.add(convertToStrokeList(list));
    }

    // Populate _laserPoints
    List<dynamic> laserPointsData = jsonData['laserPoints'];
    _laserPoints.clear();
    for (var list in laserPointsData) {
      _laserPoints.add(convertToStrokeList(list));
    }

    // Populate _highlighterPoints
    List<dynamic> highlighterPointsData = jsonData['highlighterPoints'];
    _highlighterPoints.clear();
    for (var list in highlighterPointsData) {
      _highlighterPoints.add(convertToStrokeList(list));
    }
  }

  void initSolvepadScaling() {
    tutorImageWidth = tutorSolvepadSize.height * sheetImageRatio;
    tutorExtraSpaceX = (tutorSolvepadSize.width - tutorImageWidth) / 2;
    myImageWidth = mySolvepadSize.height * sheetImageRatio;
    myExtraSpaceX = (mySolvepadSize.width - myImageWidth) / 2;
    scaleImageX = myImageWidth / tutorImageWidth;
    scaleX = mySolvepadSize.width / tutorSolvepadSize.width;
    scaleY = mySolvepadSize.height / tutorSolvepadSize.height;
  }

  void setCourseLoadState() {
    if (isCourseLoaded) return;
    if (widget.audio == null) {
      if (_isPageReady && _isSolvepadDataReady) {
        setState(() {
          isCourseLoaded = true;
        });
        _instantReplay();
      }
    } else {
      if (_isPageReady && _isSolvepadDataReady && _isAudioReady) {
        setState(() {
          isCourseLoaded = true;
        });
      }
    }
  }

  Offset convertToOffset(String offsetString) {
    final matched = RegExp(r'Offset\((.*), (.*)\)').firstMatch(offsetString);
    final dx = double.tryParse(matched!.group(1)!);
    final dy = double.tryParse(matched.group(2)!);
    var returnOffset = Offset(dx!, dy!);
    return scaleOffset(returnOffset);
  }

  Offset scaleOffset(Offset offset) {
    return Offset((offset.dx - tutorExtraSpaceX) * scaleImageX + myExtraSpaceX,
        offset.dy * scaleY);
  }

  double scaleScrollX(double scrollX) => scrollX * scaleX;
  double scaleScrollY(double scrollY) => scrollY * scaleY;

  Future<Uint8List?> downloadAudio(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        log('load audio complete');
        return response.bodyBytes;
      } else {
        log('Failed to load audio from $url');
      }
    } catch (e) {
      log('Error: $e');
    }
    return null;
  }

  void clearCanvasData() {
    _pages.clear();
    _penPoints.clear();
    _laserPoints.clear();
    _highlighterPoints.clear();
    _eraserPoints.clear();
    _replayPenPoints.clear();
    _replayLaserPoints.clear();
    _replayHighlighterPoints.clear();
    _replayEraserPoints.clear();
    _replayPoints.clear();
    _data.clear();
  }

  // ---------- FUNCTION: Replay
  void clearReplayPoint() {
    for (var point in _replayPenPoints) {
      point.clear();
    }
    for (var point in _replayHighlighterPoints) {
      point.clear();
    }
  }

  void pauseReplay() {
    log('pause replay');
    setState(() {
      isReplaying = false;
    });
    pauseAudioPlayer();
    solveStopwatch.stop();
  }

  void resumeReplay() {
    log('resume replay');
    setState(() {
      isReplaying = true;
    });
    resumeAudioPlayer();
    solveStopwatch.start();
  }

  void _initReplay() {
    log('init replay');
    setState(() {
      isReplaying = true;
      isReplayEnd = false;
      clearReplayPoint();
    });
    _replay();
    playAudioPlayer();
  }

  Future<void> _replay() async {
    solveStopwatch.start();
    _sliderTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        replayProgress = solveStopwatch.elapsed.inMilliseconds.toDouble();
        if (replayProgress >= replayDuration.toDouble()) {
          replayProgress = replayDuration.toDouble();
          timer.cancel();
        }
      });
    });

    while (currentReplayIndex < _data['actions'].length) {
      await Future.delayed(const Duration(milliseconds: 0), () async {
        if (solveStopwatch.elapsed.inMilliseconds >=
            _data['actions'][currentReplayIndex]['time']) {
          await executeReplayAction(_data['actions'][currentReplayIndex]);
          currentReplayIndex++;
        }
      });
    }

    endReplay();
  }

  void endReplay() {
    setState(() {
      isReplaying = false;
      isReplayEnd = true;
    });
    stopAudioPlayer();
    _sliderTimer?.cancel();
    solveStopwatch.reset();
    currentReplayIndex = 0;
    currentReplayPointIndex = 0;
    currentReplayScrollIndex = 0;
  }

  Future<void> executeReplayAction(Map<String, dynamic> action) async {
    switch (action['type']) {
      case 'start-recording':
        var page = action['page'];
        _pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _tutorCurrentPage = page;
        _tutorCurrentScrollZoom =
            '${scaleScrollX(action['scrollX'] / 2)}|${scaleScrollY(action['scrollY'])}|${action['scale']}';
        break;
      case 'change-page':
        if (tabFollowing) {
          await _pageController.animateToPage(
            action['data'],
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        _tutorCurrentPage = action['data'];
        break;
      case 'stop-recording':
        break;
      case 'scroll-zoom':
        List<dynamic> scrollAction = action['data'];
        while (currentReplayScrollIndex < scrollAction.length) {
          await Future.delayed(const Duration(milliseconds: 0), () {
            if (solveStopwatch.elapsed.inMilliseconds >=
                scrollAction[currentReplayScrollIndex]['time']) {
              if (tabFollowing) {
                _transformationController[_tutorCurrentPage]
                    .value = Matrix4.identity()
                  ..translate(
                      scaleScrollX(scrollAction[currentReplayScrollIndex]['x']),
                      scaleScrollY(scrollAction[currentReplayScrollIndex]['y']))
                  ..scale(scrollAction[currentReplayScrollIndex]['scale']);
              }
              _tutorCurrentScrollZoom =
                  '${scaleScrollX(scrollAction[currentReplayScrollIndex]['x'])}|${scaleScrollY(scrollAction[currentReplayScrollIndex]['y'])}|${scrollAction[currentReplayScrollIndex]['scale']}';
              currentReplayScrollIndex++;
            }
          });
        }
        currentReplayScrollIndex = 0;
        break;
      case 'drawing':
        List<dynamic> points = action['data']['points'];
        while (currentReplayPointIndex < points.length) {
          await Future.delayed(const Duration(milliseconds: 0), () {
            if (solveStopwatch.elapsed.inMilliseconds >=
                points[currentReplayPointIndex]['time']) {
              drawReplayPoint(
                  points[currentReplayPointIndex],
                  action['data']['tool'],
                  action['data']['color'],
                  action['data']['strokeWidth']);
              currentReplayPointIndex++;
            }
          });
        }
        currentReplayPointIndex = 0;
        drawReplayNull(action['data']['tool']);
        break;
      case 'erasing':
        for (var eraseAction in action['data']) {
          if (eraseAction['action'] == 'moves') {
            int movingIndex = 0;
            while (movingIndex < eraseAction['points'].length) {
              await Future.delayed(const Duration(milliseconds: 0), () {
                if (solveStopwatch.elapsed.inMilliseconds >=
                    eraseAction['points'][movingIndex]['time']) {
                  setState(() {
                    _replayEraserPoints[_tutorCurrentPage] = Offset(
                        eraseAction['points'][movingIndex]['x'],
                        eraseAction['points'][movingIndex]['y']);
                  });
                  movingIndex++;
                }
              });
            }
          } // move
          else if (eraseAction['action'] == 'erase') {
            while (
                solveStopwatch.elapsed.inMilliseconds < eraseAction['time']) {
              await Future.delayed(const Duration(milliseconds: 0), () {});
            }
            List<SolvepadStroke?> pointStack =
                _replayPenPoints[_tutorCurrentPage];
            if (eraseAction['mode'] == "pen") {
              pointStack = _replayPenPoints[_tutorCurrentPage];
            } // erase pen
            else if (eraseAction['mode'] == "high") {
              pointStack = _replayHighlighterPoints[_tutorCurrentPage];
            } // erase high
            setState(() {
              try {
                setState(() {
                  pointStack.removeRange(
                      eraseAction['prev'], eraseAction['next']);
                });
              } catch (e) {
                if (e is RangeError) {
                  print("Error removing range: ${e.toString()}");
                } else {
                  rethrow;
                }
              }
            });
          } // erase
        }
        setState(() {
          _replayEraserPoints[_tutorCurrentPage] = const Offset(-100, -100);
        });
        break;
    }
  }

  Future<void> _instantReplay() async {
    while (currentReplayIndex < _data['actions'].length) {
      await instantReplayAction(_data['actions'][currentReplayIndex]);
      currentReplayIndex++;
    }

    endReplay();
  }

  Future<void> instantReplayAction(Map<String, dynamic> action) async {
    switch (action['type']) {
      case 'start-recording':
        var page = action['page'];
        _tutorCurrentPage = page;
        break;
      case 'change-page':
        _tutorCurrentPage = action['data'];
        break;
      case 'drawing':
        List<dynamic> points = action['data']['points'];
        while (currentReplayPointIndex < points.length) {
          drawReplayPoint(
              points[currentReplayPointIndex],
              action['data']['tool'],
              action['data']['color'],
              action['data']['strokeWidth']);
          currentReplayPointIndex++;
        }
        currentReplayPointIndex = 0;
        drawReplayNull(action['data']['tool']);
        break;
      case 'erasing':
        for (var eraseAction in action['data']) {
          if (eraseAction['action'] == 'erase') {
            List<SolvepadStroke?> pointStack =
                _replayPenPoints[_tutorCurrentPage];
            if (eraseAction['mode'] == "DrawingMode.pen") {
              pointStack = _replayPenPoints[_tutorCurrentPage];
            } // erase pen
            else if (eraseAction['mode'] == "DrawingMode.highlighter") {
              pointStack = _replayHighlighterPoints[_tutorCurrentPage];
            } // erase high
            setState(() {
              pointStack.removeRange(eraseAction['prev'], eraseAction['next']);
            });
          } // erase
        }
        setState(() {
          _replayEraserPoints[_currentPage] = const Offset(-100, -100);
        });
        break;
    }
  }

  void drawReplayPoint(
      Map<String, dynamic> point, String tool, String color, double stroke) {
    if (tool == "DrawingMode.pen") {
      _replayPenPoints[_tutorCurrentPage].add(SolvepadStroke(
        scaleOffset(Offset(point['x'], point['y'])),
        Color(int.parse(color, radix: 16)),
        Responsive.isMobile(context) ? (stroke * 0.75) : stroke,
      ));
      setState(() {});
    } // pen
    else if (tool == "DrawingMode.highlighter") {
      _replayHighlighterPoints[_tutorCurrentPage].add(SolvepadStroke(
        scaleOffset(Offset(point['x'], point['y'])),
        Color(int.parse(color, radix: 16)),
        Responsive.isMobile(context) ? (stroke * 0.65) : stroke,
      ));
      setState(() {});
    } // high
  }

  void drawReplayNull(String tool) {
    if (tool == "DrawingMode.pen") {
      _replayPenPoints[_tutorCurrentPage].add(null);
    } else if (tool == "DrawingMode.highlighter") {
      _replayHighlighterPoints[_tutorCurrentPage].add(null);
    }
  }

  // ---------- FUNCTION: recording and playback

  void playAudioPlayer() {
    _audioPlayer.startPlayer(fromDataBuffer: audioBuffer);
  }

  void stopAudioPlayer() {
    _audioPlayer.stopPlayer();
  }

  void pauseAudioPlayer() {
    _audioPlayer.pausePlayer();
  }

  void resumeAudioPlayer() {
    _audioPlayer.resumePlayer();
  }

  @override
  dispose() {
    audioBuffer = null;
    _audioPlayer.closePlayer();
    _pageController.dispose();
    try {
      progressController.dispose();
    } catch (e) {
      // ignore
    }
    for (var controller in _transformationController) {
      controller.dispose();
    }
    _sliderTimer?.cancel();
    _laserTimer?.cancel();
    _tutorLaserTimer?.cancel();
    clearCanvasData();
    super.dispose();
  }

  Future<List<String>> getDocFiles(String userId, String docId) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('medias')
          .doc(userId)
          .collection('docs_list')
          .doc(docId)
          .get();
      Map<String, dynamic>? dataMap =
          documentSnapshot.data() as Map<String, dynamic>?;
      List<dynamic> docFiles = dataMap?['doc_files'] ?? [];
      return docFiles.cast<String>(); // Casting to List<String>
    } catch (e) {
      log('An error occurred while fetching doc_files: $e');
      return [];
    }
  }

  Duration convertToDuration(int timeInt) {
    int milliseconds = timeInt;
    return Duration(milliseconds: milliseconds);
  }

  @override
  Widget build(BuildContext context) {
    return isCourseLoaded
        ? Scaffold(
            backgroundColor: CustomColors.grayCFCFCF,
            body:
                !Responsive.isMobile(context) ? _buildTablet() : _buildMobile(),
          )
        : const LoadingScreen();
  }

  _buildTablet() {
    return Scaffold(
      backgroundColor: CustomColors.grayCFCFCF,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
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
            if (widget.audio != null)
              Positioned(
                left: 140,
                top: 160,
                child: slider('tablet'),
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
                                  _selectedIndexLines = index;
                                  openLines = !openLines;
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
                              ),
                            );
                          })
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      // floatingActionButton:
      //     Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      //   Row(
      //     mainAxisAlignment: MainAxisAlignment.end,
      //     children: [
      //       if (showSpeechBalloon)
      //         InkWell(
      //           onTap: () {
      //             setState(() {
      //               showSpeechBalloon = false;
      //             });
      //           },
      //           child: SpeechBalloon(
      //             width: 150,
      //             height: 40,
      //             borderRadius: 3,
      //             nipLocation: NipLocation.right,
      //             color: CustomColors.greenPrimary,
      //             child: Center(
      //               child: Text(
      //                 "คำถามที่เคยถาม",
      //                 style: CustomStyles.bold16whitePrimary,
      //               ),
      //             ),
      //           ),
      //         ),
      //       S.w(13),
      //       Stack(
      //         children: [
      //           InkWell(
      //             onTap: () {
      //               showSpeechBalloon = false;
      //               // Navigator.push(
      //               //   context,
      //               //   MaterialPageRoute(
      //               //       builder: (context) => const QAListSearchFound()),
      //               // );
      //
      //               //todo for Search Not Found question
      //               // Navigator.push(
      //               //   context,
      //               //   MaterialPageRoute(
      //               //       builder: (context) =>
      //               //           const QuestionSearchNotFound()),
      //               // );
      //             },
      //             child: Image.asset(
      //               'assets/images/ic_qa_float_black.png',
      //               width: 72,
      //             ),
      //           ),
      //           Positioned(
      //             top: 1,
      //             right: 1,
      //             child: Align(
      //               alignment: Alignment.topRight,
      //               child: Container(
      //                 decoration: const BoxDecoration(
      //                     color: CustomColors.greenPrimary,
      //                     shape: BoxShape.circle),
      //                 width: 25,
      //                 height: 25,
      //                 child: Center(
      //                   child: Text(
      //                     "13",
      //                     style: CustomStyles.bold11White,
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           )
      //         ],
      //       ),
      //     ],
      //   ),
      //   S.h(20),
      //   Row(
      //     mainAxisAlignment: MainAxisAlignment.end,
      //     children: [
      //       if (showSpeechBalloon)
      //         InkWell(
      //           onTap: () {
      //             setState(() {
      //               showSpeechBalloon = false;
      //             });
      //           },
      //           child: SpeechBalloon(
      //             width: 150,
      //             height: 40,
      //             borderRadius: 3,
      //             nipLocation: NipLocation.right,
      //             color: CustomColors.greenPrimary,
      //             child: Center(
      //               child: Text(
      //                 "กดเพื่อถามคำถาม",
      //                 style: CustomStyles.bold16whitePrimary,
      //               ),
      //             ),
      //           ),
      //         ),
      //       S.w(13),
      //       InkWell(
      //         onTap: () {
      //           showSpeechBalloon = false;
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => const AskTutor()),
      //           );
      //         },
      //         child: Image.asset(
      //           'assets/images/ic_mic_off_float.png',
      //           width: 72,
      //         ),
      //       ),
      //     ],
      //   )
      // ]),
    );
  }

  _buildMobile() {
    return Scaffold(
      backgroundColor: CustomColors.grayCFCFCF,
      body: SafeArea(
        right: false,
        left: false,
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                headerLayer2Mobile(),
                const DividerLine(),
                solvePad(),
              ],
            ),
            if (widget.audio != null)
              Positioned(
                right: 30,
                top: 55,
                child: slider('mobile'),
              ),
            if (!selectedTools) toolsMobile(),
            if (selectedTools) toolsActiveMobile(),

            /// Control menu
            // if (openShowDisplay == false) toolsControlMobile(),
          ],
        ),
      ),
    );
  }

  _buildMobileFullScreen() {
    return Scaffold(
      backgroundColor: CustomColors.grayCFCFCF,
      body: Stack(
        children: [
          const Column(
            children: [
              SizedBox(),
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

  Widget slider(String mode) {
    double height = 490;
    double padding = 25;
    double handler = 35;
    double fontSize = 12;
    double leftDuration = 12;
    double leftTooltip = -40;
    if (mode == 'mobile') {
      height = 300;
      padding = 5;
      handler = 30;
      fontSize = 10;
      leftDuration = 19;
      leftTooltip = -50;
    }
    return SizedBox(
      width: 60,
      height: height,
      child: Stack(children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: padding),
          child: FlutterSlider(
            axis: Axis.vertical,
            values: [replayProgress],
            max: replayDuration.toDouble(),
            min: 0,
            handlerWidth: handler,
            handlerHeight: handler,
            disabled: isReplayEnd || tabFreestyle,
            handlerAnimation: const FlutterSliderHandlerAnimation(scale: 1.2),
            handler: FlutterSliderHandler(
                opacity: (isReplayEnd || tabFreestyle) ? 0 : 1),
            tooltip: FlutterSliderTooltip(
              alwaysShowTooltip: true,
              textStyle: TextStyle(fontSize: fontSize, color: Colors.black),
              direction: FlutterSliderTooltipDirection.top,
              positionOffset: FlutterSliderTooltipPositionOffset(
                  top: -5, left: leftTooltip),
              boxStyle: FlutterSliderTooltipBox(
                  decoration:
                      BoxDecoration(color: Colors.white.withOpacity(0))),
              format: (value) {
                return _formatReplayElapsedTime(
                    Duration(milliseconds: double.parse(value).round()));
              },
            ),
            trackBar: FlutterSliderTrackBar(
              activeTrackBarHeight: 5,
              inactiveTrackBar: BoxDecoration(
                color: const Color(0xff20B153).withOpacity(0.3),
              ),
              activeTrackBar: const BoxDecoration(
                color: Color(0xff20B153),
              ),
            ),
            onDragging: (handlerIndex, lowerValue, upperValue) {
              if (isReplayEnd || tabFreestyle) return null;
              var seekPosition = Duration(milliseconds: lowerValue.round());
              if (lowerValue > replayProgress) {
                solveStopwatch.jumpTo(seekPosition);
                _audioPlayer.seekToPlayer(seekPosition);
                setState(() {});
              }
            },
            onDragCompleted: (handlerIndex, lowerValue, upperValue) {
              if (isReplayEnd || tabFreestyle) return null;
              if (lowerValue >= replayDuration) {
                endReplay();
              }
            },
          ),
        ),
        Positioned(
          top: 0,
          left: leftDuration,
          child: Text('00:00', style: CustomStyles.med12GreenPrimary),
        ),
        Positioned(
          bottom: 0,
          left: leftDuration,
          child: Text(
              _formatReplayElapsedTime(Duration(milliseconds: replayDuration)),
              style: CustomStyles.med12GreenPrimary),
        ),
      ]),
    );
  }

  Widget solvePad() {
    return Expanded(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        double solvepadWidth = constraints.maxWidth;
        double solvepadHeight = constraints.maxHeight;
        currentScrollX = (-1 * solvepadWidth);
        if (mySolvepadSize.width != solvepadWidth) {
          mySolvepadSize = Size(solvepadWidth, solvepadHeight);
          initSolvepadScaling();
        }
        return PageView.builder(
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
                  setState(() {
                    showSpeechBalloon = false;
                  });
                  var translation =
                      _transformationController[index].value.getTranslation();
                  double originalTranslationY = translation.y;
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
                        ignoring: (_mode == DrawingMode.drag || tabFollowing),
                        child: GestureDetector(
                          onPanDown: (_) {},
                          child: Listener(
                            onPointerDown: (details) {
                              _isHasReviewNote = true;
                              showSpeechBalloon = false;
                              if (tabFollowing) return;
                              if (activePointerId != null) return;
                              activePointerId = details.pointer;
                              if (details.kind == PointerDeviceKind.stylus) {
                                _isStylusActive = true;
                              }
                              if (_isStylusActive &&
                                  details.kind == PointerDeviceKind.touch) {
                                return;
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
                                              sqrDistanceBetween(point!.offset,
                                                      details.localPosition) <=
                                                  100);
                                  if (penHit != -1) {
                                    doErase(penHit, DrawingMode.pen);
                                  }
                                  if (highlightHit != -1) {
                                    doErase(
                                        highlightHit, DrawingMode.highlighter);
                                  }
                                  break;
                                default:
                                  break;
                              }
                            },
                            onPointerMove: (details) {
                              if (tabFollowing) return;
                              if (activePointerId != details.pointer) return;
                              activePointerId = details.pointer;
                              if (details.kind == PointerDeviceKind.stylus) {
                                _isStylusActive = true;
                              }
                              if (_isStylusActive &&
                                  details.kind == PointerDeviceKind.touch) {
                                return;
                              }
                              switch (_mode) {
                                case DrawingMode.pen:
                                  setState(() {
                                    _penPoints[_currentPage].add(SolvepadStroke(
                                        details.localPosition,
                                        _strokeColors[_selectedIndexColors],
                                        _strokeWidths[_selectedIndexLines]));
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
                                              sqrDistanceBetween(point!.offset,
                                                      details.localPosition) <=
                                                  500);
                                  if (penHit != -1) {
                                    doErase(penHit, DrawingMode.pen);
                                  }
                                  if (highlightHit != -1) {
                                    doErase(
                                        highlightHit, DrawingMode.highlighter);
                                  }
                                  break;
                                default:
                                  break;
                              }
                            },
                            onPointerUp: (details) {
                              if (tabFollowing) return;
                              if (activePointerId != details.pointer) return;
                              activePointerId = null;
                              if (_isStylusActive &&
                                  details.kind == PointerDeviceKind.touch) {
                                return;
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
                                        const Offset(-100, -100);
                                  });
                                  break;
                                default:
                                  break;
                              }
                            },
                            onPointerCancel: (details) {
                              if (tabFollowing) return;
                              if (activePointerId != details.pointer) return;
                              activePointerId = null;
                              if (_isStylusActive &&
                                  details.kind == PointerDeviceKind.touch) {
                                return;
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
                                        const Offset(-100, -100);
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
                                _replayPenPoints[index],
                                _replayLaserPoints[index],
                                _replayHighlighterPoints[index],
                                _replayEraserPoints[index],
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
        );
      }),
    );
  }

  Widget replayButton() {
    return Center(
      child: SizedBox(
        width: 70,
        height: 100,
        child: GestureDetector(
          onTap: () {
            if (!isReplaying) {
              if (isReplayEnd) {
                _initReplay();
              } else {
                resumeReplay();
              }
            } // before replay
            else {
              pauseReplay();
            }
          },
          child: Container(
            margin: EdgeInsets.symmetric(
                vertical: Responsive.isMobile(context) ? 6 : 14.0),
            decoration: BoxDecoration(
                color: isReplaying
                    ? CustomColors.gray363636
                    : CustomColors.redFF4201,
                shape: BoxShape.circle),
            child: isReplaying
                ? const Icon(
                    Icons.pause,
                    size: 20,
                    color: CustomColors.white,
                  )
                : const Icon(
                    Icons.play_arrow,
                    size: 20,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }

  // ---------- FUNCTION: solve pad feature
  double square(double x) => x * x;
  double sqrDistanceBetween(Offset p1, Offset p2) =>
      square(p1.dx - p2.dx) + square(p1.dy - p2.dy);

  void doErase(int index, DrawingMode mode) {
    List<SolvepadStroke?> pointStack;
    if (mode == DrawingMode.pen) {
      if (_isReplaying) {
        // TODO: resolve this after initial test
        // pointStack = _replayPoints[_currentReplayPage];
        pointStack = _penPoints[_currentPage];
      } else {
        pointStack = _penPoints[_currentPage];
      }
      removePointStack(pointStack, index);
    } else if (mode == DrawingMode.highlighter) {
      pointStack = _highlighterPoints[_currentPage];
      removePointStack(pointStack, index);
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

  void _tutorLaserDrawing() {
    _tutorLaserTimer?.cancel();
  }

  void _tutorStopLaserDrawing() {
    setState(() {
      _replayLaserPoints[_currentPage].clear();
    });
  }

  // ---------- FUNCTION: page control
  void _addPage() {
    _penPoints.add([]);
    _laserPoints.add([]);
    _highlighterPoints.add([]);
    _eraserPoints.add(const Offset(-100, -100));
    _replayPoints.add([]);
    _replayPenPoints.add([]);
    _replayLaserPoints.add([]);
    _replayHighlighterPoints.add([]);
    _replayEraserPoints.add(const Offset(-100, -100));
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

  String _formatReplayElapsedTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  void animateCircleProgress() {
    if (animation.value == 100) {
      progressController.reverse();
    } else {
      progressController.forward();
    }
  }

  void forwardPlayer(Duration duration) async {
    var progress = await _audioPlayer.getProgress();
    Duration newLocation = progress['progress']! + duration;
    _audioPlayer.seekToPlayer(newLocation);
  }

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
        File('${directory.path}/${widget.courseId}-${widget.start}.txt');
    await file.writeAsString(jsonString);

    // 2. Upload the text file to Firebase Storage
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('self_review_note/${widget.courseId}-${widget.start}.txt');
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
        'session_start': widget.start,
        'student_id': widget.userId,
        'update_time': FieldValue.serverTimestamp(),
      });
    });
  }

  Widget pagingTools() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Material(
          child: InkWell(
            onTap: () {
              if (tabFollowing) return;
              if (_pageController.hasClients &&
                  _pageController.page!.toInt() != 0) {
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
        ),
        S.w(defaultPadding),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Page ${_currentPage + 1}",
                  style: CustomStyles.bold14greenPrimary),
            ],
          ),
        ),
        S.w(8.0),
        Text("/ ${_pages.length}", style: CustomStyles.med14Gray878787),
        S.w(8),
        Material(
          child: InkWell(
            // splashColor: Colors.lightGreen,
            onTap: () {
              if (tabFollowing) return;
              if (_pages.length > 1) {
                if (_pageController.hasClients &&
                    _pageController.page!.toInt() != _pages.length - 1) {
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
        ),
        S.w(6.0),
      ],
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
        children: [
          S.w(8),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: CustomColors.gray878787),
            onPressed: () {
              if (_isHasReviewNote) {
                showCloseDialog(
                  context,
                  () {
                    saveReviewNote();
                    Navigator.of(context).pop();
                  },
                  title: 'คุณกำลังจะออก โดยไม่บันทึกการเขียน',
                  detail:
                      'คุณต้องการบันทึกการเขียนที่เกิดขึ้นระหว่างที่คุณดูรีวิว หรือไม่ ?',
                  confirm: 'บันทึก',
                  cancel: 'ออกโดยไม่บันทึก',
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                );
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          S.w(Responsive.isTablet(context) ? 5 : 12),
          Expanded(
            child: Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: () => headerInfo(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Image.asset(
                              ImageAssets.iconInfoPage,
                              height: 30,
                              width: 30,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: CustomColors.grayCFCFCF,
                        ),
                        S.w(6),
                        Material(
                          child: InkWell(
                            onTap: () {
                              if (_pageController.hasClients &&
                                  _pageController.page!.toInt() != 0) {
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
                        ),
                        S.w(6),
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
                        S.w(8),
                        Text("/ ${_pages.length}",
                            style: CustomStyles.med14Gray878787),
                        S.w(6),
                        Material(
                          child: InkWell(
                            // splashColor: Colors.lightGreen,
                            onTap: () {
                              if (_pages.length > 1) {
                                if (_pageController.hasClients &&
                                    _pageController.page!.toInt() !=
                                        _pages.length - 1) {
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
                        ),
                        S.w(6),
                      ],
                    ),
                  ),
                ),
                S.w(8),
                statusTouchModeIcon(),
              ],
            ),
          ),
          if (widget.audio != null)
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
                          if (_tutorCurrentScrollZoom != '') {
                            var parts = _tutorCurrentScrollZoom.split('|');
                            var scrollX = double.parse(parts[0]);
                            var scrollY = double.parse(parts[1]);
                            var zoom = double.parse(parts.last);
                            if (_currentPage != _tutorCurrentPage) {
                              _pageController.animateToPage(
                                _tutorCurrentPage,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } // re-correct page
                            _transformationController[_tutorCurrentPage].value =
                                Matrix4.identity()
                                  ..translate(scrollX, scrollY)
                                  ..scale(zoom);
                          }
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
                                ? ImageAssets.avatarMen
                                : ImageAssets.avatarDisMen,
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
                ],
              ),
            ),
          if (widget.audio != null)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // InkWell(
                  //   onTap: () {
                  //     setState(() {
                  //       micEnable = !micEnable;
                  //     });
                  //     log(_data['metadata']['duration'].toString());
                  //     log(_data['metadata']['duration'].runtimeType.toString());
                  //   },
                  //   child: Image.asset(
                  //     micEnable ? ImageAssets.micEnable : ImageAssets.micDis,
                  //     height: 44,
                  //     width: 44,
                  //   ),
                  // ),
                  // S.w(defaultPadding),
                  // const DividerVer(),
                  replayButton(),
                  RichText(
                    text: TextSpan(
                      text: 'เริ่มเรียน',
                      style: CustomStyles.bold14RedF44336,
                    ),
                  ),
                ],
              ),
            ),
          S.w(16.0),
        ],
      ),
    );
  }

  Future<void> headerInfo() {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) {
        final double statusBarHeight = MediaQuery.of(context).padding.top;
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: EdgeInsets.only(top: statusBarHeight),
                    width: double.infinity,
                    height: 60,
                    color: CustomColors.whitePrimary,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        S.w(defaultPadding),
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: const Icon(
                                  Icons.close,
                                  color: CustomColors.gray878787,
                                  size: 18,
                                ),
                              ),
                              S.w(8),
                              Text(
                                '${widget.courseName} | ',
                                style: CustomStyles.bold16Black363636Overflow,
                              ),
                              Text(
                                '${FormatDate.timeOnlyNumber(DateTime.fromMillisecondsSinceEpoch(widget.start))} น. - ${FormatDate.timeOnlyNumber(widget.end)} น. | ',
                                style: CustomStyles.bold16Black363636Overflow,
                              ),
                              Text(
                                FormatDate.dayOnly(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        widget.start)),
                                style: CustomStyles.bold16Black363636Overflow,
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget headerLayer2Mobile() {
    return Container(
      height: 46,
      decoration: BoxDecoration(color: CustomColors.whitePrimary, boxShadow: [
        BoxShadow(
            color: CustomColors.gray878787.withOpacity(.1),
            offset: const Offset(0.0, 6),
            blurRadius: 10,
            spreadRadius: 1)
      ]),
      child: Row(
        children: [
          S.w(4),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: CustomColors.gray878787),
            onPressed: () {
              if (_isHasReviewNote) {
                showCloseDialog(
                  context,
                  () {
                    saveReviewNote();
                    Navigator.of(context).pop();
                  },
                  title: 'คุณกำลังจะออก โดยไม่บันทึกการเขียน',
                  detail:
                      'คุณต้องการบันทึกการเขียนที่เกิดขึ้นระหว่างที่คุณดูรีวิว หรือไม่ ?',
                  confirm: 'บันทึก',
                  cancel: 'ออกโดยไม่บันทึก',
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                );
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          S.w(4),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
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
                padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () => headerInfo(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Image.asset(
                          ImageAssets.iconInfoPage,
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: CustomColors.grayCFCFCF,
                    ),
                    S.w(4),
                    Material(
                      child: InkWell(
                        onTap: () {
                          if (_pageController.hasClients &&
                              _pageController.page!.toInt() != 0) {
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
                    ),
                    S.w(4),
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
                    S.w(4),
                    Text("/ ${_pages.length}",
                        style: CustomStyles.med14Gray878787),
                    S.w(4),
                    Material(
                      child: InkWell(
                        // splashColor: Colors.lightGreen,
                        onTap: () {
                          if (_pages.length > 1) {
                            if (_pageController.hasClients &&
                                _pageController.page!.toInt() !=
                                    _pages.length - 1) {
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
                    ),
                    S.w(4),
                  ],
                ),
              ),
            ),
          ),
          if (widget.audio != null)
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
                          if (_tutorCurrentScrollZoom != '') {
                            var parts = _tutorCurrentScrollZoom.split('|');
                            var scrollX = double.parse(parts[0]);
                            var scrollY = double.parse(parts[1]);
                            var zoom = double.parse(parts.last);
                            if (_currentPage != _tutorCurrentPage) {
                              _pageController.animateToPage(
                                _tutorCurrentPage,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } // re-correct page
                            _transformationController[_tutorCurrentPage].value =
                                Matrix4.identity()
                                  ..translate(scrollX, scrollY)
                                  ..scale(zoom);
                          }
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
                ],
              ),
            ),
          if (widget.audio != null)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // InkWell(
                  //   onTap: () {
                  //     setState(() {
                  //       micEnable = !micEnable;
                  //     });
                  //     log(_data['metadata']['duration'].toString());
                  //     log(_data['metadata']['duration'].runtimeType.toString());
                  //   },
                  //   child: Image.asset(
                  //     micEnable ? ImageAssets.micEnable : ImageAssets.micDis,
                  //     height: 44,
                  //     width: 44,
                  //   ),
                  // ),
                  // S.w(defaultPadding),
                  // const DividerVer(),
                  replayButton(),
                  RichText(
                    text: TextSpan(
                      text: 'เริ่มเรียน',
                      style: CustomStyles.bold14RedF44336,
                    ),
                  ),
                ],
              ),
            ),
          S.w(16.0),
        ],
      ),
    );
  }

  Widget tools() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
              height: selectedTools ? 200 : 450,
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
                  S.h(12),
                  // TODO: undo redo ??
                  // Expanded(
                  //   flex: 1,
                  //   child: Padding(
                  //     padding: const EdgeInsets.symmetric(
                  //         horizontal: defaultPadding, vertical: 1),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //       children: [
                  //         InkWell(
                  //           onTap: () {
                  //           },
                  //           child: Image.asset(
                  //             ImageAssets.undo,
                  //             width: 38,
                  //           ),
                  //         ),
                  //         InkWell(
                  //           onTap: () {
                  //           },
                  //           child: Image.asset(
                  //             ImageAssets.redo,
                  //             width: 38,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // Container(
                  //     height: 2, width: 80, color: CustomColors.grayF3F3F3),
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
                          flex: 7, // flex 4 if have all
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
                                          _mode = DrawingMode.drag;
                                        } else if (index == 1) {
                                          _mode = DrawingMode.pen;
                                        } else if (index == 2) {
                                          _mode = DrawingMode.highlighter;
                                        } else if (index == 3) {
                                          _mode = DrawingMode.eraser;
                                        } else if (index == 4) {
                                          _mode = DrawingMode.laser;
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
                                  // TODO: do we need clear btn ?
                                  // Expanded(
                                  //   child: Row(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.spaceEvenly,
                                  //     children: [
                                  //       InkWell(
                                  //         onTap: () {
                                  //         },
                                  //         child: Image.asset(
                                  //           ImageAssets.bin,
                                  //           width: 38,
                                  //         ),
                                  //       ),
                                  //       InkWell(
                                  //         onTap: () {
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
                height: 450,
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
                    S.h(12),
                    Expanded(
                      flex: 7, // flex 4 if have all
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _listTools.length,
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
                                          'assets/images/pick-green-tran.png',
                                          width: 38,
                                        ),
                                        Image.asset(
                                          'assets/images/pick-line-tran.png',
                                          width: 38,
                                        ),
                                      ],
                                    ),
                                  ),
                                  S.h(38),
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
                setState(() {
                  openShowDisplay = !openShowDisplay;
                });
              },
              child: Image.asset(
                'assets/images/ic_open_show.png',
                width: 44,
              ),
            ),
            S.h(8),
            Stack(
              children: [
                InkWell(
                  onTap: () {
                    log('search found');
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => const QAListSearchFound()),
                    // );

                    /// TODO: for Search Not Found question
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => const QuestionSearchNotFound()),
                    // );
                  },
                  child: Image.asset(
                    'assets/images/ic_qa_float_black.png',
                    height: 44,
                    width: 44,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 21),
                  child: Container(
                    decoration: const BoxDecoration(
                        color: CustomColors.greenPrimary,
                        shape: BoxShape.circle),
                    width: 25,
                    height: 25,
                    child: Center(
                      child: Text(
                        "13",
                        style: CustomStyles.bold11White,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            S.h(8),
            InkWell(
              onTap: () {
                if (Responsive.isMobile(context)) {
                  log('screenshot');
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => const ScreenShotModalMobile()),
                  // );
                } else {
                  log('ask tutor');
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const AskTutor()),
                  // );
                }
              },
              child: Image.asset(
                'assets/images/ic_mic_off_float.png',
                width: 44,
              ),
            ),
            S.h(8),
            InkWell(
              onTap: () {
                setState(() {
                  fullScreen = !fullScreen;
                });
              },
              child: Image.asset(
                ImageAssets.icFullFloat,
                width: 44,
              ),
            ),
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
                                              _mode = DrawingMode.drag;
                                            } else if (index == 1) {
                                              _mode = DrawingMode.pen;
                                            } else if (index == 2) {
                                              _mode = DrawingMode.highlighter;
                                            } else if (index == 3) {
                                              _mode = DrawingMode.eraser;
                                            } else if (index == 4) {
                                              _mode = DrawingMode.laser;
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
        padding: const EdgeInsets.only(left: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                if (_pageController.hasClients &&
                    _pageController.page!.toInt() != 0) {
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

  Widget statusTouchModeIcon() {
    return InkWell(
      onTap: () {
        setState(() {
          _isStylusActive = !_isStylusActive;
        });
      },
      child: Image.asset(
        _isStylusActive
            ? 'assets/images/stylus-icon.png'
            : 'assets/images/touch-icon.png',
        height: 44,
        width: 44,
      ),
    );
  }
}
