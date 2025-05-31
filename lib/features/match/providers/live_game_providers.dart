import 'package:flutter_riverpod/flutter_riverpod.dart';

// Use centralized model exports
import 'package:mybasketteam/features/match/models/models.dart';

// Use centralized repository exports
import 'package:mybasketteam/core/services/repositories/repositories.dart';

final gameActionsProvider =
    StateNotifierProvider<GameActionNotifier, List<GameAction>>((ref) {
      final repository = ref.watch(gameActionRepositoryProvider);
      return GameActionNotifier(repository);
    });

final currentLiveMatchProvider = StateProvider<GameMatch?>((ref) => null);

final currentQuarterProvider = StateProvider<int>((ref) => 1);

// Provider to get all actions for the current match
final currentMatchActionsProvider = Provider<List<GameAction>>((ref) {
  final currentMatch = ref.watch(currentLiveMatchProvider);
  final allActions = ref.watch(gameActionsProvider);

  if (currentMatch == null) return [];
  return allActions
      .where((action) => action.matchId == currentMatch.id)
      .toList();
});

// Provider for calculating current score from actions
final currentScoreProvider = Provider<(int, int)>((ref) {
  final currentMatch = ref.watch(currentLiveMatchProvider);
  final actions = ref.watch(currentMatchActionsProvider);

  if (currentMatch == null) return (0, 0);

  int homeScore = 0;
  int awayScore = 0;

  for (final action in actions) {
    final points = getPointsForAction(action.type);
    if (points > 0) {
      if (action.isHomeTeam) {
        homeScore += points;
      } else {
        awayScore += points;
      }
    }
  }

  return (homeScore, awayScore);
});

class GameActionNotifier extends StateNotifier<List<GameAction>> {
  final GameActionRepository _repository;

  GameActionNotifier(this._repository) : super([]) {
    _loadGameActions();
  }

  Future<void> _loadGameActions() async {
    final actions = await _repository.getGameActions();
    state = actions;
  }

  Future<void> addAction(GameAction action) async {
    await _repository.addGameAction(action);
    state = [...state, action];
  }

  Future<void> removeAction(String actionId) async {
    await _repository.deleteGameAction(actionId);
    state = state.where((action) => action.id != actionId).toList();
  }

  Future<void> updateAction(GameAction updatedAction) async {
    await _repository.updateGameAction(updatedAction);
    state =
        state
            .map(
              (action) =>
                  action.id == updatedAction.id ? updatedAction : action,
            )
            .toList();
  }
}

class LiveGameManager {
  final MatchRepository _matchRepository;

  LiveGameManager(this._matchRepository);

  // Create a new match or update an existing one based on live game stats
  Future<GameMatch> saveMatchFromLiveStats({
    required String? matchId,
    required String homeTeamId,
    required String homeTeamName,
    required String awayTeamId,
    required String awayTeamName,
    required String leagueId,
    required int homeScore,
    required int awayScore,
    String? location,
    String? notes,
  }) async {
    final now = DateTime.now();

    if (matchId != null) {
      // Update existing match
      final existingMatches = await _matchRepository.getAllMatches();
      final matchIndex = existingMatches.indexWhere((m) => m.id == matchId);

      if (matchIndex != -1) {
        // Create a new GameMatch with updated fields
        final existingMatch = existingMatches[matchIndex];
        final updatedMatch = GameMatch(
          id: existingMatch.id,
          leagueId: existingMatch.leagueId,
          homeTeamId: existingMatch.homeTeamId,
          homeTeamName: existingMatch.homeTeamName,
          homeTeamScore: homeScore,  // Updated score
          awayTeamId: existingMatch.awayTeamId,
          awayTeamName: existingMatch.awayTeamName,
          awayTeamScore: awayScore,  // Updated score
          date: existingMatch.date,
          location: existingMatch.location,
          notes: notes,  // Updated notes
        );

        await _matchRepository.updateMatch(updatedMatch);
        return updatedMatch;
      }
    }

    // Create new match
    final newMatch = GameMatch(
      leagueId: leagueId,
      homeTeamId: homeTeamId,
      homeTeamName: homeTeamName,
      homeTeamScore: homeScore,
      awayTeamId: awayTeamId,
      awayTeamName: awayTeamName,
      awayTeamScore: awayScore,
      date: now,
      location: location,
      notes: notes,
    );

    await _matchRepository.addMatch(newMatch);
    return newMatch;
  }
}

/// Provider for the LiveGameManager
final liveGameManagerProvider = Provider<LiveGameManager>((ref) {
  final repository = ref.watch(matchRepositoryProvider);
  return LiveGameManager(repository);
});
