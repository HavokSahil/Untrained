import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final User user;

  const BookingConfirmationScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Booking Confirmation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Your booking has been successfully confirmed!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Booking Details:",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "User: ${user.name}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              // Add more details as required (e.g. journey details, passengers)
            ],
          ),
        ),
      ),
    );
  }
}
