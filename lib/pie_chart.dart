import 'package:flutter/material.dart';

class AttendanceViewer extends StatefulWidget {
  const AttendanceViewer({super.key});

  @override
  State<AttendanceViewer> createState() => AttendanceViewerState();
}

class AttendanceViewerState extends State<AttendanceViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance View")),
      body: Column(
        children: [
          Dropdown
        ],
      ),
    );
  }
}
