import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team.dart';
import '../models/team_repository.dart';

/// ViewModel for managing teams
class TeamsViewModel extends StateNotifier<List<Team>> {
  final TeamRepository _repository;

  TeamsViewModel(this._repository) : super(_repository.getAllTeams());

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

/// Provider for the TeamsViewModel
final teamsProvider = StateNotifierProvider<TeamsViewModel, List<Team>>((
  ref,
) {
  final repository = ref.watch(teamRepositoryProvider);
  return TeamsViewModel(repository);
});

/// Provider for a specific team by ID
final teamByIdProvider = Provider.family<Team?, String>((ref, id) {
  final teams = ref.watch(teamsProvider);
  return teams.firstWhere(
    (team) => team.id == id,
    orElse: () => throw Exception('Team not found'),
  );
});
