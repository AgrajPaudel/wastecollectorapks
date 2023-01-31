import 'dart:convert';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart'
    show PermissionStatus, Location, LocationData;
import 'package:mapbox_gl/mapbox_gl.dart'
    show
        Symbol,
        CameraUpdate,
        LatLng,
        MyLocationTrackingMode,
        MapboxMap,
        MinMaxZoomPreference,
        CameraPosition,
        MapboxMapController,
        SymbolOptions,
        CameraTargetBounds;
import 'package:wastecollector/constants/routes.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:wastecollector/services/auth/bloc/auth_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_events.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';
import 'package:wastecollector/services/cloud/firebase_cloud_storage.dart';
import 'package:wastecollector/utilities/genericdialog.dart';
import '../../services/auth/auth_service.dart';

LatLng lat_lng = LatLng(27.7172, 85.3240);
String address = '';
int? pointer;
String? docc_id;
List<String> docid = [], state = [];
List<LatLng> values = [];
QuerySnapshot? mapper;
void travelholder(String place, latlong.LatLng latLng,
    {required QuerySnapshot querySnapshot}) {
  mapper = querySnapshot;
  docid = [];
  values = [];
  state = [];
  address = place;
  pointer = 0;
}

void compensatory_travelholder(latlong.LatLng latLng,
    {required QuerySnapshot querySnapshot}) {
  mapper = querySnapshot;
  docid = [];
  values = [];
  state = [];
  pointer = 2;
}

void unscheduledtavelholder(latlong.LatLng latLng,
    {required String doc_id, required QuerySnapshot querySnapshot}) {
  pointer = 1;
  docc_id = doc_id;
  docid = [];
  values = [];
  state = [];
  mapper = querySnapshot;
}

class Travel_collection extends StatefulWidget {
  const Travel_collection({Key? key}) : super(key: key);

  @override
  State<Travel_collection>
      createState() => //state is needed to make this a widget
          Travel_collectionviewState();
}

class Travel_collectionviewState extends State<Travel_collection> {
  LatLng start = lat_lng;
  CollectionReference map_address_add =
      FirebaseFirestore.instance.collection('addresses');
  CollectionReference hauler_state =
      FirebaseFirestore.instance.collection('list_of_employees(with accounts)');
  var symbol = null;
  double? lat, long;
  late final FirebaseCloudStorage _notesservice;
  String get userid => AuthService.firebase().currentUser!.id;
  String get emailid => AuthService.firebase().currentUser!.email;
  late CameraPosition _initalcameraposition;
  CameraPosition? _newcameraposition;
  late MapboxMapController controller;
  var initial_symbol;
  List<Symbol> initial_symbols = [];
  List<Uint8List> markerimage = [];
  int j = 0;
  List<LatLng> initials = [];
  List<String> emails = [], docid = [];
  Location _location = Location(); //from location dependency

  void markermaker() async {
    bool? serviceenabled = await _location.serviceEnabled();
    if (!serviceenabled) {
      serviceenabled = await _location.requestService();
    }
    PermissionStatus? _permissiongranted = await _location.hasPermission();
    if (_permissiongranted == PermissionStatus.denied) {
      _permissiongranted = await _location.requestPermission();
    }

    LocationData _locationData = await _location.getLocation();
    LatLng current_value =
        LatLng(_locationData.latitude!, _locationData.longitude!); //not null
    lat_lng = current_value;
    start = current_value;
  }

  @override
  void initState() {
    _notesservice = FirebaseCloudStorage();
    _initalcameraposition = CameraPosition(target: lat_lng, zoom: 15);
    super.initState();
  }

  Future<Uint8List> ChangeMarkerImage() async {
    var byteData = await rootBundle.load("assets/marker.png");
    return byteData.buffer.asUint8List();
  }

  Future<Uint8List> loadMarkerImage() async {
    var byteData = await rootBundle.load("assets/marker1.png");
    return byteData.buffer.asUint8List();
  }

