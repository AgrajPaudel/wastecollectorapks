import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wastecollector/services/auth/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastecollector/services/auth/bloc/auth_events.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';

void savetoken(String? token, String emailid) async {
  await FirebaseFirestore.instance
      .collection('List_of_tokens')
      .doc(emailid)
      .set({
    'token': token,
  });
}

void requestpermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    sound: true,
    provisional: false,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('authorization status=authorized');
  } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print('authorization status=denied');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('authorization status=provisional');
  } else {
    print('sth else');
  }
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    on<AuthEventShouldRegister>((event, emit) async {
      emit(const AuthStateRegistering(exception: null, isLoading: false));
    });

    //forgot password
    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: false,
      ));
      final email = event.email;
      if (email == null) {
        return; //user just goes to forgot password.
      }
      //user wants to send forgot password email.
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: true, //displays overlay.
      ));

      bool didSendEmail;
      Exception? exception;
      try {
        await provider.sendPasswordReset(toEmail: email);
        didSendEmail = true;
        exception = null; //all good path.
      } on Exception catch (e) {
        didSendEmail = false;
        exception = e; //not so good path.
      }

      //using values from above.
      emit(AuthStateForgotPassword(
        exception: exception,
        hasSentEmail: didSendEmail,
        isLoading: false, //displays overlay.
      ));
    });

    //function to send email verification.
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state); //not changing state of application, no change in view.
    });

    on<AuthEventRegister>((event, emit) async {
      //function to register user.
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(
          email: email,
          password: password,
        ); //creates new user.
        await provider.sendEmailVerification(); //sends email.
        emit(const AuthStateNeedsVerification(
            isloading:
                false)); //sends to verify email view,isloading=false as already loaded
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    });

    on<AuthEventInitialize>((event, emit) async {
      //initialization
      //function to return current user
      await provider.initialize();
      final user = provider.currentUser; //finds current user
      print('initialize');
      if (user == null) {
        emit(const AuthStateLoggedOut(
            isLoading: false, exception: null, client: true));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification(isloading: false));
      } else {
        emit(AuthStateLoggedin(
          user: user,
          isLoading: false,
        )); //not const

      }
    });

    on<AuthEventLogIn>((event, emit) async {
      //for login
      emit(const AuthStateLoggedOut(
        isLoading: true,
        exception: null,
        client: true,
        text: 'Please wait',
      ));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);
        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(
              isLoading: false, exception: null, client: true));
          emit(const AuthStateNeedsVerification(isloading: false));
        } else {
          emit(const AuthStateLoggedOut(
              isLoading: false, exception: null, client: true));
          String? mtoken;
          await FirebaseMessaging.instance.getToken().then((token) {
            mtoken = token;
          });
          savetoken(mtoken, event.email);
          emit(AuthStateLoggedin(user: user, isLoading: false));
        }
      } on Exception catch (e) {
        //to catch type exception.
        emit(AuthStateLoggedOut(exception: e, isLoading: false, client: true));
      }
    });

    on<AuthEventLogOut>((event, emit) async {
      try {
        String? emailid = provider.currentUser!.email;
        await provider.logOut();
        emit(const AuthStateLoggedOut(
            isLoading: false, exception: null, client: true));
        await FirebaseFirestore.instance
            .collection('List_of_tokens')
            .doc(emailid)
            .update({'token': null});
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(isLoading: false, exception: e, client: true));
      }
    });

    //hauler side from here on
    on<AuthEventHaulerview>((event, emit) async {
      try {
        await provider.logOut();
      } on Exception catch (e) {
        emit(
            AuthstateHaulerside(isLoading: false, exception: e, client: false));
      }
    });

    on<AuthEventLoginpage>((event, emit) async {
      try {
        emit(const AuthStateLoginpage(isloading: false));
      } on Exception catch (e) {
        emit(
            AuthstateHaulerside(isLoading: false, exception: e, client: false));
      }
    });

    on<AuthEventHaulerLogin>((event, emit) async {
      try {
        await provider.logOut();
      } on Exception catch (e) {
        emit(const AuthStateHaulerLogin(isloading: false));
      }
    });

    on<AuthEventHaulerLoggedin>((event, emit) async {
      //for login
      emit(const AuthStateLoggedOut(
        isLoading: true,
        exception: null,
        client: true,
        text: 'Please wait',
      ));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);
        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(
              isLoading: false, exception: null, client: true));
          emit(const AuthStateNeedsVerification(isloading: false));
        } else {
          emit(const AuthStateLoggedOut(
              isLoading: false, exception: null, client: true));
          requestpermission();
          String? mtoken;
          await FirebaseMessaging.instance.getToken().then((token) {
            mtoken = token;
          });
          savetoken(mtoken, event.email);
          emit(AuthStateHaulerLoggedin(user: user, isLoading: false));
        }
      } on Exception catch (e) {
        //to catch type exception.
        emit(AuthStateLoggedOut(exception: e, isLoading: false, client: true));
      }
    });

    on<AuthEventClienttoHaulerSwitch>((event, emit) async {
      try {
        emit(const AuthStateClienttoHaulerSwitch(isloading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(isLoading: false, exception: e, client: true));
      }
    });

    on<AuthEventHaulerBack>((event, emit) async {
      try {
        emit(const AuthStateClienttoHaulerSwitch(isloading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(isLoading: false, exception: e, client: true));
      }
    });

    on<AuthEventHaulerCollect>((event, emit) async {
      try {
        emit(const AuthStateHaulercollect(isloading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(isLoading: false, exception: e, client: true));
      }
    });

    on<AuthEventHaulertoClientSwitch>((event, emit) async {
      try {
        emit(const AuthStateHaulertoClientSwitch(isloading: false));
      } on Exception {
        emit(const AuthStateHaulerLogin(isloading: false));
      }
    });

    on<AuthEventHaulerCollection>((event, emit) async {
      try {
        emit(const AuthStateHaulercollection(isloading: false));
      } on Exception {
        emit(const AuthStateHaulerLogin(isloading: false));
      }
    });

    on<Autheventchooser>((event, emit) async {
      try {
        emit(const Authstatechooser(isloading: false));
      } on Exception {
        emit(const AuthStateHaulerLogin(isloading: false));
      }
    });

    on<AuthEventScheduledCollection>((event, emit) async {
      try {
        emit(const AuthStateScheduledCollection(isloading: false));
      } on Exception {
        emit(const AuthStateHaulerLogin(isloading: false));
      }
    });

    on<AuthEventUnScheduledCollection>((event, emit) async {
      try {
        emit(const AuthStateUnScheduledCollection(isloading: false));
      } on Exception {
        emit(const AuthStateHaulerLogin(isloading: false));
      }
    });

    on<AuthEventUnscheduledCollectionList>((event, emit) async {
      try {
        emit(const AuthStateUnscheduledCollectionList(isloading: false));
      } on Exception {
        emit(const AuthStateHaulerLogin(isloading: false));
      }
    });

    on<AuthEventInsideUnscheduledCollection>((event, emit) async {
      try {
        emit(const AuthStateInsideUnscheduledCollection(isloading: false));
      } on Exception {
        emit(const AuthStateHaulerLogin(isloading: false));
      }
    });

    on<AuthEventInsideCompensatoryCollection>((event, emit) async {
      try {
        emit(const AuthStateInsideCompensatoryCollection(isloading: false));
      } on Exception {
        emit(const AuthStateHaulerLogin(isloading: false));
      }
    });

    on<AuthEventCompensatoryChooser>((event, emit) async {
      try {
        emit(const AuthStateCompensatorychooser(isloading: false));
      } on Exception {
        emit(const AuthStateHaulerLogin(isloading: false));
      }
    });
  } //SUPER NEEDED FOR BLOC SUPERCLASS, authstateloading is initial state.
}
