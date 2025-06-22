// lib/presentation/pages/detail/widgets/cast_and_crew_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/app_colors.dart';

class CastAndCrewSection extends StatelessWidget {
  final Map<String, dynamic> credits;
  const CastAndCrewSection({super.key, required this.credits});

  @override
  Widget build(BuildContext context) {
    // Take the top 10-15 cast members for a clean carousel
    final cast = (credits['cast'] as List).take(15).toList();

    // Return an empty container if there's no cast info
    if (cast.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text("Cast", style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 175,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cast.length,
            itemBuilder: (context, index) {
              final person = cast[index];
              return _CastMemberCard(person: person)
                  .animate()
                  .fadeIn(delay: (100 * index).ms, duration: 400.ms)
                  .slideX(begin: 0.5);
            },
          ),
        ),
      ],
    );
  }
}

// A private widget for a single cast member card
class _CastMemberCard extends StatelessWidget {
  final Map<String, dynamic> person;
  const _CastMemberCard({required this.person});

  @override
  Widget build(BuildContext context) {
    final profilePath = person['profile_path'];

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.darkSurface,
            backgroundImage: profilePath != null
                ? NetworkImage('https://image.tmdb.org/t/p/w200$profilePath')
                : null,
            child: profilePath == null
                ? const Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.darkTextSecondary,
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            person['name'] ?? '',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