  _onmapcreated(MapboxMapController controller) async {
    this.controller = controller;
    LatLng initial;
    var data;

    if (pointer == 0) {
      CollectionReference hauler_state = FirebaseFirestore.instance
          .collection('list_of_employees(with accounts)');
      String ax = await docidfinder(email_id: emailid);
      DocumentSnapshot x = await hauler_state.doc(ax).get();
      CollectionReference statkeeper =
          FirebaseFirestore.instance.collection('Regular_collection');
      DocumentSnapshot database = await hauler_state.doc(ax).get();
      statkeeper
          .doc(database['database'].toString())
          .update({'locations': null});
      mapper = await map_address_add.get();
      final map_length = mapper!.docs.length;
      for (int i = 0; i < map_length; i++) {
        data = mapper!.docs[i].data();
        if (data['state'].toString() == emailid.toString() &&
            data['latitude'] != null &&
            data['longitude'] != null &&
            data['address'] == address) {
          if (data['email'] != null) {
            emails.add(data['email']);

            docid.add(mapper!.docs[i].id);
            initials.add(LatLng(data['latitude'], data['longitude']));
            markerimage.add(await loadMarkerImage());
            controller.addImage('marker' + j.toString(), markerimage[j]);
            initial = LatLng(data['latitude'], data['longitude']);
            initial_symbol = await controller.addSymbol(SymbolOptions(
                iconImage: 'marker' + j.toString(),
                geometry: initial,
                iconSize: 0.16));
            j++;
            initial_symbols.add(initial_symbol);
          }
        }
      }
      initial_symbol = initial_symbol = await controller.addSymbol(
          SymbolOptions(
              iconImage: 'marker' + j.toString(),
              geometry: lat_lng,
              iconSize: 0.16));
      initial_symbols.add(initial_symbol);
      await _location.changeSettings(interval: 1000, distanceFilter: 5);
      await _location.onLocationChanged
          .listen((LocationData _locationData) async {
        double lat1, lat2, long1, long2, distance, a;
        print('movedddd');
        _locationData = await _location.getLocation();
        for (int i = 0; i < initials.length; i++) {
          lat1 = initials[i].latitude * 3.1415926535897 / 180;
          long1 = initials[i].longitude * 3.1415926535897 / 180;
          lat2 = _locationData.latitude! * 3.1415926535897 / 180;
          long2 = _locationData.longitude! * 3.1415926535897 / 180;
          a = pow(sin((lat1 - lat2) / 2), 2) +
              cos(lat1) * cos(lat2) * pow(sin((long1 - long2) / 2), 2);
          distance = 6371000 * 2 * atan2(sqrt(a), sqrt(1 - a));
          print('${i}=' + distance.toString());
          if (distance < 15) {
            controller.removeSymbol(initial_symbols[i]);
            markerimage.add(await ChangeMarkerImage());
            controller.addImage('markere', markerimage[i]);
            initial_symbols.removeAt(i);
            await controller.addSymbol(SymbolOptions(
                iconImage: 'markere', geometry: initials[i], iconSize: 0.16));

            print("j=" + initial_symbols.length.toString());
            String text = 'Collection Complete';
            String bodytext =
                'Waste should be collected at your area, please verify it.';
            DocumentSnapshot snapshot = await FirebaseFirestore.instance
                .collection('List_of_tokens')
                .doc(emails[i]) //bc i changes
                .get();
            String token = snapshot['token'];
            print(token);
            sendpushmessage(token, text, bodytext);
            CollectionReference map_address_add =
                FirebaseFirestore.instance.collection('addresses');
            DocumentSnapshot number_taker =
                await map_address_add.doc(docid[i]).get();
            map_address_add.doc(docid[i]).update({
              'state': DateTime.now().toString(),
              'last hauler': x['employee id']
            });
            statkeeper.doc(database['database'].toString()).update({
              'locations': {number_taker['number']: DateTime.now()}
            });
            initials.removeAt(i);
            emails.removeAt(i);
            docid.removeAt(i);
          }
        }
        if (initials.isEmpty) {
          String a = await docidfinder(email_id: emailid);
          hauler_state
              .doc(a)
              .update({'state': null, 'address': null, 'database': null});
          statkeeper.doc(database['database'].toString()).update({
            'final time': DateTime.now(),
          });

          Showgenericdialog(
              context: context,
              title: 'Collection Complete',
              content: 'All the waste have been collected.',
              optionBuilder: () => {
                    'OK': null,
                  });
          context.read<AuthBloc>().add(const AuthEventScheduledCollection());
        }

        controller.moveCamera(
          CameraUpdate.newLatLng(
            LatLng(_locationData.latitude!, _locationData.longitude!),
          ),
        );
      });
      print("j=" + initial_symbols.length.toString());
    } else if ////////
        (pointer == 1) {
      CollectionReference hauler_state = FirebaseFirestore.instance
          .collection('list_of_employees(with accounts)');
      String ax = await docidfinder(email_id: emailid);
      DocumentSnapshot x = await hauler_state.doc(ax).get();
      CollectionReference statkeeper =
          FirebaseFirestore.instance.collection('Unscheduled_collection');
      DocumentSnapshot database = await hauler_state.doc(ax).get();
      statkeeper
          .doc(database['database'].toString())
          .update({'locations': null});
      CollectionReference unscheduled_map_address_add =
          FirebaseFirestore.instance.collection('unscheduled_collection');
      mapper = await unscheduled_map_address_add.get();
      final map_length = mapper!.docs.length;
      for (int i = 0; i < map_length; i++) {
        data = mapper!.docs[i].data();
        if (data['unscheduled_request'].toString() == emailid &&
            data['latitude'] != null &&
            data['longitude'] != null) {
          docid.add(mapper!.docs[i].id);
          initials.add(LatLng(data['latitude'], data['longitude']));
          markerimage.add(await loadMarkerImage());
          controller.addImage('marker' + j.toString(), markerimage[j]);
          initial = LatLng(data['latitude'], data['longitude']);
          initial_symbol = await controller.addSymbol(SymbolOptions(
              iconImage: 'marker' + j.toString(),
              geometry: initial,
              iconSize: 0.16));
          j++;
          initial_symbols.add(initial_symbol);
        }
      }
      print(initials.length.toString());
      await _location.changeSettings(interval: 1000, distanceFilter: 5);
      await _location.onLocationChanged
          .listen((LocationData _locationData) async {
        double lat1, lat2, long1, long2, distance, a;
        print('movedddd');
        _locationData = await _location.getLocation();
        for (int i = 0; i < initials.length; i++) {
          lat1 = initials[i].latitude * 3.1415926535897 / 180;
          long1 = initials[i].longitude * 3.1415926535897 / 180;
          lat2 = _locationData.latitude! * 3.1415926535897 / 180;
          long2 = _locationData.longitude! * 3.1415926535897 / 180;
          a = pow(sin((lat1 - lat2) / 2), 2) +
              cos(lat1) * cos(lat2) * pow(sin((long1 - long2) / 2), 2);
          distance = 6371000 * 2 * atan2(sqrt(a), sqrt(1 - a));
          print('${i}=' + distance.toString());
          if (distance < 15) {
            controller.removeSymbol(initial_symbols[i]);
            markerimage.add(await ChangeMarkerImage());
            controller.addImage('markere', markerimage[i]);
            initial_symbols.removeAt(i);
            await controller.addSymbol(SymbolOptions(
                iconImage: 'markere', geometry: initials[i], iconSize: 0.16));
            //doesnt work then here
            print("j=" + initial_symbols.length.toString());
            String text = 'Collection Complete';
            String bodytext =
                'Unscheduled waste collection should be happening at your location, please verify it.';
            DocumentSnapshot snapshot = await FirebaseFirestore.instance
                .collection('List_of_tokens')
                .doc(docid[i]) //bc i changes
                .get();
            print(docid[i]);
            String token = snapshot['token'];
            print(token);
            sendpushmessage(token, text, bodytext);
            CollectionReference map_address_add =
                FirebaseFirestore.instance.collection('unscheduled_collection');
            DocumentSnapshot number_taker =
                await map_address_add.doc(docid[i]).get();
            map_address_add.doc(docid[i]).update({
              'unscheduled_request': DateTime.now().toString(),
              'last hauler': x['employee id']
            });
            statkeeper.doc(database['database'].toString()).update({
              'locations': {number_taker['number']: DateTime.now()}
            });
            initials.removeAt(i);
            docid.removeAt(i);
          }
        }
        if (initials.isEmpty) {
          String a = await docidfinder(email_id: emailid);
          hauler_state
              .doc(a)
              .update({'state': null, 'address': null, 'database': null});
          statkeeper.doc(database['database'].toString()).update({
            'final time': DateTime.now(),
          });
          bool x = await Showgenericdialog(
              context: context,
              title: 'Collection Complete',
              content: 'All the waste have been collected.',
              optionBuilder: () => {
                    'OK': null,
                  });
          context.read<AuthBloc>().add(const AuthEventScheduledCollection());
        }

        controller.moveCamera(
          CameraUpdate.newLatLng(
            LatLng(_locationData.latitude!, _locationData.longitude!),
          ),
        );
      });
      print("j=" + initial_symbols.length.toString());
    } else if (pointer == 2) {
      ///
      //////////////
      //////
      /////////
      CollectionReference hauler_state = FirebaseFirestore.instance
          .collection('list_of_employees(with accounts)');
      String ax = await docidfinder(email_id: emailid);
      DocumentSnapshot x = await hauler_state.doc(ax).get();
      CollectionReference statkeeper =
          FirebaseFirestore.instance.collection('Compensatory_collection');
      DocumentSnapshot database = await hauler_state.doc(ax).get();
      statkeeper
          .doc(database['database'].toString())
          .update({'locations': null});
      CollectionReference unscheduled_map_address_add =
          FirebaseFirestore.instance.collection('addresses');
      mapper = await unscheduled_map_address_add.get();
      final map_length = mapper!.docs.length;
      for (int i = 0; i < map_length; i++) {
        data = mapper!.docs[i].data();
        if (data['state'].toString() == emailid &&
            data['latitude'] != null &&
            data['longitude'] != null) {
          docid.add(mapper!.docs[i].id);
          initials.add(LatLng(data['latitude'], data['longitude']));
          markerimage.add(await loadMarkerImage());
          controller.addImage('marker' + j.toString(), markerimage[j]);
          initial = LatLng(data['latitude'], data['longitude']);
          initial_symbol = await controller.addSymbol(SymbolOptions(
              iconImage: 'marker' + j.toString(),
              geometry: initial,
              iconSize: 0.16));
          j++;
          initial_symbols.add(initial_symbol);
        }
      }
      print(initials.length.toString());
      await _location.changeSettings(interval: 1000, distanceFilter: 5);
      await _location.onLocationChanged
          .listen((LocationData _locationData) async {
        double lat1, lat2, long1, long2, distance, a;
        print('movedddd');
        _locationData = await _location.getLocation();
        for (int i = 0; i < initials.length; i++) {
          lat1 = initials[i].latitude * 3.1415926535897 / 180;
          long1 = initials[i].longitude * 3.1415926535897 / 180;
          lat2 = _locationData.latitude! * 3.1415926535897 / 180;
          long2 = _locationData.longitude! * 3.1415926535897 / 180;
          a = pow(sin((lat1 - lat2) / 2), 2) +
              cos(lat1) * cos(lat2) * pow(sin((long1 - long2) / 2), 2);
          distance = 6371000 * 2 * atan2(sqrt(a), sqrt(1 - a));
          print('${i}=' + distance.toString());
          if (distance < 15) {
            controller.removeSymbol(initial_symbols[i]);
            markerimage.add(await ChangeMarkerImage());
            controller.addImage('markere', markerimage[i]);
            initial_symbols.removeAt(i);
            await controller.addSymbol(SymbolOptions(
                iconImage: 'markere', geometry: initials[i], iconSize: 0.16));
            //doesnt work then here
            print("j=" + initial_symbols.length.toString());
            String text = 'Compensatory Collection Complete';
            String bodytext =
                'Compensatory waste collection should be happening at your location, please verify it.';
            DocumentSnapshot snapshot = await FirebaseFirestore.instance
                .collection('List_of_tokens')
                .doc(docid[i]) //bc i changes
                .get();
            String token = snapshot['token'];
            print(token);
            sendpushmessage(token, text, bodytext);
            CollectionReference map_address_add =
                FirebaseFirestore.instance.collection('addresses');
            DocumentSnapshot number_taker =
                await map_address_add.doc(docid[i]).get();
            map_address_add.doc(docid[i]).update({
              'state': DateTime.now().toString(),
              'last hauler': x['employee id']
            });
            statkeeper.doc(database['database'].toString()).update({
              'locations': {number_taker['number']: DateTime.now()}
            });
            map_address_add.doc(docid[i]).update({'unscheduled_request': null});
            initials.removeAt(i);
            docid.removeAt(i);
          }
        }
        if (initials.isEmpty) {
          String a = await docidfinder(email_id: emailid);
          hauler_state
              .doc(a)
              .update({'state': null, 'address': null, 'database': null});
          statkeeper.doc(database['database'].toString()).update({
            'final time': DateTime.now(),
          });
          Showgenericdialog(
              context: context,
              title: 'Collection Complete',
              content: 'All the waste have been collected.',
              optionBuilder: () => {
                    'OK': null,
                  });
          context.read<AuthBloc>().add(const AuthEventScheduledCollection());
        }

        controller.moveCamera(
          CameraUpdate.newLatLng(
            LatLng(_locationData.latitude!, _locationData.longitude!),
          ),
        );
      });
      print("j=" + initial_symbols.length.toString());
    }
  }

