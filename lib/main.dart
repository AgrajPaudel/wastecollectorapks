import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wastecollector/constants/routes.dart';
import 'package:wastecollector/helpers/loading/loadingscreen.dart';
import 'package:wastecollector/services/auth/bloc/auth_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_events.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';
import 'package:wastecollector/services/auth/firebase_auth_provider.dart';
import 'package:wastecollector/views/forgotpasswordview.dart';
import 'package:wastecollector/views/notes/create_update_noteview.dart';
import 'package:wastecollector/views/registerview.dart';
import 'views/loginview.dart';
import 'views/verifyemailview.dart';
import 'views/notes/notesview.dart';
import 'package:wastecollector/services/auth/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
    ),
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FireBaseAuthProvider()),
      child: const Homepage(),
    ),
    routes: {
      Createorupdateroute: (context) => const CreateUpdateNoteView(),
    },
  ));
}

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
        return const Appui();
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      } else if (state is AuthStateRegistering) {
        return const RegisterView();
      } else if (state is AuthStateForgotPassword) {
        return const ForgotPasswordView();
      } else {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    });
  }
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
