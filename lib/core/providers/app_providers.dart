/// This file centralizes all app-wide providers for easier access and management
/// 
/// We explicitly re-export selected providers to avoid naming conflicts

// Feature-specific providers
export 'package:mybasketteam/features/team/providers/teams_providers.dart';
export 'package:mybasketteam/features/player/providers/players_providers.dart';
export 'package:mybasketteam/features/player/providers/player_list_providers.dart';
export 'package:mybasketteam/features/match/providers/live_game_providers.dart';

// Only export one version of the matches providers to avoid conflicts
export 'package:mybasketteam/features/match/providers/matches_providers.dart';

/// This allows for:
/// ```
/// import 'package:mybasketteam/core/providers/app_providers.dart';
/// ```
/// Instead of importing multiple provider files.
