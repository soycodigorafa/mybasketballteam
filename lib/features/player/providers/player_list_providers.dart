import 'package:flutter_riverpod/flutter_riverpod.dart';

// Use models directly from player feature
import '../models/player.dart';

// Use centralized repositories
import '../../../core/services/repositories/repositories.dart';

/// ViewModel for the player list screen
class PlayerListViewModel extends StateNotifier<List<Player>> {
  final PlayerRepository _repository;

  PlayerListViewModel(this._repository) : super(_repository.getAllPlayers());

  /// Get all players
  List<Player> getPlayers() {
    return state;
  }

  /// Refresh the player list
  void refreshPlayers() {
    state = _repository.getAllPlayers();
  }

  /// Add a new player
  void addPlayer(Player player) {
    _repository.addPlayer(player);
    refreshPlayers();
  }

  /// Update an existing player
  void updatePlayer(Player player) {
    _repository.updatePlayer(player);
    refreshPlayers();
  }

  /// Delete a player
  void deletePlayer(String id) {
    _repository.deletePlayer(id);
    refreshPlayers();
  }
}

/// Provider for the PlayerListViewModel
final playerListViewModelProvider = StateNotifierProvider<PlayerListViewModel, List<Player>>((ref) {
  final repository = ref.watch(playerRepositoryProvider);
  return PlayerListViewModel(repository);
});
