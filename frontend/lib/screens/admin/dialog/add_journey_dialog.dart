import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/api_services.dart';
import 'package:frontend/data/models/journey.dart'; // Assuming CreateJourneyRequest is here

class AddJourneyDialog extends StatefulWidget {
  final User user;
  final VoidCallback onJourneyCreated;

  const AddJourneyDialog({super.key, required this.user, required this.onJourneyCreated});

  @override
  State<AddJourneyDialog> createState() => _AddJourneyDialogState();
}

class _AddJourneyDialogState extends State<AddJourneyDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _trainIdController = TextEditingController();
  final TextEditingController _startStationIdController = TextEditingController();
  final TextEditingController _endStationIdController = TextEditingController();

  DateTime? _startTime;
  DateTime? _endTime;
  bool isLoading = false;

  // Function to show DateTime picker
  Future<void> _selectDateTime({bool startTime = true}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(pickedDate),
      );

      if (pickedTime != null) {
        setState(() {
          if (startTime) {
            _startTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            _startTimeController.text = _startTime!.toIso8601String();
          } else {
            _endTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            _endTimeController.text = _endTime!.toIso8601String();
          }
            
        });
      }
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start time')),
      );
      return;
    }

    final newJourney = CreateJourneyRequest(
      startTime: _startTime!.toIso8601String(),
      endTime: _endTime!.toIso8601String(),
      trainId: int.parse(_trainIdController.text.trim()),
      startStationId: int.parse(_startStationIdController.text.trim()),
      endStationId: int.parse(_endStationIdController.text.trim()),
    );

    setState(() => isLoading = true);

    final response = await ApiService.createJourney(newJourney);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (response.isSuccess) {
      Navigator.of(context).pop();
      widget.onJourneyCreated();
    } else {
      final errorMsg = response.error ?? "Failed to create journey";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      title: const Text("Create New Journey", style: TextStyle(color: Colors.white)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Start Time Field with DateTime Picker
              TextFormField(
                controller: _startTimeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Start Time',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: "Select date and time",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                readOnly: true,
                onTap: () => _selectDateTime(startTime: true), // Open the DateTime Picker
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Start time is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _endTimeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'End Time',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: "Select date and time",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                readOnly: true,
                onTap: () => _selectDateTime(startTime: false), // Open the DateTime Picker
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'End time is required' : null,
              ),
              const SizedBox(height: 12),
              // Train ID
              TextFormField(
                controller: _trainIdController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Train ID',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || int.tryParse(val) == null ? 'Invalid Train ID' : null,
              ),
              const SizedBox(height: 12),
              // Start Station ID
              TextFormField(
                controller: _startStationIdController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Start Station ID',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || int.tryParse(val) == null ? 'Invalid Start Station ID' : null,
              ),
              const SizedBox(height: 12),
              // End Station ID
              TextFormField(
                controller: _endStationIdController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'End Station ID',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || int.tryParse(val) == null ? 'Invalid End Station ID' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          child: isLoading
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator())
              : const Text("Create Journey"),
        ),
      ],
    );
  }
}
