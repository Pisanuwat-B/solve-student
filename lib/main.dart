import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:solve_student/constants/app_constants.dart';
import 'package:solve_student/constants/state_index.dart';
import 'package:solve_student/constants/theme.dart';
import 'package:solve_student/splash_page.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;

Future<void> main() async {
  initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  // initializeDateFormatting();
  await Firebase.initializeApp();
  await initPurchases();
  // await checkInfo();
  runApp(const MyApp());
}

Future<void> initPurchases() async {
  // Debug logs in debug, quieter in release
  await Purchases.setDebugLogsEnabled(!kReleaseMode);

  final config = PurchasesConfiguration(
    Platform.isIOS ? 'appl_TwFQeydeYOKdGIgyvhMkcWmSLXg' : '<ANDROID_PUBLIC_API_KEY>',
    // If you have your own userId, set it here:
    // appUserId: '<your-user-id>',
  );

  await Purchases.configure(config);

  // (Optional) listen for entitlement changes to update UI/paywall visibility
  Purchases.addCustomerInfoUpdateListener((customerInfo) {
    final hasPro = customerInfo.entitlements.active.containsKey('student');
    // TODO: update your Provider/state with hasPro if you want
  });
}

Future<void> checkInfo() async {
  final pkg = await PackageInfo.fromPlatform();
  log('BUNDLE ID AT RUNTIME = ${pkg.packageName}');

  final prods = await Purchases.getProducts(['student_monthly']);
  log('Store products: ${prods.map((p) => '${p.identifier}:${p.priceString}').toList()}');

  // final offerings = await Purchases.getOfferings();
  // log('offerings: ${offerings.current?.availablePackages.map((p) => p.storeProduct.identifier).toList()}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MultiProvider(
        providers: stateIndex,
        child: MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
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
