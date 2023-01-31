import 'package:flutter/material.dart';
import 'package:wastecollector/services/auth/bloc/auth_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_events.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastecollector/services/cloud/firebase_cloud_storage.dart';
import 'package:wastecollector/utilities/errordialog.dart';
import 'package:wastecollector/utilities/logoutdialog.dart';
import 'package:wastecollector/views/notes/querieslistview.dart';
import 'package:wastecollector/views/unscheduled_collection_client.dart';
import '../../services/auth/auth_service.dart';
import 'package:wastecollector/constants/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../enum/menu_actions.dart';
import 'package:wastecollector/views/loginview.dart';
import 'dart:developer' as devtools show log; //only imports log

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
    _notesservice = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {},
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              actions: [
                Column(
                  children: [
                    Visibility(
                        visible: true,
                        child: IconButton(
                          onPressed: () async {
                            int x = await check(email: userid);
                            if (x == 1) {
                              context
                                  .read<AuthBloc>()
                                  .add(const AuthEventClienttoHaulerSwitch());
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
                        final shouldLogOut = await showLogoutDialog(context);
                        if (shouldLogOut) {
                          context.read<AuthBloc>().add(const AuthEventLogOut());
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
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AspectRatio(
                          aspectRatio: 64 / 9,
                          child: Container(
                            color: Colors.green[400],
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(Maproute);
                              },
                              child: const Text(
                                'Select Address on map',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: AspectRatio(
                    aspectRatio: 64 / 9,
                    child: Container(
                      color: Colors.green[400],
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(Addressroute);
                        },
                        child: const Text(
                          'Enter credentials',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: AspectRatio(
                    aspectRatio: 64 / 9,
                    child: Container(
                      color: Colors.green[400],
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(Complainsroute);
                        },
                        child: const Text(
                          'Complaints and Queries',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AspectRatio(
                          aspectRatio: 64 / 9,
                          child: Container(
                            color: Colors.green[400],
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(scheduleroute);
                              },
                              child: const Text(
                                'Schedule',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AspectRatio(
                          aspectRatio: 64 / 9,
                          child: Container(
                            color: Colors.green[400],
                            child: TextButton(
                              onPressed: () async {
                                CollectionReference unscheduled_collection =
                                    FirebaseFirestore.instance
                                        .collection('unscheduled_collection');
                                DocumentSnapshot data =
                                    await unscheduled_collection
                                        .doc(emailid)
                                        .get();
                                snapshotmaker(data);
                                Navigator.of(context)
                                    .pushNamed(unscheduledclientroute);
                              },
                              child: const Text(
                                'Unscheduled Collection',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )));
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





