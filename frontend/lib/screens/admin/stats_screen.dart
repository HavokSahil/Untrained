import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/api_services.dart';
import 'package:frontend/widgets/app_bar.dart';

class StatScreen extends StatefulWidget {
  final User user;
  const StatScreen({super.key, required this.user});

  @override
  State<StatScreen> createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen> {
  late Future<Map<String, dynamic>> statsData;

  @override
  void initState() {
    super.initState();
    statsData = fetchStats();
  }

  Future<Map<String, dynamic>> fetchStats() async {
    try {
      // Fetching data from multiple endpoints.
      final totalJourneys = await ApiService.getTotalNumberOfJourneys();
      final busiestRoute = await ApiService.getBusiestRoute();
      final totalPassengers = await ApiService.getTotalPassengersTraveling();
      final genderDistribution = await ApiService.getGenderDistribution();
      final busiestStation = await ApiService.getBusiestStation();
      final runningTrains = await ApiService.rankRunningTrainsByBookings();
      final busiestTimePeriod = await ApiService.getBusiestTimePeriod();
      final reservationStatusDistribution = await ApiService.getReservationStatusDistribution();

      // Return all fetched data as a map
      return {
        'total_journeys': totalJourneys.data,
        'busiest_route': busiestRoute.data,
        'total_passengers': totalPassengers.data,
        'gender_distribution': genderDistribution.data,
        'busiest_station': busiestStation.data,
        'running_trains': runningTrains.data,
        'busiest_time_period': busiestTimePeriod.data,
        'reservation_status_distribution': reservationStatusDistribution.data,
      };
    } catch (e) {
      // Handle errors (you can display an error message)
      return {
        'error': e.toString(),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(user: widget.user, title: "Statistics"),
      backgroundColor: Colors.black,
      body: FutureBuilder<Map<String, dynamic>>(
        future: statsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: Colors.white),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!['error'] != null) {
            return Center(
              child: Text(
                "Error: ${snapshot.data!['error']}",
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            // If data is successfully fetched
            final data = snapshot.data!;
            return GridView.builder(
              padding: EdgeInsets.all(128.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Number of columns in the grid
                crossAxisSpacing: 32.0, // Horizontal spacing between cards
                mainAxisSpacing: 32.0, // Vertical spacing between cards
              ),
              itemCount: 8, // Total number of items (cards) to display
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return StatCard(
                      title: "Total Journeys",
                      value: data['total_journeys']?.toString() ?? "N/A",
                    );
                  case 1:
                    return StatCard(
                      title: "Busiest Route",
                      value: data['busiest_route']?['route_name'] ?? "N/A",
                      subtitle: "Bookings: ${data['busiest_route']?['total_bookings'] ?? 0}",
                    );
                  case 2:
                    return StatCard(
                      title: "Total Passengers Traveling",
                      value: data['total_passengers']?.length.toString() ?? "N/A",
                    );
                  case 3:
                    return StatCard(
                      title: "Gender Distribution",
                      value: data['gender_distribution'] != null && data['gender_distribution'].isNotEmpty
                          ? "Male: ${data['gender_distribution'][0]['total_passengers'] ?? 0} / Female: ${data['gender_distribution'].length > 1 ? data['gender_distribution'][1]['total_passengers'] : 0}"
                          : "No data available",
                    );
                  case 4:
                    return StatCard(
                      title: "Busiest Station",
                      value: data['busiest_station'] != null
                          ? (data['busiest_station']?['station_name'] ?? "N/A")
                          : "No data available",
                    );
                  case 5:
                    return StatCard(
                      title: "Running Trains",
                      value: data['running_trains'] != null && data['running_trains'].isNotEmpty
                          ? data['running_trains']?.length.toString() ?? "0"
                          : "No data available",
                    );
                  case 6:
                    return StatCard(
                      title: "Busiest Time Period",
                      value: data['busiest_time_period'] != null && data['busiest_time_period'].isNotEmpty
                          ? "Hour: ${data['busiest_time_period'][0]['hour_of_day']} Bookings: ${data['busiest_time_period'][0]['total_bookings']}"
                          : "No data available",
                    );
                  case 7:
                    return StatCard(
                      title: "Reservation Status Distribution",
                      value: data['reservation_status_distribution'] != null && data['reservation_status_distribution'].isNotEmpty
                          ? "CNF: ${data['reservation_status_distribution'][0]['total_reservations']} / RAC: ${data['reservation_status_distribution'][1]['total_reservations']} / WL: ${data['reservation_status_distribution'][2]['total_reservations']}"
                          : "No data available",
                    );
                  default:
                    return SizedBox.shrink();
                }
              },
            );
          }
        },
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
