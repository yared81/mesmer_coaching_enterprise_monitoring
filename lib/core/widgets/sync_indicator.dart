import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmer_digital_coaching/core/sync/sync_service.dart';

class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSyncing = ref.watch(syncStatusProvider);

    return GestureDetector(
      onTap: () => ref.read(syncServiceProvider).processQueue(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isSyncing
            ? const _SyncingIcon(key: ValueKey('syncing'))
            : const _SyncedIcon(key: ValueKey('synced')),
      ),
    );
  }
}

class _SyncingIcon extends StatefulWidget {
  const _SyncingIcon({super.key});

  @override
  State<_SyncingIcon> createState() => _SyncingIconState();
}

class _SyncingIconState extends State<_SyncingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Icon(Icons.sync_rounded, color: Colors.white, size: 20),
    );
  }
}

class _SyncedIcon extends StatelessWidget {
  const _SyncedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.cloud_done_rounded, color: Colors.white70, size: 20);
  }
}
