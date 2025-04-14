import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/widgets/app_bar.dart';

class BookingScreen extends StatefulWidget {
  final User user;
  const BookingScreen({super.key, required this.user});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(user: widget.user),
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "Booking Screen",
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