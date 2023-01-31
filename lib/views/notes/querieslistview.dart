import 'package:flutter/material.dart';
import 'package:wastecollector/services/cloud/cloud_note.dart';
import 'package:wastecollector/utilities/deleterdialog.dart';

typedef Notecallback = void Function(Cloudnote note);

class Noteslistview extends StatelessWidget {
  final Iterable<Cloudnote> notes;
  final Notecallback ondeletenote; //this is for delete button.
  final Notecallback ontap; //this is for editing note.

  const Noteslistview({
    Key? key,
    required this.notes,
    required this.ondeletenote,
    required this.ontap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index); //for iterables [] not ok
        return ListTile(
          onTap: () {
            ontap(note);
          },
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ), //! null check
          trailing: IconButton(
            onPressed: () async {
              //for delete button
              final shoulddelete = await showDeleteDialog(context);
              if (shoulddelete) {
                ondeletenote(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
