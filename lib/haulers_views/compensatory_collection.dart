import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as a;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastecollector/constants/routes.dart';
import 'package:wastecollector/haulers_views/collection_travel.dart';
import 'package:wastecollector/services/auth/bloc/auth_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_events.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';
import 'package:wastecollector/utilities/genericdialog.dart';
import 'package:wastecollector/views/address_dropdown.dart';
import '../../services/auth/auth_service.dart';

Color selected_color = Colors.transparent;

List<Marker> selected_markers = [], selectedmarker = [];
List<String> docid = [], state = [];
QuerySnapshot? querySnapshots;
bool? selection, show;
String get emailid => AuthService.firebase().currentUser!.email;
List<LatLng> values = [];

LatLng lat_long = LatLng(27.7172, 85.3240);
String address = '';
void holder({required String place, required QuerySnapshot querySnapshot}) {
  querySnapshots = querySnapshot;
  docid = [];
  values = [];
  state = [];

  selected_markers = [];
  address = place;
}

void take_address() async {
  var data;
  double x, y;
  for (int i = 0; i < querySnapshots!.docs.length; i++) {
    data = querySnapshots!.docs[i].data();
    if (data['state'] == 'uncollected' || data['state'] == emailid) {
      if (data['latitude'] != null && data['longitude'] != null) {
        //date addition left
        print(data['latitude'].toString() +
            '        0            ' +
            data['longitude'].toString());
        values.add(
            LatLng(data['latitude'] as double, data['longitude'] as double));
        docid.add(querySnapshots!.docs[i].id);
        state.add(data['state'].toString());
      }
    }
  }
  print('total=' + querySnapshots!.docs.length.toString());
  print('values=' + values.length.toString());
}

List<Marker> _buildmarkers() {
  List<String> assetaddress = [];
  List<double> heights = [], widths = [];
  List<Marker> _markerlist = <Marker>[];
  for (int i = 0; i < values.length; i++) {
    heights.add(15);
    widths.add(15);
    if (state[i].toString() == emailid) {
      assetaddress.add('assets/marker.png');
    } else {
      assetaddress.add('assets/marker1.png');
    }
    _markerlist.add(Marker(
        height: heights[i],
        width: widths[i],
        point: values[i],
        builder: (_) {
          return GestureDetector(
            onTap: () async {
              print('touched the black one');
              print(docid[i]);
              if (assetaddress[i] == 'assets/marker1.png') {
                if (selection == true) {
                  CollectionReference map_address =
                      FirebaseFirestore.instance.collection('addresses');
                  map_address.doc(docid[i]).update({'state': emailid});
                  print('added');
                  assetaddress[i] = 'assets/marker.png';
                  //separation
                }
              } else if (assetaddress[i] == 'assets/marker.png') {
                CollectionReference map_address =
                    FirebaseFirestore.instance.collection('addresses');
                map_address.doc(docid[i]).update({'state': 'uncollected'});
                assetaddress[i] = 'assets/marker1.png';
              }
            },
            child: Container(
              height: heights[i],
              width: widths[i],
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(assetaddress[i]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }));
  }
  print(_markerlist.length.toString() + 'dasdsasdadadas');
  return _markerlist;
}

class Compensatory_collection extends StatefulWidget {
  const Compensatory_collection({Key? key}) : super(key: key);

  @override
  State<Compensatory_collection> createState() =>
      CompensatoryCollectionviewstate();
}

class CompensatoryCollectionviewstate extends State<Compensatory_collection> {
  List<Marker> _markers = [];

  @override
  void initState() {
    print(_markers.length.toString());
    selection = false;
    show = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    take_address();

    _markers = _buildmarkers();

    //future used bc await/async executes at last giving us 0 values.length
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Scheduled Collection"),
          actions: [
            IconButton(
                onPressed: () async {
                  context.read<AuthBloc>().add(const AuthEventHaulerBack());
                },
                icon: const Icon(Icons.home)),
            IconButton(
                onPressed: () async {
                  selection = true;
                  Showgenericdialog(
                      context: context,
                      title: 'Address Selection',
                      content:
                          'Select the collection addresses by tapping on them.',
                      optionBuilder: () => {
                            'OK': null,
                          });
                },
                icon: const Icon(Icons.select_all))
          ],
        ),
        body: Stack(children: [
          FlutterMap(
            options: MapOptions(
              center: lat_long,
              zoom: 13.0,
            ),
            nonRotatedLayers: [
              TileLayerOptions(
                  urlTemplate:
                      "https://api.mapbox.com/styles/v1/agajpaudel1/cl9ch1ru6002i14qer5fbsm2r/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYWdhanBhdWRlbDEiLCJhIjoiY2w5Y2dvc2puMTd1aTN1cDhhNml6YmptbCJ9.O5xqjT3zS_U3ZAF7oiYgyg",
                  additionalOptions: {
                    'accessToken':
                        'pk.eyJ1IjoiYWdhanBhdWRlbDEiLCJhIjoiY2w5Y2dvc2puMTd1aTN1cDhhNml6YmptbCJ9.O5xqjT3zS_U3ZAF7oiYgy',
                    'id': 'mapbox.mapbox-streets-v8',
                  }),
              MarkerLayerOptions(
                markers: selectedmarker,
              ),
              MarkerLayerOptions(markers: _markers)
            ],
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: MediaQuery.of(context).size.height * 0.2,
              child: PageView.builder(itemBuilder: (context, index) {
                return CompensatoryChooser();
              })),
        ]),
      ),
    );
  }
}

