import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wastecollector/constants/routes.dart';
import 'package:wastecollector/services/auth/auth_exceptions.dart';
import 'package:wastecollector/utilities/errordialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';
import 'package:wastecollector/services/auth/bloc/auth_events.dart';

class Haulers_LoginView extends StatefulWidget {
  const Haulers_LoginView({Key? key}) : super(key: key);

  @override
  _Haulers_loginviewstate createState() => _Haulers_loginviewstate();
}

class _Haulers_loginviewstate extends State<Haulers_LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
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
            title: const Text("Hauler Login"),
            actions: [
              IconButton(
                onPressed: () async {
                  context.read<AuthBloc>().add(const AuthEventLoginpage());
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
                      hintText: 'Enter email/employee',
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
                    final password = _password.text;
                    if (email.endsWith('@gmail.com')) {
                      int count = await check(email: _email.text);
                      if (count == 1) {
                        context.read<AuthBloc>().add(
                              AuthEventHaulerLoggedin(
                                email,
                                password, //*add extra credentials here plz.
                              ),
                            );
                      } else if (count == -1) {
                        ShowErrorDialog(context,
                            'Clients can only log in from client portals.');
                      }
                    } else {
                      CollectionReference number_check = FirebaseFirestore
                          .instance
                          .collection('old_accounts_of_haulers');
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
                        .add(AuthEventForgotPassword(email: _email.text));
                  },
                  child: const Text('Forgot Password?'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventHaulerview());
                  },
                  child: const Text('Not Registered Yet?'),
                )
              ],
            ),
          )),
    );
  }
}

Future<int> check({required String email}) async {
  CollectionReference list =
      FirebaseFirestore.instance.collection('list_of_employees(with accounts)');
  int count = -1;
  var data;
  QuerySnapshot querySnapshot = await list.get();
  final l = querySnapshot.docs.length;
  for (int i = 0; i < l; i++) {
    data = querySnapshot.docs[i].data();
    print(data['email'].toString());

    if (data['email'].toString() == email.toString()) {
      print('${email} exists');
      count = 1;
    } else {
      print('${email} doesnt exist');
    }
  }
  return count;
}
