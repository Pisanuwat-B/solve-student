import 'package:intl/intl.dart';

class FormatDate {
  static String dt(DateTime? dt) {
    if (dt == null) {
      return '';
    } else {
      var d = DateFormat('dd/MM/yyyy, HH:mm', 'th').format(dt);
      return d.toString();
    }
  }

  static String dayOnlyNumber(DateTime? dt) {
    if (dt == null) {
      return '';
    } else {
      var d = DateFormat('dd/MM/yyyy').format(dt);
      return d.toString();
    }
  }

  static String timeOnlyNumber(DateTime? dt) {
    if (dt == null) {
      return '';
    } else {
      var d = DateFormat('HH:mm').format(dt);
      return d.toString();
    }
  }

  static String dayOnly(DateTime? dt) {
    if (dt == null) {
      return '';
    } else {
      var d = DateFormat('dd MMM yyyy', 'th').format(dt);
      return d.toString();
    }
  }
}
