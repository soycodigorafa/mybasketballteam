import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'player_stats.dart';

class PlayerStatsRepository {
  // In-memory list of player stats
  final List<PlayerStats> _playerStats = [];

  PlayerStatsRepository();

  List<PlayerStats> getAllPlayerStats() {
    return _playerStats;
  }

  List<PlayerStats> getPlayerStatsByMatchId(String matchId) {
    return _playerStats.where((stats) => stats.matchId == matchId).toList();
  }

  Future<void> addPlayerStats(PlayerStats playerStats) async {
    _playerStats.add(playerStats);
  }

  Future<void> updatePlayerStats(PlayerStats playerStats) async {
    final index = _playerStats.indexWhere((stats) => stats.id == playerStats.id);
    if (index != -1) {
      _playerStats[index] = playerStats;
    }
  }

  Future<void> deletePlayerStats(String id) async {
    _playerStats.removeWhere((stats) => stats.id == id);
  }

  Future<void> deletePlayerStatsByMatchId(String matchId) async {
    _playerStats.removeWhere((stats) => stats.matchId == matchId);
  }
}

final playerStatsRepositoryProvider = Provider<PlayerStatsRepository>((ref) {
  return PlayerStatsRepository();
});

final playerStatsByMatchProvider = Provider.family<List<PlayerStats>, String>((ref, matchId) {
  final repository = ref.watch(playerStatsRepositoryProvider);
  return repository.getPlayerStatsByMatchId(matchId);
});

// Sample data provider for demonstration
final samplePlayerStatsProvider = Provider<void>((ref) {
  final repository = ref.read(playerStatsRepositoryProvider);
  
  // Check if we already have data
  if (repository.getAllPlayerStats().isEmpty) {
    // Add sample data for demo purposes
    final sampleStats = [
      // Home team players for match1
      PlayerStats(
        matchId: 'match1',
        playerId: 'player1',
        playerName: 'John Smith',
        playerNumber: 23,
        points: 18,
        minutes: 32,
        assists: 5,
        teamId: 'team1',
      ),
      PlayerStats(
        matchId: 'match1',
        playerId: 'player2',
        playerName: 'Michael Johnson',
        playerNumber: 10,
        points: 12,
        minutes: 28,
        assists: 7,
        teamId: 'team1',
      ),
      
      // Away team players for match1
      PlayerStats(
        matchId: 'match1',
        playerId: 'player3',
        playerName: 'Carlos Rodriguez',
        playerNumber: 7,
        points: 15,
        minutes: 30,
        assists: 4,
        teamId: 'team2',
      ),
      PlayerStats(
        matchId: 'match1',
        playerId: 'player4',
        playerName: 'David Williams',
        playerNumber: 21,
        points: 10,
        minutes: 25,
        assists: 3,
        teamId: 'team2',
      ),
    ];
    
    for (final stats in sampleStats) {
      repository.addPlayerStats(stats);
    }
  }
});
