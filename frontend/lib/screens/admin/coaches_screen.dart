import 'package:flutter/material.dart';
import 'package:frontend/data/models/train.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/models/coach.dart';
import 'package:frontend/data/services/api_services.dart';
import 'package:frontend/screens/admin/dialog/add_coach_dialog.dart';
import 'package:frontend/screens/admin/seat_screen.dart';
import 'package:frontend/widgets/app_bar.dart';

class CoachScreen extends StatefulWidget {
  final User user;
  final Train train;
  const CoachScreen({super.key, required this.user, required this.train});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  List<CoachResponse> coaches = [];

  int page = 1;
  int limit = 10;
  int total = 0;

  bool isLoading = false;
  String searchTerm = '';

  final TextEditingController _searchController = TextEditingController();

  void fetchCoaches() async {
    setState(() => isLoading = true);
    final response = await ApiService.getCoachesForTrain(
      page: page,
      limit: limit,
      trainId: widget.train.trainNo,
    );

    if (response.isSuccess && response.data != null) {
      final paginated = response.data!;
      setState(() {
        coaches = paginated.items;
        total = paginated.total;
      });
    }
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchCoaches();
  }

  void onClickCoach(CoachResponse coach) {
    // Navigate to the seat screen for the selected coach
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeatScreen(
          user: widget.user,
          train: widget.train,
          coach: coach,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(user: widget.user, title: widget.train.trainName),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          children: [
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
                        builder: (_) => AddCoachDialog(
                          onCoachAdded: () => fetchCoaches(),
                          train: widget.train,
                        ),
                      );
                    },
                    child: const Text("Add Coach", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                      hintText: "Search by coach name",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF272727),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        page = 1;
                        searchTerm = value.trim();
                      });
                      fetchCoaches();
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
                      fetchCoaches();
                    },
                    child: const Text("Search", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(width: 12),
                SizedBox(
                  height: 50,
                  width: 152,
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
                      fetchCoaches();
                    },
                    child: const Text("Delete Train", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  SizedBox(width: 160, child: Center(child: Text("Coach ID", style: TextStyle(fontWeight: FontWeight.bold)))),
                  SizedBox(width: 160, child: Center(child: Text("Coach Name", style: TextStyle(fontWeight: FontWeight.bold)))),
                  SizedBox(width: 160, child: Center(child: Text("Type", style: TextStyle(fontWeight: FontWeight.bold)))),
                  SizedBox(width: 160, child: Center(child: Text("Fare", style: TextStyle(fontWeight: FontWeight.bold)))),
                  SizedBox(width: 160, child: Center(child: Text("Train No", style: TextStyle(fontWeight: FontWeight.bold)))),
                  SizedBox(width: 160, child: Center(child: Text("Total Seats", style: TextStyle(fontWeight: FontWeight.bold)))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const CircularProgressIndicator()
            else if (coaches.isEmpty)
              const Text("No coaches found", style: TextStyle(color: Colors.white))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: coaches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final coach = coaches[index];
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
                        onPressed: () => onClickCoach(coach),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 160, child: Center(child: Text(coach.coachId.toString()))),
                            SizedBox(width: 160, child: Center(child: Text(coach.coachName))),
                            SizedBox(width: 160, child: Center(child: Text(coach.coachType))),
                            SizedBox(width: 160, child: Center(child: Text(coach.fare.toString()))),
                            SizedBox(width: 160, child: Center(child: Text(coach.trainId.toString().padLeft(6, '0')))),
                            SizedBox(width: 160, child: Center(child: Text(coach.totalSeats.toString()))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            if (!isLoading)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: page > 1
                        ? () {
                            setState(() => page--);
                            fetchCoaches();
                          }
                        : null,
                    style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFFD9D9D9))),
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
                            fetchCoaches();
                          }
                        : null,
                    style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFFD9D9D9))),
                    child: const Text("Next", style: TextStyle(color: Colors.black)),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
