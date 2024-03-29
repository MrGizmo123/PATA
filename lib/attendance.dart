import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Attendance extends StatefulWidget {
  const Attendance({Key? key}) : super(key: key);

  @override
  State<Attendance> createState() => AttendanceState();
}

class AttendanceState extends State<Attendance> {
  int number = 1;

  var attendance = List.generate(75, (int index) => true);

  bool isAttendanceComplete = false;

  void updateAttendance(int index, bool value) {
    attendance[index] = value;
    number = index;
  }

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
      body:  Container(
        margin: const EdgeInsets.all(15),
        child: GridView.count(
          crossAxisCount: 7,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
          shrinkWrap: true,
          children: List.generate(
            75,
            (index) {
              int displayIndex = index + 1;
              return AttendanceButton(
                number: displayIndex,
                update: updateAttendance,
                submit: confirmSubmission);
            },
          ),
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
  final int number;
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

        if (widget.number == 75) {
          widget.submit();
        }
      },
      style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(
              present ? Colors.lightGreenAccent : Colors.pinkAccent)),
      child: Text("${widget.number}",
          style: TextStyle(
              fontSize: 10, color: present ? Colors.black : Colors.white)),
    );
  }

  bool getPresent() {
    return present;
  }
}
