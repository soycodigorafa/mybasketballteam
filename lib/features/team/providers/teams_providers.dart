import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mybasketteam/core/services/repositories/team_repository.dart';
import 'package:mybasketteam/features/team/models/team.dart';

/// Notifier for managing teams
class TeamsNotifier extends StateNotifier<List<Team>> {
  final TeamRepository _repository;

  TeamsNotifier(this._repository) : super(_repository.getAllTeams());

  /// Add a new team
  Future<void> addTeam(Team team) async {
    await _repository.addTeam(team);
    _refreshState();
  }

  /// Update an existing team
  Future<void> updateTeam(Team team) async {
    await _repository.updateTeam(team);
    _refreshState();
  }

  /// Delete a team
  Future<void> deleteTeam(String id) async {
    await _repository.deleteTeam(id);
    _refreshState();
  }

  /// Get a team by ID
  Team? getTeamById(String id) {
    return state.firstWhere(
      (team) => team.id == id,
      orElse: () => throw Exception('Team not found'),
    );
  }

  /// Private method to refresh the state from the repository
  void _refreshState() {
    state = _repository.getAllTeams();
  }
}

/// Provider for the TeamsNotifier
final teamsNotifierProvider = StateNotifierProvider<TeamsNotifier, List<Team>>((ref) {
  final repository = ref.watch(teamRepositoryProvider);
  return TeamsNotifier(repository);
});

/// Provider for a specific team by ID
final teamByIdProvider = Provider.family<Team?, String>((ref, id) {
  final teams = ref.watch(teamsNotifierProvider);
  try {
    return teams.firstWhere((team) => team.id == id);
  } catch (e) {
    return null;
  }
});

/// Provider for accessing all teams
final teamsProvider = Provider<List<Team>>((ref) {
  return ref.watch(teamsNotifierProvider);
});
