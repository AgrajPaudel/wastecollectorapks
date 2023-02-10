import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wastecollector/constants/routes.dart';
import 'package:wastecollector/services/auth/auth_exceptions.dart';
import 'package:wastecollector/utilities/errordialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';
import 'package:wastecollector/services/auth/bloc/auth_events.dart';
import 'package:wastecollector/utilities/genericdialog.dart';

class Haulers_RegisterView extends StatefulWidget {
  const Haulers_RegisterView({Key? key}) : super(key: key);

  @override
  _Haulers_registerviewstate createState() => _Haulers_registerviewstate();
}

class _Haulers_registerviewstate extends State<Haulers_RegisterView> {
  late final TextEditingController _email;
  var data;
  late final TextEditingController _password;
  late final TextEditingController _key, _name;

  adddata(
      {required email,
      required employee_id,
      required password,
      required name}) {
    Map<String, dynamic> demodata = {
      'email': email,
      'employee id': employee_id,
      'password': password,
      'name': name,
    };
    CollectionReference register = FirebaseFirestore.instance
        .collection('list_of_employees(with accounts)');
    register.add(demodata);
    Map<String, dynamic> demodata2 = {
      'city': null,
      'latitude': null,
      'longitude': null,
      'price': null,
      'time': null,
      'unscheduled_request': null,
      'vehicle': null
    };
    CollectionReference unscheduled_register =
        FirebaseFirestore.instance.collection('unscheduled_collection');
    unscheduled_register.doc(email).set(demodata2);
  }

  previous_account_number_add(
      {required String employee_id,
      required String name,
      required String email}) {
    Map<String, dynamic> demodata = {
      'employee id': employee_id,
      'name': name,
    };
    CollectionReference register =
        FirebaseFirestore.instance.collection('old_accounts_of_haulers');
    register.doc(employee_id).set({
      'name': name,
      'email': email,
    });
  }

  Future<int> previous_account_number_check(
      {required String employee_id}) async {
    int count = -1;
    var data;
    CollectionReference list =
        FirebaseFirestore.instance.collection('old_accounts_of_haulers');
    QuerySnapshot querySnapshot = await list.get();
    final l = querySnapshot.docs.length;
    for (int i = 0; i < l; i++) {
      data = querySnapshot.docs[i].data();
      print(data['employee id'].toString());

      if (data['employee id'].toString() == employee_id.toString()) {
        print('${num} exists');
        count = i;
      } else {
        print('${num} doesnt exist');
      }
    }
    return count;
  }

  makeaccount({required String employee_id, required String name}) async {
    int count = -1;
    var data;
    bool namecheck = false;
    int ch = await previous_account_number_check(employee_id: employee_id);

    if (ch == -1) {
      CollectionReference list =
          FirebaseFirestore.instance.collection('list_of_employees');
      QuerySnapshot querySnapshot = await list.get(); //gets document for query
      final l = querySnapshot.docs.length; //used to find length of data
      for (int i = 0; i < l; i++) {
        data = querySnapshot.docs[i].data();
        print(data['employee id'].toString());
        //converts only the data at number field to string.
        if (data['employee id'].toString() == employee_id.toString()) {
          print('${num} exists');
          count = i;
          if (data['name'].toString() == name.toString()) {
            namecheck = true;
          }
        } else {
          print('${num} doesnt exist');
        }
      }

      if (count != -1) {
        if (namecheck == true) {
          querySnapshot.docs[count].reference.delete(); //deletes the data
          adddata(
              email: _email.text,
              employee_id: _key.text,
              password: _password.text,
              name: _name.text);
          previous_account_number_add(
              employee_id: _key.text, name: _name.text, email: _email.text);
          context
              .read<AuthBloc>()
              .add(AuthEventRegister(_email.text, _password.text));
          addressdb(email: _email.text, number: _key.text);
        } else {
          Showgenericdialog(
              context: context,
              title: "Error",
              content: 'Invalid name corresponding to number',
              optionBuilder: () => {
                    'OK': false,
                  });
        }
      } else {
        ShowErrorDialog(context, 'The number is not authorized');
      }
    } else {
      ShowErrorDialog(context, 'The number is already in use');
    }
  }

  addressdb({required String email, required String number}) {
    CollectionReference register =
        FirebaseFirestore.instance.collection('addresses');
    Map<String, dynamic> demodata = {
      'email': email,
      'address': null,
      'ward number': null,
      'latitude': null,
      'longitude': null,
      'state': null,
      'number': number,
    };
    CollectionReference complains =
        FirebaseFirestore.instance.collection('Complaints');
    Map<String, dynamic> null_complaints = {
      'email': email,
      'complain': null,
      'address': null,
      'ward': null,
      'date': null
    };
    register.add(demodata);
    complains.add(null_complaints);
  }

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    _key = TextEditingController();
    _name = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _name.dispose();
    _password.dispose();

    _key.dispose();
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
          title: const Text("Hauler Registration"),
          actions: [
            IconButton(
              onPressed: () async {
                context.read<AuthBloc>().add(const AuthEventShouldRegister());
              },
              icon: const Icon(Icons.swap_horiz_sharp),
            ),
          ],
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
              TextField(
                  controller: _name,
                  enableSuggestions: false,
                  autocorrect: false,
                  autofocus: true, //keyboard goes to field
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter name',
                  )),
              TextField(
                controller: _key,
                enableSuggestions: false,
                autocorrect: false,
                obscureText: false,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter employee id number',
                ),
              ),
              Center(
                child: Column(
                  children: [
                    //*add extra button for client and hauler
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () async {
                        final name = _name.text;
                        final email = _email.text;
                        final password = _password.text;
                        if (_key.text != null) {
                          print(_key.text);
                          makeaccount(employee_id: _key.text, name: _name.text);
                        }
                      },
                      child: const Text('Register'),
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .read<AuthBloc>()
                            .add(const AuthEventHaulerLogin());
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
