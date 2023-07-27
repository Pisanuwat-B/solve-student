import 'package:flutter/material.dart';
import 'package:slove_student/constants/theme.dart';
import 'package:slove_student/widgets/sizer.dart';

class ConfirmActionWidget extends StatefulWidget {
  ConfirmActionWidget({
    super.key,
    this.onPressed,
    this.title = "ยืนยันการทำรายการ",
    this.content = "คุณต้องการยืนยันการทำรายการนี้หรือไม่",
    this.confirmText = "ยืนยัน",
    this.closeText = "ยกเลิก",
    this.confirmColor = primaryColor,
  });
  final VoidCallback? onPressed;
  String? title;
  String? content;
  String confirmText;
  String closeText;
  Color confirmColor;
  @override
  State<ConfirmActionWidget> createState() => _ConfirmActionWidgetState();
}

class _ConfirmActionWidgetState extends State<ConfirmActionWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // SizedBox(height: 100),
          Container(
            height: 200,
            width: 300,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title ?? "",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(),
                      Expanded(
                        child: Text(
                          widget.content ?? "",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: Sizer(context).w,
                                height: 45,
                                margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.closeText,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                widget.onPressed!();
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: Sizer(context).w,
                                height: 45,
                                margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                decoration: BoxDecoration(
                                  color: widget.confirmColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.confirmText,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
