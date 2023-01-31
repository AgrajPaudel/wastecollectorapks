import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:wastecollector/constants/routes.dart';
import 'package:wastecollector/haulers_views/unscheduled_inside_collection.dart';
import 'package:wastecollector/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastecollector/services/auth/bloc/auth_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_events.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';

class CreateUpdateRequestView extends StatefulWidget {
  const CreateUpdateRequestView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateRequestView> createState() =>
      _CreateUpdateRequestiewState();
}

class _CreateUpdateRequestiewState extends State<CreateUpdateRequestView> {
  var _query = FirebaseFirestore.instance
      .collection('unscheduled_collection')
      .where('unscheduled_request', isEqualTo: 'requested');
  var _price = '';
  var _vehicleType = '';
  var data;
  var _time = '';
  var _sortAsc = true;
  List<String> doc_id = [];
  var _sortPrice = true;
  String get emailid => AuthService.firebase().currentUser!.email;

  //init state
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
      listener: (context, state) {
        // TODO: implement listener
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New requests'),
          actions: [
            IconButton(
                onPressed: () async {
                  context.read<AuthBloc>().add(const AuthEventHaulerBack());
                },
                icon: Icon(Icons.home)),
          ],
        ),
        body: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Row(children: [
                TextButton(
                  child: Text(_sortPrice ? 'Sort by Price' : 'Sort by Vehicle'),
                  onPressed: () => setState(() => _sortPrice = !_sortPrice),
                ),
                TextButton(
                  child: Text(_sortAsc ? 'Sort Descending' : 'Sort Ascending'),
                  onPressed: () => setState(() => _sortAsc = !_sortAsc),
                ),
              ]),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _query.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  var documents = snapshot.data!.docs;
                  // Apply filtering and sorting
                  if (_price.isNotEmpty) {
                    documents = documents
                        .where((doc) => doc['price'] == _price)
                        .toList();
                  }
                  if (_vehicleType.isNotEmpty) {
                    documents = documents
                        .where((doc) => doc['vehicle'] == _vehicleType)
                        .toList();
                  }
                  if (_time.isNotEmpty) {
                    documents =
                        documents.where((doc) => doc['time'] == _time).toList();
                  }
                  if (_sortAsc && _sortPrice) {
                    documents.sort((a, b) => b['price'].compareTo(a['price']));
                  } else if (!_sortAsc && _sortPrice) {
                    documents.sort((a, b) => a['price'].compareTo(b['price']));
                  } else if (_sortAsc && !_sortPrice) {
                    documents
                        .sort((a, b) => b['vehicle'].compareTo(a['vehicle']));
                  } else {
                    documents
                        .sort((a, b) => a['vehicle'].compareTo(b['vehicle']));
                  }

                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      doc_id.add(documents[index].id.toString());
                      data = documents[index].data()!;
                      return ListTile(
                        subtitle: Text('Price: ' +
                            data['price'].toString() +
                            '\n' +
                            'Vehicle: ' +
                            data['vehicle'] +
                            '\n' +
                            'Time: ' +
                            data['time']),
                        onTap: () async {
                          print(documents[index].id.toString());
                          CollectionReference address = FirebaseFirestore
                              .instance
                              .collection('unscheduled_collection');
                          querySnapshots = await address.get();
                          unscheduled_holder(
                              latLng:
                                  LatLng(data['latitude'], data['longitude']),
                              doc_id: doc_id[index],
                              querySnapshot: querySnapshots!);
                          context.read<AuthBloc>().add(
                              const AuthEventInsideUnscheduledCollection());
                          // Navigate to a new screen or perform some action when the item is tapped
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}




//for sub fields in firestore database:
// Firestore.instance.collection('address').document().setData({
//   'name': 'John Doe',
//   'address': {
//     'street': '123 Main St',
//     'city': 'Anytown',
//     'state': 'CA',
//     'zip': '12345',
//   }
// });


// Firestore.instance.collection('address').document().setData({
//   'name': 'John Doe',
// });

// Firestore.instance.collection('address').document().collection('address').add({
//     'street': '123 Main St',
//     'city': 'Anytown',
//     'state': 'CA',
//     'zip': '12345',
// });

