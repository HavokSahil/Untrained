import 'package:flutter/material.dart';
import 'package:frontend/data/models/passenger.dart';
import 'package:frontend/data/models/schedule.dart';
import 'package:frontend/data/models/transaction.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/api_services.dart';
import 'package:frontend/screens/user/booking_confirmation_screen.dart';
import 'package:frontend/widgets/app_bar.dart';

class BookingPaymentScreen extends StatefulWidget {
  final User user;
  final JourneyBetweenStations journey;
  final List<CreatePassenger> passengers;
  final double totalFare;
  final String? category;

  const BookingPaymentScreen({
    super.key,
    required this.user,
    required this.journey,
    required this.passengers,
    required this.totalFare,
    this.category
  });

  @override
  State<BookingPaymentScreen> createState() => _BookingPaymentScreenState();
}

class _BookingPaymentScreenState extends State<BookingPaymentScreen> {
  bool _isProcessing = false;

  // Process the payment transaction
  void _processTransaction() async {
    setState(() {
      _isProcessing = true;
    });

    final paymentTransaction = CreateTransaction(
      totalAmount: widget.totalFare,
      txnStatus: 'PENDING',
      paymentMode: 'UPI',
    );

    final ApiResponse<int> txnResponse = await ApiService.createPaymentTransaction(paymentTransaction);

    if (txnResponse.statusCode == 201 && txnResponse.data != null) {
      final txnId = txnResponse.data!;

      // Build GroupBookingRequest model
      final bookingRequest = GroupBookingRequest(
        groupSize: widget.passengers.length,
        passengerData: widget.passengers.map((p) {
          return Passenger(
            name: p.name,
            age: p.age,
            sex: p.gender,
            disability: p.isDisabled,
            fare: p.fare!,
          );
        }).toList(),
        journeyId: widget.journey.journeyId,
        trainId: widget.journey.trainId!,
        startStationId: widget.journey.startStationId!,
        endStationId: widget.journey.endStationId!,
        mode: 'UPI',
        txnId: txnId,
        email: widget.user.email,
        reservationCategory: widget.category!,
      );

      // Make group booking API call
      final ApiResponse<int> bookingResponse = await ApiService.createGroupBooking(bookingRequest);

      setState(() {
        _isProcessing = false;
      });

      if (bookingResponse.statusCode == 201) {
        final ApiResponse<void> bookingStatusResponse = await ApiService.updatePaymentTransactionStatus(
          txnId,
          'COMPLETE',
        );

        if (bookingStatusResponse.statusCode != 200) {
          _showErrorDialog(bookingStatusResponse.error ?? 'Failed to update transaction status');
          return;
        }

        _showSuccessDialog();
      } else {
        _showErrorDialog(bookingResponse.error ?? 'Booking failed after payment');
      }
    } else {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog(txnResponse.error ?? 'Transaction failed');
    }
  }


  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Icon(Icons.check_circle, color: Colors.green, size: 50),
          content: Text(
            "Payment Successful!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Icon(Icons.error, color: Colors.red, size: 50),
          content: Text(
            "Payment Failed! $errorMessage",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(user: widget.user, title: "Booking ~ Payment"),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                "Payment Details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
          
              // Transaction details
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(180),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Journey Details
                    Text(
                      "Journey: ${widget.journey.startStation} → ${widget.journey.endStation}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Total Fare: ₹${widget.totalFare}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
          
                    // Passenger List
                    Text(
                      "Passengers: ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    ...widget.passengers.map((passenger) {
                      return Text(
                        "${passenger.name}, Age: ${passenger.age}, Gender: ${passenger.gender}",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: 30),
          
              // Payment Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 6,
                ),
                onPressed: _isProcessing ? null : _processTransaction,
                child: _isProcessing
                    ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        "Proceed to Payment",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ),
              SizedBox(height: 20),
          
              // Text Link for cancellation or help
              GestureDetector(
                onTap: () {
                  // Navigate to Help or Contact page
                },
                child: Text(
                  "Need help? Contact Support",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
