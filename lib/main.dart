//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

void main() {
  runApp(MaterialApp(home: Login(title: "Login")));
}

class Attendance extends StatefulWidget {
  const Attendance({Key? key}) : super(key: key);

  @override
  State<Attendance> createState() => AttendanceState();
}

class AttendanceState extends State<Attendance> {
  int number = 1;
  var attendance =
      List.generate(75, (index) => true); // All are initially present
  bool isAttendanceComplete = false;

  List<int> getAbsentNos() {
    List<int> result = [];
    for (int i = 0; i < attendance.length; i++) {
      if (!attendance[i]) {
        result.add(i);
      }
    }

    return result;
  }

  void confirmSubmission() {
    showDialog(
        context: context,
        builder: (BuildContext cxt) {
          return AlertDialog(
            title: const Text('Submit attendance?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(cxt).pop();
                  },
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () async {
                    print("submitted");
                    var absentNos = getAbsentNos();
                    get(Uri.parse(
                        "http://192.168.1.49:4242/uploadAttendance?absent=$absentNos"));
                    Navigator.of(cxt).pop();
                  },
                  child: const Text("Submit")),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Attendance")),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              '$number',
              style: const TextStyle(fontSize: 50),
            ),
            Container(
              margin: const EdgeInsets.all(15),
              child: GridView.count(
                crossAxisCount: 8,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
                shrinkWrap: true,
                children: List.generate(
                  75,
                  (index) {
                    int displayIndex = index + 1;
                    return TextButton(
                      onPressed: () {
                        setState(() {
                          attendance[index] = !attendance[index];
                        });
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              attendance[index]
                                  ? Colors.lightGreenAccent
                                  : Colors.pinkAccent)),
                      child: Text('$displayIndex',
                          style: TextStyle(
                              fontSize: 10,
                              color: attendance[index]
                                  ? Colors.black
                                  : Colors.white)),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            child: FloatingActionButton.large(
              onPressed: () {
                attendance[number - 1] = false;
                if (number <= 74) {
                  number++;
                } else {
                  isAttendanceComplete = true;
                }

                setState(() {});

                if (isAttendanceComplete) {
                  confirmSubmission();
                }
              },
              backgroundColor: Colors.pinkAccent,
              child: const Icon(Icons.clear),
            ),
          ),
          Container(
              margin: const EdgeInsets.all(10),
              child: FloatingActionButton.large(
                onPressed: () {
                  attendance[number - 1] = true;
                  if (number <= 74) {
                    number++;
                  } else {
                    isAttendanceComplete = true;
                  }

                  setState(() {});

                  if (isAttendanceComplete) {
                    confirmSubmission();
                  }
                },
                backgroundColor: Colors.lightGreenAccent,
                child: const Icon(Icons.check),
              )),
        ],
      ),
    );
  }
}

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

  String url = "192.168.1.49:4242/login?";

  late Future<Response> loginResponse;

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
                  child: FutureBuilder(
                      future: loginResponse,
                      builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                        if (snapshot == null) {
                          return ElevatedButton(
                            onPressed: () {
                              var passHash = sha256.convert(
                                  utf8.encode(passwordController.text));

                              loginResponse = get(Uri.parse(
                                  "$url?user=${emailController.text}&pass=$passHash"));

                              if (_formKey.currentState!.validate()) {
                                if (emailController.text == "hrushikesh" &&
                                    passwordController.text == "1234") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Attendance()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Invalid Credentials')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Please fill input')),
                                );
                              }
                            },
                            child: const Text('Submit'),
                          );
                        } else {
                          String response = json.decode(snapshot.data.body);
                          if (response == "success") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Attendance()));
                            return const Text("success");
                          } else {
                            return const Text("login failed");
                          }
                        }
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
        ),
        body: Column(
          children: [
            Text(email),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Go back!"),
              ),
            ),
          ],
        ));
  }
}
