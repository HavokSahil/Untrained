import 'package:flutter/material.dart';
import 'package:frontend/data/models/schedule.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/api_services.dart';
import 'package:frontend/widgets/app_bar.dart';

class BookingCategoryScreen extends StatefulWidget {
  final User user;
  final JourneyBetweenStations journey;

  const BookingCategoryScreen({
    super.key,
    required this.user,
    required this.journey,
  });

  @override
  State<BookingCategoryScreen> createState() => _BookingCategoryScreenState();
}

class _BookingCategoryScreenState extends State<BookingCategoryScreen> {
  Map<String, Map<String, Map<String, int>>> availableSeats = {};
  bool isLoading = true;
  String? error;

  final types = ['cnf', 'rac', 'wl'];
  final typesLabel = {
    'cnf': 'Confirmed',
    'rac': 'RAC',
    'wl': 'Waiting List',
  };

  final List<String> categories = ['SL', 'AC3', 'AC2', 'AC1', 'CC', 'FC', '2S'];
  final Map<String, String> categoryLabels = {
    'SL': 'Sleeper Class',
    'AC3': 'AC 3 Tier',
    'AC2': 'AC 2 Tier',
    'AC1': 'AC First Class',
    'CC': 'Chair Car',
    'FC': 'First Class',
    '2S': 'Second Sitting',
  };

  @override
  void initState() {
    super.initState();
    _loadSeatData();
  }

  Future<void> _loadSeatData() async {
    try {
      Map<String, Map<String, Map<String, int>>> seatMap = {
        'cnf': {},
        'rac': {},
        'wl': {},
      };

      for (var type in types) {
        final bookedRes = await ApiService.getReservedSeatCount(
          journeyId: widget.journey.journeyId,
          type: type,
        );

        for (final category in bookedRes.data ?? []) {
          seatMap[type]![category.reservationCategory] = {
            'booked': category.seatCount,
          };
        }

        if (type != 'wl') {
          final totalRes = await ApiService.getTotalSeatCount(
            journeyId: widget.journey.journeyId,
            type: type,
          );

          for (final category in totalRes.data ?? []) {
            seatMap[type]![category.reservationCategory] = {
              ...?seatMap[type]![category.reservationCategory],
              'total': category.seatCount,
            };
          }
        }
      }

      setState(() {
        availableSeats = seatMap;
        isLoading = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _onCategorySelected(String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected: ${categoryLabels[category]}')),
    );
    // Navigation or selection logic can be added here
  }
  
  // Helper function to get the available type based on seat counts
  String? _getAvailableType(String category) {
    final availableCNF = (availableSeats['cnf']?[category]?['total'] ?? 0) - (availableSeats['cnf']?[category]?['booked'] ?? 0);
    final availableRAC = (availableSeats['rac']?[category]?['total'] ?? 0) - (availableSeats['rac']?[category]?['booked'] ?? 0);
    final availableWL = (availableSeats['wl']?[category]?['booked'] ?? 0);

    if (availableCNF > 0) {
      return 'cnf';
    } else if (availableRAC > 0) {
      return 'rac';
    } else if (availableWL > 0) {
      return 'wl';
    }
    return null; // No available seats
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBarWidget(user: widget.user, title: "Booking ~ Select Category"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Text(
                    "Error: $error",
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Show categories in a single horizontal row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: categories.map((category) {
                              final availableType = _getAvailableType(category);
                              if (availableType == null) {
                                return Container(); // Skip category if no available type
                              }

                              final label = categoryLabels[category]!;
                              final typeLabel = typesLabel[availableType]!;
                              final available = availableSeats[availableType]?[category]?['total'] ?? 0;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[900],
                                    padding: const EdgeInsets.all(24),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () => _onCategorySelected(category),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${availableType.toUpperCase()} $available",
                                        style: TextStyle(
                                          color: (availableType == 'cnf') 
                                              ? Colors.green 
                                              : (availableType == 'rac') 
                                                ? Colors.yellow 
                                                : Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Show the price
                                      Text(
                                        "₹100",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
