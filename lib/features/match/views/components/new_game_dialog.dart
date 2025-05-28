import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/match.dart';
import '../../view_models/live_game_view_model.dart';
import '../../../team/models/team.dart';

class NewGameDialog extends ConsumerStatefulWidget {
  final Team team;

  const NewGameDialog({super.key, required this.team});

  @override
  ConsumerState<NewGameDialog> createState() => _NewGameDialogState();
}

class _NewGameDialogState extends ConsumerState<NewGameDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedLeagueId;
  late TextEditingController _enemyTeamController;

  @override
  void initState() {
    super.initState();
    _enemyTeamController = TextEditingController();

    // If the team has leagues, select the first one by default
    if (widget.team.leagues.isNotEmpty) {
      _selectedLeagueId = widget.team.leagues.first.id;
    }
  }

  @override
  void dispose() {
    _enemyTeamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We'll use the leagues directly from the team object

    return AlertDialog(
      title: const Text('New Live Game'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // League dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'League',
                border: OutlineInputBorder(),
              ),
              value: _selectedLeagueId,
              items:
                  widget.team.leagues.map((leagueId) {
                    return DropdownMenuItem<String>(
                      value: leagueId.id,
                      // Just show the league ID as the name for now
                      // In a real app, you'd fetch the league details
                      child: Text(leagueId.name),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLeagueId = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a league';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Enemy team name input
            TextFormField(
              controller: _enemyTeamController,
              decoration: const InputDecoration(
                labelText: 'Opponent Team',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter opponent team name';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(onPressed: _startGame, child: const Text('START GAME')),
      ],
    );
  }

  void _startGame() {
    if (_formKey.currentState!.validate()) {
      if (_selectedLeagueId != null) {
        // Create a new match
        final newMatch = Match(
          leagueId: _selectedLeagueId!,
          homeTeamId: widget.team.id,
          homeTeamName: widget.team.name,
          homeTeamScore: 0,
          awayTeamId: 'opponent', // Placeholder ID for opponent
          awayTeamName: _enemyTeamController.text,
          awayTeamScore: 0,
          date: DateTime.now(),
        );

        // Set the current match in the provider
        ref.read(currentLiveMatchProvider.notifier).state = newMatch;

        // Close the dialog
        Navigator.pop(context, newMatch);
      }
    }
  }
}
