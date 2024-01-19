import 'package:flutter/material.dart';

import '../../calendar/constants/custom_colors.dart';
import '../../calendar/constants/custom_styles.dart';
import '../../calendar/widgets/sizebox.dart';
import '../../live_classroom/utils/responsive.dart';

Future<void> showAskDialog(BuildContext context, Function onConfirm,
    {Function? onCancel}) {
  onCancel ??= () {};
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
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
                  Text('กรุณาไฮไลท์ (Highlight) เนื้อหาที่ต้องการถาม',
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
                          text: 'หากคุณไม่มีการบันทึกเสียงภายใน 10 วินาทีแรก',
                          style: CustomStyles.med14Gray878787,
                        ),
                      ],
                    ),
                  ),
                  S.h(24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width:
                            Responsive.isMobileLandscape(context) ? 180 : 230,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColors.whitePrimary,
                              elevation: 0,
                              side: const BorderSide(
                                  width: 1, color: CustomColors.grayE5E6E9),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                8.0,
                              ))),
                          onPressed: () {
                            Navigator.of(context).pop('cancel');
                            onCancel!();
                          },
                          child: Text('ยกเลิก',
                              style: CustomStyles.bold14Gray878787),
                        ),
                      ),
                      SizedBox(
                        width:
                            Responsive.isMobileLandscape(context) ? 180 : 230,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.redF44336,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8.0), // <-- Radius
                            ), // NEW
                          ),
                          onPressed: () {
                            onConfirm();
                            Navigator.of(context).pop('confirm');
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
      );
    },
  ).then((value) {
    if (value == null || value == 'cancel') {
      onCancel!();
    }
  });
}
