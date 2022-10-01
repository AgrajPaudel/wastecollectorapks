import 'package:flutter/cupertino.dart';
import 'package:wastecollector/utilities/genericdialog.dart';

Future<void> ShowPasswordResetDialog(BuildContext context) {
  return Showgenericdialog<void>(
      context: context,
      title: 'Password Reset',
      content: 'Email has been sent to reset password, please check your mail.',
      optionBuilder: () => {
            'Ok': null,
          });
}
