import 'package:flutter/material.dart';
import 'package:wastecollector/utilities/genericdialog.dart';
//just to show error

Future<void> ShowErrorDialog(
  BuildContext context,
  String text,
) {
  return Showgenericdialog(
    context: context,
    title: 'An Error Occurred',
    content: text,
    optionBuilder: () => {
      'OK': null,
    },
  );
}
