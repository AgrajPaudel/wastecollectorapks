import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wastecollector/services/auth/bloc/auth_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_events.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastecollector/services/cloud/firebase_cloud_storage.dart';
import 'package:wastecollector/utilities/errordialog.dart';
import 'package:wastecollector/utilities/genericdialog.dart';
import 'package:wastecollector/utilities/logoutdialog.dart';
import 'package:wastecollector/views/notes/create_update_complainsview.dart';
import 'package:wastecollector/views/notes/querieslistview.dart';
import 'package:wastecollector/views/unscheduled_collection_client.dart';
import 'package:wastecollector/views/update_profile_client.dart';
import '../../services/auth/auth_service.dart';
import 'package:wastecollector/constants/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../enum/menu_actions.dart';
import 'package:wastecollector/views/loginview.dart';
import 'dart:developer' as devtools show log; //only imports log

bool existence_in_hauler_db = true;

class Appui extends StatefulWidget {
  const Appui({Key? key}) : super(key: key);

  @override
  State<Appui> createState() => _AppuiState();
}

String get userid => AuthService.firebase().currentUser!.email;

class _AppuiState extends State<Appui> {
  late final FirebaseCloudStorage _notesservice;

  @override
  void initState() {
    checker();
    _notesservice = FirebaseCloudStorage();
    super.initState();
    print(existence_in_hauler_db);
  }

  Future<void> checker() async {
    int x = await check(email: userid);
    if (x == 1) {
      existence_in_hauler_db = true;
    } else {
      print('not here');
      existence_in_hauler_db = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: checker(),
        builder: (context, snapshot) {
          return BlocListener<AuthBloc, AuthState>(
              listener: (context, state) async {},
              child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Client Dashboard'),
                    actions: [
                      Column(
                        children: [
                          Visibility(
                              visible: true,
                              child: IconButton(
                                onPressed: () async {
                                  int x = await check(email: userid);
                                  if (x == 1) {
                                    context.read<AuthBloc>().add(
                                        const AuthEventClienttoHaulerSwitch());
                                  } else if (x == -1) {
                                    ShowErrorDialog(context,
                                        'Only haulers are allowed to switch between views');
                                  }
                                },
                                icon: const Icon(Icons.swap_horiz_sharp),
                              ))
                        ],
                      ),
                      PopupMenuButton<Menu>(
                        onSelected: (value) async {
                          switch (value) {
                            case Menu.logout:
                              final shouldLogOut =
                                  await showLogoutDialog(context);
                              if (shouldLogOut) {
                                context
                                    .read<AuthBloc>()
                                    .add(const AuthEventLogOut());
                              }
                              devtools.log(shouldLogOut.toString());
                              break;
                          }
                        },
                        itemBuilder: (context) {
                          return const [
                            const PopupMenuItem<Menu>(
                              value: Menu.logout,
                              child: Text('Logout'),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        existence_in_hauler_db
                            ? Container(
                                height: 1,
                                width: 1,
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AspectRatio(
                                  aspectRatio: 64 / 9,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shadowColor: Colors.black,
                                        foregroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                      ),
                                      onPressed: () async {
                                        CollectionReference update =
                                            FirebaseFirestore.instance
                                                .collection('numbers');
                                        QuerySnapshot querySnapshot =
                                            await update.get();
                                        queryfinderclient(querySnapshot);
                                        Navigator.of(context).pushNamed(
                                            clientprofileupdateroute);
                                      },
                                      child: const Text(
                                        'Update User Profile',
                                        style: TextStyle(color: Colors.white),
                                      )),
                                ),
                              ),
                        //
                        //
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 64 / 9,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shadowColor: Colors.black,
                                    foregroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushNamed(scheduleroute);
                                  },
                                  child: const Text(
                                    'Schedule',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AspectRatio(
                            aspectRatio: 64 / 9,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.black,
                                  foregroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                onPressed: () async {
                                  CollectionReference address =
                                      FirebaseFirestore.instance
                                          .collection('addresses');
                                  QuerySnapshot querysnapshot =
                                      await address.get();
                                  var data;
                                  String address_to_be_taken, ward;
                                  for (int i = 0;
                                      i < querysnapshot.docs.length;
                                      i++) {
                                    data = querysnapshot.docs[i].data();
                                    String a =
                                        await docid_finder(email_id: emailid);
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
                                            content:
                                                'State turned back to null.',
                                            optionBuilder: () => {
                                              'OK': false,
                                            },
                                          );
                                        }
                                      } else if (data['state'] ==
                                          'uncollected') {
                                        ShowErrorDialog(context,
                                            'Please pick your address first');
                                      }
                                    }
                                  }
                                },
                                child: const Text(
                                  'Waste Collection Status',
                                  style: TextStyle(color: Colors.white),
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 1000,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GridView(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 0,
                                      crossAxisSpacing: 0),
                              children: [
                                TextButton(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),

                                          blurRadius: 7,
                                          offset: Offset(4,
                                              8), // changes position of shadow
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "assets/addressonmap.jpg"),
                                        fit: BoxFit.fill,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(Maproute);
                                  },
                                ),
                                TextButton(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),

                                          blurRadius: 7,
                                          offset: Offset(4,
                                              8), // changes position of shadow
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image: AssetImage("assets/login.jpg"),
                                        fit: BoxFit.fill,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushNamed(Addressroute);
                                  },
                                ),
                                TextButton(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),

                                          blurRadius: 7,
                                          offset: Offset(4,
                                              8), // changes position of shadow
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image:
                                            AssetImage("assets/complaints.png"),
                                        fit: BoxFit.fill,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushNamed(Complainsroute);
                                  },
                                ),
                                TextButton(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),

                                          blurRadius: 7,
                                          offset: Offset(4,
                                              8), // changes position of shadow
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "assets/unscheduled.jpg"),
                                        fit: BoxFit.fill,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    CollectionReference unscheduled_collection =
                                        FirebaseFirestore.instance.collection(
                                            'unscheduled_collection');
                                    DocumentSnapshot data =
                                        await unscheduled_collection
                                            .doc(emailid)
                                            .get();
                                    snapshotmaker(data);
                                    Navigator.of(context)
                                        .pushNamed(unscheduledclientroute);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )));
        });
  }
}

