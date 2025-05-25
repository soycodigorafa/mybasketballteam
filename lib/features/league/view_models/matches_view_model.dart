import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match.dart';
import '../models/match_repository.dart';
import '../../team/models/league.dart';
import '../../team/models/team_repository.dart';

/// Provider for sorted matches by league ID
final sortedMatchesByLeagueProvider = Provider.family<List<Match>, String>((ref, leagueId) {
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
final matchesViewModelProvider = StateNotifierProvider<MatchesViewModel, List<Match>>((ref) {
  final repository = ref.watch(matchRepositoryProvider);
  return MatchesViewModel(repository);
});



/// ViewModel for matches
class MatchesViewModel extends StateNotifier<List<Match>> {
  final MatchRepository _repository;
  
  MatchesViewModel(this._repository) : super([]) {
    _loadMatches();
  }
  
  /// Load all matches
  void _loadMatches() {
    state = _repository.getAllMatches();
  }
  
  /// Add a new match
  Future<void> addMatch(Match match) async {
    await _repository.addMatch(match);
    _loadMatches();
  }
  
  /// Update an existing match
  Future<void> updateMatch(Match match) async {
    await _repository.updateMatch(match);
    _loadMatches();
  }
  
  /// Delete a match
  Future<void> deleteMatch(String id) async {
    await _repository.deleteMatch(id);
    _loadMatches();
  }
}
