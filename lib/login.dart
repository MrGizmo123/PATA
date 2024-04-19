import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'teacher_dashboard.dart';
import 'constants.dart';
import 'attendance_viewer.dart';
import 'attendance_downloader.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.title});

  final String title;

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<Response> loginResponse = Future.any([]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                child: Center(
                    child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final passHash =
                          sha256.convert(utf8.encode(passwordController.text));

                      print(
                          "$SERVER_ADDRESS/login?user=${emailController.text}&pass=$passHash");

                      final user = emailController.text;

                      loginResponse = get(Uri.parse(
                              "$SERVER_ADDRESS/login?user=${emailController.text}&pass=$passHash"))
                          .then((Response response) {
                        var data = json.decode(response.body);

                        print(data["isfaculty"]);

                        if (data["status"] == "success") {
                          if (data["isfaculty"] == "true") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TeacherDashboard(
                                        user: user,
                                        pass: passHash.toString())));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AttendanceViewer(
                                        user: user,
                                        pass: passHash.toString())));
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Invalid Credentials')));
                        }

                        return response;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill input')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
