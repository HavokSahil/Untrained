import 'package:flutter/material.dart';
import 'package:frontend/data/models/passenger.dart';
import 'package:frontend/data/models/schedule.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/widgets/app_bar.dart';

class BookingPaymentScreen extends StatefulWidget {
  final User user;
  final JourneyBetweenStations journey;
  final List<CreatePassenger> passengers;
  const BookingPaymentScreen({
    super.key, required this.user,
    required this.journey, required this.passengers
  });

  @override
  State<BookingPaymentScreen> createState() => _BookingPaymentScreenState();
}

class _BookingPaymentScreenState extends State<BookingPaymentScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(user: widget.user),
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "Booking History Screen",
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