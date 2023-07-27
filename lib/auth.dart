import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/pages/login_page.dart';
import 'package:solve_student/authentication/pages/no_permission_page.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/nav.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  String role = 'student';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.firebaseAuth.currentUser != null) {
        auth.getSelfInfo();
        // await auth.updateRoleFirestore(role);
        await Future.delayed(const Duration(milliseconds: 500));
      }
    });
  }

  late AuthProvider auth;
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, con, child) {
        if (con.firebaseAuth.currentUser != null) {
          if (con.user?.role != role) {
            return const NoPermissionPage();
          } else {
            return Nav();
          }
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
