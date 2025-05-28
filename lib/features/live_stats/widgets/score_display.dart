import 'package:flutter/material.dart';

class ScoreDisplay extends StatelessWidget {
  final String homeTeamName;
  final String awayTeamName;
  final int homeScore;
  final int awayScore;
  final int currentQuarter;
  final VoidCallback onEndQuarter;

  const ScoreDisplay({
    super.key,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeScore,
    required this.awayScore,
    required this.currentQuarter,
    required this.onEndQuarter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  homeTeamName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const Text(
                'vs',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: Text(
                  awayTeamName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$homeScore',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 24),
              Text(
                '$awayScore',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text('Q$currentQuarter'),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: onEndQuarter,
                icon: const Icon(Icons.timer),
                label: const Text('End Quarter'),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
