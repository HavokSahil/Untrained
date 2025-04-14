import 'package:flutter/material.dart';
import 'package:frontend/data/models/coach.dart';
import 'package:frontend/data/models/seat.dart';  // Assuming you have a Seat model
import 'package:frontend/data/models/train.dart';
import 'package:frontend/data/services/api_services.dart';

class AddSeatDialog extends StatefulWidget {
  final VoidCallback onSeatAdded;
  final Train train;
  final CoachResponse coach;
  const AddSeatDialog({super.key, required this.onSeatAdded, required this.train, required this.coach});

  @override
  State<AddSeatDialog> createState() => _AddSeatDialogState();
}

class _AddSeatDialogState extends State<AddSeatDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _seatNumberController = TextEditingController();
  String? selectedSeatType = SeatType.values.first.name;
  String? selectedSeatCategory = SeatCategory.values.first.name;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || selectedSeatCategory == null || selectedSeatType == null) return;

    setState(() => isLoading = true);

    final seat = CreateSeat(
      seatNo: int.parse(_seatNumberController.text.trim()),
      coachId: widget.coach.coachId,
      seatType: selectedSeatType!,
      seatCategory: selectedSeatCategory!,
    );

    final response = await ApiService.createSeat(
      trainId: widget.train.trainNo,
      coachId: widget.coach.coachId,
      seat: seat,
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    if (response.isSuccess) {
      widget.onSeatAdded();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add seat")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF121212),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Add Seat", style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Seat Number
              TextFormField(
                controller: _seatNumberController,
                decoration: const InputDecoration(
                  labelText: "Seat Number",
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF272727),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? "Seat number is required" : null,
              ),
              const SizedBox(height: 12),

              // Coach Type
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF272727),
                decoration: const InputDecoration(
                  labelText: "Seat Type",
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF272727),
                ),
                style: const TextStyle(color: Colors.white),
                value: selectedSeatType,
                items: SeatType.values.map((type) {
                  return DropdownMenuItem(
                    value: type.name,
                    child: Text(type.name, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedSeatType = value);
                },
                validator: (value) => value == null ? "Select a coach type" : null,
              ),
              const SizedBox(height: 12),

              // Train Dropdown
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF272727),
                decoration: const InputDecoration(
                  labelText: "Seat Category",
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF272727),
                ),
                style: const TextStyle(color: Colors.white),
                value: selectedSeatCategory,
                items: SeatCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category.name,
                    child: Text(category.name, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedSeatCategory = value);
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
