import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/player/models/player.dart';
import 'features/player/models/player_repository.dart';
import 'features/team/models/team.dart';
import 'features/team/models/team_repository.dart';
import 'features/league/models/match.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Register Hive adapters
  Hive.registerAdapter(PlayerAdapter());
  Hive.registerAdapter(PlayerPositionAdapter());
  Hive.registerAdapter(TeamAdapter());
  Hive.registerAdapter(MatchAdapter());

  // Open Hive boxes
  await Hive.openBox<Match>('matches');

  // Initialize the repositories
  final playerRepository = HivePlayerRepository();
  await playerRepository.initialize();

  final teamRepository = HiveTeamRepository();
  await teamRepository.initialize();

  // Make sure the matches box is open
  if (!Hive.isBoxOpen('matches')) {
    await Hive.openBox<Match>('matches');
  }

  // Run the app
  runApp(
    ProviderScope(
      overrides: [
        // Override the repository providers with our initialized instances
        playerRepositoryProvider.overrideWithValue(playerRepository),
        teamRepositoryProvider.overrideWithValue(teamRepository),
      ],
      child: const TeamManagerApp(),
    ),
  );
}

class TeamManagerApp extends ConsumerWidget {
  const TeamManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Team Manager',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
