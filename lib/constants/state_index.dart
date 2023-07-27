import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:slove_student/authentication/service/auth_provider.dart';
import 'package:slove_student/authentication/service/setting_provider.dart';
import 'package:slove_student/feature/calendar/controller/create_course_controller.dart';
import 'package:slove_student/feature/calendar/controller/create_course_live_controller.dart';
import 'package:slove_student/feature/calendar/controller/document_controller.dart';
import 'package:slove_student/feature/calendar/controller/student_controller.dart';
import 'package:slove_student/feature/chat/service/chat_provider.dart';
import 'package:slove_student/feature/class/services/class_provider.dart';
import 'package:slove_student/feature/home/service/home_provider.dart';
import 'package:slove_student/feature/market_place/service/market_place_provider.dart';
import 'package:slove_student/feature/order/service/order_mock_provider.dart';
import 'package:slove_student/feature/standby_study/service/state_study_provider.dart';

final List<SingleChildWidget> stateIndex = [
  ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
  ChangeNotifierProvider<HomeProvider>(create: (_) => HomeProvider()),
  ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
  ChangeNotifierProvider<OrderMockProvider>(create: (_) => OrderMockProvider()),
  Provider<SettingProvider>(create: (_) => SettingProvider()),
  ChangeNotifierProvider<MarketPlaceProvider>(
      create: (_) => MarketPlaceProvider()),
  ChangeNotifierProvider<ClassProvider>(create: (_) => ClassProvider()),
  ChangeNotifierProvider<StandbyStudyProvider>(
      create: (_) => StandbyStudyProvider()),
  ChangeNotifierProvider(create: (context) => CourseController()),
  ChangeNotifierProvider(create: (context) => CourseLiveController()),
  ChangeNotifierProvider(create: (context) => DocumentController()),
  ChangeNotifierProvider(create: (context) => StudentController()),
];
