// lib/presentation/pages/detail/widgets/detail_tab_bar.dart
import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

class DetailTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  DetailTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.darkBackground, // Ensures the background is solid
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(DetailTabBarDelegate oldDelegate) => false;
}
