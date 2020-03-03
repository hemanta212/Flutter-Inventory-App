import 'package:intl/intl.dart';

class DateUtils{
  static bool isNotOfToday(String date) {
    DateTime givenDate = DateFormat.yMMMd().add_jms().parse(date);
    DateTime current = DateTime.now();
    return givenDate.year != current.year ||
        givenDate.month != current.month ||
        givenDate.day != current.day;
  }

}
