// // lib/presentation/pages/detail/widgets/cast_and_crew_section.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';

// import '../../../core/app_colors.dart';

// class CastAndCrewSection extends StatelessWidget {
//   final Map<String, dynamic> credits;
//   const CastAndCrewSection({super.key, required this.credits});

//   @override
//   Widget build(BuildContext context) {
//     // Take the top 10-15 cast members for a clean carousel
//     final cast = (credits['cast'] as List).take(15).toList();

//     // Return an empty container if there's no cast info
//     if (cast.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Text("Cast", style: Theme.of(context).textTheme.titleLarge),
//         ),
//         const SizedBox(height: 16),
//         SizedBox(
//           height: 175,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             itemCount: cast.length,
//             itemBuilder: (context, index) {
//               final person = cast[index];
//               return _CastMemberCard(person: person)
//                   .animate()
//                   .fadeIn(delay: (100 * index).ms, duration: 400.ms)
//                   .slideX(begin: 0.5);
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// // A private widget for a single cast member card
// class _CastMemberCard extends StatelessWidget {
//   final Map<String, dynamic> person;
//   const _CastMemberCard({required this.person});

//   @override
//   Widget build(BuildContext context) {
//     final profilePath = person['profile_path'];

//     return Container(
//       width: 100,
//       margin: const EdgeInsets.only(right: 16),
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 50,
//             backgroundColor: AppColors.darkSurface,
//             backgroundImage: profilePath != null
//                 ? NetworkImage('https://image.tmdb.org/t/p/w200$profilePath')
//                 : null,
//             child: profilePath == null
//                 ? const Icon(
//                     Icons.person,
//                     size: 40,
//                     color: AppColors.darkTextSecondary,
//                   )
//                 : null,
//           ),
//           const SizedBox(height: 12),
//           Text(
//             person['name'] ?? '',
//             textAlign: TextAlign.center,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/presentation/pages/detail/widgets/cast_and_crew_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/app_colors.dart';

class CastAndCrewSection extends StatelessWidget {
  final Map<String, dynamic> credits;
  const CastAndCrewSection({super.key, required this.credits});

  @override
  Widget build(BuildContext context) {
    // We can take more cast members now that we have more space
    final cast = (credits['cast'] as List).take(12).toList();

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

        // --- THIS IS THE NEW GRID IMPLEMENTATION ---
        GridView.builder(
          // These two properties are essential for nesting a grid inside a scroll view
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: cast.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Shows 3 actors per row
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.65, // Adjust this to get the perfect height
          ),
          itemBuilder: (context, index) {
            final person = cast[index];
            return _CastMemberCard(person: person)
                .animate()
                .fadeIn(delay: (50 * index).ms, duration: 400.ms)
                .slideY(begin: 0.2);
          },
        ),
        // ------------------------------------------
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

    // The margin is removed as the GridView's spacing properties now handle it
    return Column(
      children: [
        // Using Expanded to make the CircleAvatar flexible
        Expanded(
          child: CircleAvatar(
            radius: 70, // Radius will be constrained by the parent
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
        ),
        const SizedBox(height: 12),
        // Actor's Name
        Text(
          person['name'] ?? '',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        // Character's Name
        Text(
          person['character'] ?? '',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.darkTextSecondary,
          ),
        ),
      ],
    );
  }
}
