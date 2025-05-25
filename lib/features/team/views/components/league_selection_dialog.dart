import 'package:flutter/material.dart';
import '../../models/league.dart';

/// Dialog for selecting a league for a team
class LeagueSelectionDialog extends StatefulWidget {
  final League? currentLeague;
  final List<League> leagues;

  const LeagueSelectionDialog({
    super.key,
    this.currentLeague,
    required this.leagues,
  });

  @override
  State<LeagueSelectionDialog> createState() => _LeagueSelectionDialogState();
}

class _LeagueSelectionDialogState extends State<LeagueSelectionDialog> {
  late TextEditingController _nameController;
  late TextEditingController _logoUrlController;
  League? _selectedLeague;
  bool _isAddingNew = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _logoUrlController = TextEditingController();
    _selectedLeague = widget.currentLeague;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isAddingNew ? 'Add New League' : 'Select League'),
      content: SingleChildScrollView(
        child: _isAddingNew ? _buildAddLeagueForm() : _buildLeagueList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        if (_isAddingNew)
          TextButton(
            onPressed: _addNewLeague,
            child: const Text('ADD'),
          )
        else
          TextButton(
            onPressed: () => Navigator.pop(context, _selectedLeague),
            child: const Text('SELECT'),
          ),
      ],
    );
  }

  Widget _buildLeagueList() {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.leagues.map((league) => 
            RadioListTile<League>(
              title: Text(league.name),
              subtitle: league.logoUrl != null && league.logoUrl!.isNotEmpty
                  ? Text('Logo: ${league.logoUrl}', 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis)
                  : null,
              value: league,
              groupValue: _selectedLeague,
              onChanged: (value) {
                setState(() {
                  _selectedLeague = value;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('ADD NEW LEAGUE'),
              onPressed: () {
                setState(() {
                  _isAddingNew = true;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddLeagueForm() {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'League Name *',
              hintText: 'Enter league name',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _logoUrlController,
            decoration: const InputDecoration(
              labelText: 'League Logo URL',
              hintText: 'Enter logo image URL (optional)',
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text('BACK TO SELECTION'),
            onPressed: () {
              setState(() {
                _isAddingNew = false;
              });
            },
          ),
        ],
      ),
    );
  }

  void _addNewLeague() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('League name is required'),
        ),
      );
      return;
    }

    final logoUrl = _logoUrlController.text.trim();
    final newLeague = League(
      name: name,
      logoUrl: logoUrl.isEmpty ? null : logoUrl,
    );

    Navigator.pop(context, newLeague);
  }
}
