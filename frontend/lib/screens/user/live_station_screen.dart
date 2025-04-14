import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/widgets/app_bar.dart';

class LiveStationScreen extends StatefulWidget {
  final User user;
  const LiveStationScreen({super.key, required this.user});

  @override
  State<LiveStationScreen> createState() => _LiveStationScreenState();
}

class _LiveStationScreenState extends State<LiveStationScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(user: widget.user),
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "Live Station Screen",
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