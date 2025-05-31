import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Local widgets
import 'package:mybasketteam/features/live_stats/widgets/score_display.dart';
import 'package:mybasketteam/features/live_stats/widgets/actions_list.dart';
import 'package:mybasketteam/features/live_stats/widgets/action_buttons.dart';
import 'package:mybasketteam/features/live_stats/widgets/player_selection_panel.dart';
import 'package:mybasketteam/features/live_stats/widgets/ai_advice_panel.dart';

// Feature imports
import 'package:mybasketteam/features/match/models/models.dart';
import 'package:mybasketteam/features/match/providers/live_game_providers.dart';
import 'package:mybasketteam/features/player/models/player.dart';
import 'package:mybasketteam/features/player/providers/players_providers.dart';

class LiveStatsScreen extends ConsumerStatefulWidget {
  final String teamId;
  final String teamName;
  final String? matchId;

  const LiveStatsScreen({
    super.key,
    required this.teamId,
    required this.teamName,
    this.matchId,
  });

  @override
  ConsumerState<LiveStatsScreen> createState() => _LiveStatsScreenState();
}

class _LiveStatsScreenState extends ConsumerState<LiveStatsScreen> {
  late GameMatch currentMatch;
  bool isSelectingPlayer = false;
  ActionType? selectedActionType;
  bool isSelectingHomeTeam = true;
  bool isShowingAiAdvice = false;
  String aiAdvice = '';
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupMatch();
    });
  }

  Future<void> _setupMatch() async {
    // Set the current quarter to 1 by default
    ref.read(currentQuarterProvider.notifier).state = 1;

    // If we have a match ID, load the existing match
    if (widget.matchId != null) {
      // TODO: Load the existing match data
    }
  }

  void _selectAction(ActionType type) {
    setState(() {
      selectedActionType = type;
      isSelectingPlayer = true;
    });
  }

  void _selectPlayer(Player player) {
    final currentMatch = ref.read(currentLiveMatchProvider);
    final currentQuarter = ref.read(currentQuarterProvider);

    if (currentMatch != null && selectedActionType != null) {
      final action = GameAction(
        matchId: currentMatch.id,
        type: selectedActionType!,
        playerName: player.name,
        playerNumber: player.number,
        teamId: player.teamId,
        isHomeTeam: isSelectingHomeTeam,
        quarter: currentQuarter,
        timestamp: DateTime.now(),
      );

      ref.read(gameActionsProvider.notifier).addAction(action);

      setState(() {
        selectedActionType = null;
        isSelectingPlayer = false;
      });
    }
  }

  Future<void> _selectOpponentPlayer() async {
    final playerNumber = await showDialog<String>(
      context: context,
      builder: (context) {
        String playerNumber = '';
        return AlertDialog(
          title: const Text('Enter Opponent Player'),
          content: TextField(
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Player Number',
              hintText: 'Enter player number',
            ),
            onChanged: (value) {
              playerNumber = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, playerNumber);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (playerNumber != null && playerNumber.isNotEmpty) {
      final currentMatch = ref.read(currentLiveMatchProvider);
      final currentQuarter = ref.read(currentQuarterProvider);

      if (currentMatch != null && selectedActionType != null) {
        final action = GameAction(
          matchId: currentMatch.id,
          type: selectedActionType!,
          playerName: 'Opponent',
          playerNumber: int.tryParse(playerNumber) ?? 0,
          teamId: currentMatch.awayTeamId,
          isHomeTeam: isSelectingHomeTeam,
          quarter: currentQuarter,
          timestamp: DateTime.now(),
        );

        ref.read(gameActionsProvider.notifier).addAction(action);

        setState(() {
          selectedActionType = null;
          isSelectingPlayer = false;
        });
      }
    }
  }

  void _cancelAction() {
    setState(() {
      selectedActionType = null;
      isSelectingPlayer = false;
    });
  }

  void _toggleTeam() {
    setState(() {
      isSelectingHomeTeam = !isSelectingHomeTeam;
    });
  }

  void _endQuarter() {
    final currentMatch = ref.read(currentLiveMatchProvider);
    final currentQuarter = ref.read(currentQuarterProvider);

    if (currentMatch != null) {
      // Add end quarter action
      final action = GameAction(
        matchId: currentMatch.id,
        type: ActionType.endQuarter,
        teamId: widget.teamId,
        isHomeTeam: true, // Doesn't matter for end quarter
        quarter: currentQuarter,
        timestamp: DateTime.now(),
      );

      ref.read(gameActionsProvider.notifier).addAction(action);

      // Increment quarter
      ref.read(currentQuarterProvider.notifier).state = currentQuarter + 1;
    }
  }

  void _deleteAction(String actionId) {
    ref.read(gameActionsProvider.notifier).removeAction(actionId);
  }

  void _showAiAdvice() {
    final currentMatch = ref.read(currentLiveMatchProvider);
    final actions = ref.read(currentMatchActionsProvider);
    final (homeScore, awayScore) = ref.read(currentScoreProvider);
    final currentQuarter = ref.read(currentQuarterProvider);

    if (currentMatch != null) {
      // Generate AI advice using the current game state
      final advice = generateAiAdvice(
        recentActions: actions,
        homeScore: homeScore,
        awayScore: awayScore,
        isHomeTeam: isSelectingHomeTeam,
        currentQuarter: currentQuarter,
      );

      setState(() {
        aiAdvice = advice;
        isShowingAiAdvice = true;
      });
    }
  }

  void _closeAiAdvice() {
    setState(() {
      isShowingAiAdvice = false;
    });
  }

  Future<void> _saveGame() async {
    final currentMatch = ref.read(currentLiveMatchProvider);
    final (homeScore, awayScore) = ref.read(currentScoreProvider);

    if (currentMatch != null) {
      final liveGameManager = ref.read(liveGameManagerProvider);

      await liveGameManager.saveMatchFromLiveStats(
        matchId: currentMatch.id,
        homeTeamId: currentMatch.homeTeamId,
        homeTeamName: currentMatch.homeTeamName,
        awayTeamId: currentMatch.awayTeamId,
        awayTeamName: currentMatch.awayTeamName,
        leagueId: currentMatch.leagueId,
        homeScore: homeScore,
        awayScore: awayScore,
        location: currentMatch.location,
        notes: currentMatch.notes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game saved successfully')),
        );

        // Go back to the previous screen
        if (context.canPop()) {
          context.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMatch = ref.watch(currentLiveMatchProvider);
    final currentQuarter = ref.watch(currentQuarterProvider);
    final actions = ref.watch(currentMatchActionsProvider);
    final (homeScore, awayScore) = ref.watch(currentScoreProvider);
    final players =
        ref
            .watch(playersProvider)
            .where((player) => player.teamId == widget.teamId)
            .toList();

    // Sort actions by timestamp (newest first)
    final sortedActions = [...actions];
    sortedActions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (currentMatch == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Game Stats'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveGame),
        ],
      ),
      body: Column(
        children: [
          // Score display
          ScoreDisplay(
            homeTeamName: currentMatch.homeTeamName,
            awayTeamName: currentMatch.awayTeamName,
            homeScore: homeScore,
            awayScore: awayScore,
            currentQuarter: currentQuarter,
            onEndQuarter: _endQuarter,
          ),

          // Game actions list or AI advice panel
          Expanded(
            child:
                isShowingAiAdvice
                    ? AiAdvicePanel(advice: aiAdvice, onClose: _closeAiAdvice)
                    : ActionsList(
                      actions: sortedActions,
                      scrollController: scrollController,
                      onDeleteAction: _deleteAction,
                      getActionTypeString: getActionTypeString,
                    ),
          ),

          // AI Advice button
          if (!isSelectingPlayer && !isShowingAiAdvice)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.psychology),
                label: const Text('Get AI Advice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: _showAiAdvice,
              ),
            ),

          // Bottom panel - either action buttons or player selection
          if (isSelectingPlayer)
            PlayerSelectionPanel(
              players: players,
              isSelectingHomeTeam: isSelectingHomeTeam,
              onPlayerSelected: _selectPlayer,
              onOpponentSelected: _selectOpponentPlayer,
              onToggleTeam: _toggleTeam,
              onCancel: _cancelAction,
            )
          else
            ActionButtons(onActionSelected: _selectAction),
        ],
      ),
    );
  }
}

String getActionTypeString(ActionType type) {
  switch (type) {
    case ActionType.point:
      return '2 Points';
    case ActionType.threePoint:
      return '3 Points';
    case ActionType.freeThrow:
      return 'Free Throw';
    case ActionType.foul:
      return 'Foul';
    case ActionType.turnover:
      return 'Turnover';
    case ActionType.rebound:
      return 'Rebound';
    case ActionType.steal:
      return 'Steal';
    case ActionType.block:
      return 'Block';
    case ActionType.assist:
      return 'Assist';
    case ActionType.endQuarter:
      return 'End Quarter';
  }
}
