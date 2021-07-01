import 'package:ntp/ntp.dart';

enum LOGIN_STATE{LOGGED, NOT_LOGIN}

const TIME_SLOT = {
  "9:00-10:00",
  "10:00-11:00",
  "11:00-12:00",
  "12:00-13:00",
  "13:00-14:00",
  "14:00-15:00",
  "15:00-16:00",
  "16:00-17:00",
  "17:00-18:00",
  "18:00-19:00",
  "19:00-20:00",
};

Future<int> getMaxAvailableTimeSlot()async{
  DateTime now = DateTime.now();
  int offset = await NTP.getNtpOffset(localTime: now);
  DateTime syncTime = now.add(Duration(milliseconds: offset));

  if(syncTime.isAfter(DateTime(now.year, now.month, now.day, 9, 00)) && syncTime.isBefore(DateTime(now.year, now.month, now.day, 9, 30)))
    return 1;
  else if(syncTime.isAfter(DateTime(now.year, now.month, now.day, 9, 30)) && syncTime.isBefore(DateTime(now.year, now.month, now.day, 10, 00)))
    return 2;
  else if(syncTime.isAfter(DateTime(now.year, now.month, now.day, 11, 00)) && syncTime.isBefore(DateTime(now.year, now.month, now.day, 12, 00)))
    return 3;
  else if(syncTime.isAfter(DateTime(now.year, now.month, now.day, 12, 0)) && syncTime.isBefore(DateTime(now.year, now.month, now.day, 13, 0)))
    return 4;
  else if(syncTime.isAfter(DateTime(now.year, now.month, now.day, 13, 0)) && syncTime.isBefore(DateTime(now.year, now.month, now.day, 14, 0)))
    return 5;
  else if(syncTime.isAfter(DateTime(now.year, now.month, now.day, 14, 0)) && syncTime.isBefore(DateTime(now.year, now.month, now.day, 15, 0)))
    return 6;
  else if(syncTime.isAfter(DateTime(now.year, now.month, now.day, 15, 0)) && syncTime.isBefore(DateTime(now.year, now.month, now.day, 16, 0)))
    return 7;
  else if(syncTime.isAfter(DateTime(now.year, now.month, now.day, 16, 0)) && syncTime.isBefore(DateTime(now.year, now.month, now.day, 17, 0)))
    return 8;
  else if(syncTime.isAfter(DateTime(now.year, now.month, now.day, 17, 0)) && syncTime.isBefore(DateTime(now.year, now.month, now.day, 18, 0)))
    return 9;
  else if(syncTime.isAfter(DateTime(now.year, now.month, now.day, 18, 0)) && syncTime.isBefore(DateTime(now.year, now.month, now.day, 19, 0)))
    return 10;
  else if(syncTime.isAfter(DateTime(now.year, now.month, now.day, 19, 0)) && syncTime.isBefore(DateTime(now.year, now.month, now.day, 20, 0)))
    return 11;
  else
    return 12;
}

Future<DateTime> syncTime()async{
  var now = DateTime.now();
  var offset = await NTP.getNtpOffset(localTime: now);
  return now.add(Duration(milliseconds: offset));
}