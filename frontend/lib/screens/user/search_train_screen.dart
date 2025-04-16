import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/data/models/schedule.dart';
import 'package:frontend/data/models/station.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/api_services.dart';
import 'package:frontend/widgets/app_bar.dart';

class SearchTrainScreen extends StatefulWidget {
  final User user;
  const SearchTrainScreen({super.key, required this.user});

  @override
  State<SearchTrainScreen> createState() => _SearchTrainScreenState();
}

class _SearchTrainScreenState extends State<SearchTrainScreen> {
  final _startController = TextEditingController();
  final _destinationController = TextEditingController();

  StationResponse? _selectedStart;
  StationResponse? _selectedDestination;

  List<StationResponse> _startSuggestions = [];
  List<StationResponse> _destinationSuggestions = [];

  Timer? _debounce;
  DateTime _selectedDate = DateTime.now();
  List<JourneyBetweenStations> _journeys = [];

  OverlayEntry? _overlayEntry;

  final LayerLink _startLink = LayerLink();
  final LayerLink _destinationLink = LayerLink();

  bool _showStartSuggestions = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _startController.dispose();
    _destinationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onSearchChanged(String query, bool isStart) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        _clearSuggestions(isStart);
        return;
      }
      final response = await ApiService.getStationByName(query);
      final items = response.data?.items ?? [];
      setState(() {
        if (isStart) {
          _startSuggestions = items;
          _showStartSuggestions = true;
        } else {
          _destinationSuggestions = items;
        }
      });
      _showOverlay(isStart);
    });
  }

  void _clearSuggestions(bool isStart) {
    setState(() {
      if (isStart) {
        _startSuggestions = [];
        _showStartSuggestions = false;
      } else {
        _destinationSuggestions = [];
      }
    });
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onStationSelected(StationResponse station, bool isStart) {
    setState(() {
      if (isStart) {
        _selectedStart = station;
        _startController.text = station.stationName;
        _startSuggestions.clear();
        _showStartSuggestions = false;
      } else {
        _selectedDestination = station;
        _destinationController.text = station.stationName;
        _destinationSuggestions.clear();
      }
    });
    _removeOverlay();
    if (_selectedStart != null && _selectedDestination != null) {
      _fetchJourneys();
    }
  }

  void _fetchJourneys() async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final response = await ApiService.getJourneysBetweenStations(
      sourceStationId: _selectedStart!.stationId,
      destinationStationId: _selectedDestination!.stationId,
      date: formattedDate,
    );
    setState(() {
      _journeys = response.data?.items ?? [];
    });
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 10)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      if (_selectedStart != null && _selectedDestination != null) {
        _fetchJourneys();
      }
    }
  }

  String formatTime(String time) {
    final dateTime = DateTime.parse(time);
    return DateFormat('MMM dd, yyyy – h:mm a').format(dateTime);
  }

  void _showOverlay(bool isStart) {
    _removeOverlay();
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final overlay = Overlay.of(context);
    final size = renderBox.size;

    final suggestions = isStart ? _startSuggestions : _destinationSuggestions;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - 40,
        child: CompositedTransformFollower(
          link: isStart ? _startLink : _destinationLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 48),
          child: Material(
            color: Colors.grey[900],
            elevation: 4,
            child: ListView.builder(
              itemCount: min(5, suggestions.length),
              shrinkWrap: true,
              itemBuilder: (_, index) {
                final station = suggestions[index];
                return ListTile(
                  title: Text(station.stationName, style: const TextStyle(color: Colors.white)),
                  onTap: () => _onStationSelected(station, isStart),
                );
              },
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    required bool isStart,
  }) {
    return CompositedTransformTarget(
      link: isStart? _startLink : _destinationLink,
      child: TextField(
        controller: controller,
        onChanged: (value) => _onSearchChanged(value, isStart),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.black,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(user: widget.user, title: "Search Trains"),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                hint: 'From Station',
                controller: _startController,
                isStart: true,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                hint: 'To Station',
                controller: _destinationController,
                isStart: false,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                label: Text(
                  "Travel Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}",
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[850],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 30),
              if (_selectedStart != null && _selectedDestination != null)
                Text(
                  '${_selectedStart!.stationName} ➝ ${_selectedDestination!.stationName}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                )
              else
                const Text(
                  'Select your stations',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              const SizedBox(height: 20),
              // Header row
              (_journeys.isNotEmpty)? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  // border: Border.all(color: Colors.white),
                ),
                child: Table(
                  columnWidths: const {
                    0: FixedColumnWidth(80),
                    1: FixedColumnWidth(70),
                    2: FlexColumnWidth(100),
                    3: FlexColumnWidth(100),
                    4: FlexColumnWidth(100),
                    5: FixedColumnWidth(200),
                    6: FixedColumnWidth(200),
                    7: FixedColumnWidth(80),
                  },
                  children: const [
                    TableRow(
                      children: [
                        TableCell(child: Text("Journey ID", style: TextStyle(color: Colors.white))),
                        TableCell(child: Text("Train ID", style: TextStyle(color: Colors.white))),
                        TableCell(child: Text("Train Name", style: TextStyle(color: Colors.white))),
                        TableCell(child: Text("From", style: TextStyle(color: Colors.white))),
                        TableCell(child: Text("To", style: TextStyle(color: Colors.white))),
                        TableCell(child: Text("Start at", style: TextStyle(color: Colors.white))),
                        TableCell(child: Text("Reach at", style: TextStyle(color: Colors.white))),
                        TableCell(child: Text("Travel Time", style: TextStyle(color: Colors.white))),
                      ],
                    ),
                  ],
                ),
              ) : SizedBox(height: 0,),

              const SizedBox(height: 8),

              // Journey rows
              if (_journeys.isNotEmpty)
                ..._journeys.map((journey) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.symmetric(horizontal: BorderSide(color: Colors.white)),
                      ),
                      child: Table(
                        columnWidths: const {
                          0: FixedColumnWidth(80),
                          1: FixedColumnWidth(70),
                          2: FlexColumnWidth(100),
                          3: FlexColumnWidth(100),
                          4: FlexColumnWidth(100),
                          5: FixedColumnWidth(200),
                          6: FixedColumnWidth(200),
                          7: FixedColumnWidth(80),
                        },
                        children: [
                          TableRow(
                            children: [
                              Text(journey.journeyId.toString().padLeft(6, '0'), style: const TextStyle(color: Colors.white)),
                              Text(journey.trainId.toString().padLeft(6, '0'), style: const TextStyle(color: Colors.white)),
                              Text(journey.trainName ?? '', style: const TextStyle(color: Colors.white)),
                              Text(journey.startStation ?? '', style: const TextStyle(color: Colors.white)),
                              Text(journey.endStation ?? '', style: const TextStyle(color: Colors.white)),
                              Text(formatTime(journey.startTime!), style: const TextStyle(color: Colors.white)),
                              Text(formatTime(journey.endTime!), style: const TextStyle(color: Colors.white)),
                              Text(journey.travelTime != null ? '${journey.travelTime! ~/ 60} min' : '', style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ))
              else if (_selectedStart != null && _selectedDestination != null)
                const Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text("No journeys found.", style: TextStyle(color: Colors.white54)),
                ),

            ],
          ),
        ),
      ),
    );
  }
}
