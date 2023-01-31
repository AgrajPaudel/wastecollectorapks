import 'package:flutter/material.dart';
import 'package:wastecollector/services/cloud/cloud_note.dart';
import 'package:wastecollector/utilities/errordialog.dart';
import 'package:wastecollector/utilities/get_arguments.dart';
import 'package:wastecollector/services/auth/auth_service.dart';
import 'package:wastecollector/utilities/genericdialog.dart';
import 'package:wastecollector/services/cloud/firebase_cloud_storage.dart';
import 'package:wastecollector/utilities/cannt_share_empty_note_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  Cloudnote? _note;
  late final FirebaseCloudStorage _notesservice;
  late final TextEditingController _textcontroller;
  String get emailid => AuthService.firebase().currentUser!.email;

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
        title: const Text('New Complaints'),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textcontroller.text;
              if (_note == null || text.isEmpty) {
                await CantShareEMptyNoteDialog(context);
              } else {
                String address_to_be_taken, ward;
                var data;
                CollectionReference complains =
                    FirebaseFirestore.instance.collection('Complaints');
                String a = await docidfinder(email_id: emailid);
                CollectionReference address =
                    FirebaseFirestore.instance.collection('addresses');
                QuerySnapshot querysnapshot = await address.get();
                DateTime now = DateTime.now();
                DateTime date = DateTime(now.year, now.month, now.day);
                for (int i = 0; i < querysnapshot.docs.length; i++) {
                  data = querysnapshot.docs[i].data();
                  if (data['email'].toString() == emailid) {
                    print(a);
                    if (data['address'] != null &&
                        data['ward number'] != null) {
                      address_to_be_taken = data['address'].toString();
                      ward = data['ward number'].toString();
                      print(ward);
                      print(address_to_be_taken);
                      complains.doc(a).update({
                        'email': emailid,
                        'address': address_to_be_taken,
                        'complain': text,
                        'ward': ward,
                        'date': date.toString(),
                      });
                      return Showgenericdialog<void>(
                        context: context,
                        title: 'Complaint Update',
                        content: 'Complaint successfully sent.',
                        optionBuilder: () => {
                          'Cancel': false,
                        },
                      );
                    } else {
                      ShowErrorDialog(
                          context, 'Please pick your address first');
                    }
                  }
                }
              }
            },
            icon: const Text('Send'),
          ) //share button
        ],
      ),
      body: FutureBuilder(
        future: CreateNewNotesorGetExistingNotes(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              setuptextcontrollinglistener(); //autosaves
              return Column(
                children: [
                  TextButton(
                      onPressed: () async {
                        CollectionReference address =
                            FirebaseFirestore.instance.collection('addresses');
                        QuerySnapshot querysnapshot = await address.get();
                        var data;
                        String address_to_be_taken, ward;
                        for (int i = 0; i < querysnapshot.docs.length; i++) {
                          data = querysnapshot.docs[i].data();
                          String a = await docid_finder(email_id: emailid);
                          print(emailid);
                          if (data['email'].toString() == emailid) {
                            if (data['address'] != null &&
                                data['ward number'] != null) {
                              if (data['state'] != 'uncollected') {
                                address.doc(a).update({
                                  'state': 'uncollected',
                                });
                                return Showgenericdialog<void>(
                                  context: context,
                                  title: 'Complaint Update',
                                  content: 'State updated.',
                                  optionBuilder: () => {
                                    'OK': false,
                                  },
                                );
                              } else {
                                address.doc(a).update({
                                  'state': null,
                                });
                                return Showgenericdialog<void>(
                                  context: context,
                                  title: 'Complaint Update',
                                  content: 'State turned back to null.',
                                  optionBuilder: () => {
                                    'OK': false,
                                  },
                                );
                              }
                            } else if (data['state'] == 'uncollected') {
                              ShowErrorDialog(
                                  context, 'Please pick your address first');
                            }
                          }
                        }
                      },
                      child: const Text(
                          'Press here to set your collection state to uncollected or undo it.')),
                  TextField(
                    controller: _textcontroller,
                    keyboardType: TextInputType.multiline,
                    maxLines: null, //so that note is not single line
                    decoration:
                        const InputDecoration(hintText: 'Enter queries here.'),
                  ),
                ],
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

Future<String> docidfinder({required String email_id}) async {
  String docid = 'a';
  var data;
  CollectionReference address_list =
      FirebaseFirestore.instance.collection('Complaints');
  QuerySnapshot querySnapshot = await address_list.get();
  final l = querySnapshot.docs.length;
  for (int i = 0; i < l; i++) {
    data = querySnapshot.docs[i].data();
    if (data['email'].toString() == email_id.toString()) {
      docid = querySnapshot.docs[i].id;
    }
  }
  return docid;
}

Future<String> docid_finder({required String email_id}) async {
  String docid = 'a';
  var data;
  CollectionReference address_list =
      FirebaseFirestore.instance.collection('addresses');
  QuerySnapshot querySnapshot = await address_list.get();
  final l = querySnapshot.docs.length;
  for (int i = 0; i < l; i++) {
    data = querySnapshot.docs[i].data();
    if (data['email'].toString() == email_id.toString()) {
      docid = querySnapshot.docs[i].id;
    }
  }
  return docid;
}
//note is not updated from view, new note view is created but with old value ontap, this is due to context parameter and then it is edited.