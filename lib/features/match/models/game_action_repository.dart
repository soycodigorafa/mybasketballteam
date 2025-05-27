import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_action.dart';

/// Repository for managing game actions during a live basketball game
class GameActionRepository {
  static const String _storageKey = 'game_actions';
  
  // Save all game actions to storage
  Future<void> saveGameActions(List<GameAction> actions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = actions.map((action) => jsonEncode(action.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }
  
  // Get all game actions from storage
  Future<List<GameAction>> getGameActions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];
    return jsonList
        .map((json) => GameAction.fromJson(jsonDecode(json)))
        .toList();
  }
  
  // Get actions for a specific match
  Future<List<GameAction>> getActionsForMatch(String matchId) async {
    final allActions = await getGameActions();
    return allActions.where((action) => action.matchId == matchId).toList();
  }
  
  // Add a new game action
  Future<void> addGameAction(GameAction action) async {
    final actions = await getGameActions();
    actions.add(action);
    await saveGameActions(actions);
  }
  
  // Delete a game action
  Future<void> deleteGameAction(String actionId) async {
    final actions = await getGameActions();
    actions.removeWhere((action) => action.id == actionId);
    await saveGameActions(actions);
  }
  
  // Update a game action
  Future<void> updateGameAction(GameAction updatedAction) async {
    final actions = await getGameActions();
    final index = actions.indexWhere((action) => action.id == updatedAction.id);
    if (index != -1) {
      actions[index] = updatedAction;
      await saveGameActions(actions);
    }
  }
}

/// Provider for the GameActionRepository
final gameActionRepositoryProvider = Provider<GameActionRepository>((ref) {
  return GameActionRepository();
});
