import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:wastecollector/services/auth/auth_service.dart';
import 'package:wastecollector/utilities/errordialog.dart';
import 'package:wastecollector/utilities/genericdialog.dart';

snapshotmaker(DocumentSnapshot dataa) async {
  data = dataa;
}

String? location;
LatLng? latlng_address;
String get emailid => AuthService.firebase().currentUser!.email;
CollectionReference address =
    FirebaseFirestore.instance.collection('addresses');
CollectionReference unscheduled_collection =
    FirebaseFirestore.instance.collection('unscheduled_collection');
DocumentSnapshot? data;

class Clients_unScheduledCollection extends StatefulWidget {
  const Clients_unScheduledCollection({Key? key}) : super(key: key);

  @override
  State<Clients_unScheduledCollection> createState() =>
      Clients_unScheduledCollectionviewState();
}

class Clients_unScheduledCollectionviewState
    extends State<Clients_unScheduledCollection> {
  String? mtoken = '';
  String? number;
  String _selectedVehicle = '';
  int _price = 0;

  void _incrementPrice() {
    setState(() {
      _price = _price + 10;
    });
  }

  void _decrementPrice() {
    setState(() {
      if (_price > 10) _price = _price - 10;
    });
  }

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
    return Scaffold(
        appBar: AppBar(
          title: const Text("Unscheduled Collection"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Current request:',
                style: const TextStyle(fontSize: 20),
              ),
              data!['unscheduled_request'] == 'requested'
                  ? Column(
                      children: [
                        ListTile(
                          subtitle: Text('Price: ' +
                              data!['price'].toString() +
                              '\n' +
                              'Vehicle: ' +
                              data!['vehicle'] +
                              '\n' +
                              'Time: ' +
                              data!['time']),
                          onTap: () {},
                        ),
                        TextButton(
                            onPressed: () async {
                              unscheduled_collection
                                  .doc(emailid)
                                  .update({'unscheduled_request': null});
                              Showgenericdialog(
                                  context: context,
                                  title: 'Request deleted',
                                  content:
                                      'Your request has been deleted. Please reload the page.',
                                  optionBuilder: () => {'OK': null});
                            },
                            child: const Text('Cancel request')),
                      ],
                    )
                  : Text('none'),
              Container(
                height: 10,
                width: 10,
              ),
              Text(
                'New Request:',
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                'Selected: $_selectedVehicle',
                style: const TextStyle(fontSize: 20),
              ),
              Center(
                  child: Column(children: [
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedVehicle = 'Mini-Truck';
                      _price = 300;
                    });
                  },
                  child: const Text('Mini-Truck'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedVehicle = 'Dumptruck';
                      _price = 600;
                    });
                  },
                  child: const Text('Dumptruck'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedVehicle = 'Cart';
                      _price = 100;
                    });
                  },
                  child: const Text('Cart'),
                ),
                SizedBox(height: 20),
                Text(
                  'Price: \Rs$_price',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _incrementPrice,
                  child: Icon(Icons.add),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _decrementPrice,
                  child: Icon(Icons.remove),
                ),
                TextButton(
                    onPressed: () async {
                      if (_price != 0 || _selectedVehicle != '') {
                        var data;
                        QuerySnapshot firstquery = await address.get();
                        for (int i = 0; i < firstquery.docs.length; i++) {
                          data = firstquery.docs[i].data();
                          if (data['email'] == emailid) {
                            number = data['number'];
                            latlng_address =
                                LatLng(data['latitude'], data['longitude']);
                            location = data['address'];
                          }
                        }
                        if (location == null) {
                          ShowErrorDialog(
                              context, 'Please choose your city first');
                        } else if (latlng_address == null) {
                          ShowErrorDialog(context,
                              'Please Enter Your Address on map first');
                        }
                        if (data['unscheduled_request'] != null &&
                            data['unscheduled_request'] != 'requested') {
                          ShowErrorDialog(context,
                              'You cannot request for new collectoin when a collection is undergoing.');
                        } else {
                          unscheduled_collection.doc(emailid).set({
                            'unscheduled_request': 'requested',
                            'city': location,
                            'latitude': latlng_address!.latitude,
                            'longitude': latlng_address!.longitude,
                            'price': _price,
                            'number': number,
                            'vehicle': _selectedVehicle,
                            'time': DateTime.now().toString(),
                            'last hauler': data['last hauler'],
                          });
                          Showgenericdialog(
                              context: context,
                              title: 'Request Successful',
                              content:
                                  'Your request has been successfully sent.',
                              optionBuilder: () => {
                                    'OK': null,
                                  });
                        }
                      } else {
                        ShowErrorDialog(context,
                            'Please set appropriate price or choose correct vehicle.');
                      }
                    },
                    child: const Text('Confirm Request'))
              ]))
            ],
          ),
        ));
  }
}