Future<int> check({required String email}) async {
  CollectionReference list =
      FirebaseFirestore.instance.collection('list_of_employees(with accounts)');
  int count = -1;
  var data;
  QuerySnapshot querySnapshot = await list.get();
  final l = querySnapshot.docs.length;
  for (int i = 0; i < l; i++) {
    data = querySnapshot.docs[i].data();
    print(data['email'].toString());

    if (data['email'].toString() == email.toString()) {
      print('${email} exists');
      count = 1;
    } else {
      print('${email} doesnt exist');
    }
  }
  return count;
}
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.of(context).pushNamed(
//                   Maproute); //not removeduntil as back button is needed
//             },
//             icon: const Icon(Icons.map),
//           ),
//           IconButton(
//             onPressed: () {
//               Navigator.of(context).pushNamed(
//                   Createorupdateroute); //not removeduntil as back button is needed
//             },
//             icon: const Icon(Icons.add),
//           ),
//           IconButton(
//             onPressed: () {
//               Navigator.of(context).pushNamed(
//                   Addressroute); //not removeduntil as back button is needed
//             },
//             icon: const Text('Address'),
//           ),
//           PopupMenuButton<Menu>(
//             onSelected: (value) async {
//               switch (value) {
//                 case Menu.logout:
//                   final shouldLogOut = await showLogoutDialog(context);
//                   if (shouldLogOut) {
//                     context.read<AuthBloc>().add(const AuthEventLogOut());
//                   }
//                   devtools.log(shouldLogOut.toString());
//                   break;
//               }
//             },
//             itemBuilder: (context) {
//               return const [
//                 const PopupMenuItem<Menu>(
//                   value: Menu.logout,
//                   child: Text('Logout'),
//                 ),
//               ];
//             },
//           )
//         ],
//       ),
//       body: StreamBuilder(
//         stream: _notesservice.allNotes(
//             owneruserid:
//                 userid), //dont use ._  //from here aallnotes is called for calling tolist()
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.waiting:
//             case ConnectionState.active:
//               if (snapshot.hasData) {
//                 final allnote = snapshot.data as Iterable<
//                     Cloudnote>; //iterable returned not list from allNotes.
//                 print(allnote);
//                 return Noteslistview(
//                   notes: allnote,
//                   ondeletenote: (nnnote) async {
//                     await _notesservice.deleteNotes(
//                         documentid: nnnote.documentid);
//                   },
//                   ontap: (note) {
//                     Navigator.of(context)
//                         .pushNamed(Createorupdateroute, arguments: note);
//                   },
//                 );
//               } else {
//                 return const CircularProgressIndicator();
//               }
//             default:
//               return const CircularProgressIndicator();
//           }
//         },
//       ),
//     );
//   }
// }





