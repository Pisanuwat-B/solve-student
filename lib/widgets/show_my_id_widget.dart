import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/widgets/dialogs.dart';

class ShowMyIdWidget extends StatelessWidget {
  const ShowMyIdWidget({
    super.key,
    required this.authprovider,
  });
  final AuthProvider? authprovider;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: BoxDecoration(
                color: getMaterialColor(primaryColor).shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: primaryColor,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${authprovider?.uid ?? ""} ",
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                        text: authprovider?.uid ?? "",
                      ));
                      Dialogs.showSnackbar(context, "คัดลอกสำเร็จ");
                    },
                    icon: const Icon(
                      Icons.copy_sharp,
                      color: primaryColor,
                    ),
                  )
                ],
              ),
            ),
          ),
          // const SizedBox(width: 20),
          // Container(
          //   padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          //   decoration: BoxDecoration(
          //     color: Colors.transparent,
          //     borderRadius: BorderRadius.circular(10),
          //     border: Border.all(
          //       color: greyColor,
          //     ),
          //   ),
          //   child: IconButton(
          //     onPressed: () {},
          //     icon: const Icon(
          //       Icons.ios_share,
          //       color: Colors.grey,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
