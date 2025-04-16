import 'package:flutter/material.dart';
import 'package:frontend/data/models/passenger.dart';
import 'package:frontend/data/models/schedule.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/screens/user/booking_payment_screen.dart';
import 'package:frontend/widgets/app_bar.dart';
import 'package:intl/intl.dart';

class BookingUserDetailsScreen extends StatefulWidget {
  final User user;
  final JourneyBetweenStations journey;

  const BookingUserDetailsScreen({
    super.key,
    required this.user,
    required this.journey,
  });

  @override
  State<BookingUserDetailsScreen> createState() => _BookingUserDetailsScreenState();
}

class _BookingUserDetailsScreenState extends State<BookingUserDetailsScreen> {
  final List<Map<String, dynamic>> passengers = [];

  @override
  void initState() {
    super.initState();
    _addPassenger();
  }

  void _addPassenger() {
    if (passengers.length < 5) {
      setState(() {
        passengers.add({
          'nameController': TextEditingController(),
          'ageController': TextEditingController(),
          'gender': 'Male',
          'isDisabled': false,
        });
      });
    }
  }

  void _updatePassenger(int index, String key, dynamic value) {
    setState(() {
      passengers[index][key] = value;
    });
  }

  void _handleNext() {
  List<CreatePassenger> passengerData = [];

  for (var passenger in passengers) {
    final name = passenger['nameController'].text.trim();
    final ageText = passenger['ageController'].text.trim();
    final gender = passenger['gender'];
    final isDisabled = passenger['isDisabled'];

    if (name.isEmpty || ageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    final age = int.tryParse(ageText);
    if (age == null || age <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid age')),
      );
      return;
    }

    passengerData.add(CreatePassenger(
      name: name,
      age: age,
      gender: gender,
      isDisabled: isDisabled,
    ));
  }

  // Navigate to next screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BookingPaymentScreen(
        user: widget.user,
        journey: widget.journey,
        passengers: passengerData,
      ),
    ),
  );
}


  Widget _buildJourneyDetails() {
    final journey = widget.journey;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow("Train", journey.trainName ?? ''),
          _infoRow("From", journey.startStation ?? ''),
          _infoRow("To", journey.endStation ?? ''),
          _infoRow("Journey Start", formatTime(journey.startTime!)),
          _infoRow("Journey Ends", formatTime(journey.endTime!)),
          _infoRow("Duration", journey.travelTime != null ? '${journey.travelTime! ~/ 60} min' : 'N/A'),
          _infoRow("Stops", '${journey.endStopNumber! - journey.startStopNumber!}'),
        ],
      ),
    );
  }

  String formatTime(String time) {
    final dateTime = DateTime.parse(time);
    return DateFormat('MMM dd, yyyy – h:mm a').format(dateTime);
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text("$label:", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildPassengerForm(int index) {

    final passenger = passengers[index];

    final nameController = passenger['nameController'] as TextEditingController;
    final ageController = passenger['ageController'] as TextEditingController;


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Name',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: ageController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Age',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: passenger['gender'],
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.black,
                hintText: 'Gender',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
              items: const [
                DropdownMenuItem(value: "Male", child: Text("Male")),
                DropdownMenuItem(value: "Female", child: Text("Female")),
                DropdownMenuItem(value: "Other", child: Text("Other")),
              ],
              onChanged: (value) => _updatePassenger(index, 'gender', value),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              const Text("Disabled", style: TextStyle(color: Colors.white, fontSize: 12)),
              Checkbox(
                value: passenger['isDisabled'],
                activeColor: Colors.white,
                checkColor: Colors.black,
                onChanged: (value) => _updatePassenger(index, 'isDisabled', value),
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              if (passengers.length > 1) {
                setState(() {
                  passenger['nameController'].dispose();
                  passenger['ageController'].dispose();
                  passengers.removeAt(index);
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("At least one passenger is required.")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBarWidget(user: widget.user, title: "Booking ~ Passenger Details"),
      floatingActionButton: passengers.length < 5
          ? FloatingActionButton(
              onPressed: _addPassenger,
              backgroundColor: Colors.white,
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildJourneyDetails(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text("Passenger Details", style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ...List.generate(passengers.length, (index) => _buildPassengerForm(index)),
            
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text("Next"),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
