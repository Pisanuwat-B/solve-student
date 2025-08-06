import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../calendar/constants/assets_manager.dart';
import '../../calendar/constants/custom_colors.dart';
import '../../calendar/constants/custom_styles.dart';
import '../../calendar/helper/utility_helper.dart';
import '../../calendar/widgets/sizebox.dart';
import '../components/circle_progress.dart';
import '../components/divider.dart';
import '../components/divider_vertical.dart';
import '../quiz/quiz_model.dart';
import '../utils/responsive.dart';

class AskTutor extends StatefulWidget {
  const AskTutor({Key? key}) : super(key: key);

  @override
  State<AskTutor> createState() => _AskTutorState();
}

class _AskTutorState extends State<AskTutor>
    with SingleTickerProviderStateMixin {
  bool micEnable = false;
  bool displayEnable = false;
  bool selected = false;
  bool selectedTools = false;
  bool openColors = false;
  bool openLines = false;
  bool openMore = false;
  bool enableDisplay = true;
  int _selectedIndexTools = 1;
  int _selectedIndexColors = 0;
  int _selectedIndexLines = 0;
  late bool isSelected;
  bool isChecked = false;
  late AnimationController progressController;
  late Animation<double> animation;

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
    {"color": ImageAssets.pickGreen},
    {"color": ImageAssets.pickBlack},
    {"color": ImageAssets.pickRed},
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
    {
      "image_active": ImageAssets.laserPenActive,
      "image_dis": ImageAssets.laserPenDis,
    }
  ];

  List students = [
    {
      "image": ImageAssets.avatarWomen,
      "name": "Dianne Russell",
      "status_share": "enable",
    },
    {
      "image": ImageAssets.avatarMen,
      "name": "Robert Fox",
      "status_share": "enable",
    },
    {
      "image": ImageAssets.avatarMen,
      "name": "Ron Ferrary",
      "status_share": "enable",
    },
    {
      "image": ImageAssets.avatarWomen,
      "name": "Arlene McCoy",
      "status_share": "enable",
    },
    {
      "image": ImageAssets.avatarMen,
      "name": "Brooklyn Simmons",
      "status_share": "enable",
    },
    {
      "image": ImageAssets.avatarMen,
      "name": "Dianne Russell",
      "status_share": "enable",
    },
    {
      "image": ImageAssets.avatarDisMen,
      "name": "Floyd Miles",
      "status_share": "disable",
    },
    {
      "image": ImageAssets.avatarDisWomen,
      "name": "Ronald Richards",
      "status_share": "disable",
    },
    {
      "image": ImageAssets.avatarDisMen,
      "name": "Theresa Webb",
      "status_share": "disable",
    },
    {
      "image": ImageAssets.avatarDisMen,
      "name": "Wade Warren",
      "status_share": "disable",
    },
  ];

  List<SelectQuizModel> quizList = [
    SelectQuizModel("ชุดที่#1 สมการเชิงเส้นตัวแปรเดียว", "1 ข้อ", false),
    SelectQuizModel("ชุดที่#2 สมการเชิงเส้น 2 ตัวแปร", "10 ข้อ", false),
    SelectQuizModel("ชุดที่#3  สมการจำนวนเชิงซ้อน", "5 ข้อ", false),
    SelectQuizModel("ชุดที่#4 สมการเชิงเส้นตัวแปรเดียว", "5 ข้อ", false),
    SelectQuizModel("ชุดที่#5 สมการเชิงเส้นตัวแปรเดียว", "5 ข้อ", false),
  ];

  List studentsDisplay = [
    {
      "image": ImageAssets.avatarMe,
      "name": "My Screen",
      "status_txt": "Sharing screen...",
      "share_now": "N",
      "status_share": "enable",
    },
    {
      "image": ImageAssets.avatarWomen,
      "name": "Dianne Russel",
      "status_txt": "Sharing screen...",
      "share_now": "Y",
      "status_share": "enable",
    },
    {
      "image": ImageAssets.avatarWomen,
      "name": "Darlene Robertson",
      "status_txt": "Sharing screen...",
      "share_now": "N",
      "status_share": "enable",
    },
    {
      "image": ImageAssets.avatarMen,
      "name": "Marvin McKinney",
      "status_txt": "Sharing screen...",
      "share_now": "N",
      "status_share": "enable",
    },
    {
      "image": ImageAssets.avatarWomen,
      "name": "Kathryn Murphy",
      "status_txt": "Sharing screen...",
      "share_now": "N",
      "status_share": "enable",
    },
    {
      "image": ImageAssets.avatarDisWomen,
      "name": "Bessie Cooper",
      "status_txt": "Not sharing",
      "share_now": "N",
      "status_share": "disable",
    },
    {
      "image": ImageAssets.avatarDisMen,
      "name": "Jacob Jones",
      "status_txt": "Not sharing",
      "share_now": "N",
      "status_share": "disable",
    },
    {
      "image": ImageAssets.avatarDisMen,
      "name": "Ralph Edwards",
      "status_txt": "Not sharing",
      "share_now": "N",
      "status_share": "disable",
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
            [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft])
        .then((value) => screenShotModal());
    firstRun();
    progressController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    animation = Tween<double>(begin: 0, end: 80).animate(progressController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.dispose();
  }

  firstRun() async {
    await Future.delayed(const Duration(seconds: 1));
    if (animation.value == 80) {
      progressController.reverse();
    } else {
      progressController.forward();
    }
  }

  final _util = UtilityHelper();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _util.hideKeyboard(context),
      child: Scaffold(
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
                    children: [tools(), sheetLayer()],
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
                    statusScreenRed("Recording Screen...", ImageAssets.pickRed),
                  ],
                )),
          ],
        )),
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
                flex: Responsive.isTablet(context) ? 4 : 3,
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_back,
                      color: CustomColors.gray878787,
                      size: 20.0,
                    ),
                    S.w(8),
                    Text(
                      "คอร์สปรับพื้นฐานคณิตศาสตร์ ก่อนขึ้น ม.4  - 01 ม.ค. 2023",
                      style: CustomStyles.bold16Black363636Overflow,
                      maxLines: 1,
                    ),
                  ],
                )),
          if (Responsive.isDesktop(context))
            Expanded(
                flex: 4,
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_back,
                      color: CustomColors.gray878787,
                      size: 20.0,
                    ),
                    S.w(defaultPadding),
                    Text(
                      "คอร์สปรับพื้นฐานคณิตศาสตร์ ก่อนขึ้น ม.4  - 01 ม.ค. 2023",
                      style: CustomStyles.bold16Black363636Overflow,
                      maxLines: 1,
                    ),
                  ],
                )),
          if (Responsive.isMobile(context))
            Expanded(
                flex: 2,
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_back,
                      color: CustomColors.gray878787,
                      size: 20.0,
                    ),
                    S.w(8),
                    Text(
                      "คอร์สปรับพื้นฐานคณิตศาสตร์ ก่อนขึ้น ม.4  - 01 ม.ค. 2023",
                      style: CustomStyles.bold16Black363636Overflow,
                      maxLines: 1,
                    ),
                  ],
                )),
          Expanded(
              flex: Responsive.isDesktop(context) ? 3 : 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  S.w(16.0),
                  Container(
                    height: 11,
                    width: 11,
                    decoration: BoxDecoration(
                        color: CustomColors.grayCFCFCF,
                        borderRadius: BorderRadius.circular(100)
                        //more than 50% of width makes circle
                        ),
                  ),
                  S.w(4.0),
                  Text(
                    'Live Ended: 01/01/2023 at 13:00',
                    style: CustomStyles.bold14Gray878787,
                  ),
                  S.w(8.0),
                  Text(
                    '(01:59:59 hr)',
                    style: CustomStyles.reg12Gray878787,
                  ),
                  S.w(Responsive.isTablet(context) ? 5 : 24),
                ],
              ))
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
              icon:
              const Icon(Icons.arrow_back, color: CustomColors.gray878787),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          S.w(Responsive.isTablet(context) ? 5 : 24),
          Expanded(
            flex: 2,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          ImageAssets.allPages,
                          height: 30,
                          width: 32,
                        ),
                        S.w(defaultPadding),
                        Container(
                          width: 1,
                          height: 24,
                          color: CustomColors.grayCFCFCF,
                        ),
                        S.w(defaultPadding),
                        Image.asset(
                          ImageAssets.backDis,
                          height: 16,
                          width: 17,
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text("Page 20",
                                  style: CustomStyles.bold14greenPrimary),
                            ],
                          ),
                        ),
                        S.w(8.0),
                        Text("/ 149", style: CustomStyles.med14Gray878787),
                        S.w(defaultPadding),
                        Image.asset(
                          ImageAssets.forward,
                          height: 16,
                          width: 17,
                        ),
                        S.w(6.0),
                      ],
                    ))),
          ),
          Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        micEnable = !micEnable;
                      });
                    },
                    child: Image.asset(
                      micEnable ? ImageAssets.micEnable : ImageAssets.micDis,
                      height: 44,
                      width: 44,
                    ),
                  ),
                  S.w(defaultPadding),
                  const DividerVer(),
                  S.w(defaultPadding),
                  // Image.asset(
                  //   ImageAssets.soundWave,
                  //   width: 240,
                  // ),
                  S.w(8),
                  RichText(
                    text: TextSpan(
                      text: '00:15 ',
                      style: CustomStyles.bold14RedF44336,
                      children: <TextSpan>[
                        TextSpan(
                          text: '/ 00:30',
                          style: CustomStyles.bold14Black363636,
                        ),
                      ],
                    ),
                  ),
                  S.w(8),
                  Stack(
                    children: [play()],
                  )
                ],
              )),
          SizedBox(
            width: 150,
            height: 40,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.greenPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // <-- Radius
                  ), // NEW
                ),
                onPressed: () {
                  print('recording view');
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => const RecordingReview()),
                  // );
                },
                child: Row(
                  children: [
                    Text('ส่งคำถาม', style: CustomStyles.bold14White),
                    S.w(4),
                    Container(
                      width: 3,
                      height: 16,
                      color: CustomColors.whitePrimary,
                    ),
                    S.w(4),
                    const Icon(
                      Icons.arrow_forward,
                      color: CustomColors.whitePrimary,
                      size: 20.0,
                    ),
                  ],
                ),
            ),
          ),
          S.w(Responsive.isTablet(context) ? 5 : 24),
        ],
      ),
    );
  }

  /// Tools
  Widget tools() {
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (Responsive.isDesktop(context)) S.w(10),
          Center(
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
                    S.h(8),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding, vertical: 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: () {
                                print("Undo");
                              },
                              child: Image.asset(
                                ImageAssets.undo,
                                width: 38,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                print("Redo");
                              },
                              child: Image.asset(
                                ImageAssets.redo,
                                width: 38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        height: 2, width: 80, color: CustomColors.grayF3F3F3),
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
                                          print('Tap : index $index');
                                          print(
                                              'Tap : _selectIndex $_selectedIndexTools');
                                        },
                                        child: Image.asset(
                                          _selectedIndexTools == index
                                              ? _listTools[index]
                                                  ['image_active']
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
                                                  print("Choose Color");
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
                                                  _listColors[
                                                          _selectedIndexColors]
                                                      ['color'],
                                                  width: 38,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  print("Pick Line");

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
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  print("Clear");
                                                },
                                                child: Image.asset(
                                                  ImageAssets.bin,
                                                  width: 38,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  print("More");

                                                  setState(() {
                                                    if (openColors ||
                                                        openLines == true) {
                                                      openColors = false;
                                                      openLines = false;
                                                    }
                                                    openMore = !openMore;
                                                  });
                                                },
                                                child: Image.asset(
                                                  ImageAssets.more,
                                                  width: 38,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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
                                    )),
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
                        ))
                  ],
                ),
              ),
            ),
          ),
          if (openColors)
            Container(
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

                                  // Close popup
                                  openColors = !openColors;
                                });
                                print('Tap : index $index');
                                print(
                                    'Tap : _selectIndex $_selectedIndexColors');
                              },
                              child: Image.asset(
                                _listColors[index]['color'],
                              ),
                            ),
                            S.h(4)
                          ],
                        );
                      })
                ],
              ),
            ),
          if (openLines)
            Container(
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

                                  // Close popup
                                  openLines = !openLines;
                                });
                              });
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  _selectedIndexLines == index
                                      ? _listLines[index]['image_active']
                                      : _listLines[index]['image_dis'],
                                ),
                                S.h(8)
                              ],
                            ));
                      })
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget statusScreenRed(String txt, String img) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: CustomColors.pinkFFCDD2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          S.w(16),
          Image.asset(
            img,
            width: 16,
          ),
          S.w(12),
          Text(
            txt,
            style: CustomStyles.bold14RedB71C1C,
          ),
          S.w(16),
        ],
      ),
    );
  }

  Future<void> screenShotModal() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Column(
              children: [
                ///Header
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
                                flex: Responsive.isTablet(context) ? 4 : 3,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.arrow_back,
                                      color: CustomColors.gray878787,
                                      size: 20.0,
                                    ),
                                    S.w(8),
                                    Text(
                                      "คอร์สปรับพื้นฐานคณิตศาสตร์ ก่อนขึ้น ม.4  - 01 ม.ค. 2023",
                                      style: CustomStyles
                                          .bold16Black363636Overflow,
                                      maxLines: 1,
                                    ),
                                  ],
                                )),
                          if (Responsive.isDesktop(context))
                            Expanded(
                                flex: 4,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.arrow_back,
                                      color: CustomColors.gray878787,
                                      size: 20.0,
                                    ),
                                    S.w(defaultPadding),
                                    Text(
                                      "คอร์สปรับพื้นฐานคณิตศาสตร์ ก่อนขึ้น ม.4  - 01 ม.ค. 2023",
                                      style: CustomStyles
                                          .bold16Black363636Overflow,
                                      maxLines: 1,
                                    ),
                                  ],
                                )),
                          if (Responsive.isMobile(context))
                            Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.arrow_back,
                                      color: CustomColors.gray878787,
                                      size: 20.0,
                                    ),
                                    S.w(8),
                                    Text(
                                      "คอร์สปรับพื้นฐานคณิตศาสตร์ ก่อนขึ้น ม.4  - 01 ม.ค. 2023",
                                      style: CustomStyles
                                          .bold16Black363636Overflow,
                                      maxLines: 1,
                                    ),
                                  ],
                                )),
                          Expanded(
                              flex: Responsive.isDesktop(context) ? 3 : 4,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  S.w(16.0),
                                  Container(
                                    height: 11,
                                    width: 11,
                                    decoration: BoxDecoration(
                                        color: CustomColors.grayCFCFCF,
                                        borderRadius: BorderRadius.circular(100)
                                        //more than 50% of width makes circle
                                        ),
                                  ),
                                  S.w(4.0),
                                  Text(
                                    'Live Ended: 01/01/2023 at 13:00',
                                    style: CustomStyles.bold14Gray878787,
                                  ),
                                  S.w(8.0),
                                  Text(
                                    '(01:59:59 hr)',
                                    style: CustomStyles.reg12Gray878787,
                                  ),
                                  S.w(Responsive.isTablet(context) ? 5 : 24),
                                ],
                              ))
                        ],
                      ),
                    )),
                Material(
                    // color: Colors.transparent,
                    child: Container(
                  width: double.infinity,
                  height: 1,
                  color: CustomColors.grayCFCFCF,
                )),

                ///Header2
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
                        S.w(8),
                        IconButton(
                            icon:
                            const Icon(Icons.arrow_back, color: CustomColors.gray878787),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }),
                        S.w(Responsive.isTablet(context) ? 5 : 24),
                        Expanded(
                          flex: 2,
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1, vertical: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        ImageAssets.allPages,
                                        height: 30,
                                        width: 32,
                                      ),
                                      S.w(defaultPadding),
                                      Container(
                                        width: 1,
                                        height: 24,
                                        color: CustomColors.grayCFCFCF,
                                      ),
                                      S.w(defaultPadding),
                                      Image.asset(
                                        ImageAssets.backDis,
                                        height: 16,
                                        width: 17,
                                      ),
                                      S.w(defaultPadding),
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
                                      S.w(defaultPadding),
                                      Image.asset(
                                        ImageAssets.forward,
                                        height: 16,
                                        width: 17,
                                      ),
                                      S.w(6.0),
                                    ],
                                  ))),
                        ),
                        Expanded(
                            flex: 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      micEnable = !micEnable;
                                    });
                                  },
                                  child: Image.asset(
                                    micEnable
                                        ? ImageAssets.micEnable
                                        : ImageAssets.micDis,
                                    height: 44,
                                    width: 44,
                                  ),
                                ),
                                S.w(defaultPadding),
                                const DividerVer(),
                                S.w(defaultPadding),
                                // Image.asset(
                                //   ImageAssets.soundWave,
                                //   width: 240,
                                // ),
                                S.w(8),
                                RichText(
                                  text: TextSpan(
                                    text: '00:15 ',
                                    style: CustomStyles.bold14RedF44336,
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: '/ 00:30',
                                        style: CustomStyles.bold14Black363636,
                                      ),
                                    ],
                                  ),
                                ),
                                S.w(8),
                                Stack(
                                  children: [play()],
                                )
                              ],
                            )),
                        SizedBox(
                          width: 150,
                          height: 40,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CustomColors.greenPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(8.0), // <-- Radius
                                ), // NEW
                              ),
                              onPressed: () {
                                print('recording view');
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) =>
                                //           const RecordingReview()),
                                // );
                              },
                              child: Row(
                                children: [
                                  Text('ส่งคำถาม',
                                      style: CustomStyles.bold14White),
                                  S.w(4),
                                  Container(
                                    width: 3,
                                    height: 16,
                                    color: CustomColors.whitePrimary,
                                  ),
                                  S.w(4),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: CustomColors.whitePrimary,
                                    size: 20.0,
                                  ),
                                ],
                              )),
                        ),
                        S.w(Responsive.isTablet(context) ? 5 : 24),
                      ],
                    ),
                  ),
                ),

                ///Modal screenshot
                Expanded(
                  child: Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 0,
                    backgroundColor: CustomColors.grayF3F3F3,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text('บันทึกคำถาม ได้ไม่เกิน 30 วินาที',
                                  style: CustomStyles.bold22Black363636),
                              S.h(defaultPadding * 2),
                              Image.asset(
                                'assets/images/ic_screenshot.png',
                                width: 80,
                              ),
                              S.h(defaultPadding * 2),
                              Text(
                                  'กรุณาไฮไลท์ (Highlight) เนื้อหาที่ต้องการถาม',
                                  style: CustomStyles.bold14Black363636),
                              Text('เพื่อไม่ให้คำถามของคุณคลุมเครือ',
                                  style: CustomStyles.med14Black363636),
                              S.h(defaultPadding * 2),
                              RichText(
                                text: TextSpan(
                                  text: 'ระบบจะหยุดการบันทึกโดยอัตโนมัติ ',
                                  style: CustomStyles.bold14Gray878787,
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          'หากคุณไม่มีการบันทึกเสียงภายใน 10 วินาทีแรก',
                                      style: CustomStyles.med14Gray878787,
                                    ),
                                  ],
                                ),
                              ),
                              S.h(24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width: 230,
                                    height: 40,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                CustomColors.whitePrimary,
                                            elevation: 0,
                                            side: const BorderSide(
                                                width: 1,
                                                color: CustomColors.grayE5E6E9),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                              8.0,
                                            ))),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('ยกเลิก',
                                            style:
                                                CustomStyles.bold14Gray878787)),
                                  ),
                                  SizedBox(
                                    width: 230,
                                    height: 40,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              CustomColors.redF44336,
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
                                            Image.asset(
                                              'assets/images/ic_start_screenshot.png',
                                              width: 22,
                                            ),
                                            S.w(defaultPadding / 4),
                                            Text('เริ่มบันทึกเสียงและหน้าจอ',
                                                style: CustomStyles.bold14White)
                                          ],
                                        ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          });
        });
  }

  play() {
    return Center(
      child: CustomPaint(
        foregroundPainter: CircleProgress(
            animation.value), // this will add custom painter after child
        child: SizedBox(
          width: 100,
          height: 100,
          child: GestureDetector(
            onTap: () {
              if (animation.value == 80) {
                progressController.reverse();
              } else {
                progressController.forward();
              }
            },
            child: Container(
              margin: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                  color: AnimationStatus.completed == animation.status
                      ? CustomColors.gray363636
                      : CustomColors.redFF4201,
                  shape: BoxShape.circle),
              child: AnimationStatus.completed == animation.status
                  ? const Icon(
                      Icons.pause,
                      size: 23,
                      color: CustomColors.white,
                    )
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        'assets/images/ic_start_screenshot.png',
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget sheetLayer() {
    return Expanded(
      flex: 4,
      child: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          children: <Widget>[
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Responsive.isDesktop(context) ? 35 : 30),
                    child: Column(
                      children: [
                        ///Sheet area
                        AspectRatio(
                          aspectRatio: 6 / 9,
                          child: Container(
                            color: Colors.lightBlue,
                            child: Center(
                              child: Text(
                                'Sheet',
                                style: CustomStyles.bold14White,
                              ),
                            ),
                          ),
                        ),
                        S.h(30)
                      ],
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
