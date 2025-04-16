import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/api_services.dart';
import 'package:frontend/widgets/app_bar.dart';

class PnrStatusScreen extends StatefulWidget {
  final User user;
  const PnrStatusScreen({super.key, required this.user});

  @override
  State<PnrStatusScreen> createState() => _PnrStatusScreenState();
}

class _PnrStatusScreenState extends State<PnrStatusScreen> {
  TextEditingController _pnrController = TextEditingController();
  bool _isLoading = false;
  String? _pnrStatusMessage = '';
  Color _statusColor = Colors.white;
  Map<String, String> _pnrDetails = {};  // Store PNR details here

  void _fetchPnrStatus() async {
    if (_pnrController.text.isEmpty) {
      setState(() {
        _pnrStatusMessage = "Please enter a valid PNR.";
        _statusColor = Colors.red;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _pnrStatusMessage = '';
    });

    try {
      // Call the API to fetch PNR status
      var response = await ApiService.getPnrStatus(int.parse(_pnrController.text));

      if (response.statusCode == 200) {
        setState(() {
          _pnrDetails = {
            'Train': response.data?.trainName ?? 'N/A',
            'Start Station': response.data?.startStation ?? 'N/A',
            'End Station': response.data?.endStation ?? 'N/A',
            'Start Time': (response.data?.startTime ?? 'N/A').toString(),
            'End Time': (response.data?.endTime ?? 'N/A').toString(),
            'Seat No': (response.data?.seatNo ?? 'N/A').toString(),
            'Status': response.data?.bookingStatus ?? 'N/A',
          };
          _statusColor = Colors.green;
        });
      } else {
        setState(() {
          _pnrStatusMessage = response.error ?? 'Failed to fetch PNR status';
          _statusColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        _pnrStatusMessage = e.toString();
        _statusColor = Colors.red;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pnrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(user: widget.user, title: "PNR Status"),
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // PNR Status Header
              Text(
                "Check PNR Status",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),

              // Search Bar
              TextField(
                controller: _pnrController,
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  hintText: "Enter PNR",
                  hintStyle: TextStyle(color: Colors.grey[200]),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Search Button
              ElevatedButton(
                onPressed: _isLoading ? null : _fetchPnrStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.black)
                    : Text(
                        "Search",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
              SizedBox(height: 20),

              // Display PNR Status as a Tile
              if (_pnrDetails.isNotEmpty) 
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _pnrDetails.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                entry.key,
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(
                                entry.value,
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              
              // Error or Status Message
              if (_pnrStatusMessage != null && _pnrStatusMessage!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _pnrStatusMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
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
