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
