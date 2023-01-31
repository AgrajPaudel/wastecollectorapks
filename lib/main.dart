import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path/path.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wastecollector/firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wastecollector/constants/routes.dart';
import 'package:wastecollector/haulers_views/collection_travel.dart';
import 'package:wastecollector/haulers_views/compensatory_collection.dart';
import 'package:wastecollector/haulers_views/dashboard.dart';
import 'package:wastecollector/haulers_views/inside_collection.dart';
import 'package:wastecollector/haulers_views/loginview_haulers.dart';
import 'package:wastecollector/haulers_views/registerview_haulers.dart';
import 'package:wastecollector/haulers_views/scheduled_collection.dart';
import 'package:wastecollector/haulers_views/unscheduled_collection_hauler.dart';
import 'package:wastecollector/haulers_views/unscheduled_collection_list.dart';
import 'package:wastecollector/haulers_views/unscheduled_inside_collection.dart';
import 'package:wastecollector/helpers/loading/loadingscreen.dart';
import 'package:wastecollector/services/auth/auth_service.dart';
import 'package:wastecollector/services/auth/bloc/auth_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_events.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';
import 'package:wastecollector/services/auth/firebase_auth_provider.dart';
import 'package:wastecollector/views/address_dropdown.dart';
import 'package:wastecollector/views/forgotpasswordview.dart';
import 'package:wastecollector/views/map.dart';
import 'package:wastecollector/views/notes/create_update_complainsview.dart';
import 'package:wastecollector/views/notes/dashboard.dart';
import 'package:wastecollector/views/registerview.dart';
import 'package:wastecollector/views/schedule.dart';
import 'package:wastecollector/views/unscheduled_collection_client.dart';
import 'views/loginview.dart';
import 'views/verifyemailview.dart';
import 'views/notes/complainsview.dart';

FlutterLocalNotificationsPlugin blip = FlutterLocalNotificationsPlugin();

class NotificationApi {
  static void resetter() {
    NotificationApi.showscheduledNotification(
        title: 'Waste Collection',
        body: 'Time to throw wastes',
        schedule: DateTime.now().add(Duration(seconds: 5)),
        payload: 'sadaa');
  }

  static final _notifications = FlutterLocalNotificationsPlugin();
  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.show(
        id,
        title,
        body,
        await _notificationdetails(),
        payload: payload,
      );

