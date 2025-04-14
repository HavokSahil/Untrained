import 'package:flutter/material.dart';
import 'package:frontend/data/models/route.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/api_services.dart';

class AddRouteDialog extends StatefulWidget {
  final User user;
  final VoidCallback onRouteCreated;

  const AddRouteDialog({super.key, required this.user, required this.onRouteCreated});

  @override
  State<AddRouteDialog> createState() => _AddRouteDialogState();
}

class _AddRouteDialogState extends State<AddRouteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _routeNameController = TextEditingController();
  final _distanceController = TextEditingController();

  int? _startStationId;
  bool isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final route = CreateRoute(
      routeName: _routeNameController.text.trim(),
      sourceStationId: _startStationId!,
    );

    final response = await ApiService.createRoute(route);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (response.isSuccess) {
      Navigator.of(context).pop(); // Close dialog
      widget.onRouteCreated();     // Notify parent
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.error ?? "Failed to create route")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      title: const Text("Create New Route", style: TextStyle(color: Colors.white)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Route Name
              TextFormField(
                controller: _routeNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Route Name',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Start Station ID
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Start Station ID',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => _startStationId = int.tryParse(val),
                validator: (val) =>
                    val == null || int.tryParse(val) == null ? 'Invalid station ID' : null,
              ),
              const SizedBox(height: 12),
              // Distance
              TextFormField(
                controller: _distanceController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Distance (in km)',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || double.tryParse(val) == null
                    ? 'Enter a valid distance'
                    : null,
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
              : const Text("Create Route"),
        ),
      ],
    );
  }
}
