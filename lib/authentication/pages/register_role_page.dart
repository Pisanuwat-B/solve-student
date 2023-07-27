import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slove_student/auth.dart';
import 'package:slove_student/authentication/service/auth_provider.dart';
import 'package:slove_student/constants/theme.dart';
import 'package:slove_student/widgets/sizer.dart';

class RegisterRolePage extends StatefulWidget {
  const RegisterRolePage({super.key});

  @override
  State<RegisterRolePage> createState() => _RegisterRolePageState();
}

class _RegisterRolePageState extends State<RegisterRolePage> {
  updateRole(AuthProvider auth, String role) async {
    try {
      await auth.updateRoleFirestore(role);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Authenticate()),
      );
    } catch (e) {
      log("catch $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Sizer s = Sizer(context);
    AuthProvider authProvider = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Role",
          style: TextStyle(color: appTextPrimaryColor),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: s.w,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      updateRole(authProvider, 'student');
                    },
                    child: Container(
                      height: 150,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.fromLTRB(10, 10, 5, 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.child_care),
                          Text(
                            "Student",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      updateRole(authProvider, 'tutor');
                    },
                    child: Container(
                      height: 150,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.fromLTRB(5, 10, 10, 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.face),
                          Text(
                            "Tutor",
                            style: TextStyle(
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
      ),
    );
  }
}
