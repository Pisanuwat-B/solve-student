import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/authentication/service/setting_provider.dart';
import 'package:solve_student/feature/calendar/controller/create_course_controller.dart';
import 'package:solve_student/feature/calendar/controller/create_course_live_controller.dart';
import 'package:solve_student/feature/calendar/controller/document_controller.dart';
import 'package:solve_student/feature/calendar/controller/student_controller.dart';
import 'package:solve_student/feature/chat/service/chat_provider.dart';
import 'package:solve_student/feature/class/services/class_provider.dart';
import 'package:solve_student/feature/market_place/service/market_home_provider.dart';
import 'package:solve_student/feature/market_place/service/market_search_provider.dart';
import 'package:solve_student/feature/order/service/order_mock_provider.dart';
import 'package:solve_student/feature/standby_study/service/state_study_provider.dart';

final List<SingleChildWidget> stateIndex = [
  ChangeNotifierProvider<AuthProvider>(
    create: (_) => AuthProvider(),
  ),
  ChangeNotifierProvider<MarketHomeProvider>(
    create: (_) => MarketHomeProvider(),
  ),
  ChangeNotifierProvider<MarketSearchProvider>(
    create: (_) => MarketSearchProvider(),
  ),
  ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
  ChangeNotifierProvider<OrderMockProvider>(create: (_) => OrderMockProvider()),
  Provider<SettingProvider>(create: (_) => SettingProvider()),
  ChangeNotifierProvider<ClassProvider>(create: (_) => ClassProvider()),
  ChangeNotifierProvider<StandbyStudyProvider>(
      create: (_) => StandbyStudyProvider()),
  ChangeNotifierProvider(create: (context) => CourseController()),
  ChangeNotifierProvider(create: (context) => CourseLiveController()),
  ChangeNotifierProvider(create: (context) => DocumentController()),
  ChangeNotifierProvider(create: (context) => StudentController()),
];
