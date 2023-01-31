import 'package:firebase_messaging/firebase_messaging.dart';

import 'auth_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_provider.dart';
import 'auth_exceptions.dart';
import 'package:wastecollector/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;

class FireBaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password, //*might need changes here too
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (error) {
      print(error.code);
      if (error.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (error.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else if (error.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else {
        throw GeneralAuthException();
      }
    } catch (_) {
      throw GeneralAuthException();
    }
  }

  @override
  Future<AuthUser> createUserwithphone({
    required String phone_number,
    required String password,
  }) async {
    try {
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (error) {
      print(error.code);
      if (error.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (error.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else if (error.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else {
        throw GeneralAuthException();
      }
    } catch (_) {
      throw GeneralAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (error) {
      print(error.code);
      if (error.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (error.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else {
        throw GeneralAuthException();
      }
    } catch (_) {
      throw GeneralAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    // NotificationSettings settings = await firebaseMessaging.requestPermission(
    //     alert: true,
    //     announcement: false,
    //     badge: true,
    //     carPlay: false,
    //     criticalAlert: false,
    //     provisional: false,
    //     sound: true);
    // print('permission=' + settings.authorizationStatus.toString());
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   if (message.notification != null) {
    //     print('message came!');
    //   }
    // });
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: toEmail);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'firebase_auth/invalid-email':
          throw InvalidEmailAuthException();
        case 'firebase-auth/user-not-found':
          throw UserNotFoundAuthException();
        default:
          throw GeneralAuthException();
      }
    } catch (_) {
      //_ is variable itself for dart.
      throw GeneralAuthException();
    }
  }
}

// //bg message handler
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();

//   print("Handling a background message: ${message.messageId}");
// }
