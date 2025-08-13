// lib/presentation/pages/home/widgets/media_type_toggle.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/home/home_providers.dart';
import '../../../../data/local/persistence_service.dart';

class MediaTypeToggle extends ConsumerWidget {
  const MediaTypeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentType = ref.watch(mediaTypeNotifierProvider);
    final notifier = ref.read(mediaTypeNotifierProvider.notifier);

    return Container(
      width: 130,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // The animated "pill" indicator
          AnimatedAlign(
            duration: 300.ms,
            curve: Curves.easeInOut,
            alignment: currentType == MediaType.movie
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: 65,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // The text options
          Row(
            children: [
              _buildOption(
                context,
                "Movies",
                () => notifier.setMediaType(MediaType.movie),
              ),
              _buildOption(
                context,
                "TV",
                () => notifier.setMediaType(MediaType.tv),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
