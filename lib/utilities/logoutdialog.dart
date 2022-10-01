import 'package:flutter/cupertino.dart';
import 'package:wastecollector/utilities/genericdialog.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return Showgenericdialog<bool>(
    context: context,
    title: 'Log Out',
    content: 'Are You Sure you want to log out?',
    optionBuilder: () => {
      'Cancel': false,
      'Log Out': true,
    },
  ).then((value) => value ?? false);
}
