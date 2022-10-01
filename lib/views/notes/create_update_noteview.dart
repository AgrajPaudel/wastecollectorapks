import 'package:flutter/material.dart';
import 'package:wastecollector/services/cloud/cloud_note.dart';
import 'package:wastecollector/utilities/get_arguments.dart';
import 'package:wastecollector/services/auth/auth_service.dart';
import 'package:wastecollector/services/cloud/cloud_storage_exceptions.dart';
import 'package:wastecollector/services/cloud/firebase_cloud_storage.dart';
import 'package:wastecollector/utilities/cannt_share_empty_note_dialog.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  Cloudnote? _note;
  late final FirebaseCloudStorage _notesservice;
  late final TextEditingController _textcontroller;

  //init state
  @override
  void initState() {
    _notesservice = FirebaseCloudStorage();
    _textcontroller = TextEditingController();
    super.initState();
  }

//this is to update notes as per typing instead of once user has finished writing.
  void Textcontrollinglistener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textcontroller.text;

    await _notesservice.updateNotes(
      documentid: note.documentid,
      text: text,
    );
  }

  void setuptextcontrollinglistener() {
    _textcontroller.removeListener(Textcontrollinglistener);
    _textcontroller.addListener(Textcontrollinglistener);
  }

  Future<Cloudnote> CreateNewNotesorGetExistingNotes(
      BuildContext context) async {
    //future always async
    //to create new note if there is no note.
    final widgetnotes = context.getArgument<Cloudnote>();

    if (widgetnotes != null) {
      _note = widgetnotes;
      _textcontroller.text = widgetnotes.text; //to populate the textfield.
    }

    final existingnote = _note;
    if (existingnote != null) {
      return existingnote;
    }
    final currentuser = AuthService.firebase().currentUser!;
    final userid = currentuser.id;
    print('creating new note');
    final Newnote = await _notesservice.createNewNotes(owneruserid: userid);
    _note = Newnote;
    return Newnote;
  }

  //this is so that empty notes do not get saved, eg: if u press back from new notes tab.
  void _deleteNoteifEmpty() {
    final note = _note;
    if (_textcontroller.text.isEmpty && note != null) {
      _notesservice.deleteNotes(documentid: note.documentid);
    }
  }

  //this is to save notes automatically.

  void Savenotesifnonempty() async {
    final note = _note;
    final text = _textcontroller.text;
    if (note != null && text.isNotEmpty) {
      await _notesservice.updateNotes(
        documentid: note.documentid,
        text: text,
      );
    }
  }

  //this is to kill new view after pressing bacc
  @override
  void dispose() {
    _deleteNoteifEmpty();
    Savenotesifnonempty();
    _textcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Notes'),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textcontroller.text;
              if (_note == null || text.isEmpty) {
                await CantShareEMptyNoteDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          ) //share button
        ],
      ),
      body: FutureBuilder(
        future: CreateNewNotesorGetExistingNotes(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              setuptextcontrollinglistener(); //autosaves
              return TextField(
                controller: _textcontroller,
                keyboardType: TextInputType.multiline,
                maxLines: null, //so that note is not single line
                decoration: const InputDecoration(hintText: 'Enter note here.'),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
//note is not updated from view, new note view is created but with old value ontap, this is due to context parameter and then it is edited.