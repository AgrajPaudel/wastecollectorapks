import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wastecollector/services/auth/bloc/auth_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_events.dart';
import 'package:wastecollector/services/cloud/cloud_note.dart';
import 'package:wastecollector/services/cloud/firebase_cloud_storage.dart';
import 'package:wastecollector/utilities/errordialog.dart';
import 'package:wastecollector/utilities/genericdialog.dart';
import 'package:wastecollector/utilities/logoutdialog.dart';
import 'package:wastecollector/views/notes/querieslistview.dart';
import '../../services/auth/auth_service.dart';
import 'package:wastecollector/constants/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../enum/menu_actions.dart';
import 'dart:developer' as devtools show log; //only imports log

class Complainsui extends StatefulWidget {
  const Complainsui({Key? key}) : super(key: key);

  @override
  State<Complainsui> createState() => _ComplainsuiState();
}

class _ComplainsuiState extends State<Complainsui> {
  late final FirebaseCloudStorage _notesservice;
  String get userid => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesservice = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Query Tickets'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                  Createorupdateroute); //not removeduntil as back button is needed
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _notesservice.allNotes(
            owneruserid:
                userid), //dont use ._  //from here aallnotes is called for calling tolist()
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allnote = snapshot.data as Iterable<
                    Cloudnote>; //iterable returned not list from allNotes.
                print(allnote);
                return Noteslistview(
                  notes: allnote,
                  ondeletenote: (nnnote) async {
                    await _notesservice.deleteNotes(
                        documentid: nnnote.documentid);
                  },
                  ontap: (note) {
                    Navigator.of(context)
                        .pushNamed(Createorupdateroute, arguments: note);
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}


// class Appui extends StatefulWidget {
//   const Appui({Key? key}) : super(key: key);

//   @override
//   State<Appui> createState() => _AppuiState();
// }

// class _AppuiState extends State<Appui> {
//   late final FirebaseCloudStorage _notesservice;
//   String get userid => AuthService.firebase().currentUser!.id;

//   @override
//   void initState() {
//     _notesservice = FirebaseCloudStorage();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('My Notes'),
//           actions: [
//             IconButton(
//               onPressed: () {
//                 Navigator.of(context).pushNamed(
//                     Createorupdateroute); //not removeduntil as back button is needed
//               },
//               icon: const Icon(Icons.add),
//             ),
//             PopupMenuButton<Menu>(
//               onSelected: (value) async {
//                 switch (value) {
//                   case Menu.logout:
//                     final shouldLogOut = await showLogoutDialog(context);
//                     if (shouldLogOut) {
//                       await AuthService.firebase().logOut();
//                       Navigator.of(context)
//                           .pushNamedAndRemoveUntil(loginroute, (_) => false);
//                     }
//                     devtools.log(shouldLogOut.toString());
//                     break;
//                 }
//               },
//               itemBuilder: (context) {
//                 return const [
//                   const PopupMenuItem<Menu>(
//                     value: Menu.logout,
//                     child: Text('Logout'),
//                   ),
//                 ];
//               },
//             )
//           ],
//         ),
//         body: StreamBuilder(
//           stream: _notesservice.allNotes(
//               owneruserid:
//                   userid), //dont use ._  //from here aallnotes is called for calling tolist()
//           builder: (context, snapshot) {
//             switch (snapshot.connectionState) {
//               case ConnectionState.waiting:
//               case ConnectionState.active:
//                 if (snapshot.hasData) {
//                   final allnote = snapshot.data as Iterable<
//                       Cloudnote>; //iterable returned not list from allNotes.
//                   print(allnote);
//                   return Noteslistview(
//                     notes: allnote,
//                     ondeletenote: (nnnote) async {
//                       await _notesservice.deleteNotes(
//                           documentid: nnnote.documentid);
//                     },
//                     ontap: (note) {
//                       Navigator.of(context)
//                           .pushNamed(Createorupdateroute, arguments: note);
//                     },
//                   );
//                 } else {
//                   return const CircularProgressIndicator();
//                 }
//               default:
//                 return const CircularProgressIndicator();
//             }
//           },
//         ));
//   }
// }
