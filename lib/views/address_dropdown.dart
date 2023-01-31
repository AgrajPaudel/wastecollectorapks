import 'package:flutter/material.dart';
import 'package:wastecollector/main.dart';
import 'package:wastecollector/services/cloud/firebase_cloud_storage.dart';
import 'package:wastecollector/utilities/errordialog.dart';
import 'package:wastecollector/utilities/genericdialog.dart';
import '../../services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Addressui extends StatefulWidget {
  const Addressui({Key? key}) : super(key: key);

  @override
  State<Addressui> createState() => _AddressuiState();
}

class _AddressuiState extends State<Addressui> {
  var value_chosen = null, wards_chosen = null;
  List addresses = [
    'Kathmandu',
    'Lalitpur',
    'Bhaktapur',
    'Tokha',
    'Budhanilkantha',
    'Tarakeshwar',
    'Gokarneshwar',
    'Suryabinayak',
    'Chandragiri',
    'Kageshwari-Manohara',
    'Thimi',
    'Mahalaxmi',
    'Nagarjun',
    'Kirtipur',
    'Godawari',
    'Changunarayan'
  ];
  List wards = ['0'];
  String get userid => AuthService.firebase().currentUser!.id;
  String get emailid => AuthService.firebase().currentUser!.email;
  late final FirebaseCloudStorage _notesservice;

  @override
  void initState() {
    _notesservice = FirebaseCloudStorage();
    super.initState();
  }

  wardmapper({required String city}) {
    switch (city) {
      case 'Kathmandu':
        {
          wards = [
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '10',
            '11',
            '12',
            '13',
            '14',
            '15',
            '16',
            '17',
            '18',
            '19',
            '20',
            '21',
            '22',
            '23',
            '24',
            '25',
            '26',
            '27',
            '28',
            '29',
            '30',
            '31',
            '32'
          ];
          break;
        }
      case 'Lalitpur':
        {
          wards = [
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '10',
            '11',
            '12',
            '13',
            '14',
            '15',
            '16',
            '17',
            '18',
            '19',
            '20',
            '21',
            '22',
            '23',
            '24',
            '25',
            '26',
            '27',
            '28',
            '29',
          ];
          break;
        }
      case 'Tokha':
        {
          wards = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11'];
          break;
        }
      case 'Budhanilkantha':
        {
          wards = [
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '10',
            '11',
            '12',
            '13'
          ];
          break;
        }
      case 'Tarakeshwar':
        {
          wards = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11'];
          break;
        }
      case 'Gokarneshwar':
        {
          wards = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
          break;
        }
      case 'Suryabinayak':
        {
          wards = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
          break;
        }
      case 'Chandragiri':
        {
          wards = [
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '10',
            '11',
            '12',
            '13',
            '14',
            '15'
          ];
          break;
        }
      case 'Kageshwari-Manohara':
        {
          wards = [
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '10',
            '11',
            '12'
          ];
          break;
        }
      case 'Thimi':
        {
          wards = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
          break;
        }
      case 'Mahalaxmi':
        {
          wards = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
          break;
        }
      case 'Nagarjun':
        {
          wards = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
          break;
        }
      case 'Kirtipur':
        {
          wards = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
          break;
        }
      case 'Godawari':
        {
          wards = [
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '10',
            '11',
            '12',
            '13',
            '14'
          ];
          break;
        }
      case 'Changunarayan':
        {
          wards = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
          break;
        }
      case 'Bhaktapur':
        {
          wards = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
          break;
        }
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          DropdownButton(
            hint: const Text('Choose city'),
            items: addresses.map((address) {
              return DropdownMenuItem(
                value: address,
                child: Text(address),
              );
            }).toList(), //to list to convert iterable to list
            value: value_chosen,
            onChanged: (new_value) async {
              await wardmapper(
                  city: new_value
                      .toString()); //async/await required else error due to multiple length of list items
              setState(() {
                value_chosen = new_value;
              });
            },
          ),
          DropdownButton(
            hint: const Text('Choose ward number'),
            items: wards.map((wards) {
              return DropdownMenuItem(
                value: wards,
                child: Text(wards),
              );
            }).toList(), //to list to convert iterable to list
            value: wards_chosen,
            onChanged: (new_value) {
              setState(() {
                wards_chosen = new_value;
              });
            },
          ),
          TextButton(
            onPressed: () async {
              String a;
              if (value_chosen != null &&
                  (wards_chosen != null && wards_chosen != '0')) {
                CollectionReference address_add =
                    FirebaseFirestore.instance.collection('addresses');
                CollectionReference unscheduled = FirebaseFirestore.instance
                    .collection('unscheduled_collection');
                DocumentSnapshot data2;
                data2 = await unscheduled.doc(emailid).get();
                a = await docidfinder(email_id: emailid);
                var data;
                data = await snapshotfinder(email_id: emailid);
                print(data['state'].toString());
                print(data2['unscheduled_request']);
                if (!data['state'].toString().endsWith('@email.com') &&
                    !data2['unscheduled_request']
                        .toString()
                        .endsWith('@gmail.com')) {
                  address_add.doc(a).update({
                    'email': AuthService.firebase().currentUser!.email,
                    'address': value_chosen,
                    'ward number': wards_chosen,
                  });
                  NotificationApi.resetter();
                  return Showgenericdialog<void>(
                    context: context,
                    title: 'Address Update',
                    content: 'Address successfully updated.',
                    optionBuilder: () => {
                      'OK': false,
                    },
                  );
                } else {
                  return Showgenericdialog<void>(
                    context: context,
                    title: 'Address Update',
                    content: 'Cannot update address mid collection.',
                    optionBuilder: () => {
                      'OK': false,
                    },
                  );
                }
              } else {
                ShowErrorDialog(
                    context, 'Please choose correct data in all the fields.');
              }
            },
            child: const Text('Save'),
          ),
        ]),
      ),
    );
  }
}

Future<String> docidfinder({required String email_id}) async {
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

Future<DocumentSnapshot?> snapshotfinder({required String email_id}) async {
  CollectionReference address_list =
      FirebaseFirestore.instance.collection('addresses');
  String a = await docidfinder(email_id: email_id);
  DocumentSnapshot? docid = await address_list.doc(a).get();
  return docid;
}




//  'Kathmandu',    32
//     'Lalitpur',  29
//     'Bhaktapur', 10
//     'Tokha',      11
//     'Budhanilkantha',    13
//     'Tarakeshwar',   11
//     'Gokarneshwar',  9
//     'Suryabinayak',    10
//     'Chandagiri',    15
//     'Kageshwari-Manohara',   12
//     'Thimi',   9
//     'Mahalaxmi',   10
//     'Nagarjun',    10
//     'Kirtipur',  10
//     'Godawari',  14
//     'Changunarayan'  9