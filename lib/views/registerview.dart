import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wastecollector/services/auth/auth_exceptions.dart';
import 'package:wastecollector/utilities/errordialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_bloc.dart';
import 'package:wastecollector/services/auth/bloc/auth_state.dart';
import 'package:wastecollector/services/auth/bloc/auth_events.dart';
import 'package:wastecollector/utilities/genericdialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  var data;
  late final TextEditingController _password;
  late final TextEditingController _number;
  late final TextEditingController _name;

  adddata({required email, required number, required password, required name}) {
    Map<String, dynamic> demodata = {
      'email': email,
      'number': number,
      'password': password,
      'name': name,
    };
    Map<String, dynamic> demodata2 = {
      'city': null,
      'latitude': null,
      'longitude': null,
      'price': null,
      'time': null,
      'unscheduled_request': null,
      'vehicle': null
    };

    CollectionReference register =
        FirebaseFirestore.instance.collection('numbers');
    CollectionReference unscheduled_register =
        FirebaseFirestore.instance.collection('unscheduled_collection');
    unscheduled_register.doc(email).set(demodata2);
    register.add(demodata);
  }

  previous_account_number_add(
      {required String num, required String name, required String email}) {
    CollectionReference register =
        FirebaseFirestore.instance.collection('old_accounts');
    register.doc(num).set({
      'name': name,
      'email': email,
    });
  }

  Future<int> previous_account_number_check({required String num}) async {
    int count = -1;
    var data;
    CollectionReference list =
        FirebaseFirestore.instance.collection('old_accounts');
    QuerySnapshot querySnapshot = await list.get();
    final l = querySnapshot.docs.length;
    for (int i = 0; i < l; i++) {
      data = querySnapshot.docs[i].data();
      print(data['number'].toString());

      if (data['number'].toString() == num.toString()) {
        print('${num} exists');
        count = i;
      } else {
        print('${num} doesnt exist');
      }
    }
    return count;
  }

  makeaccount({required String num, required String name}) async {
    int count = -1;
    var data;
    int ch = await previous_account_number_check(num: num);
    bool namecheck = false;

    if (ch == -1) {
      CollectionReference list = FirebaseFirestore.instance.collection('list');
      QuerySnapshot querySnapshot = await list.get(); //gets document for query
      final l = querySnapshot.docs.length; //used to find length of data
      for (int i = 0; i < l; i++) {
        data = querySnapshot.docs[i].data();
        print(data['number'].toString());
        //converts only the data at number field to string.
        if (data['number'].toString() == num.toString()) {
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
              number: _number.text,
              password: _password.text,
              name: _name.text);
          previous_account_number_add(
              num: _number.text, name: _name.text, email: _email.text);
          context
              .read<AuthBloc>()
              .add(AuthEventRegister(_email.text, _password.text));
          addressdb(email: _email.text, number: _number.text);
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
    _number = TextEditingController();
    _name = TextEditingController();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _name.dispose();
    _password.dispose();
    _number.dispose();
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
          title: const Text("Registration"),
          actions: [
            IconButton(
              onPressed: () async {
                context.read<AuthBloc>().add(const AuthEventHaulerview());
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
                controller: _number,
                enableSuggestions: false,
                autocorrect: false,
                obscureText: false,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter phone number',
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
                        if (_number.text != null) {
                          print(_number.text);

                          makeaccount(num: _number.text, name: _name.text);
                        }
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
