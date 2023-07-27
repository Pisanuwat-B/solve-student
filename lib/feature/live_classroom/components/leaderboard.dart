import 'package:flutter/material.dart';

import '../../calendar/constants/assets_manager.dart';
import '../../calendar/constants/custom_colors.dart';
import '../../calendar/constants/custom_styles.dart';
import '../../calendar/widgets/sizebox.dart';
import '../utils/responsive.dart';
import 'close_dialog.dart';

Future<void> showLeader(BuildContext context) async {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
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
                                showCloseDialog(context, () {});
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
                                        "ปิดห้องเรียน",
                                        style: CustomStyles.bold14White,
                                      ),
                                    ],
                                  )),
                            ),
                            S.w(Responsive.isTablet(context) ? 5 : 24),
                          ],
                        ))
                  ],
                ),
              ),
            ),

            ///Modal Leaderboard
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
                              S.w(32),
                              Text('Leaderboard',
                                  style: CustomStyles.bold22Black363636),
                              Expanded(child: Container()),

                              /// Statics
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: CustomColors.grayCFCFCF,
                                        style: BorderStyle.solid,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(32),
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
                                          Text("100%",
                                              style: CustomStyles
                                                  .bold14greenPrimary),
                                          if (!Responsive.isTablet(context))
                                            S.w(8.0),
                                          Image.asset(
                                            ImageAssets.x,
                                            height: 18,
                                            width: 18,
                                          ),
                                          if (!Responsive.isTablet(context))
                                            S.w(8.0),
                                          Text("100%",
                                              style:
                                                  CustomStyles.bold14RedF44336),
                                          if (!Responsive.isTablet(context))
                                            S.w(8.0),
                                          Image.asset(
                                            ImageAssets.icQa,
                                            height: 18,
                                            width: 18,
                                          ),
                                          if (!Responsive.isTablet(context))
                                            S.w(8.0),
                                          Text("100%",
                                              style: CustomStyles
                                                  .bold14orangeCC6700),
                                          if (!Responsive.isTablet(context))
                                            S.w(8.0),
                                        ],
                                      ),
                                    ),
                                  )),
                              S.w(32),
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
                          SizedBox(
                            height: 40,
                            child: TextFormField(
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                labelText: 'ค้นหาชื่อผู้เรียน',
                                labelStyle: CustomStyles.med14Gray878787,
                                border: const OutlineInputBorder(),
                                suffixIcon: const Icon(
                                  Icons.search,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          S.h(20),
                          AspectRatio(
                            aspectRatio: 16 / 4,
                            child: SingleChildScrollView(
                              child: Container(
                                color: CustomColors.pinkFFCDD2.withOpacity(.6),
                                child: Center(
                                    child: Column(
                                  children: [
                                    Text("Leaderboard"),
                                    Text("Leaderboard"),
                                    Text("Leaderboard"),
                                    Text("Leaderboard"),
                                    Text("Leaderboard"),
                                    Text("Leaderboard"),
                                    Text("Leaderboard"),
                                    Text("Leaderboard"),
                                    Text("Leaderboard"),
                                    Text("Leaderboard"),
                                    Text("Leaderboard"),
                                    Text("Leaderboard"),
                                    Text("Leaderboard"),
                                    Text("Leaderboard"),
                                    Text("Leaderboard"),
                                    Text("Leaderboard"),
                                    Text("Leaderboard"),
                                    Text("Leaderboard"),
                                    Text("Leaderboard"),
                                  ],
                                )),
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
                                    backgroundColor: CustomColors.greenPrimary,
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
                                  )),
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
      });
}
