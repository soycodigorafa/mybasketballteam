import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/team/views/team_detail_screen.dart';
import '../../features/team/views/teams_screen.dart';
import '../../features/league/views/league_detail_screen.dart';
import '../../features/match/views/add_match_screen.dart';
import '../../features/match/views/match_detail_screen.dart';
import '../../features/match/views/post_match_stats_screen.dart';

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
        path: '/team/:teamId',
        name: 'teamDetail',
        builder: (context, state) => TeamDetailScreen(
          teamId: state.pathParameters['teamId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/team/:teamId/league/:leagueId',
        name: 'leagueDetail',
        builder: (context, state) => LeagueDetailScreen(
          teamId: state.pathParameters['teamId'] ?? '',
          leagueId: state.pathParameters['leagueId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/team/:teamId/league/:leagueId/addMatch',
        name: 'addMatch',
        builder: (context, state) => AddMatchScreen(
          teamId: state.pathParameters['teamId'] ?? '',
          leagueId: state.pathParameters['leagueId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/team/:teamId/league/:leagueId/match/:matchId',
        name: 'matchDetail',
        builder: (context, state) => MatchDetailScreen(
          teamId: state.pathParameters['teamId'] ?? '',
          leagueId: state.pathParameters['leagueId'] ?? '',
          matchId: state.pathParameters['matchId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/team/:teamId/league/:leagueId/match/:matchId/postMatchStats',
        name: 'postMatchStats',
        builder: (context, state) => PostMatchStatsScreen(
          teamId: state.pathParameters['teamId'] ?? '',
          leagueId: state.pathParameters['leagueId'] ?? '',
          matchId: state.pathParameters['matchId'] ?? '',
        ),
      ),
    ],
  );
});
