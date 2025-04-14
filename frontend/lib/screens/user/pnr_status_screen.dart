import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/widgets/app_bar.dart';

class PnrStatusScreen extends StatefulWidget {
  final User user;
  const PnrStatusScreen({super.key, required this.user});

  @override
  State<PnrStatusScreen> createState() => _PnrStatusScreenState();
}

class _PnrStatusScreenState extends State<PnrStatusScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(user: widget.user),
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "PNR Status Screen",
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