import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/screens/admin/journey_screen.dart';
import 'package:frontend/screens/admin/route_screen.dart';
import 'package:frontend/screens/admin/schedule_screen.dart';
import 'package:frontend/screens/admin/station_screen.dart';
import 'package:frontend/screens/admin/stats_screen.dart';
import 'package:frontend/screens/admin/train_screen.dart';
import 'package:frontend/screens/user/booking_history_screen.dart';
import 'package:frontend/screens/user/booking_screen.dart';
import 'package:frontend/screens/user/live_station_screen.dart';
import 'package:frontend/screens/user/live_train_screen.dart';
import 'package:frontend/screens/user/pnr_status_screen.dart';
import 'package:frontend/screens/user/search_train_screen.dart';
import 'package:frontend/widgets/app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key
  });

  static final Map<String, Widget Function(BuildContext, User)> adminOptions = {
    "Trains":(context, user) => TrainScreen(user: user),
    "Journeys":(context, user) => JourneyScreen(user: user),
    "Schedule":(context, user) => ScheduelScreen(user: user),
    "Stats":(context, user) => StatScreen(user: user),
    "Routes":(context, user) => RouteScreen(user: user),
    "Stations":(context, user) => StationScreen(user: user),
  };

  static final Map<String, Widget Function(BuildContext, User)> userOptions = {
    "Booking History": (context, user) => BookingHistoryScreen(user: user),
    "Book Ticket": (context, user) => BookingScreen(user: user),
    "Live Station": (context, user) => LiveStationScreen(user: user),
    "Live Train": (context, user) => LiveTrainScreen(user: user),
    "PNR Status": (context, user) => PnrStatusScreen(user: user),
    "Search Train": (context, user) => SearchTrainScreen(user: user)
  };

  @override
  State<StatefulWidget> createState() =>  _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late User user;
  late List<MapEntry<String, Widget Function(BuildContext, User)>> options;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    user = ModalRoute.of(context)!.settings.arguments as User;
    options = (user.role == Role.admin)?HomeScreen.adminOptions.entries.toList(): HomeScreen.userOptions.entries.toList();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBarWidget(user: user),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 156, vertical: 64),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 32,
            mainAxisSpacing: 32,
            childAspectRatio: 1.5
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final label = options[index].key;
            final builder = options[index].value;
            return Padding(
              padding: EdgeInsets.all(8),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Color(0xFF212121)),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ))
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => builder(ctx, user))
                  );
                },
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'mono'
                  ))
              ),
            );
          },
        ),
      ),
    );
  }
}