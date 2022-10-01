//this is to display a dialog when logging in, prompted to show user that the app is running.
import 'package:flutter/material.dart';

typedef CloseDialog = void Function();

CloseDialog showLoadingDialog({
  required BuildContext context,
  required String text,
}) {
  final dialog = AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 10),
        Text(text),
      ],
    ),
  );
  showDialog(
      context: context,
      barrierDismissible:
          false, //taps outside dismissible or not(in case of here, not)
      builder: (context) => dialog);

  return () => Navigator.of(context).pop();
}
