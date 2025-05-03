import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team.dart';
import '../view_models/teams_view_model.dart';

/// Screen with a form to add a new team
class AddTeamScreen extends ConsumerStatefulWidget {
  const AddTeamScreen({super.key});

  @override
  ConsumerState<AddTeamScreen> createState() => _AddTeamScreenState();
}

class _AddTeamScreenState extends ConsumerState<AddTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _coachNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _logoUrlController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _coachNameController.dispose();
    _descriptionController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Create a new team with the form data
        final team = Team(
          name: _nameController.text.trim(),
          coachName: _coachNameController.text.trim().isNotEmpty 
              ? _coachNameController.text.trim() 
              : null,
          description: _descriptionController.text.trim().isNotEmpty 
              ? _descriptionController.text.trim() 
              : null,
          logoUrl: _logoUrlController.text.trim().isNotEmpty 
              ? _logoUrlController.text.trim() 
              : null,
        );

        // Add the team using the TeamsViewModel
        await ref.read(teamsProvider.notifier).addTeam(team);

        // Show success message and navigate back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Team added successfully'),
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
              content: Text('Error adding team: ${e.toString()}'),
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
      appBar: AppBar(title: const Text('Add New Team')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Team name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Team Name',
                hintText: 'Enter team name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sports_basketball),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a team name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Coach name field
            TextFormField(
              controller: _coachNameController,
              decoration: const InputDecoration(
                labelText: 'Coach Name (Optional)',
                hintText: 'Enter coach name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter team description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Logo URL field
            TextFormField(
              controller: _logoUrlController,
              decoration: const InputDecoration(
                labelText: 'Logo URL (Optional)',
                hintText: 'Enter logo image URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
              ),
              keyboardType: TextInputType.url,
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
              child: _isSubmitting
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
