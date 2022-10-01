import 'package:flutter/material.dart';
import 'package:wastecollector/services/auth/auth_exceptions.dart';
import 'package:wastecollector/utilities/errordialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';
import 'package:wastecollector/services/auth/bloc/auth_events.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        //exception handling.
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await ShowErrorDialog(context, 'Weak Password.');
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await ShowErrorDialog(context, 'Email already in use.');
          } else if (state.exception is InvalidEmailAuthException) {
            await ShowErrorDialog(context, 'Invalid Email.');
          } else if (state.exception is GeneralAuthException) {
            await ShowErrorDialog(context, 'Failed to register.');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Register View"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Register new account using correct credentials.'),
              TextField(
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  autofocus: true, //keyboard goes to field
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter email',
                  )),
              TextField(
                controller: _password,
                enableSuggestions: false,
                autocorrect: false,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Enter password',
                ),
              ),
              Center(
                child: Column(
                  children: [
                    //*add extra button for client and hauler
                    TextButton(
                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;
                        context
                            .read<AuthBloc>()
                            .add(AuthEventRegister(email, password));
                      },
                      child: const Text('Register'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(const AuthEventLogOut());
                      },
                      child: const Text('Already registered?'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
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

