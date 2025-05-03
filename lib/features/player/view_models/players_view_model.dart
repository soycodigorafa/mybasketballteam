import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/player_repository.dart';

/// ViewModel for managing players
class PlayersViewModel extends StateNotifier<List<Player>> {
  final PlayerRepository _repository;

  PlayersViewModel(this._repository) : super(_repository.getAllPlayers());

  /// Add a new player to the team
  Future<void> addPlayer(Player player) async {
    await _repository.addPlayer(player);
    _refreshState();
  }

  /// Update an existing player
  Future<void> updatePlayer(Player player) async {
    await _repository.updatePlayer(player);
    _refreshState();
  }

  /// Delete a player from the team
  Future<void> deletePlayer(String id) async {
    await _repository.deletePlayer(id);
    _refreshState();
  }

  /// Get a player by ID
  Player? getPlayerById(String id) {
    return state.firstWhere(
      (player) => player.id == id,
      orElse: () => throw Exception('Player not found'),
    );
  }

  /// Filter players by position
  List<Player> getPlayersByPosition(PlayerPosition position) {
    return state.where((player) => player.position == position).toList();
  }

  /// Private method to refresh the state from the repository
  void _refreshState() {
    state = _repository.getAllPlayers();
  }
}

/// Provider for the PlayersViewModel
final playersProvider = StateNotifierProvider<PlayersViewModel, List<Player>>((
  ref,
) {
  final repository = ref.watch(playerRepositoryProvider);
  return PlayersViewModel(repository);
});

/// Provider for filtered players by position
final playersByPositionProvider = Provider.family<List<Player>, PlayerPosition>(
  (ref, position) {
    final players = ref.watch(playersProvider);
    return players.where((player) => player.position == position).toList();
  },
);

/// Provider for a specific player by ID
final playerByIdProvider = Provider.family<Player?, String>((ref, id) {
  final players = ref.watch(playersProvider);
  return players.firstWhere(
    (player) => player.id == id,
    orElse: () => throw Exception('Player not found'),
  );
});
