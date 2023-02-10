import 'package:flutter/material.dart';
import 'package:wastecollector/main.dart';
import 'package:wastecollector/services/cloud/firebase_cloud_storage.dart';
import 'package:wastecollector/utilities/errordialog.dart';
import 'package:wastecollector/utilities/genericdialog.dart';
import '../../services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String get userid => AuthService.firebase().currentUser!.id;
String get emailidd => AuthService.firebase().currentUser!.email;

QuerySnapshot? querySnapshot;
String? docid, number, name;
var data;
queryfinderclient(QuerySnapshot q) {
  querySnapshot = q;
  print(q.docs.length.toString());
  for (int i = 0; i < querySnapshot!.docs.length; i++) {
    data = querySnapshot!.docs[i].data();
    print(emailidd);
    print(data['email']);
    if (emailidd == data['email']) {
      docid = querySnapshot!.docs[i].id;
      number = data['number'];
      name = data['name'];
    }
  }
}

class Profile_update_client extends StatefulWidget {
  const Profile_update_client({Key? key}) : super(key: key);

  @override
  State<Profile_update_client> createState() => Profile_update_clientview();
}

class Profile_update_clientview extends State<Profile_update_client> {
  TextEditingController? _name;
  bool updater = false;
  CollectionReference update = FirebaseFirestore.instance.collection('numbers');
  @override
  void initState() {
    _name = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                enabled: false,
                enableSuggestions: false,
                autocorrect: false,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Number ' + number!,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _name,
                enabled: true,
                enableSuggestions: false,
                autocorrect: false,
                obscureText: false,
                decoration: InputDecoration(
                  hintText: 'Name: ' + name!,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: () async {
                if (_name?.text != null && _name?.text != '') {
                  update.doc(docid).update({'name': _name?.text});
                  Showgenericdialog(
                      context: context,
                      title: 'Name Updated',
                      content: 'Your Name has been successfully updated.',
                      optionBuilder: () => {
                            'OK': null,
                          });
                } else {
                  Showgenericdialog(
                      context: context,
                      title: 'Empty name',
                      content: 'Your Name cannot be updated as it is empty.',
                      optionBuilder: () => {
                            'OK': null,
                          });
                }
              },
              child: const Text('Update Name'),
            ),
          ],
        ),
      )),
    );
  }
}
