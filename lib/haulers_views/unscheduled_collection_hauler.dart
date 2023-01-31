import 'dart:convert';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mapbox_gl/mapbox_gl.dart' show LatLng;
import 'package:wastecollector/constants/routes.dart';
import 'package:wastecollector/haulers_views/compensatory_collection.dart';
import 'package:wastecollector/services/auth/bloc/auth_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_events.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';

LatLng lat_lng = LatLng(27.7172, 85.3240);
String address = '';
List<String> docid = [], state = [];
List<LatLng> values = [];
QuerySnapshot? mapper;
void travelholder(String place, LatLng latLng,
    {required QuerySnapshot querySnapshot}) {
  mapper = querySnapshot;
  docid = [];
  values = [];
  state = [];
  address = place;
}

class Haulers_unScheduledCollection extends StatefulWidget {
  const Haulers_unScheduledCollection({Key? key}) : super(key: key);

  @override
  State<Haulers_unScheduledCollection> createState() =>
      Haulers_unScheduledCollectionviewState();
}

class Haulers_unScheduledCollectionviewState
    extends State<Haulers_unScheduledCollection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Unscheduled Collection'),
          actions: [
            IconButton(
                onPressed: () async {
                  context.read<AuthBloc>().add(const AuthEventHaulerBack());
                },
                icon: const Icon(Icons.home)),
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
                          onPressed: () async {
                            context.read<AuthBloc>().add(
                                const AuthEventUnscheduledCollectionList());
                          },
                          child: const Text(
                            'Client Requests',
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
                            CollectionReference aa = FirebaseFirestore.instance
                                .collection('addresses');
                            QuerySnapshot querySnapshot = await aa.get();
                            holder(
                                place: 'compensatory',
                                querySnapshot: querySnapshot);
                            context.read<AuthBloc>().add(
                                const AuthEventInsideCompensatoryCollection());
                          },
                          child: const Text(
                            'Compensatory Collection',
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
        ),
      ),
    );
  }
}
