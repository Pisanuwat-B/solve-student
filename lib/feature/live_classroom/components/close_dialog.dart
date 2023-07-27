import 'package:flutter/material.dart';

import '../../calendar/constants/custom_colors.dart';
import '../../calendar/constants/custom_styles.dart';
import '../../calendar/widgets/sizebox.dart';
import '../utils/responsive.dart';

Future<void> showCloseDialog(BuildContext context, Function onConfirm) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: CustomColors.whitePrimary,
          child: SizedBox(
            width: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.width * 0.65
                : MediaQuery.of(context).size.width * 0.5,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('ต้องการจบการสอน?',
                      style: CustomStyles.bold22Black363636),
                  S.h(32),
                  Text("นักเรียนในห้องของคุณทั้งหมดจะถูกบังคับให้ออกจากห้อง",
                      style: CustomStyles.med14Gray878787,
                      textAlign: TextAlign.center),
                  S.h(32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 185,
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
                              Navigator.of(context).pop(); // Close the dialog
                              onConfirm(); // Execute the confirmation function
                            },
                            child: Text('ปิดห้องเรียน',
                                style: CustomStyles.bold14White)),
                      ),
                      SizedBox(
                        width: 185,
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
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('กลับไปที่ห้องเรียน',
                                style: CustomStyles.bold14Gray878787)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      });
  // }
}
