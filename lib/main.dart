import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:solve_student/constants/app_constants.dart';
import 'package:solve_student/constants/state_index.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/splash_page.dart';
import 'authentication/service/fcm.dart';

//global context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  // initializeDateFormatting();
  await Firebase.initializeApp();

  //initial push notification
  final FCMServices fcmService = FCMServices();
  await fcmService.firebaseMessaging.setAutoInitEnabled(true);
  await fcmService.initializeService();
  String token = await fcmService.getDeviceToken();
  print("token: $token");
  //firebase background service
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
          // localizationsDelegates: const [
          //   GlobalMaterialLocalizations.delegate,
          //   GlobalWidgetsLocalizations.delegate,
          //   GlobalCupertinoLocalizations.delegate,
          // ],
          supportedLocales: const [
            Locale('th', 'TH'),
            Locale('en', 'GB'),
            Locale('en', 'US'),
          ],
          locale: const Locale('th', 'TH'),
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
          home: const SplashPage(),
        ),
      );
    });
  }
}

// must handle in main methods
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage? message) async {
  await Firebase.initializeApp();
  if (message != null) {
    //handle background notification
    print("message: ${message.notification?.title}");
  }
}