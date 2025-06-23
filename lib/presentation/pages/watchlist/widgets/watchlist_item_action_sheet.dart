// lib/presentation/pages/watchlist/widgets/watchlist_item_action_sheet.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../data/firestore/firestore_service.dart';
import '../../../core/app_colors.dart';

// A function to show our custom bottom sheet
void showWatchlistItemActionSheet(
  BuildContext context,
  Map<String, dynamic> item,
) {
  final service = FirestoreService();
  final title = item['title'] ?? item['name'] ?? 'Item';
  final mediaId = item['id'].toString();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Menu Item: Mark as Watched
              ListTile(
                leading: const FaIcon(
                  FontAwesomeIcons.solidEye,
                  color: AppColors.darkTextSecondary,
                ),
                title: const Text("Mark as Watched"),
                onTap: () {
                  service.addToList('watched', item);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Moved '$title' to Watched")),
                  );
                },
              ),
              // Menu Item: Add to a Custom List
              ListTile(
                leading: const FaIcon(
                  FontAwesomeIcons.listCheck,
                  color: AppColors.darkTextSecondary,
                ),
                title: const Text("Add to another list..."),
                onTap: () {
                  // This is where you would show the "Add to Custom List" bottom sheet
                  Navigator.pop(context);
                },
              ),
              const Divider(color: Colors.white12),
              // Menu Item: Remove from Watchlist
              ListTile(
                leading: const FaIcon(
                  FontAwesomeIcons.bookmark,
                  color: AppColors.darkErrorRed,
                ),
                title: const Text(
                  "Remove from Watchlist",
                  style: TextStyle(color: AppColors.darkErrorRed),
                ),
                onTap: () {
                  service.removeFromList('watchlist', mediaId);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Removed '$title' from Watchlist")),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
