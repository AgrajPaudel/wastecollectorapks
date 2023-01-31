import 'package:flutter/material.dart';

class Schedule extends StatefulWidget {
  const Schedule({Key? key}) : super(key: key);

  @override
  State<Schedule> createState() => ScheduleviewState();
}

class ScheduleviewState extends State<Schedule> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: [
            const DataColumn(label: Text('Days')),
            const DataColumn(label: Text('Renewable\nwaste\ncollection')),
            const DataColumn(label: Text('Non-renewable\nwaste\ncollection')),
          ],
          rows: [
            const DataRow(cells: [
              DataCell(Text('Sunday')),
              DataCell(Text('Kathmandu')),
              DataCell(Text('Kirtipur,\nGodawari,\nChangunarayan,\nNagarjun')),
            ]),
            const DataRow(cells: [
              DataCell(Text('Monday')),
              DataCell(Text('Bhaktapur,\nLalitpur')),
              DataCell(Text('Suryabinayak,\nChandagiri,\nGokarneshwar')),
            ]),
            const DataRow(cells: [
              DataCell(Text('Tuesday')),
              DataCell(Text('Tokha,\nBudhanilkantha,\nTarakeshwar')),
              DataCell(Text('Kageswari-Manohara,\nThimi,\nMahalaxmi')),
            ]),
            const DataRow(cells: [
              DataCell(Text('Thursday')),
              DataCell(Text('Gokarneshwar,\nSuyrabinayak,\nChandragiri')),
              DataCell(Text('Bhaktapur,\nLalitpur')),
            ]),
            const DataRow(cells: [
              DataCell(Text('Friday')),
              DataCell(Text('Kageswari-Manohara,\nThimi,\nMahalaxmi')),
              DataCell(Text('Tokha,\nBudhanilkantha,\nTarakeshwar')),
            ]),
            const DataRow(cells: [
              DataCell(Text('Saturday')),
              DataCell(Text('Kirtipur,\nGodawari,\nChangunarayan,\nNagarjun')),
              DataCell(Text('Kathmandu')),
            ]),
          ],
          dataRowHeight: 100,
          columnSpacing: 40,
          horizontalMargin: 20,
          headingRowHeight: 60,
          showBottomBorder: true,
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

