import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

import 'constants.dart';
import 'attendance.dart';

class Schedule extends StatelessWidget {
  final String user;
  final String pass;
  final List weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  Schedule({super.key, required this.user, required this.pass});

  Future<Response> getSchedule() {
    final currentDay = weekdays[DateTime.now().weekday - 1];
    print(
        "$SERVER_ADDRESS/getSchedule?user=$user&pass=$pass&scope=$currentDay");
    return get(Uri.parse(
        "$SERVER_ADDRESS/getSchedule?user=$user&pass=$pass&scope=$currentDay"));
  }

  Future<Response> getBatch(String batchName) {
    print("$SERVER_ADDRESS/getBatch?batch=$batchName");
    return get(Uri.parse("$SERVER_ADDRESS/getBatch?batch=$batchName"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: getSchedule(),
            builder: (cxt, snapshot) {
              // Checking if future is resolved or not
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
                  // Extracting data from snapshot object
                  final Response data = snapshot.data as Response;
                  String schedule = data.body;

                  final Map<String, dynamic> parsedData =
                      json.decode(data.body);

                  final timings = parsedData.keys.toList();

                  return Center(
                      child: ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: parsedData.length,
                    itemBuilder: (BuildContext cxt, int index) {
                      String timing = timings[index];
                      String batchAndSubject = parsedData[timing] as String;
                      List<String> batchAndSubjectSplit =
                          batchAndSubject.split(":");

                      String batch = batchAndSubjectSplit[0].trim();
                      String subjectName = batchAndSubjectSplit[1].trim();
                      return InkWell(
                          onTap: () {
                            getBatch(batch).then((Response response) {
                              List<String> members = List<String>.from(
                                  json.decode(response.body)["members"]);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Attendance(user: user, pass: pass, members: members, batch: batch, subject: subjectName)));
                            });
                          },
                          child: Container(
                              color: Colors.amber,
                              child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Text(batch,
                                          style: const TextStyle(fontSize: 25)),
                                      Text(timing,
                                          style: const TextStyle(fontSize: 20)),
                                    ],
                                  ))));
                    },
                    separatorBuilder: (BuildContext cxt, int index) =>
                        const Divider(),
                  ));
                }
              }

              // Displaying LoadingSpinner to indicate waiting state
              return const Center(
                child: CircularProgressIndicator(),
              );
            }));
  }
}
