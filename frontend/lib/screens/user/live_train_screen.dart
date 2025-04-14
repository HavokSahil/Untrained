import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/widgets/app_bar.dart';

class LiveTrainScreen extends StatefulWidget {
  final User user;
  const LiveTrainScreen({super.key, required this.user});

  @override
  State<LiveTrainScreen> createState() => _LiveTrainScreenState();
}

class _LiveTrainScreenState extends State<LiveTrainScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(user: widget.user),
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "Live Train Screen",
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