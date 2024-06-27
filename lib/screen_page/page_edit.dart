import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/model_pegawai.dart';
import 'page_utama.dart'; // import your PageUtama here

class PageEditEmployee extends StatefulWidget {
  final Datum employee;

  const PageEditEmployee({required this.employee});

  @override
  _PageEditEmployeeState createState() => _PageEditEmployeeState();
}

class _PageEditEmployeeState extends State<PageEditEmployee> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _txtFirstname = TextEditingController();
  final TextEditingController _txtLastname = TextEditingController();
  final TextEditingController _txtPhone = TextEditingController();
  final TextEditingController _txtEmail = TextEditingController();

  @override
  void initState() {
    super.initState();
    _txtFirstname.text = widget.employee.firstname;
    _txtLastname.text = widget.employee.lastname;
    _txtPhone.text = widget.employee.nohp;
    _txtEmail.text = widget.employee.email;
  }

  @override
  void dispose() {
    _txtFirstname.dispose();
    _txtLastname.dispose();
    _txtPhone.dispose();
    _txtEmail.dispose();
    super.dispose();
  }

  Future<void> _updateEmployee() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('http://192.168.158.29/pegawaiDB/updatePegawai.php'),
          body: {
            'id': widget.employee.id.toString(),
            'firstname': _txtFirstname.text,
            'lastname': _txtLastname.text,
            'nohp': _txtPhone.text,
            'email': _txtEmail.text,
          },
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          if (jsonResponse['value'] == 1) {
            Datum updatedEmployee = Datum(
              id: widget.employee.id,
              firstname: _txtFirstname.text,
              lastname: _txtLastname.text,
              nohp: _txtPhone.text,
              email: _txtEmail.text,
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => PageUtama()),
                  (Route<dynamic> route) => false,
            );
          } else {
            _showErrorDialog(jsonResponse['message']);
          }
        } else {
          _showErrorDialog('An error occurred while sending data to the server');
        }
      } catch (error) {
        _showErrorDialog('An error occurred: $error');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Employee'),
        backgroundColor: Color.fromRGBO(5, 25, 54, 1.0),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              TextFormField(
                controller: _txtFirstname,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _txtLastname,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _txtPhone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _txtEmail,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateEmployee,
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}