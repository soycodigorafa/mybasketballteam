import 'package:flutter/material.dart';
import 'package:mybasketteam/features/match/models/models.dart';

class AiAdvicePanel extends StatelessWidget {
  final String advice;
  final VoidCallback onClose;

  const AiAdvicePanel({
    super.key,
    required this.advice,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.psychology, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'AI Assistant Advice',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                advice,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Generate a fake AI advice based on the current game state
String generateAiAdvice({
  required List<GameAction> recentActions,
  required int homeScore,
  required int awayScore,
  required bool isHomeTeam,
  required int currentQuarter,
}) {
  // In a real implementation, this would call an actual AI service
  // For now, we'll generate some fake advice based on the game state
  
  final scoreDifference = homeScore - awayScore;
  final teamScore = isHomeTeam ? homeScore : awayScore;
  final opponentScore = isHomeTeam ? awayScore : homeScore;
  final teamPerformance = teamScore > opponentScore ? 'leading' : 'trailing';
  
  // Calculate some simple statistics
  int teamPoints = 0;
  int teamRebounds = 0;
  int teamTurnovers = 0;
  int teamFouls = 0;
  
  // Only look at the last 10 actions to determine recent trends
  final lastTenActions = recentActions.take(10).toList();
  
  for (final action in lastTenActions) {
    if (action.isHomeTeam == isHomeTeam) {
      if (action.type == ActionType.point) teamPoints += 2;
      if (action.type == ActionType.threePoint) teamPoints += 3;
      if (action.type == ActionType.freeThrow) teamPoints += 1;
      if (action.type == ActionType.rebound) teamRebounds += 1;
      if (action.type == ActionType.turnover) teamTurnovers += 1;
      if (action.type == ActionType.foul) teamFouls += 1;
    }
  }
  
  // Generate advice based on game situation
  final List<String> advicePoints = [];
  
  // Score-based advice
  if (scoreDifference.abs() <= 5) {
    advicePoints.add("The game is close! Focus on high-percentage shots and protect the ball.");
  } else if (scoreDifference > 10 && isHomeTeam) {
    advicePoints.add("You have a comfortable lead. Consider rotating in bench players to rest your starters.");
  } else if (scoreDifference < -10 && isHomeTeam) {
    advicePoints.add("You're down by more than 10. Consider a more aggressive defensive approach and look for three-point opportunities.");
  }
  
  // Quarter-based advice
  if (currentQuarter == 4) {
    if (scoreDifference.abs() <= 8) {
      advicePoints.add("It's the final quarter with a close score. Ensure your best free-throw shooters are on the floor for potential late-game situations.");
    }
  }
  
  // Recent performance advice
  if (teamTurnovers >= 3) {
    advicePoints.add("You've had ${teamTurnovers} turnovers recently. Focus on safer passes and better ball protection.");
  }
  
  if (teamRebounds <= 1) {
    advicePoints.add("You need to improve your rebounding. Ensure players are boxing out on every shot.");
  }
  
  if (teamFouls >= 3) {
    advicePoints.add("Your team is accumulating fouls quickly. Adjust your defensive approach to avoid getting into the bonus.");
  }
  
  // Add some general advice if we don't have enough specific points
  if (advicePoints.isEmpty) {
    advicePoints.add("Maintain communication on defense and look for the open player on offense.");
    advicePoints.add("Remember to control the tempo of the game to your advantage.");
  }
  
  // Format the advice
  final formattedAdvice = advicePoints.join("\n\n");
  
  return """Based on the current game situation:

$formattedAdvice

Key Stats:
• You are $teamPerformance (${isHomeTeam ? homeScore : awayScore}-${isHomeTeam ? awayScore : homeScore})
• Quarter: $currentQuarter
• Recent points scored: $teamPoints
• Recent rebounds: $teamRebounds
• Recent turnovers: $teamTurnovers

Good luck with the rest of the game!
""";
}
