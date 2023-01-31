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
String doc_idd = '';
List<LatLng> values = [];

LatLng lat_long = LatLng(27.7172, 85.3240);
String address = '';
void unscheduled_holder(
    {required LatLng latLng,
    required String doc_id,
    required QuerySnapshot querySnapshot}) {
  querySnapshots = querySnapshot;
  doc_idd = doc_id;
  values = [];

  selected_markers = [];
  lat_long = latLng;
}

void take_address() async {
  var data;

  for (int i = 0; i < querySnapshots!.docs.length; i++) {
    data = querySnapshots!.docs[i].data();
    if (querySnapshots!.docs[i].id.toString() == doc_idd) {
      //date addition left
      print(data['latitude'].toString() +
          '        0            ' +
          data['longitude'].toString());
      values
          .add(LatLng(data['latitude'] as double, data['longitude'] as double));
      docid.add(querySnapshots!.docs[i].id);
      state.add(data['state'].toString());
    }
  }
  print('total=' + querySnapshots!.docs.length.toString());
  print('values=' + values.length.toString());
}

List<Marker> _buildmarkers() {
  List<Marker> _markerlist = <Marker>[];
  for (int i = 0; i < values.length; i++) {
    _markerlist.add(Marker(
        height: 15,
        width: 15,
        point: values[i],
        builder: (_) {
          return GestureDetector(
            onTap: () async {},
            child: Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/marker1.png'),
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

class UnscheduledInside_collection extends StatefulWidget {
  const UnscheduledInside_collection({Key? key}) : super(key: key);

  @override
  State<UnscheduledInside_collection> createState() =>
      UnscheduledInsideCollectionviewstate();
}

class UnscheduledInsideCollectionviewstate
    extends State<UnscheduledInside_collection> {
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
                  CollectionReference map_address = FirebaseFirestore.instance
                      .collection('unscheduled_collection');
                  map_address
                      .doc(docid[0])
                      .update({'unscheduled_request': emailid});
                  CollectionReference tokens =
                      FirebaseFirestore.instance.collection('List_of_tokens');
                  var data2;
                  DocumentSnapshot q = await tokens.doc(doc_idd).get();
                  data2 = q.data();
                  sendpushmessage(data2['token']);
                  CollectionReference hauler_state = FirebaseFirestore.instance
                      .collection('list_of_employees(with accounts)');
                  String a = await docidfinder(email_id: emailid);
                  DocumentSnapshot x = await hauler_state.doc(a).get();
                  hauler_state.doc(a).update({
                    'state': 'unscheduled_hauling',
                    'address': null,
                    'database':
                        x['employee id'] + '+' + DateTime.now().toString()
                  });
                  print('here');
                  CollectionReference statkeeper = FirebaseFirestore.instance
                      .collection('Unscheduled_collection');
                  DocumentSnapshot database = await hauler_state.doc(a).get();
                  print(database['database'].toString());
                  statkeeper.doc(database['database'].toString()).set({
                    'start time': DateTime.now(),
                    'location': null,
                    'final time': null,
                    'not gone locations': null,
                  });
                  unscheduledtavelholder(lat_long,
                      doc_id: doc_idd, querySnapshot: querySnapshots!);
                  context.read<AuthBloc>().add(const AuthEventHaulerCollect());
                },
                icon: const Text('Confirm')),
            IconButton(
                onPressed: () async {
                  context
                      .read<AuthBloc>()
                      .add(const AuthEventUnscheduledCollectionList());
                },
                icon: Icon(Icons.arrow_back)),
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
        ]),
      ),
    );
  }
}

//for notification
void sendpushmessage(String token) async {
  String title = 'Waste Collection';
  String body = 'Hauler on the way';
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

// class RegisterView extends StatefulWidget {
//   const RegisterView({Key? key}) : super(key: key);

//   @override
//   _RegisterViewState createState() => _RegisterViewState();
// }

// class _RegisterViewState extends State<RegisterView> {
//   late final TextEditingController _email;
//   late final TextEditingController _password;

//   @override
//   void initState() {
//     _email = TextEditingController();
//     _password = TextEditingController();
//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _email.dispose();
//     _password.dispose();
//     // TODO: implement dispose
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Register View"),
//       ),
//       body: Column(
//         children: [
//           TextField(
//               controller: _email,
//               enableSuggestions: false,
//               autocorrect: false,
//               keyboardType: TextInputType.emailAddress,
//               decoration: const InputDecoration(
//                 hintText: 'Enter email',
//               )),
//           TextField(
//             controller: _password,
//             enableSuggestions: false,
//             autocorrect: false,
//             obscureText: true,
//             decoration: const InputDecoration(
//               hintText: 'Enter password',
//             ),
//           ),
//           TextButton(
//             onPressed: () async {
//               final email = _email.text;
//               final password = _password.text;
//               try {
//                 await AuthService //await garena vane it always goes to verify email altho email already verified
//                         .firebase()
//                     .createUser(email: email, password: password);
//                 AuthService.firebase().sendEmailVerification();
//                 Navigator.of(context).pushNamed(verifyemailroute);
//               } on WeakPasswordAuthException {
//                 ShowErrorDialog(context, 'Weak Password.');
//               } on EmailAlreadyInUseAuthException {
//                 ShowErrorDialog(context, 'Email already in use.');
//               } on InvalidEmailAuthException {
//                 ShowErrorDialog(context, 'Email is invalid.');
//               } on GeneralAuthException {
//                 ShowErrorDialog(context, 'Registration Failed.');
//               }
//             },
//             child: const Text('Register'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context)
//                   .pushNamedAndRemoveUntil(loginroute, (route) => false);
//             },
//             child: const Text('Already registered?'),
//           )
//         ],
//       ),
//     );
//   }
// }