class CompensatoryChooser extends StatelessWidget {
  const CompensatoryChooser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Card(
            color: Colors.white,
            child: Stack(
              children: [
                Text(values.length.toString() + ' total.'),
                //
                TextButton(
                    onPressed: () async {
                      CollectionReference tokens = FirebaseFirestore.instance
                          .collection('List_of_tokens');
                      CollectionReference aa =
                          FirebaseFirestore.instance.collection('addresses');
                      QuerySnapshot query = await aa.get();
                      String token;
                      var data, data2;
                      for (int i = 0; i < query.docs.length; i++) {
                        print(query.docs.length);
                        data = query.docs[i].data();
                        print('j=' + address);
                        print(data['address'].toString());
                        print(data['state']);

                        if (data['latitude'] != null &&
                            data['longitude'] != null) {
                          if (data['state'] == emailid) {
                            print('xxxxxxxxxxxxxxxxxxx');
                            if (data['email'] != null) {
                              String em = data['email'];
                              print(em);
                              DocumentSnapshot q = await tokens.doc(em).get();
                              data2 = q.data();
                              print(data2['token']);
                              sendpushmessage(data2['token']);
                            }
                          }
                        }
                      }
                      compensatory_travelholder(lat_long,
                          querySnapshot: querySnapshots!);
                      CollectionReference hauler_state = FirebaseFirestore
                          .instance
                          .collection('list_of_employees(with accounts)');
                      String a = await docidfinder(email_id: emailid);
                      DocumentSnapshot x = await hauler_state.doc(a).get();
                      hauler_state.doc(a).update({
                        'state': 'compensatory_haul',
                        'address': 'compensatory',
                        'database':
                            x['employee id'] + '+' + DateTime.now().toString()
                      });
                      CollectionReference statkeeper = FirebaseFirestore
                          .instance
                          .collection('Compensatory_collection');
                      DocumentSnapshot database =
                          await hauler_state.doc(a).get();
                      statkeeper.doc(database['database'].toString()).set({
                        'start time': DateTime.now(),
                        'locations': null,
                        'final time': null,
                        'not gone locations': null
                      });
                      context
                          .read<AuthBloc>()
                          .add(const AuthEventHaulerCollect());
                    },
                    child: Text('Confirm Haul')),
              ],
            ),
          ),
        ));
  }
}

//for notification
void sendpushmessage(String token) async {
  String title = 'Compensatory Collection';
  String body = 'Hauler on the way.';
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
