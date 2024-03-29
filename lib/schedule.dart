import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

class Schedule extends StatelessWidget {
  final String user;
  final String pass;
  final String url = "http://192.168.1.53:4242";
  final List weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  Schedule({super.key, required this.user, required this.pass});

  Future<Response> getSchedule() {
    print("$url/getSchedule?user=$user");
    final currentDay = weekdays[DateTime.now().weekday - 1];
    return get(
      Uri.parse("$url/getSchedule?user=$user&pass=$pass&scope=$currentDay"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule")),
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

              final Map<String, dynamic> parsedData = json.decode(data.body);

              final timings = parsedData.keys.toList();

              return Center(
                child: ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: parsedData.length,
                  itemBuilder:
                  (BuildContext cxt, int index) {
                    String timing = timings[index];
                    String batch = parsedData[timing] as String;
                    return Container(
                      color: Colors.amber,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child:  Column(  
                          children: [
                            Text(batch, style: const TextStyle(fontSize: 25)),
                            Text(timing, style: const TextStyle(fontSize: 20)),
                          ],
                        )
                      )
                    );
                  },
                  separatorBuilder: (BuildContext cxt, int index) => const Divider(),
                )
              );
            }
          }

          // Displaying LoadingSpinner to indicate waiting state
          return const Center(
            child: CircularProgressIndicator(),
          );
    }));
  }
}
