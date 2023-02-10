import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wastecollector/services/auth/auth_exceptions.dart';
import 'package:wastecollector/services/auth/bloc/auth_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_events.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';
import 'package:wastecollector/utilities/errordialog.dart';
import 'package:wastecollector/constants/routes.dart';
import 'package:wastecollector/utilities/loading_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
    String? eemail;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        //listens to events and allows displaying dialogs when operation is ongoing
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await ShowErrorDialog(context, 'User Not Found.');
          } else if (state.exception is WrongPasswordAuthException) {
            await ShowErrorDialog(context, 'Invalid Password.');
          } else if (state.exception is GeneralAuthException) {
            await ShowErrorDialog(context, 'Authentication Error.');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
          actions: [
            IconButton(
              onPressed: () async {
                context.read<AuthBloc>().add(const AuthEventHaulerLogin());
              },
              icon: const Icon(Icons.swap_horiz_sharp),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Please login using your credentials.'),
              TextField(
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter email/phone number',
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () async {
                  final email = _email.text;
                  eemail = _email.text;
                  final password = _password.text;
                  if (email.endsWith('@gmail.com')) {
                    context.read<AuthBloc>().add(
                          AuthEventLogIn(
                            email,
                            password, //*add extra credentials here plz.
                          ),
                        );
                  } else {
                    CollectionReference number_check =
                        FirebaseFirestore.instance.collection('old_accounts');
                    DocumentSnapshot? data =
                        await number_check.doc(email).get();
                    if (data.exists) {
                      context.read<AuthBloc>().add(
                            AuthEventHaulerLoggedin(
                              data['email'].toString(),
                              password, //*add extra credentials here plz.
                            ),
                          );
                    } else {
                      ShowErrorDialog(context, 'Wrong number');
                    }
                  }
                },
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  context
                      .read<AuthBloc>()
                      .add(AuthEventForgotPassword(email: eemail));
                },
                child: const Text('Forgot Password?'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventShouldRegister());
                },
                child: const Text('Not Registered Yet?'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
