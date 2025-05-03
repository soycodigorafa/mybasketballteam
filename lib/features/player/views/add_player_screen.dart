import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../view_models/players_view_model.dart';

/// Screen with a form to add a new player
class AddPlayerScreen extends ConsumerStatefulWidget {
  final String teamId;

  const AddPlayerScreen({super.key, required this.teamId});

  @override
  ConsumerState<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends ConsumerState<AddPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  PlayerPosition _selectedPosition = PlayerPosition.pointGuard;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Create a new player with the form data
        final player = Player(
          name: _nameController.text.trim(),
          number: int.parse(_numberController.text.trim()),
          position: _selectedPosition,
          teamId: widget.teamId,
        );

        // Add the player using the PlayersViewModel
        await ref.read(playersProvider.notifier).addPlayer(player);

        // Show success message and navigate back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Player added successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding player: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Player')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter player name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Number field
            TextFormField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: 'Number',
                hintText: 'Enter jersey number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a number';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Please enter a valid number';
                }
                if (number <= 0 || number > 99) {
                  return 'Number must be between 1 and 99';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Position dropdown
            DropdownButtonFormField<PlayerPosition>(
              value: _selectedPosition,
              decoration: const InputDecoration(
                labelText: 'Position',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sports_basketball),
              ),
              items:
                  PlayerPosition.values.map((position) {
                    return DropdownMenuItem<PlayerPosition>(
                      value: position,
                      child: Text(position.displayName),
                    );
                  }).toList(),
              onChanged: (position) {
                if (position != null) {
                  setState(() {
                    _selectedPosition = position;
                  });
                }
              },
            ),
            const SizedBox(height: 32),

            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text(
                        'SAVE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
