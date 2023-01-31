import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart'
    show PermissionStatus, Location, LocationData;
import 'package:mapbox_gl/mapbox_gl.dart'
    show
        CameraUpdate,
        LatLng,
        MyLocationTrackingMode,
        MapboxMap,
        MinMaxZoomPreference,
        CameraPosition,
        MapboxMapController,
        SymbolOptions,
        CameraTargetBounds;
import 'package:wastecollector/services/cloud/firebase_cloud_storage.dart';
import 'package:wastecollector/utilities/genericdialog.dart';
import '../../services/auth/auth_service.dart';

LatLng lat_lng = LatLng(27.7172, 85.3240);

class Mapui extends StatefulWidget {
  const Mapui({Key? key}) : super(key: key);

  @override
  State<Mapui> createState() => _MapuiState();
}

class _MapuiState extends State<Mapui> {
  CollectionReference map_address_add =
      FirebaseFirestore.instance.collection('addresses');
  int tap = 0;
  var symbol = null;
  double? lat, long;
  late final FirebaseCloudStorage _notesservice;
  String get userid => AuthService.firebase().currentUser!.id;
  String get emailid => AuthService.firebase().currentUser!.email;
  late CameraPosition _initalcameraposition;
  CameraPosition? _newcameraposition;
  late MapboxMapController controller;

  void markermaker() async {
    Location _location = Location(); //from location dependency
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
  }

  @override
  void initState() {
    markermaker();
    _notesservice = FirebaseCloudStorage();
    _initalcameraposition = CameraPosition(target: lat_lng, zoom: 15);
    super.initState();
  }

  _onmapcreated(MapboxMapController controller) async {
    this.controller = controller;
    LatLng initial;
    var data;
    var initial_symbol;
    QuerySnapshot mapper = await map_address_add.get();
    final map_length = mapper.docs.length;
    for (int i = 0; i < map_length; i++) {
      data = mapper.docs[i].data();
      if (data['email'].toString() == emailid.toString() &&
          data['latitude'] != null &&
          data['longitude'] != null) {
        initial = LatLng(data['latitude'], data['longitude']);
        initial_symbol = await controller.addSymbol(SymbolOptions(
          iconImage: 'assets/marker1.png',
          iconSize: 0.1,
          textField: 'old address',
          geometry: initial,
        ));
      }
    }
  }

  _onstyleloadedcallback() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          IconButton(
            onPressed: () async {
              tap = 1;
              Showgenericdialog(
                  context: context,
                  title: 'Mark Address',
                  content: 'Tap on the map to mark address',
                  optionBuilder: () => {
                        'OK': null,
                      });
              markermaker();
            },
            icon: const Icon(Icons.location_pin),
          ),
          IconButton(
              onPressed: () async {
                CollectionReference unscheduled = FirebaseFirestore.instance
                    .collection('unscheduled_collection');
                DocumentSnapshot data2;
                data2 = await unscheduled.doc(emailid).get();
                String a;
                a = await docidfinder(email_id: emailid);
                var data;
                data = await snapshotfinder(email_id: emailid);
                print(data['state'].toString());
                print(data2['unscheduled_request']);
                if (!data['state'].toString().endsWith('@email.com') &&
                    !data2['unscheduled_request']
                        .toString()
                        .endsWith('@gmail.com')) {
                  map_address_add.doc(a).update({
                    'email': AuthService.firebase().currentUser!.email,
                    'latitude': lat,
                    'longitude': long,
                    'state': null,
                  });
                  Showgenericdialog(
                      context: context,
                      title: 'Save Address',
                      content: 'Address saved successfully.',
                      optionBuilder: () => {
                            'OK': null,
                          });
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
              },
              icon: Icon(Icons.save))
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: MapboxMap(
                accessToken:
                    'sk.eyJ1IjoiYWdhanBhdWRlbDEiLCJhIjoiY2w5d3lydndhMDJrNjN3cXc3OXlidndyaSJ9.FpDaGLBJmd2D5NwzcYvxnA',
                initialCameraPosition: _initalcameraposition,
                onMapCreated: _onmapcreated,
                onStyleLoadedCallback: _onstyleloadedcallback,
                myLocationEnabled: true,
                myLocationTrackingMode: MyLocationTrackingMode.TrackingCompass,
                minMaxZoomPreference: const MinMaxZoomPreference(13, 17),
                scrollGesturesEnabled: true, //to disable map rotations
                rotateGesturesEnabled: true,
                dragEnabled: true,
                tiltGesturesEnabled: true,
                doubleClickZoomEnabled: true,
                compassEnabled: true,
                onMapClick: (point, coordinates) async {
                  print(coordinates);
                  print(point);
                  _newcameraposition =
                      CameraPosition(target: coordinates, zoom: 15);
                  controller.animateCamera(
                      CameraUpdate.newCameraPosition(_newcameraposition!));
                  if (symbol == null) {
                    if (tap == 1) {
                      lat = coordinates.latitude;
                      long = coordinates.longitude;
                      symbol = await controller.addSymbol(SymbolOptions(
                        geometry: coordinates,
                        iconImage: 'assets/marker1.png',
                        iconSize: 0.1,
                      ));
                    }
                  } else {
                    if (tap == 1) {
                      await controller.removeSymbol(symbol);
                      symbol = await controller.addSymbol(SymbolOptions(
                        geometry: coordinates,
                        iconImage: 'assets/marker1.png',
                        iconSize: 0.1,
                      ));
                      lat = coordinates.latitude;
                      long = coordinates.longitude;
                    }
                  }
                }),
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



//  FlutterMap(
//         options: MapOptions(
//           center: LatLng(lat_lng.latitude, lat_lng.longitude),
//           zoom: 13.0,
//         ),
//         layers: [
//           TileLayerOptions(
//               urlTemplate:
//                   "https://api.mapbox.com/styles/v1/agajpaudel1/cl9ch1ru6002i14qer5fbsm2r/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYWdhanBhdWRlbDEiLCJhIjoiY2w5Y2dvc2puMTd1aTN1cDhhNml6YmptbCJ9.O5xqjT3zS_U3ZAF7oiYgyg",
//               additionalOptions: {
//                 'accessToken':
//                     'pk.eyJ1IjoiYWdhanBhdWRlbDEiLCJhIjoiY2w5Y2dvc2puMTd1aTN1cDhhNml6YmptbCJ9.O5xqjT3zS_U3ZAF7oiYgyg',
//                 'id': 'mapbox.mapbox-streets-v8',
//               }),
//         ],
//       ),




