import 'package:flutter/material.dart';
import 'package:frontend/data/models/route.dart';
import 'package:frontend/data/models/schedule.dart';
import 'package:frontend/data/services/api_services.dart';

class SetRouteDialog extends StatefulWidget {
  final int sourceStationId;
  final int destinationStationId;
  final ScheduleDetails prevStation;
  final ScheduleDetails nextStation;
  final Function(int routeId) onRouteSelected;

  const SetRouteDialog({
    super.key,
    required this.sourceStationId,
    required this.destinationStationId,
    required this.prevStation,
    required this.nextStation,
    required this.onRouteSelected,
  });

  @override
  State<SetRouteDialog> createState() => _SetRouteDialogState();
}

class _SetRouteDialogState extends State<SetRouteDialog> {
  bool isLoading = false;
  String? error;
  List<RoutesBetweenStations> routeOptions = [];

  @override
  void initState() {
    super.initState();
    fetchRouteOptions();
  }

  void fetchRouteOptions() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final response = await ApiService.getRoutesBetweenStations(
      sourceStationId: widget.sourceStationId,
      destinationStationId: widget.destinationStationId,
    );

    debugPrint("Response: ${response.toString()}, error: ${response.error}");
    if (response.isSuccess && response.data != null) {
      setState(() {
        routeOptions = response.data!;
        isLoading = false;
      });
    } else {
      setState(() {
        error = response.error ?? 'Failed to load route options';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        "Available Routes",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: 320, // Compact width
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : error != null
                ? Text(
                    error!,
                    style: const TextStyle(color: Colors.redAccent),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: routeOptions.length,
                    separatorBuilder: (_, __) => Divider(color: Colors.grey[800]),
                    itemBuilder: (context, index) {
                      final option = routeOptions[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          title: Text(
                            "Route #${option.routeId}: ${option.routeName}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "Distance: ${option.distance.toStringAsFixed(2)} km",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () {
                              widget.onRouteSelected(option.routeId);
                              Navigator.of(context).pop();
                            },
                            child: const Text("Select"),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
