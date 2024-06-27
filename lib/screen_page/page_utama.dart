import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pegawai/screen_page/page_detail.dart';
import 'package:pegawai/screen_page/page_edit.dart';
import 'package:pegawai/screen_page/page_insert.dart';
import '../model/model_pegawai.dart';

class PageUtama extends StatefulWidget {
  const PageUtama({Key? key}) : super(key: key);

  @override
  State<PageUtama> createState() => _PageUtamaState();
}

class _PageUtamaState extends State<PageUtama> {
  TextEditingController searchController = TextEditingController();
  List<Datum>? employeeList;
  List<Datum>? filteredEmployeeList;

  @override
  void initState() {
    super.initState();
    getEmployees();
  }

  Future<void> getEmployees() async {
    try {
      var response = await http.get(Uri.parse('http://192.168.158.29/pegawaiDB/getPegawai.php'));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['isSuccess'] == true) {
          List<Datum> employees = (jsonData['data'] as List).map((item) => Datum.fromJson(item)).toList();
          setState(() {
            employeeList = employees;
            filteredEmployeeList = employeeList;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load employees: ${jsonData['message']}')));
        }
      } else {
        throw Exception('Failed to load employees');
      }
    } catch (e) {
      print('Error getEmployees: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> deleteEmployee(String id) async {
    try {
      var response = await http.post(
        Uri.parse('http://192.168.158.29/pegawaiDB/deletePegawai.php'),
        body: {'id': id},
      );
      var jsonData = json.decode(response.body);
      if (response.statusCode == 200 && jsonData['is_success'] == true) {
        setState(() {
          employeeList!.removeWhere((employee) => employee.id == id);
          filteredEmployeeList = List.from(employeeList!);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Employee deleted successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete employee: ${jsonData['message']}')));
      }
    } catch (e) {
      print('Error deleteEmployee: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Employees', style: TextStyle(fontWeight: FontWeight.bold))),
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  filteredEmployeeList = employeeList
                      ?.where((employee) =>
                  employee.firstname.toLowerCase().contains(value.toLowerCase()) ||
                      employee.lastname.toLowerCase().contains(value.toLowerCase()) ||
                      employee.email.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              },
              decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search by name or email",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredEmployeeList != null
                ? ListView.builder(
              itemCount: filteredEmployeeList!.length,
              itemBuilder: (context, index) {
                Datum data = filteredEmployeeList![index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PageDetailEmployee(employee: data),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                '${data.firstname} ${data.lastname}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyan,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Text(
                                "${data.email}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.cyan),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PageEditEmployee(
                                          employee: data,
                                        ),
                                      ),
                                    ).then((updatedEmployee) {
                                      if (updatedEmployee != null) {
                                        setState(() {
                                          int index = employeeList!.indexWhere((employee) => employee.id == updatedEmployee.id);
                                          if (index != -1) {
                                            employeeList![index] = updatedEmployee;
                                            filteredEmployeeList = List.from(employeeList!);
                                          }
                                        });
                                      }
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Delete Employee'),
                                        content: Text('Are you sure you want to delete this employee?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              deleteEmployee(data.id);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Yes'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
                : Center(
              child: CircularProgressIndicator(color: Colors.cyan),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var newEmployee = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PageInsertEmployee()),
          );

          if (newEmployee != null) {
            setState(() {
              employeeList!.add(newEmployee);
              if (searchController.text.isNotEmpty) {
                filteredEmployeeList = employeeList
                    ?.where((employee) =>
                employee.firstname
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()) ||
                    employee.lastname
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase()) ||
                    employee.email
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase()))
                    .toList();
              } else {
                filteredEmployeeList = List.from(employeeList!);
              }
            });
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.cyan,
      ),
    );
  }
}