  static Future showscheduledNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime schedule,
  }) async {
    String a = await addressfinder();

    if (a == 'Kathmandu') {
      print('Kathmandu');
      notificationsender(
          title: title,
          body: body,
          payload: payload,
          schedule: schedule,
          days: [DateTime.sunday, DateTime.saturday]);
    } else if (a == 'Bhaktapur') {
      notificationsender(
          title: title,
          body: body,
          payload: payload,
          schedule: schedule,
          days: [DateTime.monday, DateTime.thursday]);
    } else if (a == 'Lalitpur') {
      notificationsender(
          title: title,
          body: body,
          payload: payload,
          schedule: schedule,
          days: [DateTime.monday, DateTime.thursday]);
    } else if (a == 'Tokha') {
      notificationsender(
          title: title,
          body: body,
          payload: payload,
          schedule: schedule,
          days: [DateTime.tuesday, DateTime.friday]);
    } else if (a == 'Budhanilkantha') {
      notificationsender(
          title: title,
          body: body,
          payload: payload,
          schedule: schedule,
          days: [DateTime.tuesday, DateTime.friday]);
    } else if (a == 'Tarakeshwar') {
      notificationsender(
          title: title,
          body: body,
          payload: payload,
          schedule: schedule,
          days: [DateTime.tuesday, DateTime.friday]);
    } else if (a == 'Gokareshwar') {
      notificationsender(
          title: title,
          body: body,
          payload: payload,
          schedule: schedule,
          days: [DateTime.monday, DateTime.thursday]);
    } else if (a == 'Suryabinayak') {
      notificationsender(
          title: title,
          body: body,
          payload: payload,
          schedule: schedule,
          days: [DateTime.monday, DateTime.thursday]);
    } else if (a == 'Chandragiri') {
      notificationsender(
          title: title,
          body: body,
          payload: payload,
          schedule: schedule,
          days: [DateTime.monday, DateTime.thursday]);
    } else if (a == 'Kageshwari-Manohara') {
      notificationsender(
          title: title,
          body: body,
          payload: payload,
          schedule: schedule,
          days: [DateTime.tuesday, DateTime.friday]);
    } else if (a == 'Thimi') {
      notificationsender(
          title: title,
          body: body,
          payload: payload,
          schedule: schedule,
          days: [DateTime.tuesday, DateTime.friday]);
    } else if (a == 'Mahalaxmi') {
      notificationsender(
          title: title,
          body: body,
          payload: payload,
          schedule: schedule,
          days: [DateTime.tuesday, DateTime.friday]);
    } else if (a == 'Nagarjun') {
      notificationsender(
          title: title,
          body: body,
          payload: payload,
          schedule: schedule,
          days: [DateTime.sunday, DateTime.saturday]);
    } else if (a == 'Kirtipur') {
      notificationsender(
          title: title,
          body: body,
          payload: payload,
          schedule: schedule,
          days: [DateTime.sunday, DateTime.saturday]);
    } else if (a == 'Godawari') {
      notificationsender(
          title: title,
          body: body,
          payload: payload,
          schedule: schedule,
          days: [DateTime.sunday, DateTime.saturday]);
    } else if (a == 'Changunarayan') {
      notificationsender(
          title: title,
          body: body,
          payload: payload,
          schedule: schedule,
          days: [DateTime.sunday, DateTime.saturday]);
    }
  }

  static Future notificationsender({
    required List<int> days,
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime schedule,
  }) async {
    print(days);
    _notifications.zonedSchedule(
      id,
      title,
      body,
      _scheduleweekly(
        Time(14, 15, 00),
        days: days,
      ),
      await _notificationdetails(),
      payload: payload,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static tz.TZDateTime _scheduleweekly(Time time, {required List<int> days}) {
    print(days);
    tz.TZDateTime _scheduledate = _scheduledaily(time);
    if (days.contains(_scheduledate.weekday + 1)) {
      print('change the db here');
    }
    print(_scheduledate.weekday);
    while (!days.contains(_scheduledate.weekday + 1)) {
      print('not contains');
      _scheduledate = _scheduledate.add(Duration(days: 1));
    }
    return _scheduledate;
  }

  static tz.TZDateTime _scheduledaily(Time time) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduleddate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
        time.hour, time.minute, time.second);
    print(now);
    print(scheduleddate);
    if (scheduleddate.isBefore(now)) {
      print('adsdsadsa');
      return scheduleddate.add((Duration(days: 1)));
    } else {
      return scheduleddate;
    }
  }

  static Future _notificationdetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id',
        'channel name',
        channelDescription: 'channel description',
        importance: Importance.max,
        icon: 'mipmap/ic_launcher', //add this else doesnt work
      ),
      iOS: DarwinNotificationDetails(),
    );
  }
}

Future __notificationdetails() async {
  return const NotificationDetails(
    android: AndroidNotificationDetails(
      'channel.id', //change this else default notificaiton sound.
      'channel name',
      channelDescription: 'channel description',
      importance: Importance.max,
      playSound: true,
      icon: 'mipmap/ic_launcher', //add this else doesnt work
      sound: RawResourceAndroidNotificationSound('r2d2'),
    ),
    iOS: DarwinNotificationDetails(),
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.

  print("Handling a background message: ${message.messageId}");
  blip.show(0, message.data['title'], message.data['body'],
      await __notificationdetails());

  print('Message data: ${message.data}');

  if (message.notification != null) {
    print('Message also contained a notification: ${message.data['body']}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); //always initialise time zones
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    blip.show(0, message.data['title'], message.data['body'],
        await __notificationdetails());

    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.data['body']}');
    }
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.green,
    ),
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FireBaseAuthProvider()),
      child: const Homepage(),
    ),
    routes: {
      Addressroute: (context) => const Addressui(),
      Maproute: (context) => const Mapui(),
      Createorupdateroute: (context) => const CreateUpdateNoteView(),
      Dashboardroute: (context) => const Appui(),
      Complainsroute: (context) => const Complainsui(),
      scheduleroute: (context) => const Schedule(),
      unscheduledclientroute: (context) =>
          const Clients_unScheduledCollection(),
    },
  ));
}

