import 'table.dart';
import 'package:intl/intl.dart';
import 'dart:io';

DateFormat DMY = DateFormat('dd/MM/yyyy');

void main() {
  DateTime today = DateTime.now();

  if (isSunday(today)) {
    stdout.writeln('No buses on Sundays');
    exit(0);
  }

  if (isPublicHoliday(publicHolidays, today)) {
    exit(0);
  }

  DateTime? nextBusTime = gettNextBus(today, isSchoolHoliday(schoolHolidays, today));

  if (nextBusTime == null) {
    stdout.writeln('No next bus time found! Buses may have ended for the day.');
  } else {
    stdout.writeln("Next bus: ${nextBusTime.hour}:${nextBusTime.minute}");
  }
}

DateTime? gettNextBus(DateTime today, bool isSchoolHoliday) {
  if (today.day == DateTime.saturday)
    return parseBusStopTimes(today, 'Wknd');
  else if (isSchoolHoliday)
    return parseBusStopTimes(today, 'NSch');
  else if (!isSchoolHoliday) {
    return parseBusStopTimes(today, 'Sch');
  }
}

DateTime? parseBusStopTimes(DateTime now, String mode) {
  for (int time in stops[mode]!) {
    DateTime stopAsDateTime = DateTime(now.year, now.month, now.day, time ~/ 100, time % 100);
    if (stopAsDateTime.compareTo(now) > 0) return stopAsDateTime;
  }
  return null;
}

bool isPublicHoliday(List<Holiday> holidays, DateTime today) {
  Holiday day = holidays.firstWhere(
      (holiday) =>
          today.day == DMY.parse(holiday['date']!).day &&
          today.month == DMY.parse(holiday['date']!).month,
      orElse: () => {});

  if (day.isNotEmpty) {
    stdout.writeln("No buses: ${day['name']!}.");
    return true;
  }
  return false;
}

bool isSchoolHoliday(List<Holiday> holidays, DateTime today) {
  Holiday day = holidays.firstWhere(
      (holiday) =>
          today.isAfter(DMY.parse(holiday['start']!)) && today.isBefore(DMY.parse(holiday['end']!)),
      orElse: () => {});
  if (day.isNotEmpty) {
    stdout.writeln("School holiday season: ${day['name']!}, ends ${day['end']}.");
    return true;
  }
  return false;
}

bool isSunday(DateTime today) {
  return today.weekday == DateTime.sunday;
}

DateTime parseTimeString(DateTime today, String timeString) {
  int hours = int.parse(timeString.substring(0, 2));
  int minutes = int.parse(timeString.substring(2, 4));
  return DateTime(0, 1, 1, hours, minutes); // Date doesn't matter, so use arbitrary values
}
