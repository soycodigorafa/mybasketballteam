import 'package:flutter/material.dart';
import '../../models/team_stats.dart';

/// Component to display team statistics
class TeamStatsSection extends StatelessWidget {
  final TeamStats stats;
  final VoidCallback onEdit;

  const TeamStatsSection({
    super.key, 
    required this.stats,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Team Statistics', 
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            
            // Stats grid
            Row(
              children: [
                _buildStatItem(
                  context,
                  'Wins',
                  stats.wins.toString(),
                  Colors.green,
                ),
                _buildStatItem(
                  context,
                  'Losses',
                  stats.losses.toString(),
                  Colors.red,
                ),
                _buildStatItem(
                  context,
                  'Avg Points',
                  stats.avgPointsPerGame.toStringAsFixed(1),
                  Colors.blue,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Win percentage
            _buildWinPercentage(context, stats),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, 
    String label, 
    String value, 
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinPercentage(BuildContext context, TeamStats stats) {
    final theme = Theme.of(context);
    final totalGames = stats.wins + stats.losses;
    final winPercentage = totalGames > 0 
        ? (stats.wins / totalGames) * 100 
        : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Win Percentage',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: totalGames > 0 ? stats.wins / totalGames : 0,
          backgroundColor: Colors.grey.shade200,
          color: Colors.green,
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Text(
          '${winPercentage.toStringAsFixed(1)}%',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
