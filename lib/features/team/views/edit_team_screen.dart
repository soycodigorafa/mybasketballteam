import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team.dart';
import '../providers/teams_providers.dart';

/// Screen for editing team information
class EditTeamScreen extends ConsumerStatefulWidget {
  final Team team;

  const EditTeamScreen({super.key, required this.team});

  @override
  ConsumerState<EditTeamScreen> createState() => _EditTeamScreenState();
}

class _EditTeamScreenState extends ConsumerState<EditTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _logoUrlController;
  late TextEditingController _descriptionController;
  late TextEditingController _coachNameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team.name);
    _logoUrlController = TextEditingController(text: widget.team.logoUrl ?? '');
    _descriptionController = TextEditingController(text: widget.team.description ?? '');
    _coachNameController = TextEditingController(text: widget.team.coachName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _logoUrlController.dispose();
    _descriptionController.dispose();
    _coachNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Team'),
        actions: [
          TextButton(
            onPressed: _saveTeam,
            child: const Text('SAVE'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team Logo Preview
                if (_logoUrlController.text.isNotEmpty) ...[
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        _logoUrlController.text,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildLogoPlaceholder('Invalid image URL');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else
                  Center(
                    child: _buildLogoPlaceholder('No logo'),
                  ),
                
                const SizedBox(height: 24),
                
                // Team Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Team Name *',
                    hintText: 'Enter team name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Team name is required';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Logo URL
                TextFormField(
                  controller: _logoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Logo URL',
                    hintText: 'Enter URL for team logo (optional)',
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Coach Name
                TextFormField(
                  controller: _coachNameController,
                  decoration: const InputDecoration(
                    labelText: 'Coach Name',
                    hintText: 'Enter coach name (optional)',
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Team Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Team Description',
                    hintText: 'Enter team description (optional)',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoPlaceholder(String text) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.sports_basketball,
            size: 40,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTeam() async {
    if (_formKey.currentState!.validate()) {
      final teamsViewModel = ref.read(teamsNotifierProvider.notifier);
      
      final updatedTeam = widget.team.copyWith(
        name: _nameController.text.trim(),
        logoUrl: _logoUrlController.text.trim().isEmpty 
            ? null 
            : _logoUrlController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        coachName: _coachNameController.text.trim().isEmpty 
            ? null 
            : _coachNameController.text.trim(),
      );
      
      await teamsViewModel.updateTeam(updatedTeam);
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }
}
