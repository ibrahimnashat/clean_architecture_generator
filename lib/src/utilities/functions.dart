import 'dart:developer';

import 'package:dart_style/dart_style.dart';

extension StringExtension on String {
  String formatDartCode() {
    final formatter = DartFormatter();
    return formatter.format(this);
  }
}

void dPrint(dynamic message, {int level = 1, String? tag}) {
  var a = StackTrace.current;
  final regexCodeLine = RegExp(r" (\(.*\))$");
  var i = regexCodeLine
      .stringMatch(a.toString().split("\n")[level])
      .toString()
      .replaceAll("(", "")
      .replaceAll(")", "")
      .trim() /*.split("/")*/;
  var tPrent = "$i\n${tag != null ? "$tag: " : ""}$message";
  if (message.length > 1000) {
    log(tPrent);
  } else {
    print(tPrent);
  }
}
