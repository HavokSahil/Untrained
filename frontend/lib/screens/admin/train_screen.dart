import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/models/train.dart';
import 'package:frontend/data/services/api_services.dart';
import 'package:frontend/screens/admin/coaches_screen.dart';
import 'package:frontend/screens/admin/dialog/add_train_dialog.dart';
import 'package:frontend/widgets/app_bar.dart';

class TrainScreen extends StatefulWidget {
  final User user;
  const TrainScreen({super.key, required this.user});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  List<TrainDetails> trains = [];

  int page = 1;
  int limit = 10;
  int total = 0;

  String searchTerm = '';

  bool isLoading = false;
  bool searchByName = true;

  String selectedTrainType = "ALL";

  final TextEditingController _searchController = TextEditingController();

  void fetchTrains() async {
    setState(() => isLoading = true);
    final response = await ApiService.getDetailedTrains(
      page: page,
      limit: limit,
      trainName: (searchTerm.isNotEmpty && searchByName) ? searchTerm : null,
      trainNo: (searchTerm.isNotEmpty && !searchByName)? int.tryParse(searchTerm, radix: 10): null,
      trainType: selectedTrainType
    );

    if (response.isSuccess && response.data != null) {
      final paginated = response.data!;
      setState(() {
        trains = paginated.items;
        total = paginated.total;
      });
    } else {
      // Show error if needed
    }
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchTrains();
  }

  void onClickTrain(TrainDetails trainDetails) {
    // Handle train click
    Train train = Train(trainName: trainDetails.trainName, trainNo: trainDetails.trainNo, trainType: trainDetails.trainType);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => CoachScreen(user: widget.user, train: train))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(user: widget.user, title: "Train"),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          children: [
            // Search bar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: 124,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddTrainDialog(
                            onTrainAdded: () {
                              fetchTrains(); // Refresh list after adding
                            },
                          ),
                        );
                      },
                    child: const Text("Add Train", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),)
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
                      hintText: searchByName?'Search by train name': 'Search by train no',
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
                        searchTerm = value.trim();
                      });
                      fetchTrains();
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
                        searchTerm = _searchController.text.trim();
                      });
                      fetchTrains();
                    },
                    child: const Text("Search", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ),
                SizedBox(width: 12),
                SizedBox(
                  height: 50,
                  width: 124,
                  child: DropdownButtonFormField<String>(
                    dropdownColor: Color(0xFF272727),
                    decoration: InputDecoration(
                      labelText: "Train Type",
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 32),
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    value: selectedTrainType,
                    items: [
                      const DropdownMenuItem(
                        value: 'ALL',
                        child: Text('ALL', style: TextStyle(color: Colors.white)),
                      ),
                      ...TrainType.values.map((type) {
                        final typeStr = type.name; // or use type.toString().split('.').last;
                        return DropdownMenuItem(
                          value: typeStr,
                          child: Text(typeStr[0].toUpperCase() + typeStr.substring(1), style: TextStyle(color: Colors.white)),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedTrainType = value!;
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    value: "train_name",
                    items: [
                      const DropdownMenuItem(
                        value: 'train_no',
                        child: Text('Number', style: TextStyle(color: Colors.white)),
                      ),
                      const DropdownMenuItem(
                        value: 'train_name',
                        child: Text('Name', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        searchByName = (value == "train_name");
                      });
                    },
                  )
                ),
                SizedBox(width: 12,),
                const SizedBox(width: 12),
                SizedBox(
                  height: 50,
                  width: 132,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Color(0xFFD9D9D9)),
                      foregroundColor: WidgetStatePropertyAll(Colors.black),
                    ),
                    onPressed: () {
                    },
                    child: const Text("Random Train", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24,),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 190,
                    child: const Text("Train No", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(
                    width: 110,
                    child: const Text("Type", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(
                    width: 284,
                    child: const Text("Name", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(
                    width: 110,
                    child: const Text("Coaches", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(
                    width: 110,
                    child: const Text("Seats", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(
                    width: 110,
                    child: const Text("Journeys", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(
                    width: 204,
                    child: const Text("Upcoming Journeys", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Train list
            if (isLoading)
              const CircularProgressIndicator()
            else if (trains.isEmpty)
              const Text("No trains found", style: TextStyle(color: Colors.white))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: trains.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.black),
                  itemBuilder: (context, index) {
                    final train = trains[index];
                    return SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Color(0xFF212121)),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ))
                        ),
                        onPressed: () => onClickTrain(train),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 190,
                              child: Text(
                                train.trainNo.toString().padLeft(6, '0'),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              width: 110,
                              child: Text(
                                train.trainType.toString().split('.').last,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              width: 284,
                              child: Text(
                                train.trainName,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              width: 110,
                              child: Text(
                                train.coaches.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              width: 110,
                              child: Text(
                                train.seats.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              width: 110,
                              child: Text(
                                train.journeys.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              width: 204,
                              child: Text(
                                train.upcomingJourneys.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )

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
                            fetchTrains();
                          }
                        : () => (),
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFFD9D9D9))),
                    child: const Text("Previous", style: TextStyle(color: Colors.black),),
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
                            fetchTrains();
                          }
                        : () => (),
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFFD9D9D9))),
                    child: const Text("Next", style: TextStyle(color: Colors.black),),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
