import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:solve_student/constants/app_constants.dart';
import 'package:solve_student/constants/state_index.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/splash_page.dart';

Future<void> main() async {
  initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  // initializeDateFormatting();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MultiProvider(
        providers: stateIndex,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appTitle,
          theme: ThemeData(
            primaryColor: primaryColor,
            primarySwatch: getMaterialColor(primaryColor),
            scaffoldBackgroundColor: Colors.grey.shade100,
            fontFamily: 'NotoSans',
            // textTheme: GoogleFonts.kanitTextTheme(
            //   Theme.of(context).textTheme,
            // ),
          ),
          home: SplashPage(),
        ),
      );
    });
  }
}
