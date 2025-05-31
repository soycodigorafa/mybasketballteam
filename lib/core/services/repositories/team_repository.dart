import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mybasketteam/core/models/app_models.dart';

/// Abstract repository interface for managing team data
abstract class TeamRepository {
  /// Get all teams
  List<Team> getAllTeams();

  /// Get a team by ID
  Team? getTeamById(String id);

  /// Add a new team
  Future<void> addTeam(Team team);

  /// Update an existing team
  Future<void> updateTeam(Team team);

  /// Delete a team
  Future<void> deleteTeam(String id);
}

/// In-memory implementation of TeamRepository
class InMemoryTeamRepository implements TeamRepository {
  // In-memory storage for teams
  final Map<String, Team> _teams = {};

  InMemoryTeamRepository() {
    // Initialize with sample data
    final sampleTeams = [
      Team(
        name: 'Lakers',
        description: 'Los Angeles Lakers basketball team',
        coachName: 'Frank Vogel',
        logoUrl: 'https://example.com/lakers.png',
      ),
      Team(
        name: 'Warriors',
        description: 'Golden State Warriors basketball team',
        coachName: 'Steve Kerr',
        logoUrl: 'https://example.com/warriors.png',
      ),
    ];

    for (final team in sampleTeams) {
      _teams[team.id] = team;
    }
  }

  @override
  List<Team> getAllTeams() {
    return _teams.values.toList();
  }

  @override
  Team? getTeamById(String id) {
    return _teams[id];
  }

  @override
  Future<void> addTeam(Team team) async {
    _teams[team.id] = team;
  }

  @override
  Future<void> updateTeam(Team team) async {
    if (_teams.containsKey(team.id)) {
      _teams[team.id] = team;
    }
  }

  @override
  Future<void> deleteTeam(String id) async {
    _teams.remove(id);
  }
}

/// Provider for the TeamRepository
final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  // Use InMemoryTeamRepository for temporary storage
  return InMemoryTeamRepository();
});

/// Provider for the current list of teams
final teamsProvider = Provider<List<Team>>((ref) {
  final repository = ref.watch(teamRepositoryProvider);
  return repository.getAllTeams();
});

/// Provider for a specific team by ID
final teamByIdProvider = Provider.family<Team?, String>((ref, id) {
  final repository = ref.watch(teamRepositoryProvider);
  return repository.getTeamById(id);
});
