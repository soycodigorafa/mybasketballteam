import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mybasketteam/core/models/app_models.dart';

import '../../../core/providers/app_providers.dart';

class PlayerListView extends ConsumerWidget {
  const PlayerListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(playerListViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add player screen
            },
          ),
        ],
      ),
      body:
          players.isEmpty
              ? const Center(child: Text('No players in the team yet'))
              : ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return PlayerListTile(player: player);
                },
              ),
    );
  }
}

class PlayerListTile extends StatelessWidget {
  final Player player;

  const PlayerListTile({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildPlayerAvatar(),
        title: Text(
          player.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${player.position.displayName} | #${player.number}'),
        trailing: Text(
          _buildPhysicalStats(),
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        onTap: () {
          // TODO: Navigate to player detail screen
        },
      ),
    );
  }

  String _buildPhysicalStats() {
    final height =
        player.height != null ? '${player.height!.toInt()} cm' : '-- cm';
    final weight =
        player.weight != null ? '${player.weight!.toInt()} kg' : '-- kg';
    return '$height | $weight';
  }

  Widget _buildPlayerAvatar() {
    return CircleAvatar(
      radius: 25,
      backgroundColor: Colors.grey.shade200,
      child:
          player.photoUrl != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: CachedNetworkImage(
                  imageUrl: player.photoUrl!,
                  placeholder:
                      (context, url) => const CircularProgressIndicator(),
                  errorWidget:
                      (context, url, error) => const Icon(Icons.person),
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                ),
              )
              : const Icon(Icons.person),
    );
  }
}
