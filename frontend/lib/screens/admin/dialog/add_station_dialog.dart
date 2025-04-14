import 'package:flutter/material.dart';
import 'package:frontend/data/models/station.dart';
import 'package:frontend/data/services/api_services.dart';

class AddStationDialog extends StatefulWidget {
  final VoidCallback onStationAdded;

  const AddStationDialog({super.key, required this.onStationAdded});

  @override
  State<AddStationDialog> createState() => _AddStationDialogState();
}

class _AddStationDialogState extends State<AddStationDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _stationNameController = TextEditingController();
  String? _stationType = 'ST'; // Default station type
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final stationName = _stationNameController.text.trim();
      final stationType = _stationType;

      if (!mounted || _stationType == null) return;

      final response = await ApiService.createStation(stationName: stationName, stationType: stationType!);

      if (response.isSuccess) {
        widget.onStationAdded();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add station")),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF121212),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Add Station", style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Seat Number
              TextFormField(
                controller: _stationNameController,
                decoration: const InputDecoration(
                  labelText: "Station Name",
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF272727),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? "Station name is required" : null,
              ),
              const SizedBox(height: 12),

              // Coach Type
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF272727),
                decoration: const InputDecoration(
                  labelText: "Station Type",
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF272727),
                ),
                style: const TextStyle(color: Colors.white),
                value: _stationType,
                items: StationType.values.map((type) {
                  return DropdownMenuItem(
                    value: type.name,
                    child: Text(type.name, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _stationType = value);
                },
                validator: (value) => value == null ? "Select a coach type" : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Color(0xFFD9D9D9)),
          ),
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Add", style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
