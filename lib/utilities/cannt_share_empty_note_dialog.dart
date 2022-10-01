import 'package:flutter/cupertino.dart';
import 'package:wastecollector/utilities/genericdialog.dart';

Future<void> CantShareEMptyNoteDialog(BuildContext context) {
  return Showgenericdialog(
      context: context,
      title: 'Sharing Notes',
      content: 'You cannot share empty notes.',
      optionBuilder: () => {
            'OK': null,
          });
}
