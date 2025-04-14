import 'package:flutter/material.dart';
import 'package:frontend/data/models/route.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/api_services.dart';
import 'package:frontend/widgets/app_bar.dart';

class RouteDetailScreen extends StatefulWidget {
  final User user;
  final RouteResponse route;

  const RouteDetailScreen({super.key, required this.user, required this.route});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  RouteStationInfo? routeInfo;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchRouteStations();
  }

  void fetchRouteStations() async {
    setState(() => isLoading = true);
    final response = await ApiService.getRouteStations(widget.route.routeId);

    if (response.isSuccess && response.data != null) {
      setState(() {
        routeInfo = response.data!;
      });
    }
    setState(() => isLoading = false);
  }

  void addIntermediateStation() async {
    final stationIdController = TextEditingController();
    final distanceController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF212121),
          title: const Text("Add Intermediate Station", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stationIdController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Station ID",
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF272727),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: distanceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Distance from source (km)",
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF272727),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9D9D9),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final stationId = int.tryParse(stationIdController.text.trim());
                final distance = double.tryParse(distanceController.text.trim());

                if (stationId != null && distance != null) {
                  final res = await ApiService.addIntermediateStation(
                    routeId: widget.route.routeId,
                    stationId: stationId,
                    distance: distance,
                  );

                  if (res.isSuccess) {
                    Navigator.pop(context);
                    fetchRouteStations();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to add station: error ${res.error}"),
                      ),
                    );
                  }
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBarWidget(
        user: widget.user,
        title: "Route ${widget.route.routeName}",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : routeInfo == null
                ? const Center(
                    child: Text("No data available", style: TextStyle(color: Colors.white)),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: const Color(0xFF1E1E1E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoRow("Route ID", routeInfo!.routeId.toString()),
                              _infoRow("Route Name", routeInfo!.routeName),
                              _infoRow("Source Station", routeInfo!.sourceStationId.toString()),
                              _infoRow("Stations", routeInfo!.stations.length.toString()),
                              _infoRow("Total Distance", "${routeInfo!.totalDistance} km"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: routeInfo!.stations.length,
                          itemBuilder: (context, index) {
                            final station = routeInfo!.stations[index];
                            return Card(
                              color: const Color(0xFF212121),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text("Station ID: ${station.stationId}", style: const TextStyle(color: Colors.white)),
                                subtitle: Text(
                                  "Distance: ${station.distance} km",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: addIntermediateStation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD9D9D9),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: const Text("Add Intermediate Station", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
