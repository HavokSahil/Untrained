import 'package:flutter/material.dart';
import 'package:frontend/data/models/journey.dart';
import 'package:frontend/data/models/train.dart';
import 'package:frontend/data/models/schedule.dart';  // Assuming this is the schedule model
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/api_services.dart';
import 'package:frontend/screens/admin/dialog/add_stop_dialog.dart';
import 'package:frontend/screens/admin/dialog/set_route_dialog.dart';
import 'package:frontend/widgets/app_bar.dart';
import "package:intl/intl.dart";

class JourneyDetailScreen extends StatefulWidget {
  final User user;
  final JourneyDetails journey;

  const JourneyDetailScreen({super.key, required this.user, required this.journey});

  @override
  State<JourneyDetailScreen> createState() => _JourneyDetailScreenState();
}

class _JourneyDetailScreenState extends State<JourneyDetailScreen> {
  bool isLoading = false;
  Train? trainDetails;
  List<ScheduleDetails> schedules = [];  // This will store the schedule data

  late DateTime startDateTime;
  late DateTime endDateTime;

  late String formattedStart;
  late String formattedEnd;

  // Duration of the journey
  late Duration duration;
  late String formattedDuration;

  @override
  void initState() {
    super.initState();
    fetchTrainDetails();
    fetchSchedules();  // Fetching schedules
    startDateTime = DateTime.parse(widget.journey.startTime);
    endDateTime = DateTime.parse(widget.journey.endTime);
    formattedStart = DateFormat('MMM dd, yyyy – h:mm a').format(startDateTime);
    formattedEnd = DateFormat('MMM dd, yyyy – h:mm a').format(endDateTime);
    duration = endDateTime.difference(startDateTime);
    formattedDuration = "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
  }

  void onClickSetRoute(ScheduleDetails prevStation, ScheduleDetails nextStation) {
    showDialog(
      context: context,
      builder: (_) => SetRouteDialog(
        sourceStationId: prevStation.stationId,
        destinationStationId: nextStation.stationId,
        prevStation: prevStation,
        nextStation: nextStation,
        onRouteSelected: (routeId) async {
          UpdateScheduleRequest scheduleRequest = UpdateScheduleRequest(
            routeId: routeId,
          );
          final updateResponse = await ApiService.updateSchedule(
            prevStation.id,
            scheduleRequest,
          );
          if (!mounted) return;
          debugPrint("Update Response: ${updateResponse.toString()}, error: ${updateResponse.error}");
          if (updateResponse.isSuccess) {
            fetchSchedules(); // Refresh UI
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Route updated successfully")),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${updateResponse.error ?? 'Could not update route'}")),
            );
          }
        },
      ),
    );
  }

  void onClickAddStop(ScheduleDetails prevStation) {
    showDialog(
      context: context,
      builder: (_) => AddStopDialog(
        journeyId: widget.journey.journeyId,
        stationId: prevStation.stationId, // Replace with actual station ID
        routeId: prevStation.routeId??0,
        stopNumber: prevStation.stopNumber + 1,
        onStopAdded: (CreateScheduleRequest schedule) async {
          
          final createResponse = await ApiService.createSchedule(schedule);

          if (!mounted) return;
          if (createResponse.isSuccess) {
            fetchSchedules(); // Refresh UI
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Stop added successfully")),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${createResponse.error ?? 'Could not add stop'}")),
            );
          }
        },
      ),
    );
  }

  void fetchTrainDetails() {
    setState(() {
      isLoading = true;
    });
    ApiService.getTrainByNo(widget.journey.trainId).then((response) {
      if (response.isSuccess) {
        setState(() {
          trainDetails = response.data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void fetchSchedules() async {
    setState(() {
      isLoading = true;
    });

    final response = await ApiService.getSchedulesByJourney(widget.journey.journeyId);

    if (response.isSuccess && response.data != null) {
      setState(() {
        schedules = response.data!;
        double cumulativeDistance = 0;
        for (var schedule in schedules) {
          cumulativeDistance += schedule.distance ?? 0;
          schedule.setCumulativeDistance = cumulativeDistance;
        }
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatTime(String time) {
    final dateTime = DateTime.parse(time);
    return DateFormat('MMM dd, yyyy – h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final journey = widget.journey;

    return Scaffold(
      appBar: AppBarWidget(user: widget.user, title: "Journey Details"),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Journey Info
            Text("Journey #${journey.journeyId} [${journey.startStationName} to ${journey.endStationName}]", style: const TextStyle(color: Colors.white, fontSize: 24)),
            Text("${trainDetails != null ? trainDetails!.trainName : "Train"} | ${journey.trainId.toString().padLeft(6, '0')}", style: const TextStyle(color: Colors.white, fontSize: 20)),
            SizedBox(height: 12,),
            Text("Start: $formattedStart", style: const TextStyle(color: Colors.white, fontFamily: 'mono')),
            Text("End: $formattedEnd", style: const TextStyle(color: Colors.white, fontFamily: 'mono')),
            Text("Duration: $formattedDuration", style: const TextStyle(color: Colors.white, fontFamily: 'mono')),
            const SizedBox(height: 32),

            // Header + Add Button for Stops
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Somethings here
              ],
            ),

            const SizedBox(height: 16),

            // Stops Table
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: schedules.isEmpty ? 0 : schedules.length * 2 - 1,
                  itemBuilder: (context, index) {
                    // Schedule item
                    if (index.isEven) {
                      final scheduleIndex = index ~/ 2;
                      final schedule = schedules[scheduleIndex];
                      return ListTile(
                        title: Text("@${scheduleIndex + 1} ${schedule.stationName} * ${schedule.stationId}", style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                          "Arrival: ${formatTime(schedule.arrivalTime)} | Departure: ${formatTime(schedule.departureTime)}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // TODO: Implement delete stop logic
                          },
                        ),
                      );
                    } else {
                      // Button row between two schedule items
                      final prevStation = schedules[index ~/ 2];
                      final nextStation = schedules[index ~/ 2 + 1];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                onClickSetRoute(prevStation, nextStation);
                                debugPrint("Prev Station ID: ${prevStation.id}, Next Station ID: ${nextStation.id}");
                              },
                              child: const Text("Set Route", style: TextStyle(fontWeight: FontWeight.bold),),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                onClickAddStop(prevStation);
                              },
                              child: const Text("Add Stop", style: TextStyle(fontWeight: FontWeight.bold),),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Colors.grey[200]),
                                foregroundColor: WidgetStatePropertyAll(Colors.black),
                              ),
                              onPressed: (){},
                              child: Text("Route ~ ${prevStation.routeId??"Unset"}", style: TextStyle(fontWeight: FontWeight.bold),),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Colors.grey[200]),
                                foregroundColor: WidgetStatePropertyAll(Colors.black),
                              ),
                              onPressed: (){},
                              child: Text("V ${prevStation.distance?? 0} km", style: TextStyle(fontWeight: FontWeight.bold),),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Colors.grey[200]),
                                foregroundColor: WidgetStatePropertyAll(Colors.black),
                              ),
                              onPressed: (){},
                              child: Text("V ${prevStation.cumulativeDistance?? 0} km", style: TextStyle(fontWeight: FontWeight.bold),),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),

          ],
        ),
      ),
    );
  }
}
