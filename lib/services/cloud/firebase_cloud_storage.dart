import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastecollector/services/cloud/cloud_note.dart';
import 'package:wastecollector/services/cloud/cloud_storage_constants.dart';
import 'package:wastecollector/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance
      .collection('notes'); //used to specify which database

  Future<void> updateNotes({
    required String documentid,
    required String text,
  }) async {
    try {
      return await notes.doc(documentid).update({textfieldName: text});
    } catch (e) {
      throw Couldnotupdatenotesexception();
    }
  }

  Future<void> deleteNotes({
    required String documentid,
  }) async {
    try {
      return await notes.doc(documentid).delete();
    } catch (e) {
      throw Couldnotdeletenotesexception();
    }
  }

  Stream<Iterable<Cloudnote>> allNotes({required String owneruserid}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => Cloudnote.fromSnapshot(doc))
          .where((note) =>
              note.owneruserid ==
              owneruserid)); //user specific notes, without where all notes for all users.

  Future<Iterable<Cloudnote>> getNotes({required String owneruserid}) async {
    try {
      return await notes
          .where(
            owneruseridfieldname,
            isEqualTo: owneruserid,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) => Cloudnote.fromSnapshot(doc),
            ),
          );
    } catch (e) {
      throw Couldnotgetallnotesexception();
    }
  }

  Future<Cloudnote> createNewNotes({required String owneruserid}) async {
    final document = await notes.add({
      //await becase async
      owneruseridfieldname: owneruserid,
      textfieldName: '',
    });
    final fetchednote = await document.get();
    return Cloudnote(
        documentid: fetchednote.id, owneruserid: owneruserid, text: '');
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedinstances();
  FirebaseCloudStorage._sharedinstances();
  factory FirebaseCloudStorage() => _shared;
}
