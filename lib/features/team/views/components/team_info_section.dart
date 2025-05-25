import 'package:flutter/material.dart';
import '../../models/team.dart';

/// Component to display basic team information
class TeamInfoSection extends StatelessWidget {
  final Team team;

  const TeamInfoSection({super.key, required this.team});

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team logo/shield
                _buildTeamLogo(team.logoUrl),
                
                const SizedBox(width: 16),
                
                // Team name and coach info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (team.coachName != null && team.coachName!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Coach: ${team.coachName}',
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            // Team description
            if (team.description != null && team.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'About',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                team.description!,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTeamLogo(String? logoUrl) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          logoUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _defaultLogoPlaceholder();
          },
        ),
      );
    } else {
      return _defaultLogoPlaceholder();
    }
  }

  Widget _defaultLogoPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Icon(
        Icons.sports_basketball,
        size: 40,
        color: Colors.grey,
      ),
    );
  }
}
