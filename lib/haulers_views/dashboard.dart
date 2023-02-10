import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wastecollector/constants/routes.dart';
import 'package:wastecollector/haulers_views/collection_travel.dart';
import 'package:wastecollector/services/auth/auth_exceptions.dart';
import 'package:wastecollector/services/auth/auth_service.dart';
import 'package:wastecollector/utilities/errordialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_bloc.dart';
import 'package:wastecollector/haulers_views/update_profile.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';
import 'package:wastecollector/utilities/logoutdialog.dart';
import 'package:wastecollector/services/auth/bloc/auth_events.dart';
import '../enum/menu_actions.dart';
import 'dart:developer' as devtools show log; //only imports log

String get emailid => AuthService.firebase().currentUser!.email;

class Haulers_Dashboard extends StatefulWidget {
  const Haulers_Dashboard({Key? key}) : super(key: key);

  @override
  _Haulers_Dashoardviewstate createState() => _Haulers_Dashoardviewstate();
}

class _Haulers_Dashoardviewstate extends State<Haulers_Dashboard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {},
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Hauler Dashboard"),
          actions: [
            Column(
              children: [
                Visibility(
                    visible: true,
                    child: IconButton(
                      onPressed: () async {
                        context
                            .read<AuthBloc>()
                            .add(const AuthEventHaulertoClientSwitch());
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AspectRatio(
                        aspectRatio: 64 / 9,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pushNamed(scheduleroute);
                          },
                          child: const Text(
                            'Schedules',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AspectRatio(
                        aspectRatio: 64 / 9,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onPressed: () async {
                            CollectionReference update = FirebaseFirestore
                                .instance
                                .collection('list_of_employees(with accounts)');
                            QuerySnapshot querySnapshot = await update.get();
                            queryfinder(querySnapshot);
                            Navigator.of(context)
                                .pushNamed(haulerprofileupdateroute);
                          },
                          child: const Text(
                            'Profile Update',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 1000,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                                offset:
                                    Offset(4, 8), // changes position of shadow
                              ),
                            ],
                            image: DecorationImage(
                              image: AssetImage("assets/collection.jpg"),
                              fit: BoxFit.fill,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          var data;
                          CollectionReference hauler_state = FirebaseFirestore
                              .instance
                              .collection('list_of_employees(with accounts)');
                          String a = await docidfinder(email_id: emailid);
                          DocumentSnapshot q = await hauler_state.doc(a).get();
                          data = q.data();
                          if (data['state'] == 'hauling') {
                            CollectionReference map_address = FirebaseFirestore
                                .instance
                                .collection('addresses');
                            QuerySnapshot querySnapshot =
                                await map_address.get();
                            travelholder(
                                data['address'], LatLng(27.7172, 85.3240),
                                querySnapshot: querySnapshot);
                            context
                                .read<AuthBloc>()
                                .add(const AuthEventHaulerCollect());
                          } else if (data['state'] == 'unscheduled_hauling') {
                            ShowErrorDialog(context,
                                'Cant go for scheduled collection when you are in private collection');
                          } else if (data['state'] == 'compensatory_haul') {
                            ShowErrorDialog(context,
                                'Cant go for scheduled collection when you are in compensatory collection');
                          } else {
                            context
                                .read<AuthBloc>()
                                .add(const AuthEventScheduledCollection());
                          }
                        },
                      ),
                      TextButton(
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),

                                blurRadius: 7,
                                offset:
                                    Offset(4, 8), // changes position of shadow
                              ),
                            ],
                            image: DecorationImage(
                              image: AssetImage("assets/unscheduled.jpg"),
                              fit: BoxFit.fill,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          var data;
                          CollectionReference hauler_state = FirebaseFirestore
                              .instance
                              .collection('list_of_employees(with accounts)');
                          String a = await docidfinder(email_id: emailid);
                          DocumentSnapshot q = await hauler_state.doc(a).get();
                          data = q.data();
                          if (data['state'] == 'unscheduled_hauling') {
                            CollectionReference address = FirebaseFirestore
                                .instance
                                .collection('unscheduled_collection');
                            QuerySnapshot querySnapshots = await address.get();
                            LatLng? latLng = LatLng(27.7172, 85.3240);
                            unscheduledtavelholder(latLng,
                                doc_id: ' ', querySnapshot: querySnapshots);
                            context
                                .read<AuthBloc>()
                                .add(const AuthEventHaulerCollect());
                          } else if (data['state'] == 'compensatory_haul') {
                            CollectionReference address = FirebaseFirestore
                                .instance
                                .collection('addresses');
                            QuerySnapshot querySnapshots = await address.get();
                            LatLng? latLng = LatLng(27.7172, 85.3240);
                            compensatory_travelholder(latLng,
                                querySnapshot: querySnapshots);
                            context
                                .read<AuthBloc>()
                                .add(const AuthEventHaulerCollect());
                          } else if (data['state'] == 'hauling') {
                            ShowErrorDialog(context,
                                'Cant go for private collection when you are in scheduled collection');
                          } else {
                            context
                                .read<AuthBloc>()
                                .add(const AuthEventUnScheduledCollection());
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String> docidfinder({required String email_id}) async {
  String docid = 'a';
  var data;
  CollectionReference address_list =
      FirebaseFirestore.instance.collection('list_of_employees(with accounts)');
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
