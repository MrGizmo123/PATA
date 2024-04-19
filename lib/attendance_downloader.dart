//import 'package:path_provider/path_provider.dart';

import 'dart:io';
import 'package:open_file/open_file.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

import 'constants.dart';

class AttendanceDownloader extends StatefulWidget {
  final String user;
  final String pass;

  AttendanceDownloader({super.key, required this.user, required this.pass});

  @override
  State<AttendanceDownloader> createState() => AttendanceDownloaderState();
}

class AttendanceDownloaderState extends State<AttendanceDownloader> {
  String batch = "";
  String subject = "";

  late Future<Response> options;

  @override
  void initState() {
    options = getOptions();
    super.initState();
  }

  Future<Response> getOptions() {
    print(
        "$SERVER_ADDRESS/getDownloadAttendanceOptions?user=${widget.user}&pass=${widget.pass}");
    return get(Uri.parse(
        "$SERVER_ADDRESS/getDownloadAttendanceOptions?user=${widget.user}&pass=${widget.pass}"));
  }

  List<String> getSubjects(String batch, dynamic data) {
    if (batch == "") {
      return [""];
    }
    return data[batch].cast<String>();
  }

  void downloadAttendance() async {
    //var downloadsDirectory = await getDownloadsDirectory();

    // if (downloadsDirectory != null) {
    //   print('Downloads folder path: $downloadsDirectory');
    // } else {
    //   print('Failed to retrieve downloads folder path.');
    // }

    print(
        "$SERVER_ADDRESS/downloadAttendance?user=${widget.user}&pass=${widget.pass}&batch=$batch&subject=$subject");

    get(Uri.parse(
            "$SERVER_ADDRESS/downloadAttendance?user=${widget.user}&pass=${widget.pass}&batch=$batch&subject=$subject"))
        .then((response) {
      DateTime now = DateTime.now();

      int day = now.day;
      int month = now.month;
      int year = now.year;
      int hour = now.hour;
      int minute = now.minute;
      int second = now.second;

      String filename = "${batch}_attendance_$day-$month-$year-$hour-$minute-$second.csv";

      print(filename);

      new File("/storage/emulated/0/Download/$filename")
          .writeAsString(response.body);
      // File("/storage/emulated/0/Download/$filename")
      // .writeAsBytes(response.bodyBytes);
      OpenFile.open("/storage/emulated/0/Download/$filename", type: "text/plain");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: options,
            builder: (cxt, snapshot) {
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

                  var data = snapshot.data!;
                  Map<String, dynamic> parsedData = json.decode(data.body);

                  List<String> subjects = getSubjects(batch, parsedData);

                  return Container(
                      margin: const EdgeInsets.all(15),
                      child: Center(
                          child: Column(
                        children: [
                          DropdownMenu<String>(
                            width: 200,
                            onSelected: (String? item) {
                              setState(() {
                                batch = item!;
                              });
                            },
                            dropdownMenuEntries: parsedData.keys.map((x) {
                              return DropdownMenuEntry(value: x, label: x);
                            }).toList(),
                          ),
                          const SizedBox(height: 30),
                          DropdownMenu<String>(
                            initialSelection: subjects[0],
                            width: 200,
                            onSelected: (String? item) {
                              setState(() {
                                subject = item!;
                              });
                            },
                            dropdownMenuEntries: subjects.map((x) {
                              return DropdownMenuEntry(value: x, label: x);
                            }).toList(),
                          ),
                        ],
                      )));
                }
              }
              // Displaying LoadingSpinner to indicate waiting state
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
        floatingActionButton: Container(
            margin: const EdgeInsets.all(10),
            child: FloatingActionButton.large(
              onPressed: () {
                downloadAttendance();
              },
              backgroundColor: Colors.lightBlueAccent,
              child: const Icon(Icons.download),
            )));
  }
}
