import 'package:flutter/material.dart';

import '../../calendar/constants/assets_manager.dart';
import '../../calendar/constants/custom_colors.dart';
import '../../calendar/constants/custom_styles.dart';
import '../../calendar/widgets/sizebox.dart';
import 'divider.dart';

class ViewAllStudentMobile extends StatefulWidget {
  const ViewAllStudentMobile({Key? key}) : super(key: key);

  @override
  State<ViewAllStudentMobile> createState() => _ViewAllStudentMobileState();
}

class _ViewAllStudentMobileState extends State<ViewAllStudentMobile> {
  List studentsDisplay = [
    {
      "image": ImageAssets.avatarMen,
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.grayF3F3F3,
      body: Column(
        children: [
          Container(
            height: 36,
            decoration:
                BoxDecoration(color: CustomColors.whitePrimary, boxShadow: [
              BoxShadow(
                  color: CustomColors.gray878787.withOpacity(.1),
                  offset: const Offset(0.0, 6),
                  blurRadius: 10,
                  spreadRadius: 1)
            ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                S.w(28),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    color: CustomColors.gray878787,
                    size: 24,
                  ),
                )
              ],
            ),
          ),
          const DividerLine(),
          Padding(
            padding: const EdgeInsets.all(40),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('สลับหน้าไปจอของ...',
                          style: CustomStyles.bold16Black363636),
                      Expanded(child: Container()),
                      SizedBox(
                        height: 40,
                        width: 220,
                        child: TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            labelText: 'ชื่อผู้เรียน',
                            labelStyle: CustomStyles.med14Gray878787,
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(
                              Icons.search,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  S.h(16),
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.53,
                    child: ListView.builder(
                        itemCount: studentsDisplay.length,
                        itemBuilder: (BuildContext context, index) {
                          return Column(
                            children: [
                              Container(
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: CustomColors.whitePrimary,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    S.w(defaultPadding),
                                    Image.asset(
                                      studentsDisplay[index]['image'],
                                      height: 32,
                                      width: 32,
                                    ),
                                    S.w(defaultPadding),
                                    Text(
                                      studentsDisplay[index]['name'],
                                      style: CustomStyles.bold16Black363636,
                                      maxLines: 1,
                                    ),
                                    S.w(defaultPadding),
                                    if (studentsDisplay[index]
                                            ['status_share'] !=
                                        'disable')
                                      Image.asset(
                                        ImageAssets.shareGreen,
                                        width: 22,
                                      ),
                                    if (studentsDisplay[index]
                                            ['status_share'] !=
                                        'disable')
                                      S.w(3),
                                    Text(
                                      studentsDisplay[index]['status_txt'],
                                      style: studentsDisplay[index]
                                                  ['status_share'] ==
                                              'disable'
                                          ? CustomStyles.med12gray878787
                                          : CustomStyles.bold12greenPrimary,
                                    ),
                                    Expanded(child: Container()),
                                    if (studentsDisplay[index]
                                                ['status_share'] !=
                                            'disable' &&
                                        studentsDisplay[index]['share_now'] ==
                                            'N')
                                      SizedBox(
                                        width: 80,
                                        height: 30,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  CustomColors.greenPrimary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8.0), // <-- Radius
                                              ), // NEW
                                            ),
                                            onPressed: () {
// Navigator.of(context).pop();
                                            },
                                            child: Text('เลือก',
                                                style:
                                                    CustomStyles.bold11White)),
                                      ),
                                    if (studentsDisplay[index]['share_now'] ==
                                        'Y')
                                      Container(
                                        width: 100,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: CustomColors.grayCFCFCF,
                                            style: BorderStyle.solid,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: CustomColors.whitePrimary,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "ออกจากการแชร์",
                                            style:
                                                CustomStyles.bold11Gray878787,
                                          ),
                                        ),
                                      ),
                                    S.w(8)
                                  ],
                                ),
                              ),
                              S.h(8)
                            ],
                          );
                        }),
                  ),
                  // S.h(24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
