import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart';
import 'package:wastecollector/constants/routes.dart';
import 'package:wastecollector/haulers_views/inside_collection.dart';
import 'package:wastecollector/services/auth/bloc/auth_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_events.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';

String x = '';

class Listoflocations {
  final String area;
  final LatLng location;
  Listoflocations({required this.area, required this.location});
}

List<TextButton> areaputter(
    {required String x, required BuildContext context, required int a}) {
  final cities = <Listoflocations>[];
  final buttons = <TextButton>[];
  final buttons2 = <TextButton>[];
  if (x == 'Sunday') {
    int i = 0;
    cities.add(
        Listoflocations(area: 'Kathmandu', location: LatLng(27.7172, 85.3240)));

    for (i = 0; i < cities.length; i++) {
      final LatLng location = cities[i].location;
      final String place = cities[i].area.toString();
      buttons.add(TextButton(
          onPressed: () async {
            CollectionReference map_address =
                FirebaseFirestore.instance.collection('addresses');
            QuerySnapshot querySnapshot = await map_address.get();
            holder(
                place: place, latLng: location, querySnapshot: querySnapshot);
            context.read<AuthBloc>().add(const AuthEventHaulerCollection());
          },
          child: Text(cities[i].area.toString())));
    }
    int j = cities.length;
    cities.add(
        Listoflocations(area: 'Nagarjun', location: LatLng(27.7325, 85.2567)));
    cities.add(
        Listoflocations(area: 'Kirtipur', location: LatLng(27.6630, 85.2774)));
    cities.add(Listoflocations(
        area: 'Changunarayan', location: LatLng(27.7029, 85.4307)));
    cities.add(
        Listoflocations(area: 'Godawari', location: LatLng(27.5925, 85.2922)));
    for (j; j < cities.length; j++) {
      final LatLng location = cities[j].location;
      final String place = cities[j].area.toString();
      buttons2.add(TextButton(
          onPressed: () async {
            CollectionReference map_address =
                FirebaseFirestore.instance.collection('addresses');
            QuerySnapshot querySnapshot = await map_address.get();
            holder(
                place: place, latLng: location, querySnapshot: querySnapshot);
            context.read<AuthBloc>().add(const AuthEventHaulerCollection());
          },
          child: Text(cities[j].area.toString())));
    }
  } else if (x == 'Monday') {
    int i = 0;
    cities.add(
        Listoflocations(area: 'Bhaktapur', location: LatLng(27.6710, 85.4298)));
    cities.add(
        Listoflocations(area: 'Lalitpur', location: LatLng(27.6588, 85.3247)));
    for (i = 0; i < cities.length; i++) {
      final LatLng location = cities[i].location;
      final String place = cities[i].area.toString();
      buttons.add(TextButton(
          onPressed: () async {
            CollectionReference map_address =
                FirebaseFirestore.instance.collection('addresses');
            QuerySnapshot querySnapshot = await map_address.get();
            holder(
                place: place, latLng: location, querySnapshot: querySnapshot);
            context.read<AuthBloc>().add(const AuthEventHaulerCollection());
          },
          child: Text(cities[i].area.toString())));
    }
    int j = cities.length;
    cities.add(Listoflocations(
        area: 'Gokarneshwar', location: LatLng(27.7668, 85.4066)));
    cities.add(Listoflocations(
        area: 'Suryabinayak', location: LatLng(27.6451, 85.4427)));
    cities.add(Listoflocations(
        area: 'Chandragiri', location: LatLng(27.6903, 85.2205)));
    for (j; j < cities.length; j++) {
      final LatLng location = cities[j].location;
      final String place = cities[j].area.toString();
      buttons2.add(TextButton(
          onPressed: () async {
            CollectionReference map_address =
                FirebaseFirestore.instance.collection('addresses');
            QuerySnapshot querySnapshot = await map_address.get();
            holder(
                place: place, latLng: location, querySnapshot: querySnapshot);
            context.read<AuthBloc>().add(const AuthEventHaulerCollection());
          },
          child: Text(cities[j].area.toString())));
    }
  } else if (x == 'Tuesday') {
    int i = 0;
    cities.add(
        Listoflocations(area: 'Tokha', location: LatLng(27.7701, 85.3293)));
    cities.add(Listoflocations(
        area: 'Budhanilkantha', location: LatLng(27.7654, 85.3653)));
    cities.add(Listoflocations(
        area: 'Tarakeshwar', location: LatLng(27.7867, 85.3033)));
    for (i = 0; i < cities.length; i++) {
      final LatLng location = cities[i].location;
      final String place = cities[i].area.toString();
      buttons.add(TextButton(
          onPressed: () async {
            CollectionReference map_address =
                FirebaseFirestore.instance.collection('addresses');
            QuerySnapshot querySnapshot = await map_address.get();
            holder(
                place: place, latLng: location, querySnapshot: querySnapshot);
            context.read<AuthBloc>().add(const AuthEventHaulerCollection());
          },
          child: Text(cities[i].area.toString())));
    }
    int j = cities.length;
    cities.add(Listoflocations(
        area: 'Kageshwari-Manohara', location: LatLng(27.7260, 85.4118)));
    cities.add(
        Listoflocations(area: 'Thimi', location: LatLng(27.6837, 85.3898)));
    cities.add(
        Listoflocations(area: 'Mahalaxmi', location: LatLng(27.6427, 85.3705)));
    for (j; j < cities.length; j++) {
      final LatLng location = cities[j].location;
      final String place = cities[j].area.toString();
      buttons2.add(TextButton(
          onPressed: () async {
            CollectionReference map_address =
                FirebaseFirestore.instance.collection('addresses');
            QuerySnapshot querySnapshot = await map_address.get();
            holder(
                place: place, latLng: location, querySnapshot: querySnapshot);
            context.read<AuthBloc>().add(const AuthEventHaulerCollection());
          },
          child: Text(cities[j].area.toString())));
    }
  } else if (x == 'Thursday') {
    int i = 0;
    cities.add(Listoflocations(
        area: 'Gokarneshwar', location: LatLng(27.7668, 85.4066)));
    cities.add(Listoflocations(
        area: 'Suryabinayak', location: LatLng(27.6451, 85.4427)));
    cities.add(Listoflocations(
        area: 'Chandragiri', location: LatLng(27.6903, 85.2205)));
    for (i = 0; i < cities.length; i++) {
      final LatLng location = cities[i].location;
      final String place = cities[i].area.toString();
      buttons.add(TextButton(
          onPressed: () async {
            CollectionReference map_address =
                FirebaseFirestore.instance.collection('addresses');
            QuerySnapshot querySnapshot = await map_address.get();
            holder(
                place: place, latLng: location, querySnapshot: querySnapshot);
            context.read<AuthBloc>().add(const AuthEventHaulerCollection());
          },
          child: Text(cities[i].area.toString())));
    }
    int j = cities.length;
    cities.add(
        Listoflocations(area: 'Bhaktapur', location: LatLng(27.6710, 85.4298)));
    cities.add(
        Listoflocations(area: 'Lalitpur', location: LatLng(27.6588, 85.3247)));
    for (j; j < cities.length; j++) {
      final LatLng location = cities[j].location;
      final String place = cities[j].area.toString();
      buttons2.add(TextButton(
          onPressed: () async {
            CollectionReference map_address =
                FirebaseFirestore.instance.collection('addresses');
            QuerySnapshot querySnapshot = await map_address.get();
            holder(
                place: place, latLng: location, querySnapshot: querySnapshot);
            context.read<AuthBloc>().add(const AuthEventHaulerCollection());
          },
          child: Text(cities[j].area.toString())));
    }
  } else if (x == 'Friday') {
    int i = 0;
    cities.add(Listoflocations(
        area: 'Kageshwari-Manohara', location: LatLng(27.7260, 85.4118)));
    cities.add(
        Listoflocations(area: 'Thimi', location: LatLng(27.6837, 85.3898)));
    cities.add(
        Listoflocations(area: 'Mahalaxmi', location: LatLng(27.6427, 85.3705)));
    for (i = 0; i < cities.length; i++) {
      final LatLng location = cities[i].location;
      final String place = cities[i].area.toString();
      buttons.add(TextButton(
          onPressed: () async {
            CollectionReference map_address =
                FirebaseFirestore.instance.collection('addresses');
            QuerySnapshot querySnapshot = await map_address.get();
            holder(
                place: place, latLng: location, querySnapshot: querySnapshot);
            context.read<AuthBloc>().add(const AuthEventHaulerCollection());
          },
          child: Text(cities[i].area.toString())));
    }
    int j = cities.length;
    cities.add(
        Listoflocations(area: 'Tokha', location: LatLng(27.7701, 85.3293)));
    cities.add(Listoflocations(
        area: 'Budhanilkantha', location: LatLng(27.7654, 85.3653)));
    cities.add(Listoflocations(
        area: 'Tarakeshwar', location: LatLng(27.7867, 85.3033)));
    for (j; j < cities.length; j++) {
      final LatLng location = cities[j].location;
      final String place = cities[j].area.toString();
      buttons2.add(TextButton(
          onPressed: () async {
            CollectionReference map_address =
                FirebaseFirestore.instance.collection('addresses');
            QuerySnapshot querySnapshot = await map_address.get();
            holder(
                place: place, latLng: location, querySnapshot: querySnapshot);
            context.read<AuthBloc>().add(const AuthEventHaulerCollection());
          },
          child: Text(cities[j].area.toString())));
    }
  } else if (x == 'Saturday') {
    int i = 0;
    cities.add(
        Listoflocations(area: 'Nagarjun', location: LatLng(27.7325, 85.2567)));
    cities.add(
        Listoflocations(area: 'Kirtipur', location: LatLng(27.6630, 85.2774)));
    cities.add(Listoflocations(
        area: 'Changunarayan', location: LatLng(27.7029, 85.4307)));
    cities.add(
        Listoflocations(area: 'Godawari', location: LatLng(27.5925, 85.2922)));
    for (i = 0; i < cities.length; i++) {
      final LatLng location = cities[i].location;
      final String place = cities[i].area.toString();
      buttons.add(TextButton(
          onPressed: () async {
            CollectionReference map_address =
                FirebaseFirestore.instance.collection('addresses');
            QuerySnapshot querySnapshot = await map_address.get();
            holder(
                place: place, latLng: location, querySnapshot: querySnapshot);
            context.read<AuthBloc>().add(const AuthEventHaulerCollection());
          },
          child: Text(cities[i].area.toString())));
    }
    int j = cities.length;
    cities.add(
        Listoflocations(area: 'Kathmandu', location: LatLng(27.7172, 85.3240)));
    for (j; j < cities.length; j++) {
      final LatLng location = cities[j].location;
      final String place = cities[j].area.toString();
      buttons2.add(TextButton(
          onPressed: () async {
            CollectionReference map_address =
                FirebaseFirestore.instance.collection('addresses');
            QuerySnapshot querySnapshot = await map_address.get();
            holder(
                place: place, latLng: location, querySnapshot: querySnapshot);
            context.read<AuthBloc>().add(const AuthEventHaulerCollection());
          },
          child: Text(cities[j].area.toString())));
    }
  }
  if (a == 1) {
    return buttons;
  } else {
    return buttons2;
  }
}

class Haulers_ScheduledCollection extends StatefulWidget {
  const Haulers_ScheduledCollection({Key? key}) : super(key: key);

  @override
  State<Haulers_ScheduledCollection> createState() =>
      Haulers_ScheduledCollectionviewState();
}

class Haulers_ScheduledCollectionviewState
    extends State<Haulers_ScheduledCollection> {
  @override
  void initState() {
    x = DateFormat('EEEE').format(DateTime.now());
    print(x);
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
          title: const Text("Scheduled Collection"),
          actions: [
            IconButton(
                onPressed: () async {
                  context.read<AuthBloc>().add(const AuthEventHaulerBack());
                },
                icon: const Icon(Icons.home))
          ],
        ),
        body: Column(children: [
          const Text('Degradable Waste Collection'),
          Wrap(
            children: areaputter(x: x, context: context, a: 1),
            spacing: 9,
            runSpacing: 10,
          ),
          const Text('Non-Degradable Waste Collection'),
          Wrap(
            children: areaputter(x: x, context: context, a: 2),
          ),
        ]),
      ),
    );
  }
}
