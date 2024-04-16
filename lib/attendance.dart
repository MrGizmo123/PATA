import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'constants.dart';

class Attendance extends StatefulWidget {
  final List<String> members;
  final String user;
  final String pass;
  final String batch;
  final String subject;

  const Attendance(
      {super.key,
      required this.user,
      required this.pass,
      required this.members,
      required this.batch,
      required this.subject});

  @override
  State<Attendance> createState() => AttendanceState();
}

class AttendanceState extends State<Attendance> {
  Map<String, bool> attendance = {};

  @override
  void initState() {
    attendance = Map<String, bool>.fromIterable(
      widget.members,
      key: (item) => item,
      value: (item) => true,
    );

    super.initState();
  }

  bool isAttendanceComplete = false;

  void updateAttendance(String index, bool value) {
    attendance[index] = value;
  }

  List<String> getPresentNos() {
    List<String> result = [];

    Iterable<String> keys = attendance.keys;
    for (String i in keys) {
      if (attendance[i] == true) {
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
                    List<String> presentNos = getPresentNos();
                    String presentList = "";

                    for (String num in presentNos) {
                      presentList = "$presentList,$num";
                    }

                    presentList = presentList.substring(1);

                    String user = widget.user;
                    String pass = widget.pass;
                    String subject = widget.subject;

                    get(Uri.parse(
                        "$SERVER_ADDRESS/uploadAttendance?user=$user&pass=$pass&subject=$subject&present=$presentList"));
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
          title: Center(child: Text("${widget.batch} : ${widget.subject}")),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: Container(
          margin: const EdgeInsets.all(15),
          child: GridView.count(
            crossAxisCount: 7,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            shrinkWrap: true,
            children: widget.members
                .map((element) => AttendanceButton(
                    number: element,
                    update: updateAttendance,
                    submit: confirmSubmission))
                .toList(),
          ),
        ),
        floatingActionButton: Container(
            margin: const EdgeInsets.all(10),
            child: FloatingActionButton.large(
              onPressed: () {
                confirmSubmission();
              },
              backgroundColor: Colors.lightBlueAccent,
              child: const Icon(Icons.upload),
            )));
  }
}

class AttendanceButton extends StatefulWidget {
  final String number;
  final Function update;
  final Function submit;

  const AttendanceButton(
      {super.key,
      required this.number,
      required this.update,
      required this.submit});

  @override
  State<AttendanceButton> createState() => AttendanceButtonState();
}

class AttendanceButtonState extends State<AttendanceButton> {
  bool present = true;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        setState(() {
          present = !present;
        });

        widget.update(widget.number, present);
      },
      style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(
              present ? Colors.lightGreenAccent : Colors.pinkAccent)),
      child: Text(
          widget.number
              .substring(widget.number.length - 2), // The last 2 charachters
          style: TextStyle(
              fontSize: 10, color: present ? Colors.black : Colors.white)),
    );
  }

  bool getPresent() {
    return present;
  }
}
