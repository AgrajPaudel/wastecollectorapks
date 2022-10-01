import 'package:flutter/material.dart';
import 'package:wastecollector/constants/routes.dart';
import '../services/auth/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';
import 'package:wastecollector/services/auth/bloc/auth_events.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email View'),
      ),
      body: Column(children: [
        const Text('Verification email will be sent to you.'),
        const Text('Please verify from your email.....................'),
        TextButton(
            onPressed: () {
              context
                  .read<AuthBloc>()
                  .add(const AuthEventSendEmailVerification());
            },
            child: const Text('Send Email Verification')),
        TextButton(
            onPressed: () async {
              context.read<AuthBloc>().add(const AuthEventLogOut());
            },
            child: const Text('Reload.'))
      ]),
    );
  }
}

// class VerifyEmailView extends StatefulWidget {
//   const VerifyEmailView({Key? key}) : super(key: key);

//   @override
//   State<VerifyEmailView> createState() => _VerifyEmailViewState();
// }

// class _VerifyEmailViewState extends State<VerifyEmailView> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Verify Email View'),
//       ),
//       body: Column(children: [
//         const Text('Verification email will be sent to you.'),
//         const Text('Please verify from your email.....................'),
//         TextButton(
//             onPressed: () async {
//               await AuthService.firebase().sendEmailVerification();
//             },
//             child: const Text('Send Email Verification')),
//         TextButton(
//             onPressed: () async {
//               await AuthService.firebase().logOut();
//               Navigator.of(context)
//                   .pushNamedAndRemoveUntil(registerroute, (route) => false);
//             },
//             child: const Text('Reload'))
//       ]),
//     );
//   }
// }

