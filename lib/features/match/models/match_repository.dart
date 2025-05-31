import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_match.dart';

/// Abstract repository interface for managing match data
abstract class MatchRepository {
  /// Get all matches
  List<GameMatch> getAllMatches();

  /// Get matches by league ID
  List<GameMatch> getMatchesByLeagueId(String leagueId);

  /// Get matches by team ID
  List<GameMatch> getMatchesByTeamId(String teamId);

  /// Add a new match
  Future<void> addMatch(GameMatch match);

  /// Update an existing match
  Future<void> updateMatch(GameMatch match);

  /// Delete a match
  Future<void> deleteMatch(String id);
}

/// In-memory implementation of MatchRepository
class InMemoryMatchRepository implements MatchRepository {
  // In-memory storage for matches
  final Map<String, GameMatch> _matches = {};

  InMemoryMatchRepository() {
    // Initialize with sample data
    final sampleMatches = [
      GameMatch(
        id: 'match-1',
        leagueId: 'default-league',
        homeTeamId: 'default-team',
        homeTeamName: 'Lakers',
        homeTeamScore: 105,
        awayTeamId: 'default-team-2',
        awayTeamName: 'Warriors',
        awayTeamScore: 100,
        date: DateTime.now().subtract(const Duration(days: 3)),
        location: 'Staples Center',
      ),
      GameMatch(
        id: 'match-2',
        leagueId: 'default-league',
        homeTeamId: 'default-team-2',
        homeTeamName: 'Warriors',
        homeTeamScore: 120,
        awayTeamId: 'default-team',
        awayTeamName: 'Lakers',
        awayTeamScore: 110,
        date: DateTime.now().subtract(const Duration(days: 10)),
        location: 'Chase Center',
      ),
    ];

    for (final match in sampleMatches) {
      _matches[match.id] = match;
    }
  }

  @override
  List<GameMatch> getAllMatches() {
    return _matches.values.toList();
  }

  @override
  List<GameMatch> getMatchesByLeagueId(String leagueId) {
    return _matches.values
        .where((match) => match.leagueId == leagueId)
        .toList();
  }

  @override
  List<GameMatch> getMatchesByTeamId(String teamId) {
    return _matches.values
        .where(
          (match) => match.homeTeamId == teamId || match.awayTeamId == teamId,
        )
        .toList();
  }

  @override
  Future<void> addMatch(GameMatch match) async {
    _matches[match.id] = match;
  }

  @override
  Future<void> updateMatch(GameMatch match) async {
    if (_matches.containsKey(match.id)) {
      _matches[match.id] = match;
    }
  }

  @override
  Future<void> deleteMatch(String id) async {
    _matches.remove(id);
  }
}

/// Provider for the MatchRepository
final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  // Use InMemoryMatchRepository for temporary storage
  return InMemoryMatchRepository();
});

/// Provider for the current list of matches
final matchesProvider = Provider<List<GameMatch>>((ref) {
  final repository = ref.watch(matchRepositoryProvider);
  return repository.getAllMatches();
});

/// Provider for filtering matches by league ID
final matchesByLeagueProvider = Provider.family<List<GameMatch>, String>((
  ref,
  leagueId,
) {
  final repository = ref.watch(matchRepositoryProvider);
  return repository.getMatchesByLeagueId(leagueId);
});

/// Provider for filtering matches by team ID
final matchesByTeamProvider = Provider.family<List<GameMatch>, String>((
  ref,
  teamId,
) {
  final repository = ref.watch(matchRepositoryProvider);
  return repository.getMatchesByTeamId(teamId);
});
