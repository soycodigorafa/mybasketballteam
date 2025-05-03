import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

/// Hive implementation of PlayerRepository for persistent storage
class HivePlayerRepository implements PlayerRepository {
  static const String _boxName = 'players';
  late Box<Player> _playersBox;
  
  /// Initialize the Hive box
  Future<void> initialize() async {
    // Register the adapters if they haven't been registered yet
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PlayerAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PlayerPositionAdapter());
    }
    
    try {
      // Try to open the box
      if (!Hive.isBoxOpen(_boxName)) {
        _playersBox = await Hive.openBox<Player>(_boxName);
        
        // Add sample data if the box is empty
        if (_playersBox.isEmpty) {
          final samplePlayers = [
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
          
          for (final player in samplePlayers) {
            await _playersBox.put(player.id, player);
          }
        }
      } else {
        _playersBox = Hive.box<Player>(_boxName);
      }
    } catch (e) {
      // If there's an error (likely due to type mismatch from schema changes),
      // delete the box and recreate it
      print('Error opening Hive box: $e');
      if (Hive.isBoxOpen(_boxName)) {
        await Hive.box(_boxName).close();
      }
      await Hive.deleteBoxFromDisk(_boxName);
      
      // Re-register adapters and create a new box
      Hive.registerAdapter(PlayerAdapter());
      Hive.registerAdapter(PlayerPositionAdapter());
      _playersBox = await Hive.openBox<Player>(_boxName);
      
      // Add sample data to the new box
      final samplePlayers = [
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
      
      for (final player in samplePlayers) {
        await _playersBox.put(player.id, player);
      }
    }
  }
  
  @override
  List<Player> getAllPlayers() {
    return _playersBox.values.toList();
  }

  @override
  Future<void> addPlayer(Player player) async {
    await _playersBox.put(player.id, player);
  }

  @override
  Future<void> updatePlayer(Player player) async {
    await _playersBox.put(player.id, player);
  }

  @override
  Future<void> deletePlayer(String id) async {
    await _playersBox.delete(id);
  }
}

/// Provider for the PlayerRepository
final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  // Use HivePlayerRepository for persistent storage
  return HivePlayerRepository();
});

