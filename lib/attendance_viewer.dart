import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

import 'constants.dart';

class AttendanceViewer extends StatelessWidget {
  final String user;
  final String pass;

  const AttendanceViewer({super.key, required this.user, required this.pass});

  Future<Response> getResponse() {
    return get(
        Uri.parse("$SERVER_ADDRESS/getAttendance?user=$user&pass=$pass"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(leading: null, title: const Text("Attendance Viewer")),
        body: FutureBuilder(
            future: getResponse(),
            builder: (BuildContext cxt, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If we got an error
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '${snapshot.error} occurred',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );

                  // if we got our data
                } else if (snapshot.hasData) {
                  final Response data = snapshot.data as Response;

                  final Map<String, dynamic> parsedData =
                      json.decode(data.body);

                  final subjects = parsedData.keys.toList();

                  return Center(
                      child: ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: parsedData.length,
                    itemBuilder: (BuildContext cxt, int index) {
                      String subject = subjects[index];
                      //String teacher = parsedData[subject]["teacher"] as String;

                      int present_int = parsedData[subject]["present"];
                      int total_int = parsedData[subject]["total"];

                      double percentage = (present_int / total_int) * 100;

                      String present = "$present_int";
                      String total = "$total_int";
                      String attendance = "${percentage.toStringAsFixed(2)}%";
                      return Container(
                          color: Colors.amber,
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Text(subject,
                                      style: const TextStyle(fontSize: 25)),
                                  Text(attendance,
                                      style: const TextStyle(fontSize: 20)),
                                ],
                              )));
                    },
                    separatorBuilder: (BuildContext cxt, int index) =>
                        const Divider(),
                  ));
                }
              }

              //return this if request not yet answered
              return const Center(
                child: CircularProgressIndicator(),
              );
            }));
  }
}
