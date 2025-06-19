import 'package:flutter/material.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Watchlist Screen',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
