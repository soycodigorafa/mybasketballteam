import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/match.dart';
import '../view_models/matches_view_model.dart';
import '../../team/view_models/teams_view_model.dart';

/// Screen for adding a new match
class AddMatchScreen extends ConsumerStatefulWidget {
  final String leagueId;
  final String teamId;

  const AddMatchScreen({
    super.key,
    required this.leagueId,
    required this.teamId,
  });

  @override
  ConsumerState<AddMatchScreen> createState() => _AddMatchScreenState();
}

class _AddMatchScreenState extends ConsumerState<AddMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _homeTeamId;
  late String _homeTeamName;
  int _homeTeamScore = 0;
  String _awayTeamId = '';
  String _awayTeamName = '';
  int _awayTeamScore = 0;
  DateTime _matchDate = DateTime.now();
  String _location = '';
  String _notes = '';
  bool _isHomeTeam =
      true; // Track if the user's team is the home team to help with displaying stats later

  @override
  void initState() {
    super.initState();
    // Default to user's team as home team
    _homeTeamId = widget.teamId;

    // Will be populated in didChangeDependencies
    _homeTeamName = '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the team name for the current team
    final team = ref.read(teamByIdProvider(widget.teamId));
    if (team != null && _homeTeamName.isEmpty) {
      setState(() {
        _homeTeamName = team.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final teams = ref.watch(teamsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Match')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Teams', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 16),

                      // Home team selector
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Home Team',
                          border: OutlineInputBorder(),
                        ),
                        value: _homeTeamId,
                        items:
                            teams.map((team) {
                              return DropdownMenuItem<String>(
                                value: team.id,
                                child: Text(team.name),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _homeTeamId = value;
                              _homeTeamName =
                                  teams
                                      .firstWhere((team) => team.id == value)
                                      .name;

                              // If the user switches their team to away, update accordingly
                              if (value == widget.teamId) {
                                _isHomeTeam = true;
                              } else if (_awayTeamId == widget.teamId) {
                                _isHomeTeam = false;
                              }
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a home team';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Away team input field
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Away Team Name',
                          border: OutlineInputBorder(),
                          hintText: 'Enter the name of the opponent team',
                        ),
                        initialValue: _awayTeamName,
                        onChanged: (value) {
                          setState(() {
                            _awayTeamName = value;
                            _awayTeamId = 'manual_entry';
                            _isHomeTeam =
                                true; // Always set the user's team as home when using manual entry
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the away team name';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Score and Date
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Match Details', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 16),

                      // Score inputs
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: '${_homeTeamName} Score',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              initialValue: _homeTeamScore.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _homeTeamScore = int.tryParse(value) ?? 0;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Enter valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText:
                                    '${_awayTeamName.isNotEmpty ? _awayTeamName : "Away Team"} Score',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              initialValue: _awayTeamScore.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _awayTeamScore = int.tryParse(value) ?? 0;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Enter valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Date picker
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Match Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_matchDate.day}/${_matchDate.month}/${_matchDate.year}',
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Location
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _location = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          setState(() {
                            _notes = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveMatch,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('SAVE MATCH'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _matchDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _matchDate) {
      setState(() {
        _matchDate = picked;
      });
    }
  }

  void _saveMatch() async {
    if (_formKey.currentState!.validate()) {
      // Create the match object
      String notes = _notes;
      if (_notes.isNotEmpty) {
        notes =
            '$_notes\nUser team is the ${_isHomeTeam ? "home" : "away"} team';
      } else {
        notes = 'User team is the ${_isHomeTeam ? "home" : "away"} team';
      }

      // When using text input for away team, always use 'manual_entry' as the ID
      final match = Match(
        leagueId: widget.leagueId,
        homeTeamId: _homeTeamId,
        homeTeamName: _homeTeamName,
        homeTeamScore: _homeTeamScore,
        awayTeamId:
            'manual_entry', // Always use manual_entry since we're using a text field
        awayTeamName: _awayTeamName,
        awayTeamScore: _awayTeamScore,
        date: _matchDate,
        location: _location.isNotEmpty ? _location : null,
        notes: notes.isNotEmpty ? notes : null,
      );

      // Save the match
      await ref.read(matchesViewModelProvider.notifier).addMatch(match);

      // Navigate back to the league screen
      if (mounted) {
        context.pop();
      }
    }
  }
}
