import 'package:flutter/material.dart';

class PersonCard extends StatelessWidget {
  final String name;
  final String profilePath;
  final String knownFor;

  const PersonCard({
    super.key,
    required this.name,
    required this.profilePath,
    required this.knownFor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(
              'https://image.tmdb.org/t/p/w500$profilePath',
            ),
            backgroundColor: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            knownFor,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
