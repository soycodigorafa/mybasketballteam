import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/player/views/players_screen.dart';
import '../../features/team/views/teams_screen.dart';

/// Provider for the application router
final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const TeamsScreen(),
      ),
      GoRoute(
        path: '/team/:teamId/players',
        name: 'players',
        builder: (context, state) => PlayersScreen(
          teamId: state.pathParameters['teamId'] ?? '',
        ),
      ),
    ],
  );
});
