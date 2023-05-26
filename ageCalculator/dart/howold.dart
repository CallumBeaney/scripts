import 'dart:io';
import 'package:intl/intl.dart'; // DateFormat objects
import 'package:number_to_words_chinese/number_to_words_chinese.dart';

// This version outputs in Chinese numbers because I can do that if I want

void main(List<String> args) {
  if (args.length != 1) {
    print("ARGUMENT ERROR.\nUSAGE: dart run howold 01/01/1999\n");
    exit(1);
  }

  DateFormat DMY = DateFormat('dd/MM/yyyy'); // can replace / with - etc
  DateTime? inputRaw; // this holds data about an instant in time

  try {
    inputRaw = DMY.parseLoose(args[0]);
  } catch (FormatException) {
    print("FORMAT ERROR.\nUSAGE: dart run howold 01/01/1999\n");
    exit(2);
  }

  DateTime todayRaw = DateTime.now();
  Duration difference = todayRaw.difference(inputRaw);

  String years = NumberToWordsChinese.convert(difference.inDays ~/ 365); // crude but sufficient
  String months = NumberToWordsChinese.convert((difference.inDays % 365) ~/ 30); // likewise

  print("\n　${years}　歲、${months}　個月。\n");
}
