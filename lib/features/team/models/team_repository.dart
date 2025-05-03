import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'team.dart';

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

/// Hive implementation of TeamRepository for persistent storage
class HiveTeamRepository implements TeamRepository {
  static const String _boxName = 'teams';
  late Box<Team> _teamsBox;
  
  /// Initialize the Hive box
  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _teamsBox = await Hive.openBox<Team>(_boxName);
      
      // Add sample data if the box is empty
      if (_teamsBox.isEmpty) {
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
          await _teamsBox.put(team.id, team);
        }
      }
    } else {
      _teamsBox = Hive.box<Team>(_boxName);
    }
  }
  
  @override
  List<Team> getAllTeams() {
    return _teamsBox.values.toList();
  }
  
  @override
  Team? getTeamById(String id) {
    return _teamsBox.get(id);
  }

  @override
  Future<void> addTeam(Team team) async {
    await _teamsBox.put(team.id, team);
  }

  @override
  Future<void> updateTeam(Team team) async {
    await _teamsBox.put(team.id, team);
  }

  @override
  Future<void> deleteTeam(String id) async {
    await _teamsBox.delete(id);
  }
}

/// Provider for the TeamRepository
final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  // Use HiveTeamRepository for persistent storage
  return HiveTeamRepository();
});
