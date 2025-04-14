import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/widgets/app_bar.dart';

class SearchTrainScreen extends StatefulWidget {
  final User user;
  const SearchTrainScreen({super.key, required this.user});

  @override
  State<SearchTrainScreen> createState() => _SearchTrainScreenState();
}

class _SearchTrainScreenState extends State<SearchTrainScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(user: widget.user),
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "Search Train Screen",
          style: TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold
          ),
          ),
      ),
    );
  }
}