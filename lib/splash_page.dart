import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/auth.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    auth = Provider.of<AuthProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (auth.firebaseAuth.currentUser != null) {
        auth.getSelfInfo();
      }
      await Future.delayed(const Duration(seconds: 2));
      goToMiddleware();
    });
  }

  void goToMiddleware() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Authenticate()),
    );
  }

  late AuthProvider auth;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset("assets/images/logo.json", width: 100),
      ),
    );
  }
}
