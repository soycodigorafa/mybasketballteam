import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'player.dart';

/// Repository for managing player data
class PlayerRepository {
  // In-memory storage for players (would be replaced with actual database in real app)
  final List<Player> _players = [
    Player(
      name: 'Michael Jordan',
      number: 23,
      position: 'Shooting Guard',
      age: 35,
      height: 198,
      weight: 98,
      photoUrl: 'https://example.com/mj.jpg',
    ),
    Player(
      name: 'LeBron James',
      number: 6,
      position: 'Small Forward',
      age: 38,
      height: 206,
      weight: 113,
      photoUrl: 'https://example.com/lebron.jpg',
    ),
    Player(
      name: 'Stephen Curry',
      number: 30,
      position: 'Point Guard',
      age: 35,
      height: 188,
      weight: 84,
      photoUrl: 'https://example.com/curry.jpg',
    ),
    Player(
      name: 'Nikola Jokić',
      number: 15,
      position: 'Center',
      age: 28,
      height: 211,
      weight: 129,
      photoUrl: 'https://example.com/jokic.jpg',
    ),
  ];

  /// Get all players
  List<Player> getAllPlayers() {
    return List.unmodifiable(_players);
  }

  /// Add a new player
  void addPlayer(Player player) {
    _players.add(player);
  }

  /// Update an existing player
  void updatePlayer(Player player) {
    final index = _players.indexWhere((p) => p.id == player.id);
    if (index != -1) {
      _players[index] = player;
    }
  }

  /// Delete a player
  void deletePlayer(String id) {
    _players.removeWhere((player) => player.id == id);
  }
}

/// Provider for the PlayerRepository
final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return PlayerRepository();
});

