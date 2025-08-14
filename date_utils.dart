import 'package:intl/intl.dart';

class AppDate {
  static final _fmtDate = DateFormat('dd.MM.yyyy');
  static final _fmtDateTime = DateFormat('dd.MM.yyyy HH:mm');

  static String d(DateTime dt) => _fmtDate.format(dt);
  static String dt(DateTime dt) => _fmtDateTime.format(dt);

  static int fullDaysCeil(DateTime start, DateTime end) {
    final diff = end.difference(start);
    final hours = diff.inHours + (diff.inMinutes % 60 > 0 ? 1 : 0);
    final days = (hours / 24).ceil();
    return days <= 0 ? 1 : days;
  }
}
