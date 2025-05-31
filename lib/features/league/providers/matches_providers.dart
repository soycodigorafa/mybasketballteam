import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../match/models/game_match.dart';
import '../models/match_repository.dart';
import '../../team/models/league.dart';
import '../../team/models/team_repository.dart';

/// Global counter to force refresh of all match-related providers
final matchChangeNotifierProvider = StateProvider<int>((ref) => 0);

/// Provider for sorted matches by league ID
final sortedMatchesByLeagueProvider = Provider.family<List<GameMatch>, String>((
  ref,
  leagueId,
) {
  // Watch the change notifier to force refresh when changes occur
  ref.watch(matchChangeNotifierProvider);

  final matches = ref.watch(matchesByLeagueProvider(leagueId));
  // Sort by date descending (newest first)
  matches.sort((a, b) => b.date.compareTo(a.date));
  return matches;
});

/// Provider for leagues with their associated match count
final leagueByIdProvider = Provider.family<League?, String>((ref, leagueId) {
  final teams = ref.watch(teamsProvider);
  for (final team in teams) {
    if (team.currentLeague?.id == leagueId) {
      return team.currentLeague;
    }
    for (final league in team.leagues) {
      if (league.id == leagueId) {
        return league;
      }
    }
  }
  return null;
});

/// Provider for the matches view model
final matchesViewModelProvider =
    StateNotifierProvider<MatchesViewModel, List<GameMatch>>((ref) {
      final repository = ref.watch(matchRepositoryProvider);
      return MatchesViewModel(repository, ref);
    });

/// Provider for all matches, refreshes when notifier changes
final allMatchesProvider = Provider<List<GameMatch>>((ref) {
  // Watch the change notifier to force refresh
  ref.watch(matchChangeNotifierProvider);
  final repository = ref.watch(matchRepositoryProvider);
  return repository.getAllMatches();
});

/// Provider for matches filtered by league ID
final matchesByLeagueProvider = Provider.family<List<GameMatch>, String>((
  ref,
  leagueId,
) {
  // Watch the change notifier to force refresh
  ref.watch(matchChangeNotifierProvider);
  final repository = ref.watch(matchRepositoryProvider);
  return repository.getMatchesByLeagueId(leagueId);
});

/// ViewModel for matches
class MatchesViewModel extends StateNotifier<List<GameMatch>> {
  final MatchRepository _repository;
  final Ref _ref;

  MatchesViewModel(this._repository, this._ref) : super([]) {
    _loadMatches();
  }

  /// Load all matches
  void _loadMatches() {
    state = _repository.getAllMatches();
  }

  /// Add a new match
  Future<void> addMatch(GameMatch match) async {
    await _repository.addMatch(match);
    _loadMatches();
    // Notify all dependent providers about the change
    _notifyChange();
  }

  /// Update an existing match
  Future<void> updateMatch(GameMatch match) async {
    await _repository.updateMatch(match);
    _loadMatches();
    // Notify all dependent providers about the change
    _notifyChange();
  }

  /// Delete a match
  Future<void> deleteMatch(String id) async {
    await _repository.deleteMatch(id);
    _loadMatches();
    // Notify all dependent providers about the change
    _notifyChange();
  }

  /// Notify all dependent providers that data has changed
  void _notifyChange() {
    // Increment the counter to force refresh of all dependent providers
    _ref.read(matchChangeNotifierProvider.notifier).state++;
  }
}
