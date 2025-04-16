import 'package:flutter/material.dart';
import 'package:frontend/data/models/booking.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/api_services.dart';
import 'package:frontend/widgets/app_bar.dart';

class BookingHistoryScreen extends StatefulWidget {
  final User user;
  const BookingHistoryScreen({super.key, required this.user});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  late Future<ApiResponse<List<BookingDetail>>> _futureBookings;

  @override
  void initState() {
    super.initState();
    _futureBookings = ApiService.getBookingDetails(widget.user.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(user: widget.user, title: "Booking History"),
      backgroundColor: Colors.black,
      body: FutureBuilder<ApiResponse<List<BookingDetail>>>(
        future: _futureBookings,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (snapshot.data!.error != null) {
            return Center(child: Text(snapshot.data!.error!, style: TextStyle(color: Colors.red)));
          }

          final bookings = snapshot.data!.data!;
          final now = DateTime.now();

          final past = bookings.where((b) => b.endTime.isBefore(now)).toList();
          final present = bookings.where((b) => b.startTime.isBefore(now) && b.endTime.isAfter(now)).toList();
          final future = bookings.where((b) => b.startTime.isAfter(now)).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (present.isNotEmpty) buildSection("Ongoing Bookings", present),
              if (future.isNotEmpty) buildSection("Upcoming Bookings", future),
              if (past.isNotEmpty) buildSection("Past Bookings", past),
              if (bookings.isEmpty)
                const Center(
                  child: Text("No bookings found.", style: TextStyle(color: Colors.white70, fontSize: 20)),
                )
            ],
          );
        },
      ),
    );
  }

  Widget buildSection(String title, List<BookingDetail> bookings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...bookings.map((booking) => buildBookingCard(booking)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        "$label: $value",
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  void _printTicket(BookingDetail booking) {
  // Placeholder logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Printing ticket for ${booking.passName}..."),
        backgroundColor: Colors.green,
      ),
    );
    // You can integrate PDF ticket generation here
  }

  void _cancelBooking(BookingDetail booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Cancel Booking", style: TextStyle(color: Colors.white)),
        content: Text(
          "Are you sure you want to cancel the booking for ${booking.passName}?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (!(confirmed ?? false)) return;

    // Optional: Show progress indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Sample refund logic — adjust as needed
    double refundAmount = booking.amount * 0.8;

    final response = await ApiService.cancelBooking(
      CancelBookingRequest(
        bookingId: booking.bookingId,
        refundAmount: refundAmount,
        txnId: booking.txnId!,
      ),
    );

    // Close the loading dialog
    Navigator.of(context).pop();

    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Booking cancelled for ${booking.passName}"),
          backgroundColor: Colors.red,
        ),
      );

      // Refresh the bookings
      setState(() {
        _futureBookings = ApiService.getBookingDetails(widget.user.email);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cancellation failed: ${response.error}"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }




  Widget buildBookingCard(BookingDetail booking) {
    final now = DateTime.now();
    final isOngoing = booking.startTime.isBefore(now) && booking.endTime.isAfter(now);
    final isPast = booking.endTime.isBefore(now);

    return Column(
      children: [
        ListTile(
          tileColor: Colors.grey[900],
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${booking.trainName}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Time to the top-right corner with a subtle style
              Text(
                "${_formatDate(booking.startTime)} ➝ ${_formatDate(booking.endTime)}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _infoLine("Passenger", "${booking.passName}, ${booking.age} yrs"),
              _infoLine("Route", "${booking.startStation} ➝ ${booking.endStation}"),

              // Booking Status Highlight
              if (booking.bookingStatus == 'CONFIRMED')
                _infoLineWithHighlight("Status", booking.bookingStatus, Colors.green),
              if (booking.bookingStatus == 'CANCELLED')
                _infoLineWithHighlight("Status", booking.bookingStatus, Colors.red),
              if (booking.bookingStatus == 'PENDING')
                _infoLineWithHighlight("Status", booking.bookingStatus, Colors.orange),

              if (booking.reservationStatus! == "CNF")
                _infoLineWithHighlight("Reservation Status", booking.reservationStatus!, Colors.green),
              if (booking.reservationStatus! == "WL")
                _infoLineWithHighlight("Reservation Status", booking.reservationStatus!, Colors.red),
              if (booking.reservationStatus! == "RAC")
                _infoLineWithHighlight("Reservation Status", booking.reservationStatus!, Colors.yellow),

              _infoLine("Coach/Seat", "${booking.coachName ?? "N/A"}, Seat ${booking.seatNo?? "N/A"} (${booking.seatType ?? "N/A"})"),
              _infoLine("Booking Time", _formatDate(DateTime.parse(booking.bookingTime))),
              _infoLine("Amount", "₹${booking.amount.toStringAsFixed(2)}"),

              // Displaying Payment Details (if available)
              if (booking.paymentMode != null)
                _infoLine("Payment Mode", booking.paymentMode!),
              if (booking.txnStatus != null)
                _infoLine("Transaction Status", booking.txnStatus!),

              // Highlight Ongoing Journey
              if (isOngoing)
                const SizedBox(height: 12),
              if (isOngoing) buildActionButtons(booking),

              // Past Journey Status
              if (isPast)
                const SizedBox(height: 8),
              if (isPast) 
                _infoLineWithHighlight("Booking Status", "Past Journey", Colors.grey),

              const SizedBox(height: 10),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }


  // Helper function to highlight specific information with different colors
  Widget _infoLineWithHighlight(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildActionButtons(BookingDetail booking) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () => _printTicket(booking),
          icon: const Icon(Icons.print, color: Colors.white),
          label: const Text("Print Ticket", style: TextStyle(color: Colors.white)),
          style: TextButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(width: 12),
        TextButton.icon(
          onPressed: () => _cancelBooking(booking),
          icon: const Icon(Icons.cancel, color: Colors.white),
          label: const Text("Cancel", style: TextStyle(color: Colors.white)),
          style: TextButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
 TextStyle whiteText() => const TextStyle(color: Colors.white, fontSize: 16);
}
