import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:wastecollector/services/cloud/cloud_storage_constants.dart';

@immutable
class Cloudnote {
  final String documentid;
  final String owneruserid;
  final String text;
  const Cloudnote({
    //initialization of final variables.
    required this.documentid,
    required this.owneruserid,
    required this.text,
  });

  Cloudnote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentid = snapshot.id,
        owneruserid = snapshot.data()[owneruseridfieldname],
        text = snapshot.data()[textfieldName] as String;
}
