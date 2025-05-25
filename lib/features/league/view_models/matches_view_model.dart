import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/match.dart';
import '../../team/models/league.dart';
import '../../team/view_models/teams_view_model.dart';

const String _matchesBoxName = 'matches';

/// Repository provider for matches
final matchesRepositoryProvider = Provider<MatchesRepository>((ref) {
  return MatchesRepository();
});

/// Provider for all matches
final matchesProvider = Provider<List<Match>>((ref) {
  final repository = ref.watch(matchesRepositoryProvider);
  return repository.getAllMatches();
});

/// Provider for matches by league ID
final matchesByLeagueProvider = Provider.family<AsyncValue<List<Match>>, String>((ref, leagueId) {
  try {
    // Check if Hive box is open first
    if (!Hive.isBoxOpen(_matchesBoxName)) {
      // Return loading state if box is not available yet
      return const AsyncValue.loading();
    }
    
    final matches = ref.watch(matchesProvider);
    final leagueMatches = matches.where((match) => match.leagueId == leagueId).toList();
    // Sort by date descending (newest first)
    leagueMatches.sort((a, b) => b.date.compareTo(a.date));
    return AsyncValue.data(leagueMatches);
  } catch (e, stackTrace) {
    return AsyncValue.error(e, stackTrace);
  }
});

/// Provider for a match by ID
final matchByIdProvider = Provider.family<Match?, String>((ref, matchId) {
  final matches = ref.watch(matchesProvider);
  try {
    return matches.firstWhere(
      (match) => match.id == matchId,
    );
  } catch (e) {
    return null;
  }
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
final matchesViewModelProvider = StateNotifierProvider<MatchesViewModel, AsyncValue<List<Match>>>((ref) {
  final repository = ref.watch(matchesRepositoryProvider);
  return MatchesViewModel(repository);
});

/// Repository for matches data
class MatchesRepository {
  /// Safely get or open the matches box
  Future<Box<Match>> _getBox() async {
    if (Hive.isBoxOpen(_matchesBoxName)) {
      return Hive.box<Match>(_matchesBoxName);
    } else {
      return await Hive.openBox<Match>(_matchesBoxName);
    }
  }

  /// Get all matches
  List<Match> getAllMatches() {
    try {
      final box = Hive.isBoxOpen(_matchesBoxName) 
          ? Hive.box<Match>(_matchesBoxName) 
          : throw Exception('Matches box not initialized yet');
      return box.values.toList();
    } catch (e) {
      // Return empty list if box can't be accessed
      return [];
    }
  }
  
  /// Get a match by ID
  Match? getMatchById(String id) {
    try {
      final box = Hive.isBoxOpen(_matchesBoxName) 
          ? Hive.box<Match>(_matchesBoxName) 
          : throw Exception('Matches box not initialized yet');
      return box.values.firstWhere(
        (match) => match.id == id,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Add a new match
  Future<void> addMatch(Match match) async {
    final box = await _getBox();
    await box.put(match.id, match);
  }
  
  /// Update an existing match
  Future<void> updateMatch(Match match) async {
    final box = await _getBox();
    await box.put(match.id, match);
  }
  
  /// Delete a match
  Future<void> deleteMatch(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}

/// ViewModel for matches
class MatchesViewModel extends StateNotifier<AsyncValue<List<Match>>> {
  final MatchesRepository _repository;
  
  MatchesViewModel(this._repository) : super(const AsyncValue.loading()) {
    _loadMatches();
  }
  
  /// Load all matches
  Future<void> _loadMatches() async {
    try {
      final matches = _repository.getAllMatches();
      state = AsyncValue.data(matches);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  /// Add a new match
  Future<void> addMatch(Match match) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addMatch(match);
      _loadMatches();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  /// Update an existing match
  Future<void> updateMatch(Match match) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateMatch(match);
      _loadMatches();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  /// Delete a match
  Future<void> deleteMatch(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteMatch(id);
      _loadMatches();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
