import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'player.dart';

/// Abstract repository interface for managing player data
abstract class PlayerRepository {
  /// Get all players
  List<Player> getAllPlayers();

  /// Add a new player
  Future<void> addPlayer(Player player);

  /// Update an existing player
  Future<void> updatePlayer(Player player);

  /// Delete a player
  Future<void> deletePlayer(String id);
}

/// In-memory implementation of PlayerRepository (for testing)
class InMemoryPlayerRepository implements PlayerRepository {
  // In-memory storage for players
  final List<Player> _players = [
    Player(
      name: 'Michael Jordan',
      number: 23,
      position: PlayerPosition.shootingGuard,
      teamId: 'default-team',
      age: 35,
      height: 198,
      weight: 98,
      photoUrl: 'https://example.com/mj.jpg',
    ),
    Player(
      name: 'LeBron James',
      number: 6,
      position: PlayerPosition.smallForward,
      teamId: 'default-team',
      age: 38,
      height: 206,
      weight: 113,
      photoUrl: 'https://example.com/lebron.jpg',
    ),
    Player(
      name: 'Stephen Curry',
      number: 30,
      position: PlayerPosition.pointGuard,
      teamId: 'default-team',
      age: 35,
      height: 188,
      weight: 84,
      photoUrl: 'https://example.com/curry.jpg',
    ),
    Player(
      name: 'Nikola Jokić',
      number: 15,
      position: PlayerPosition.center,
      teamId: 'default-team',
      age: 28,
      height: 211,
      weight: 129,
      photoUrl: 'https://example.com/jokic.jpg',
    ),
  ];

  @override
  List<Player> getAllPlayers() {
    return List.unmodifiable(_players);
  }

  @override
  Future<void> addPlayer(Player player) async {
    _players.add(player);
  }

  @override
  Future<void> updatePlayer(Player player) async {
    final index = _players.indexWhere((p) => p.id == player.id);
    if (index != -1) {
      _players[index] = player;
    }
  }

  @override
  Future<void> deletePlayer(String id) async {
    _players.removeWhere((player) => player.id == id);
  }
}



/// Provider for the PlayerRepository
final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  // Use InMemoryPlayerRepository for temporary storage
  return InMemoryPlayerRepository();
});

/// Provider for the current list of players
final playersProvider = Provider<List<Player>>((ref) {
  final repository = ref.watch(playerRepositoryProvider);
  return repository.getAllPlayers();
});

/// Provider for filtering players by team ID
final playersByTeamProvider = Provider.family<List<Player>, String>((ref, teamId) {
  final allPlayers = ref.watch(playersProvider);
  return allPlayers.where((player) => player.teamId == teamId).toList();
});

