import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/models/journey.dart';
import 'package:frontend/data/services/api_services.dart';
import 'package:frontend/screens/admin/dialog/add_journey_dialog.dart';
import 'package:frontend/screens/admin/journey_detail_screen.dart';
import 'package:frontend/widgets/app_bar.dart';
import 'package:intl/intl.dart';

class JourneyScreen extends StatefulWidget {
  final User user;
  const JourneyScreen({super.key, required this.user});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  List<JourneyDetails> journeys = [];

  int page = 1;
  int limit = 10;
  int total = 0;

  bool isLoading = false;

  String searchQuery = "";
  SearchBy searchBy = SearchBy.JourneyId;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchJourneys();
  }

  void fetchJourneys() async {
    setState(() => isLoading = true);

    final response = await ApiService.getDetailedJourneys(
      page: page,
      limit: limit,
      journeyId: (searchBy == SearchBy.JourneyId) ? int.tryParse(searchQuery) : null,
      trainId: (searchBy == SearchBy.TrainId) ? int.tryParse(searchQuery) : null,
      startStationName: (searchBy == SearchBy.StartStationName) ? searchQuery : null,
      endStationName: (searchBy == SearchBy.EndStationName) ? searchQuery : null,
    );

    if (response.isSuccess && response.data != null) {
      final paginated = response.data!;
      setState(() {
        journeys = paginated.items;
        total = paginated.total;
      });
    } else {
      // Handle error if needed
    }

    setState(() => isLoading = false);
  }

  void onSearchChanged(String query) {
    setState(() {
      searchQuery = query.trim();
    });
    fetchJourneys();
  }

  String formatTime(String time) {
    final dateTime = DateTime.parse(time);
    return DateFormat('MMM dd, yyyy – h:mm a').format(dateTime);
  }

  void onJourneyClicked(JourneyDetails journey) {
    // Navigate to JourneyDetailScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JourneyDetailScreen(user: widget.user, journey: journey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(user: widget.user, title: "Journeys"),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          children: [
            // Header Row with Search Bar
            Row(
              children: [
                SizedBox(
                  height: 50,
                  width: 152,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AddJourneyDialog(
                          user: widget.user,
                          onJourneyCreated: () => fetchJourneys(),
                        ),
                      );
                    },
                    child: const Text(
                      "Add Journey",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 50,
                  width: 420,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 32),
                      hintText: "Search by ${searchBy.name}",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF272727),
                      focusColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        page = 1;
                        searchQuery = value.trim();
                      });
                      fetchJourneys();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 50,
                  width: 124,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Color(0xFFD9D9D9)),
                      foregroundColor: WidgetStatePropertyAll(Colors.black)
                    ),
                    onPressed: () {
                      setState(() {
                        page = 1;
                        searchQuery = _searchController.text.trim();
                      });
                      fetchJourneys();
                    },
                    child: const Text("Search", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ),
                const SizedBox(width: 12),
                // Dropdown for Search By
                SizedBox(
                  height: 50,
                  width: 180,
                  child: DropdownButtonFormField<SearchBy>(
                    dropdownColor: Color(0xFF272727),
                    decoration: InputDecoration(
                      labelText: "Search By",
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    value: searchBy,
                    items: SearchBy.values.map((SearchBy value) {
                      return DropdownMenuItem<SearchBy>(
                        value: value,
                        child: Text(value.name, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        searchBy = value!;
                      });
                    },
                  )
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Table Header
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(width: 120, child: Text("Journey ID", style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 160, child: Text("Train No", style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 200, child: Text("Start Time", style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 200, child: Text("End Time", style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 200, child: Text("Start Station", style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 200, child: Text("Final Station", style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (isLoading)
              const CircularProgressIndicator()
            else if (journeys.isEmpty)
              const Text("No journeys found", style: TextStyle(color: Colors.white))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: journeys.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.black),
                  itemBuilder: (context, index) {
                    final journey = journeys[index];
                    return SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Color(0xFF212121)),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          )),
                        ),
                        onPressed: () {
                          onJourneyClicked(journey);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 120, child: Text(journey.journeyId.toString())),
                            SizedBox(width: 160, child: Text(journey.trainId.toString().padLeft(6, '0'))),
                            SizedBox(width: 200, child: Text(formatTime(journey.startTime))),
                            SizedBox(width: 200, child: Text(formatTime(journey.endTime))),
                            SizedBox(width: 200, child: Text(journey.startStationName)),
                            SizedBox(width: 200, child: Text(journey.endStationName)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Pagination
            if (!isLoading)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: page > 1
                        ? () {
                            setState(() => page--);
                            fetchJourneys();
                          }
                        : null,
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFFD9D9D9))),
                    child: const Text("Previous", style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Page $page of ${((total + limit - 1) / limit).floor()}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: (page * limit) < total
                        ? () {
                            setState(() => page++);
                            fetchJourneys();
                          }
                        : null,
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFFD9D9D9))),
                    child: const Text("Next", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

enum SearchBy {
  JourneyId,
  TrainId,
  StartStationName,
  EndStationName,
}