DateTime a = DateTime.now();

class Homepage extends StatelessWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(//consumer=builder+listener
        listener: (context, state) {
      if (state is! AuthStateRegistering && state.isLoading) {
        Loadingscreen()
            .show(context: context, text: state.text ?? 'Please wait.');
      } else {
        Loadingscreen().hide();
      }
    }, builder: (context, state) {
      if (state is AuthStateLoggedin) {
        print(a.toString());
        NotificationApi.showscheduledNotification(
            title: 'Waste Collection',
            body: 'Time to throw wastes',
            schedule: DateTime.now().add(Duration(seconds: 5)),
            payload: 'sadaa');
        return const Appui();
        //
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      } else if (state is AuthStateLoginpage) {
        return const LoginView();
      } else if (state is AuthStateRegistering) {
        return const RegisterView();
      } else if (state is AuthStateForgotPassword) {
        return const ForgotPasswordView();
      } else if (state is AuthstateHaulerside) {
        return const Haulers_RegisterView();
      } else if (state is AuthStateHaulerLogin) {
        return const Haulers_LoginView();
      } else if (state is AuthStateHaulerLoggedin) {
        return const Haulers_Dashboard();
      } else if (state is AuthStateClienttoHaulerSwitch) {
        return const Haulers_Dashboard();
      } else if (state is AuthStateHaulertoClientSwitch) {
        return const Appui();
      } else if (state is AuthStateHaulercollect) {
        return const Travel_collection();
      } else if (state is AuthStateHaulercollection) {
        return const Inside_collection();
      } else if (state is Authstatechooser) {
        return const Chooser();
      } else if (state is AuthStateScheduledCollection) {
        return const Haulers_ScheduledCollection();
      } else if (state is AuthStateUnScheduledCollection) {
        return const Haulers_unScheduledCollection();
      } else if (state is AuthStateUnscheduledCollectionList) {
        return const CreateUpdateRequestView();
      } else if (state is AuthStateInsideUnscheduledCollection) {
        return const UnscheduledInside_collection();
      } else if (state is AuthStateInsideCompensatoryCollection) {
        return const Compensatory_collection();
      } else if (state is AuthStateCompensatorychooser) {
        return const CompensatoryChooser();
      } else {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    });
  }
}

Future<String> addressfinder() async {
  String userid = AuthService.firebase().currentUser!.email;
  String addresss = 'a';
  var data;
  CollectionReference address_list =
      FirebaseFirestore.instance.collection('addresses');
  QuerySnapshot querySnapshot = await address_list.get();
  final l = querySnapshot.docs.length;
  for (int i = 0; i < l; i++) {
    data = querySnapshot.docs[i].data();
    if (userid == data['email'].toString()) {
      addresss = data['address'].toString();
    }
  }
  return addresss;
}



// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MaterialApp(
//     title: 'Flutter Demo',
//     theme: ThemeData(
//       primarySwatch: Colors.blue,
//     ),
//     home: const Homepage(),
//     routes: {
//       verifyemailroute: (context) => const VerifyEmailView(),
//       loginroute: (context) => const LoginView(),
//       registerroute: (context) => const RegisterView(),
//       dashboardroute: (context) => const Appui(),
//       Createorupdateroute: (context) => const CreateUpdateNoteView(),
//     },
//   ));
// }

// class Homepage extends StatelessWidget {
//   const Homepage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future: AuthService.firebase().initialize(),
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.done:
//               final user = AuthService.firebase().currentUser;
//               if (user != null) {
//                 if (user.isEmailVerified) {
//                   return const Appui();
//                 } else {
//                   return const VerifyEmailView();
//                 }
//               } else {
//                 return const LoginView();
//               }
//             default:
//               return const CircularProgressIndicator();
//           }
//         });
//   }
// }
