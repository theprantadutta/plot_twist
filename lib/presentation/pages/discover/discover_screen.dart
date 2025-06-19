import 'package:flutter/material.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Discover Screen',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
