import 'package:flutter/material.dart';
import '../model/model_pegawai.dart';

class PageDetailEmployee extends StatelessWidget {
  final Datum employee;

  const PageDetailEmployee({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Employee'),
        backgroundColor: Color.fromRGBO(5, 25, 54, 1.0),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${employee.firstname} ${employee.lastname}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Phone: ${employee.nohp}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Email: ${employee.email}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}