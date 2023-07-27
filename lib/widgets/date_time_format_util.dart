import 'package:intl/intl.dart';

extension DateTimeFormat on DateTime {
  String date() {
    DateTime dateTime = toLocal();
    DateTime be = DateTime(dateTime.year, dateTime.month, dateTime.day);
    return DateFormat('yyyy-MM-dd', 'th_TH').format(be);
  }

  String time() {
    DateTime dateTime = toLocal();
    DateTime be = DateTime(dateTime.year, dateTime.month, dateTime.day,
        dateTime.hour, dateTime.minute);
    return DateFormat(
      'HH:mm',
    ).format(be);
  }

  String dateTime() {
    DateTime dateTime = toLocal();
    DateTime be = DateTime(dateTime.year, dateTime.month, dateTime.day);
    return DateFormat('yyyy-MM-dd HH:mm', 'th_TH').format(be);
  }
}
