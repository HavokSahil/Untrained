import 'package:flutter/material.dart';
import 'package:frontend/data/models/train.dart';
import 'package:frontend/data/services/api_services.dart';

class AddTrainDialog extends StatefulWidget {
  final VoidCallback onTrainAdded;

  const AddTrainDialog({super.key, required this.onTrainAdded});

  @override
  State<AddTrainDialog> createState() => _AddTrainDialogState();
}

class _AddTrainDialogState extends State<AddTrainDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _trainNoController = TextEditingController();
  final TextEditingController _trainNameController = TextEditingController();
  TrainType? _selectedType;

  bool _isSubmitting = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final trainNo = int.tryParse(_trainNoController.text.trim());
    final trainName = _trainNameController.text.trim();
    final trainType = _selectedType?.name;

    final response = await ApiService.addTrain(trainNo!, trainName, trainType!);

    if (!mounted) return;

    if (response.isSuccess) {
      Navigator.of(context).pop(); // Close dialog
      widget.onTrainAdded();       // Refresh train list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.error ?? "Failed to add train"),
        backgroundColor: Colors.red,
      ));
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      title: const Text("Add New Train", style: TextStyle(color: Colors.white)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _trainNoController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Train No",
                labelStyle: TextStyle(color: Colors.white70),
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value == null || value.isEmpty ? "Required" : null,
            ),
            TextFormField(
              controller: _trainNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Train Name",
                labelStyle: TextStyle(color: Colors.white70),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? "Required" : null,
            ),
            DropdownButtonFormField<TrainType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: "Train Type",
                labelStyle: TextStyle(color: Colors.white70),
              ),
              dropdownColor: const Color(0xFF272727),
              items: TrainType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedType = val;
                });
              },
              validator: (value) => value == null ? "Select a type" : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: const Text("Add Train", style: TextStyle(backgroundColor: Colors.white, color: Colors.black, fontWeight: FontWeight.bold),),
        ),
      ],
    );
  }
}
