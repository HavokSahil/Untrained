import 'package:flutter/material.dart';
import 'package:frontend/data/models/coach.dart';
import 'package:frontend/data/models/train.dart';
import 'package:frontend/data/services/api_services.dart';

class AddCoachDialog extends StatefulWidget {
  final VoidCallback onCoachAdded;
  final Train train;
  const AddCoachDialog({super.key, required this.onCoachAdded, required this.train});

  @override
  State<AddCoachDialog> createState() => _AddCoachDialogState();
}

class _AddCoachDialogState extends State<AddCoachDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _coachNameController = TextEditingController();
  final TextEditingController _fareController = TextEditingController();

  bool isLoading = false;

  String? selectedCoachType;
  int? selectedTrainId;

  List<TrainDetails> trains = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || selectedTrainId == null || selectedCoachType == null) return;

    setState(() => isLoading = true);

    final coach = CreateCoach(
      coachName: _coachNameController.text.trim(),
      coachType: (selectedCoachType! == "S2")? "2S": selectedCoachType!,
      fare: double.parse(_fareController.text.trim()),
      trainId: widget.train.trainNo,
    );

    final response = await ApiService.createCoach(coach);
    setState(() => isLoading = false);

    if (!mounted) return;

    if (response.isSuccess) {
      widget.onCoachAdded();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add coach")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF121212),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Add Coach", style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Coach Name
              TextFormField(
                controller: _coachNameController,
                decoration: const InputDecoration(
                  labelText: "Coach Name",
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF272727),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? "Coach name is required" : null,
              ),
              const SizedBox(height: 12),

              // Coach Type
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF272727),
                decoration: const InputDecoration(
                  labelText: "Coach Type",
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF272727),
                ),
                style: const TextStyle(color: Colors.white),
                value: selectedCoachType,
                items: CoachType.values.map((type) {
                  return DropdownMenuItem(
                    value: type.name,
                    child: Text(type.name, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedCoachType = value);
                },
                validator: (value) => value == null ? "Select a coach type" : null,
              ),
              const SizedBox(height: 12),

              // Fare
              TextFormField(
                controller: _fareController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Fare",
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF272727),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? "Fare is required" : null,
              ),
              const SizedBox(height: 12),

              // Train Dropdown
              DropdownButtonFormField<int>(
                dropdownColor: const Color(0xFF272727),
                decoration: const InputDecoration(
                  labelText: "Train",
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF272727),
                ),
                style: const TextStyle(color: Colors.white),
                value: selectedTrainId,
                items: [
                  DropdownMenuItem(
                    value: widget.train.trainNo,
                    child:  Text(widget.train.trainName, style: const TextStyle(color: Colors.white))
                  ),
                ],
                onChanged: (value) {
                  setState(() => selectedTrainId = value);
                },
                validator: (value) => value == null ? "Select a train" : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _submit,
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Color(0xFFD9D9D9)),
          ),
          child: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Add", style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