  _onstyleloadedcallback() async {}

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Map'),
          actions: [
            IconButton(
                onPressed: () async {
                  context.read<AuthBloc>().add(const AuthEventHaulerBack());
                },
                icon: Icon(Icons.home)),
            IconButton(
                onPressed: () async {
                  CollectionReference hauler_state = FirebaseFirestore.instance
                      .collection('list_of_employees(with accounts)');
                  String ax = await docidfinder(email_id: emailid);
                  DocumentSnapshot xa = await hauler_state.doc(ax).get();

                  CollectionReference tokens =
                      FirebaseFirestore.instance.collection('List_of_tokens');
                  if (pointer == 0) {
                    CollectionReference statkeeper = FirebaseFirestore.instance
                        .collection('Regular_collection');
                    DocumentSnapshot database =
                        await hauler_state.doc(ax).get();
                    bool x = await Showgenericdialog(
                        context: context,
                        title: 'Stop Collection',
                        content: 'There are ' +
                            initials.length.toString() +
                            ' collections left, how do you want to exit?',
                        optionBuilder: () => {
                              'Temporary exit': false,
                              'Permanent exit': true,
                            }).then((value) => value ?? false);

                    var data, data1;
                    String data2;
                    if (x) {
                      for (int i = 0; i < mapper!.docs.length; i++) {
                        data = mapper!.docs[i].data();
                        if (data['state'] == emailid) {
                          data2 = mapper!.docs[i].id.toString();
                          map_address_add
                              .doc(data2)
                              .update({'state': DateTime.now().toString()});
                          DocumentSnapshot q =
                              await tokens.doc(data['email']).get();
                          data1 = q.data();
                          sendpushmessage(
                              data1['token'],
                              'Waste has been said to be collected in your area, please verify it.',
                              'Collection Complete');
                          DocumentSnapshot number_taker =
                              await map_address_add.doc(docid[i]).get();
                          map_address_add.doc(docid[i]).update({
                            'state': DateTime.now().toString(),
                            'last hauler': xa['employee id']
                          });
                          statkeeper
                              .doc(database['database'].toString())
                              .update({
                            'locations': {
                              number_taker['number']: DateTime.now()
                            },
                            'final time': DateTime.now(),
                          });
                        }
                      }
                      context.read<AuthBloc>().add(const AuthEventHaulerBack());

                      String a = await docidfinder(email_id: emailid);
                      hauler_state.doc(a).update(
                          {'state': null, 'address': null, 'database': null});
                    } else if (!x) {
                      for (int i = 0; i < mapper!.docs.length; i++) {
                        data = mapper!.docs[i].data();
                        if (data['state'] == emailid) {
                          data2 = mapper!.docs[i].id.toString();
                          map_address_add.doc(data2).update({'state': null});
                          DocumentSnapshot q =
                              await tokens.doc(data['email']).get();
                          data1 = q.data();
                          sendpushmessage(
                              data1['token'],
                              'Waste collection in your area has been temporarily exited, we are sorry for the inconvenience',
                              'Collection exited temporarily');
                          DocumentSnapshot number_taker =
                              await map_address_add.doc(docid[i]).get();
                          statkeeper
                              .doc(database['database'].toString())
                              .update({
                            'not gone locations': {number_taker['number']: '-'},
                            'final time': DateTime.now(),
                          });
                        }
                      }
                      context.read<AuthBloc>().add(const AuthEventHaulerBack());

                      String a = await docidfinder(email_id: emailid);
                      hauler_state.doc(a).update(
                          {'state': null, 'address': null, 'database': null});
                    }
                  } else if (pointer == 1) {
                    CollectionReference statkeeper = FirebaseFirestore.instance
                        .collection('Unscheduled_collection');
                    DocumentSnapshot database =
                        await hauler_state.doc(ax).get();
                    CollectionReference map_address_add = FirebaseFirestore
                        .instance
                        .collection('unscheduled_collection');
                    bool x = await Showgenericdialog(
                        context: context,
                        title: 'Stop Collection',
                        content: 'There are ' +
                            initials.length.toString() +
                            ' collections left, how do you want to exit?',
                        optionBuilder: () => {
                              'Temporary exit': false,
                              'Permanent exit': true,
                            }).then((value) => value ?? false);

                    var data, data1;
                    String data2;
                    if (x) {
                      for (int i = 0; i < mapper!.docs.length; i++) {
                        String idd;
                        data = mapper!.docs[i].data();
                        idd = mapper!.docs[i].id;
                        if (data['unscheduled_request'] == emailid) {
                          data2 = mapper!.docs[i].id.toString();
                          map_address_add.doc(data2).update({
                            'unscheduled_request': DateTime.now().toString()
                          });
                          DocumentSnapshot q = await tokens.doc(idd).get();
                          data1 = q.data();
                          sendpushmessage(
                              data1['token'],
                              'Waste has been said to be collected in your area, please verify it.',
                              'Collection Complete');
                          DocumentSnapshot number_taker =
                              await map_address_add.doc(docid[0]).get();
                          map_address_add.doc(docid[0]).update({
                            'unscheduled_request': DateTime.now().toString(),
                            'last hauler': xa['employee id']
                          });
                          statkeeper
                              .doc(database['database'].toString())
                              .update({
                            'locations': {
                              number_taker['number']: DateTime.now()
                            },
                            'final time': DateTime.now(),
                          });
                        }
                      }
                      context.read<AuthBloc>().add(const AuthEventHaulerBack());

                      String a = await docidfinder(email_id: emailid);
                      hauler_state.doc(a).update(
                          {'state': null, 'address': null, 'database': null});
                    } else if (!x) {
                      for (int i = 0; i < mapper!.docs.length; i++) {
                        String idd = mapper!.docs[i].id;
                        data = mapper!.docs[i].data();
                        print(idd);
                        print(data['unscheduled_request']);
                        if (data['unscheduled_request'] == emailid) {
                          data2 = mapper!.docs[i].id.toString();
                          map_address_add
                              .doc(data2)
                              .update({'unscheduled_request': 'requested'});
                          DocumentSnapshot q = await tokens.doc(idd).get();
                          data1 = q.data();
                          print(data1['token']);
                          sendpushmessage(
                              data1['token'],
                              'Waste collection in your area has been temporarily exited, we are sorry for the inconvenience',
                              'Collection exited temporarily');
                          DocumentSnapshot number_taker =
                              await map_address_add.doc(docid[0]).get();
                          statkeeper
                              .doc(database['database'].toString())
                              .update({
                            'locations': {number_taker['number']: '-'},
                            'final time': DateTime.now(),
                          });
                        }
                      }
                      context.read<AuthBloc>().add(const AuthEventHaulerBack());

                      String a = await docidfinder(email_id: emailid);
                      hauler_state.doc(a).update(
                          {'state': null, 'address': null, 'database': null});
                    }
                  } else if (pointer == 2) {
                    CollectionReference statkeeper = FirebaseFirestore.instance
                        .collection('Compensatory_collection');
                    DocumentSnapshot database =
                        await hauler_state.doc(ax).get();
                    CollectionReference map_address_add =
                        FirebaseFirestore.instance.collection('addresses');
                    bool x = await Showgenericdialog(
                        context: context,
                        title: 'Stop Collection',
                        content: 'There are ' +
                            initials.length.toString() +
                            ' collections left, how do you want to exit?',
                        optionBuilder: () => {
                              'Temporary exit': false,
                              'Permanent exit': true,
                            }).then((value) => value ?? false);

                    var data, data1;
                    String data2;
                    if (x) {
                      for (int i = 0; i < mapper!.docs.length; i++) {
                        data = mapper!.docs[i].data();
                        if (data['state'] == emailid) {
                          data2 = mapper!.docs[i].id.toString();
                          map_address_add
                              .doc(data2)
                              .update({'state': DateTime.now().toString()});
                          DocumentSnapshot q =
                              await tokens.doc(data['email']).get();
                          data1 = q.data();
                          sendpushmessage(
                              data1['token'],
                              'Waste has been said to be collected in your area, please verify it.',
                              'Collection Complete');
                          DocumentSnapshot number_taker =
                              await map_address_add.doc(docid[i]).get();
                          map_address_add.doc(docid[i]).update({
                            'state': DateTime.now().toString(),
                            'last hauler': xa['employee id']
                          });
                          statkeeper
                              .doc(database['database'].toString())
                              .update({
                            'locations': {
                              number_taker['number']: DateTime.now()
                            },
                            'final time': DateTime.now(),
                          });
                        }
                      }
                      context.read<AuthBloc>().add(const AuthEventHaulerBack());

                      String a = await docidfinder(email_id: emailid);
                      hauler_state.doc(a).update(
                          {'state': null, 'address': null, 'database': null});
                    } else if (!x) {
                      for (int i = 0; i < mapper!.docs.length; i++) {
                        data = mapper!.docs[i].data();
                        if (data['state'] == emailid) {
                          data2 = mapper!.docs[i].id.toString();
                          map_address_add
                              .doc(data2)
                              .update({'state': 'uncollected'});
                          DocumentSnapshot q =
                              await tokens.doc(data['email']).get();
                          data1 = q.data();
                          sendpushmessage(
                              data1['token'],
                              'Waste collection in your area has been temporarily exited, we are sorry for the inconvenience',
                              'Collection exited temporarily');
                          DocumentSnapshot number_taker =
                              await map_address_add.doc(docid[i]).get();
                          statkeeper
                              .doc(database['database'].toString())
                              .update({
                            'not gone locations': {number_taker['number']: '-'},
                            'final time': DateTime.now(),
                          });
                        }
                      }
                      context.read<AuthBloc>().add(const AuthEventHaulerBack());

                      String a = await docidfinder(email_id: emailid);
                      hauler_state.doc(a).update(
                          {'state': null, 'address': null, 'database': null});
                    }
                  }
                },
                icon: Icon(Icons.cancel)),
          ],
        ),
        body: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: MapboxMap(
                dragEnabled: true,
                accessToken:
                    'sk.eyJ1IjoiYWdhanBhdWRlbDEiLCJhIjoiY2w5d3lydndhMDJrNjN3cXc3OXlidndyaSJ9.FpDaGLBJmd2D5NwzcYvxnA',
                initialCameraPosition: _initalcameraposition,
                onMapCreated: _onmapcreated,
                onStyleLoadedCallback: _onstyleloadedcallback,
                myLocationEnabled: true,
                myLocationTrackingMode: MyLocationTrackingMode.TrackingCompass,
                minMaxZoomPreference: const MinMaxZoomPreference(10, 17),
                scrollGesturesEnabled: true, //to disable map rotations
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
                doubleClickZoomEnabled: true,
                compassEnabled: true,
                onMapLongClick: (point, coordinates) async {},
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            controller.animateCamera(
                CameraUpdate.newCameraPosition(_initalcameraposition));
          },
          child: const Icon(Icons.my_location),
        ),
      ),
    );
  }
}

void sendpushmessage(String token, String body, String title) async {
  try {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAx6JHUW4:APA91bG7_yc4xsQ9tFURSsgE4ZCf3g5Jm2gTIhy1PyyoUdb-yufhIqZIbPHanl-MmGSoxb0OZnRfrwnJz_BmVX36AP9pBNAi_WyQXmQyRCudZdHl-q2qNPzEf-3jW5QKFsfWvmJkQuLQ',
      },
      body: jsonEncode(
        <String, dynamic>{
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            'body': body,
            'title': title
          },
          'notification': <String, dynamic>{
            'title': title,
            'body': body,
          },
          'to': token
        },
      ),
    );
  } catch (e) {
    if (kDebugMode) {
      print('error pushing notification');
    }
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
