import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/widgets/app_bar.dart';

class ScheduelScreen extends StatefulWidget {
  final User user;
  const ScheduelScreen({super.key, required this.user});

  @override
  State<ScheduelScreen> createState() => _ScheduelScreenState();
}

class _ScheduelScreenState extends State<ScheduelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(user: widget.user),
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "Schedule Screen",
          style: TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold
          ),
          ),
      ),
    );
  }
}