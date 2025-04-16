import 'package:flutter/material.dart';
import 'package:frontend/data/models/route.dart';
import 'package:frontend/data/models/schedule.dart';
import 'package:frontend/data/services/api_services.dart';

class AddStopDialog extends StatefulWidget {
  final int journeyId;
  final int stationId;
  final int routeId;
  final int stopNumber;
  final Function(CreateScheduleRequest) onStopAdded;

  const AddStopDialog({
    super.key,
    required this.journeyId,
    required this.stationId,
    required this.routeId,
    required this.stopNumber,
    required this.onStopAdded,
  });

  @override
  State<AddStopDialog> createState() => _AddStopDialogState();
}

class _AddStopDialogState extends State<AddStopDialog> {
  bool isLoading = false;
  String? error;
  List<RelativeStation> stations = [];

  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _departureController = TextEditingController();

  RelativeStation? selectedStation;

  @override
  void initState() {
    super.initState();
    fetchStations();
  }

  @override
  void dispose() {
    _arrivalController.dispose();
    _departureController.dispose();
    super.dispose();
  }

  void fetchStations() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final response = await ApiService.getStationsRelativeTo(
      routeId: widget.routeId,
      stationId: widget.stationId,
    );

    if (response.isSuccess && response.data != null) {
      setState(() {
        stations = response.data!;
        isLoading = false;
      });
    } else {
      setState(() {
        error = response.error ?? 'Failed to load stations';
        isLoading = false;
      });
    }
  }

  void onAddPressed(int stationId) async {
    if (_arrivalController.text.isEmpty || _departureController.text.isEmpty) {
      setState(() => error = 'Please select both arrival and departure time');
      return;
    }

    final schedule = CreateScheduleRequest(
      journeyId: widget.journeyId,
      stationId: stationId,
      stopNumber: widget.stopNumber,
      arrivalTime: _arrivalController.text,
      departureTime: _departureController.text,
    );

    widget.onStopAdded(schedule);
  }

  Future<void> _pickTime(BuildContext context, TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.dark(),
        child: child!,
      ),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) => Theme(
          data: ThemeData.dark(),
          child: child!,
        ),
      );

      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        controller.text = dateTime.toUtc().toIso8601String();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        "Add Stop",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 320,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : error != null
                ? Text(error!, style: const TextStyle(color: Colors.redAccent))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        itemCount: stations.length,
                        separatorBuilder: (_, __) => Divider(color: Colors.grey[800]),
                        itemBuilder: (context, index) {
                          final option = stations[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              title: Text(
                                "#${option.stationId} ${option.stationName}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                "Distance: ${option.distanceFromGivenStation.toStringAsFixed(2)} km",
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
                                  selectedStation = option;
                                  setState(() {});
                                },
                                child: const Text("Select"),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _arrivalController,
                        readOnly: true,
                        onTap: () => _pickTime(context, _arrivalController),
                        decoration: const InputDecoration(
                          labelText: "Arrival Time",
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.black,
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _departureController,
                        readOnly: true,
                        onTap: () => _pickTime(context, _departureController),
                        decoration: const InputDecoration(
                          labelText: "Departure Time",
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.black,
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: selectedStation == null
                            ? null
                            : () => onAddPressed(selectedStation!.stationId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("Add Stop"),
                      )
                    ],
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
