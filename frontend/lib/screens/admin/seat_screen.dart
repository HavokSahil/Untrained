import 'package:flutter/material.dart';
import 'package:frontend/data/models/coach.dart';
import 'package:frontend/data/models/train.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/models/seat.dart';
import 'package:frontend/data/services/api_services.dart';
import 'package:frontend/screens/admin/dialog/add_seat_dialog.dart';
import 'package:frontend/widgets/app_bar.dart';

class SeatScreen extends StatefulWidget {
  final User user;
  final Train train;
  final CoachResponse coach;
  const SeatScreen({super.key, required this.user, required this.train, required this.coach});

  @override
  State<SeatScreen> createState() => _SeatScreenState();
}

class _SeatScreenState extends State<SeatScreen> {
  List<SeatResponse> seats = [];

  int page = 1;
  int limit = 10;
  int total = 0;

  bool isLoading = false;
  String searchTerm = '';

  final TextEditingController _searchController = TextEditingController();

  void fetchSeats() async {
    setState(() => isLoading = true);
    final response = await ApiService.getSeatsByCoach(
      page: page,
      limit: limit,
      coachId: widget.coach.coachId,
      trainId: widget.train.trainNo
    );

    if (response.isSuccess && response.data != null) {
      final paginated = response.data!;
      setState(() {
        seats = paginated.items;
        total = paginated.total;
      });
    }
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchSeats();
  }

  void onClickSeat(SeatResponse seat) {
    debugPrint("Seat clicked: ${seat.seatId}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(user: widget.user, title: "Seats for ${widget.coach.coachName}"),
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
                        builder: (_) => AddSeatDialog(
                          onSeatAdded: () => fetchSeats(),
                          coach: widget.coach,
                          train: widget.train,
                        ),
                      );
                    },
                    child: const Text("Add Seat", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                      hintText: "Search by seat number",
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
                      fetchSeats();
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
                      fetchSeats();
                    },
                    child: const Text("Search", style: TextStyle(fontWeight: FontWeight.bold)),
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
                  SizedBox(width: 160, child: Center(child: Text("Seat ID", style: TextStyle(fontWeight: FontWeight.bold)))),
                  SizedBox(width: 160, child: Center(child: Text("Seat Number", style: TextStyle(fontWeight: FontWeight.bold)))),
                  SizedBox(width: 160, child: Center(child: Text("Seat Type", style: TextStyle(fontWeight: FontWeight.bold)))),
                  SizedBox(width: 160, child: Center(child: Text("Seat Category", style: TextStyle(fontWeight: FontWeight.bold)))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const CircularProgressIndicator()
            else if (seats.isEmpty)
              const Text("No seats found", style: TextStyle(color: Colors.white))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: seats.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final seat = seats[index];
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
                        onPressed: () => onClickSeat(seat),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 160, child: Center(child: Text(seat.seatId.toString()))),
                            SizedBox(width: 160, child: Center(child: Text(seat.seatNo.toString()))),
                            SizedBox(width: 160, child: Center(child: Text(seat.seatType))),
                            SizedBox(width: 160, child: Center(child: Text(seat.seatCategory))),
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
                            fetchSeats();
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
                            fetchSeats();
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
