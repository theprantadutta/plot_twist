import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

class ProfileMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const ProfileMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.darkErrorRed : Colors.white;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      trailing: isDestructive
          ? null
          : const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.white54,
            ),
      onTap: onTap,
    );
  }
}
