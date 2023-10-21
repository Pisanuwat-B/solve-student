import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:sizer/sizer.dart';

import '../../../firebase/database.dart';
import '../../calendar/constants/custom_styles.dart';
import '../../calendar/controller/create_course_controller.dart';
import '../../calendar/widgets/sizebox.dart';

import '../../calendar/constants/assets_manager.dart';
import '../../calendar/constants/custom_colors.dart';
import '../../live_classroom/components/divider.dart';
import '../../live_classroom/components/divider_vertical.dart';
import '../../live_classroom/components/room_loading_screen.dart';
import '../../live_classroom/solvepad/solve_watch.dart';
import '../../live_classroom/solvepad/solvepad_drawer.dart';
import '../../live_classroom/solvepad/solvepad_stroke_model.dart';
import '../../live_classroom/utils/responsive.dart';
import '../model/course_market_model.dart';
import '../model/lesson_market_model.dart';

class LearningPage extends StatefulWidget {
  final CourseMarketModel course;
  final Lesson lesson;
  const LearningPage({
    Key? key,
    required this.lesson,
    required this.course,
  }) : super(key: key);

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  // Screen and tools
  bool micEnable = false;
  bool displayEnable = false;
  bool showStudent = false;
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
  final List _strokeColors = [
    Colors.red,
    Colors.black,
    Colors.green,
    Colors.yellow,
  ];
  final List _strokeWidths = [1.0, 2.0, 5.0];
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
    {"image": 'assets/images/hand-tran.png'},
    {"image": 'assets/images/pencil-tran.png'},
    {"image": 'assets/images/highlight-tran.png'},
    {"image": 'assets/images/rubber-tran.png'},
    // {"image": 'assets/images/laserPen-tran.png'},
  ];

  FirebaseService firebaseService = FirebaseService();

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
  DrawingMode _mode = DrawingMode.drag;
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
  bool _isPrevBtnActive = false;
  bool _isNextBtnActive = true;
  int? activePointerId;

  // ---------- VARIABLE: page control
  Timer? _laserTimer;
  int _currentPage = 0;
  int _tutorCurrentPage = 0;
  String _tutorCurrentScrollZoom = '';
  final PageController _pageController = PageController();
  final List<TransformationController> _transformationController = [];
  var courseController = CourseController();
  late String courseName;
  bool isCourseLoaded = false;
  bool isReplaying = false;
  bool isReplayEnd = true;

  bool tabFollowing = true;
  bool tabFreestyle = false;

  // ---------- VARIABLE: recorder
  String _mPath = 'tau_file.mp4';
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  bool _mPlayerIsInited = false;
  bool _mPlaybackReady = false;

  // ---------- VARIABLE: tutor solvepad data
  late Map<String, dynamic> _data;
  String jsonData = '';
  List<StrokeStamp> currentStroke = [];
  List<ScrollZoomStamp> currentScrollZoom = [];
  int currentReplayIndex = 0;
  int currentReplayPointIndex = 0;
  int currentReplayScrollIndex = 0;
  double currentScale = 2.0;
  double currentScrollX = 2.0;
  double currentScrollY = 0;
  Timer? _sliderTimer;
  double replayProgress = 0;
  int replayDuration = 100;

  /// TODO: Get rid of all Mockup reference
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
    initAudio();
    initSolvepadData();
    initPagesData();
    initPagingBtn();
  }

  void initAudio() {
    _mPlayer!.openPlayer().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });
  }

  Future<void> initPagesData() async {
    await courseController.getCourseById(widget.course.id!);
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
      isCourseLoaded = true;
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

  void initSolvepadData() async {
    log('init data');
    log(widget.lesson.media!);
    var downloadData =
        await firebaseService.getSolvepadData(widget.lesson.media!);
    String voiceUrl = await firebaseService.downloadAudio(downloadData[1]);
    log('download success');
    _data = downloadData[0];
    setState(() {
      _mPath = voiceUrl;
      _mPlaybackReady = true;
      tutorSolvepadSize = Size(_data['solvepadWidth'], _data['solvepadHeight']);
      replayDuration = _data['metadata']['duration'];
    });
    initSolvepadScaling();
    log(tutorSolvepadSize.toString());
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

  Offset scaleOffset(Offset offset) {
    return Offset((offset.dx - tutorExtraSpaceX) * scaleImageX + myExtraSpaceX,
        offset.dy * scaleY);
  }

  double scaleScrollX(double scrollX) => scrollX * scaleX;
  double scaleScrollY(double scrollY) => scrollY * scaleY;

  @override
  dispose() {
    _mPlayer!.closePlayer();
    _mPlayer = null;
    _pageController.dispose();
    _sliderTimer?.cancel();
    _laserTimer?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPopScope() async {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return true;
  }

  void updateRatio(String url) {
    Image image = Image.network(url);
    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      double ratio = info.image.width / info.image.height;
      sheetImageRatio = ratio;
    }));
  }

  // ---------- FUNCTION: page control
  void _addPage() {
    setState(() {
      _penPoints.add([]);
      _laserPoints.add([]);
      _highlighterPoints.add([]);
      _eraserPoints.add(const Offset(-100, -100));
      _replayPenPoints.add([]);
      _replayLaserPoints.add([]);
      _replayHighlighterPoints.add([]);
      _replayEraserPoints.add(const Offset(-100, -100));
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

  // ---------- FUNCTION: solve pad feature
  double square(double x) => x * x;
  double sqrDistanceBetween(Offset p1, Offset p2) =>
      square(p1.dx - p2.dx) + square(p1.dy - p2.dy);

  void doErase(int index, DrawingMode mode) {
    List<SolvepadStroke?> pointStack;
    if (mode == DrawingMode.pen) {
      pointStack = _penPoints[_currentPage];
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

  // ---------- FUNCTION: solve pad core
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
    _sliderTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
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
        _transformationController[page].value = Matrix4.identity()
          ..translate(scaleScrollX(action['scrollX']) / 2,
              scaleScrollY(action['scrollY']))
          ..scale(action['scale']);
        _tutorCurrentScrollZoom =
            '${action['scrollX']}|${action['scrollY']}|${action['scale']}';
        break;
      case 'change-page':
        if (tabFollowing) {
          _pageController.animateToPage(
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
                _transformationController[_currentPage]
                    .value = Matrix4.identity()
                  ..translate(
                      scaleScrollX(scrollAction[currentReplayScrollIndex]['x']),
                      scaleScrollY(scrollAction[currentReplayScrollIndex]['y']))
                  ..scale(scrollAction[currentReplayScrollIndex]['scale']);
              }
              _tutorCurrentScrollZoom =
                  '${scaleScrollX(scrollAction[currentReplayScrollIndex]['x'])}|${scaleScrollX(scrollAction[currentReplayScrollIndex]['y'])}|${scrollAction[currentReplayScrollIndex]['scale']}';
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
                    _replayEraserPoints[_currentPage] = Offset(
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
            } else if (eraseAction['mode'] == "high") {
              pointStack = _replayHighlighterPoints[_tutorCurrentPage];
            }
            setState(() {
              pointStack.removeRange(eraseAction['prev'], eraseAction['next']);
            });
          } // erase
        }
        setState(() {
          _replayEraserPoints[_tutorCurrentPage] = const Offset(-100, -100);
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
        stroke,
      ));
      setState(() {});
    } // pen
    else if (tool == "DrawingMode.highlighter") {
      _replayHighlighterPoints[_tutorCurrentPage].add(SolvepadStroke(
        scaleOffset(Offset(point['x'], point['y'])),
        Color(int.parse(color, radix: 16)),
        stroke,
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
    assert(_mPlayerIsInited && _mPlaybackReady && _mPlayer!.isStopped);
    _mPlayer!.startPlayer(fromURI: _mPath);
  }

  void stopAudioPlayer() {
    _mPlayer!.stopPlayer();
  }

  void pauseAudioPlayer() {
    _mPlayer!.pausePlayer();
  }

  void resumeAudioPlayer() {
    _mPlayer!.resumePlayer();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: isCourseLoaded
          ? Scaffold(
              backgroundColor: CustomColors.grayCFCFCF,
              body: !Responsive.isMobile(context)
                  ? _buildTablet()
                  : _buildMobile(),
            )
          : const LoadingScreen(),
    );
  }

  Widget _buildTablet() {
    return SafeArea(
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
          Positioned(
            left: 140,
            top: 160,
            child: slider('tablet'),
          ),

          ///tools widget
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
    );
  }

  Widget _buildMobile() {
    return SafeArea(
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
          Positioned(
            right: 30,
            top: 70,
            child: slider('mobile'),
          ),

          ///tools widget
          if (!selectedTools) toolsMobile(),
          if (selectedTools) toolsActiveMobile(),
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
      padding = 15;
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
            handlerAnimation: const FlutterSliderHandlerAnimation(scale: 1.2),
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
              var seekPosition = Duration(milliseconds: lowerValue.round());
              if (lowerValue > replayProgress) {
                solveStopwatch.jumpTo(seekPosition);
                _mPlayer!.seekToPlayer(seekPosition);
                setState(() {});
              }
            },
            // onDragCompleted: (handlerIndex, lowerValue, upperValue) {},
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
          log('my solvepad size $mySolvepadSize');
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
                                if (activePointerId != details.pointer) return;
                                activePointerId = null;
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
          ),
        ]);
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
                courseName,
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
                courseName,
                style: CustomStyles.bold16Black363636Overflow,
                maxLines: 1,
              ),
            ),
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
        children: [
          S.w(8),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: CustomColors.gray878787),
            onPressed: () => Navigator.pop(context),
          ),
          S.w(Responsive.isTablet(context) ? 5 : 12),
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
                padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    S.w(8),
                    InkWell(
                      onTap: () => headerLayer1Mobile(),
                      child: Image.asset(
                        ImageAssets.iconInfoPage,
                        height: 24,
                        width: 24,
                      ),
                    ),
                    S.w(8),
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
                              ..translate(
                                  scaleScrollX(scrollX), scaleScrollX(scrollY))
                              ..scale(zoom);
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

  Future<void> headerLayer1Mobile() {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: Container(
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
                                  Flexible(
                                    child: Text(
                                      courseName,
                                      style: CustomStyles
                                          .bold16Black363636Overflow,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              )),
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
                                S.w(defaultPadding),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          S.w(4),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: CustomColors.gray878787),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            height: 38,
            margin: const EdgeInsets.only(left: 10),
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
                  onTap: () => headerLayer1Mobile(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
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
                // Image.asset(
                //   ImageAssets.allPages,
                //   height: 24,
                //   width: 24,
                // ),
                // S.w(8),
                // Container(
                //   width: 1,
                //   height: 32,
                //   color: CustomColors.grayCFCFCF,
                // ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("Page ${_currentPage + 1}",
                          style: CustomStyles.bold12greenPrimary),
                    ],
                  ),
                ),
                S.w(8.0),
                Text("/ ${_pages.length}", style: CustomStyles.med12gray878787),
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
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      if (tabFreestyle == true) {
                        tabFollowing = !tabFollowing;
                        tabFreestyle = false;
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
                              ..translate(scrollX / 2, scrollY)
                              ..scale(zoom);
                      }
                    });
                  },
                  child: Container(
                    height: 38,
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
                    height: 38,
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
          // / Statistics
          // Expanded(
          //     flex: 2,
          //     child: Align(
          //       alignment: Alignment.centerRight,
          //       child: InkWell(
          //         onTap: () {
          //           log('Go to Statistics');
          //           showLeader(context);
          //         },
          //         child: Container(
          //           decoration: BoxDecoration(
          //             border: Border.all(
          //               color: CustomColors.grayCFCFCF,
          //               style: BorderStyle.solid,
          //               width: 1.0,
          //             ),
          //             borderRadius: BorderRadius.circular(8),
          //             color: CustomColors.whitePrimary,
          //           ),
          //           padding:
          //               const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
          //           child: Padding(
          //             padding: const EdgeInsets.all(6.0),
          //             child: Row(
          //               mainAxisSize: MainAxisSize.min,
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: <Widget>[
          //                 Image.asset(
          //                   ImageAssets.leaderboard,
          //                   height: 23,
          //                   width: 25,
          //                 ),
          //                 S.w(8),
          //                 Container(
          //                   width: 1,
          //                   height: 24,
          //                   color: CustomColors.grayCFCFCF,
          //                 ),
          //                 S.w(8),
          //                 Image.asset(
          //                   ImageAssets.checkTrue,
          //                   height: 18,
          //                   width: 18,
          //                 ),
          //                 if (!Responsive.isTablet(context)) S.w(8.0),
          //                 Text("100%", style: CustomStyles.bold14Gray878787),
          //                 if (!Responsive.isTablet(context)) S.w(8.0),
          //                 Image.asset(
          //                   ImageAssets.x,
          //                   height: 18,
          //                   width: 18,
          //                 ),
          //                 if (!Responsive.isTablet(context)) S.w(8.0),
          //                 Text("100%", style: CustomStyles.bold14Gray878787),
          //                 if (!Responsive.isTablet(context)) S.w(8.0),
          //                 Image.asset(
          //                   ImageAssets.icQa,
          //                   height: 18,
          //                   width: 18,
          //                 ),
          //                 if (!Responsive.isTablet(context)) S.w(8.0),
          //                 Text("100%", style: CustomStyles.bold14Gray878787),
          //                 if (!Responsive.isTablet(context)) S.w(8.0),
          //                 Image.asset(
          //                   ImageAssets.arrowNextCircle,
          //                   width: 21,
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ),
          //     )),
        ],
      ),
    );
  }

  /// Tools

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
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(90)),
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
            )));
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
                            // // crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisAlignment:
                            //     MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedIndexColors = index;

                                    // Close popup
                                    openColors = !openColors;
                                  });
                                  log('Tap : index $index');
                                  log('Tap : _selectIndex $_selectedIndexColors');
                                },
                                child: Image.asset(_listColors[index]['color'],
                                    width: 48),
                              ),
                              S.w(4)
                            ],
                          );
                        }),
                  )),
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

                                        // Close popup
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
                                  )),
                              S.w(4)
                            ],
                          );
                        }),
                  )),
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
              height: 65,
              width: selectedTools ? 0 : 390,
              // TODO: change to 430 when laser ready
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
                            // mainAxisAlignment: MainAxisAlignment.start,
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
                                  log("Pick Line");

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
                              S.w(4),
                              // InkWell(
                              //   onTap: () {
                              //     log("Clear");
                              //   },
                              //   child: Image.asset(
                              //     ImageAssets.bin,
                              //     width: 38,
                              //   ),
                              // ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedTools = !selectedTools;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
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
              height: selectedTools ? 270 : 440,
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
                  //             log("Undo");
                  //           },
                  //           child: Image.asset(
                  //             ImageAssets.undo,
                  //             width: 38,
                  //           ),
                  //         ),
                  //         InkWell(
                  //           onTap: () {
                  //             log("Redo");
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
                                        } // drag
                                        else if (index == 1) {
                                          _mode = DrawingMode.pen;
                                        } // pen
                                        else if (index == 2) {
                                          _mode = DrawingMode.highlighter;
                                        } // high
                                        else if (index == 3) {
                                          _mode = DrawingMode.eraser;
                                        } // eraser
                                        else if (index == 4) {
                                          _mode = DrawingMode.laser;
                                        } // laser
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

            // Find the ScaffoldMessenger in the widget tree
            // and use it to show a SnackBar.
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedContainer(
                duration: const Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
                height: selectedTools ? 270 : 450,
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
                      flex: 3,
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
}
