import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/models/station.dart';
import 'package:frontend/data/services/api_services.dart';
import 'package:frontend/widgets/app_bar.dart';
import 'package:frontend/screens/admin/dialog/add_station_dialog.dart';

class StationScreen extends StatefulWidget {
  final User user;
  const StationScreen({super.key, required this.user});

  @override
  State<StationScreen> createState() => _StationScreenState();
}

class _StationScreenState extends State<StationScreen> {
  List<StationResponse> stations = [];
  int page = 1;
  int limit = 10;
  int total = 0;
  bool isLoading = false;
  String searchTerm = '';
  String? stationType = "ALL";
  SearchBy searchBy = SearchBy.name;

  final TextEditingController _searchController = TextEditingController();

  void fetchStations() async {
    setState(() => isLoading = true);
    final response = await ApiService.getStations(
      page: page,
      limit: limit,
      stationId:    (searchBy == SearchBy.id) ?  int.tryParse(searchTerm): null,
      stationName:  (searchBy == SearchBy.name) ? searchTerm : null,
      stationType:  (stationType != "ALL") ? stationType : null,
    );

    if (response.isSuccess && response.data != null) {
      final paginated = response.data!;
      setState(() {
        stations = paginated.items;
        total = paginated.total;
      });
    }
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchStations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(user: widget.user, title: "Stations"),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          children: [
            // Top bar with actions
            Row(
              children: [
                SizedBox(
                  height: 50,
                  width: 124,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AddStationDialog(
                          onStationAdded: () => fetchStations(),
                        ),
                      );
                    },
                    child: const Text("Add Station", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                      hintText: "Search by ${searchBy.name}",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF272727),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        page = 1;
                        searchTerm = value.trim();
                      });
                      fetchStations();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 50,
                  width: 124,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Color(0xFFD9D9D9)),
                      foregroundColor: WidgetStatePropertyAll(Colors.black),
                    ),
                    onPressed: () {
                      setState(() {
                        page = 1;
                        searchTerm = _searchController.text.trim();
                      });
                      fetchStations();
                    },
                    child: const Text("Search", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 50,
                  width: 124,
                  child: DropdownButtonFormField<String>(
                    dropdownColor: Color(0xFF272727),
                    decoration: InputDecoration(
                      labelText: "Station Type",
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 24),
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    value: stationType,
                    items: [
                      DropdownMenuItem(value: "ALL", child: Text("ALL", style: TextStyle(color: Colors.white, fontSize: 12),)),
                      ...StationType.values.map((value) {
                        return DropdownMenuItem(
                          value: value.name,
                          child: Text(value.name.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 12),),
                        );
                      })
                    ],
                    onChanged: (value) {
                      setState(() {
                        stationType = value;
                      });
                    },
                  )
                ),
                SizedBox(width: 12),
                SizedBox(
                  height: 50,
                  width: 124,
                  child: DropdownButtonFormField<String>(
                    dropdownColor: Color(0xFF272727),
                    decoration: InputDecoration(
                      labelText: "Search by",
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 24),
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    value: searchBy.name,
                    items: SearchBy.values.map((value) {
                      return DropdownMenuItem(
                        value: value.name,
                        child: Text(value.name.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 12),),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        searchBy = value! == "name"
                            ? SearchBy.name
                                : SearchBy.id;
                      });
                    },
                  )
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Table headers
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  SizedBox(width: 200, child: Center(child: Text("Station ID", style: TextStyle(fontWeight: FontWeight.bold)))),
                  SizedBox(width: 300, child: Center(child: Text("Station Name", style: TextStyle(fontWeight: FontWeight.bold)))),
                  SizedBox(width: 200, child: Center(child: Text("Type", style: TextStyle(fontWeight: FontWeight.bold)))),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Body
            if (isLoading)
              const CircularProgressIndicator()
            else if (stations.isEmpty)
              const Text("No stations found", style: TextStyle(color: Colors.white))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: stations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final station = stations[index];
                    return SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: const WidgetStatePropertyAll(Color(0xFF212121)),
                          foregroundColor: const WidgetStatePropertyAll(Colors.white),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                        ),
                        onPressed: () {
                          // Optionally implement edit or view details
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 200, child: Center(child: Text(station.stationId.toString()))),
                            SizedBox(width: 300, child: Center(child: Text(station.stationName))),
                            SizedBox(width: 200, child: Center(child: Text(station.stationType))),
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
                            fetchStations();
                          }
                        : null,
                    style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFFD9D9D9))),
                    child: const Text("Previous", style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(width: 16),
                  Text("Page $page of ${((total + limit - 1) / limit).floor()}",
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: (page * limit) < total
                        ? () {
                            setState(() => page++);
                            fetchStations();
                          }
                        : null,
                    style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFFD9D9D9))),
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
  name,
  id,
}