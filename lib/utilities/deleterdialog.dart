import 'package:flutter/cupertino.dart';
import 'package:wastecollector/utilities/genericdialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return Showgenericdialog<bool>(
    context: context,
    title: 'Delete Note',
    content: 'Are YOu Sure you want to delete this note?',
    optionBuilder: () => {
      'Cancel': false,
      'Delete': true,
    },
  ).then((value) => value ?? false);
}
