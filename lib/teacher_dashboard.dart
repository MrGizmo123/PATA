import 'package:flutter/material.dart';
import 'package:test_app/attendance_downloader.dart';

import 'schedule.dart';

class TeacherDashboard extends StatelessWidget {
  final String user;
  final String pass;

  const TeacherDashboard({super.key, required this.user, required this.pass});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Dashboard"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car)),
              Tab(icon: Icon(Icons.directions_transit)),
            ],
          ),
        ),
        body: TabBarView(children: [
            Schedule(user: user, pass: pass),
            AttendanceDownloader(user: user, pass: pass)
        ]),
      )
    );
  }
}
