import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(MaterialApp(home: SimpleHttpDemo()));
}

class SimpleHttpDemo extends StatefulWidget {
  const SimpleHttpDemo({Key? key}) : super(key: key);

  @override
  State<SimpleHttpDemo> createState() => HttpState();
}

class HttpState extends State<SimpleHttpDemo> {
  int number = 1;
  var attendance =
      List.generate(75, (index) => true); // All are initially present
  bool isAttendanceComplete = false;

  List<int> getAbsentNos() {
    List<int> result = [];
    for (int i = 0;i<attendance.length;i++) {
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
                    get(Uri.parse("http://192.168.140.184:4242/uploadAttendance?absent=$absentNos"));
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
                            style: TextStyle(fontSize: 10,
                              color: attendance[index] ? Colors.black : Colors.white)),
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
