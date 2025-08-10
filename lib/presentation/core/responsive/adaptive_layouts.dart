import 'package:flutter/material.dart';

import 'responsive_layout.dart';
import '../app_colors.dart';

/// Adaptive layouts that utilize available screen space efficiently
class AdaptiveLayouts {
  /// Create adaptive grid layout
  static Widget adaptiveGrid({
    required List<Widget> children,
    required BuildContext context,
    int? mobileColumns,
    int? tabletColumns,
    int? desktopColumns,
    int? largeDesktopColumns,
    double? childAspectRatio,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
  }) {
    final columnCount = ResponsiveBreakpoints.getResponsiveValue(
      context,
      mobile: mobileColumns ?? 2,
      tablet: tabletColumns ?? 3,
      desktop: desktopColumns ?? 4,
      largeDesktop: largeDesktopColumns ?? 6,
    );

    final aspectRatio =
        childAspectRatio ??
        ResponsiveBreakpoints.getResponsiveValue(
          context,
          mobile: 0.8,
          tablet: 0.85,
          desktop: 0.9,
          largeDesktop: 0.95,
        );

    final crossSpacing =
        crossAxisSpacing ??
        ResponsiveBreakpoints.getResponsiveValue(
          context,
          mobile: 12.0,
          tablet: 16.0,
          desktop: 20.0,
          largeDesktop: 24.0,
        );

    final mainSpacing =
        mainAxisSpacing ??
        ResponsiveBreakpoints.getResponsiveValue(
          context,
          mobile: 12.0,
          tablet: 16.0,
          desktop: 20.0,
          largeDesktop: 24.0,
        );

    return GridView.builder(
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        childAspectRatio: aspectRatio ?? 1.0,
        crossAxisSpacing: crossSpacing ?? 8.0,
        mainAxisSpacing: mainSpacing ?? 8.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  /// Create adaptive list layout
  static Widget adaptiveList({
    required List<Widget> children,
    required BuildContext context,
    Axis? scrollDirection,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    double? itemExtent,
  }) {
    final direction =
        scrollDirection ??
        (ResponsiveBreakpoints.isMobile(context)
            ? Axis.vertical
            : Axis.horizontal);

    final responsivePadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: ResponsiveBreakpoints.getResponsiveValue(
            context,
            mobile: 16.0,
            tablet: 24.0,
            desktop: 32.0,
            largeDesktop: 48.0,
          ),
          vertical: ResponsiveBreakpoints.getResponsiveValue(
            context,
            mobile: 8.0,
            tablet: 12.0,
            desktop: 16.0,
            largeDesktop: 20.0,
          ),
        );

    return ListView.builder(
      scrollDirection: direction,
      padding: responsivePadding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemExtent: itemExtent,
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  /// Create adaptive column layout
  static Widget adaptiveColumn({
    required List<Widget> children,
    required BuildContext context,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    double? spacing,
    EdgeInsetsGeometry? padding,
  }) {
    final responsiveSpacing =
        spacing ??
        ResponsiveBreakpoints.getResponsiveValue(
          context,
          mobile: 16.0,
          tablet: 20.0,
          desktop: 24.0,
          largeDesktop: 32.0,
        );

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(height: responsiveSpacing));
      }
    }

    Widget column = Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: spacedChildren,
    );

    if (padding != null) {
      column = Padding(padding: padding, child: column);
    }

    return column;
  }

  /// Create adaptive row layout
  static Widget adaptiveRow({
    required List<Widget> children,
    required BuildContext context,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    double? spacing,
    EdgeInsetsGeometry? padding,
    bool wrapOnMobile = true,
  }) {
    final responsiveSpacing =
        spacing ??
        ResponsiveBreakpoints.getResponsiveValue(
          context,
          mobile: 12.0,
          tablet: 16.0,
          desktop: 20.0,
          largeDesktop: 24.0,
        );

    // Use wrap on mobile if enabled
    if (wrapOnMobile && ResponsiveBreakpoints.isMobile(context)) {
      Widget wrap = Wrap(
        alignment: _getWrapAlignment(mainAxisAlignment),
        crossAxisAlignment: _getWrapCrossAlignment(crossAxisAlignment),
        spacing: responsiveSpacing ?? 8.0,
        runSpacing: responsiveSpacing ?? 8.0,
        children: children,
      );

      if (padding != null) {
        wrap = Padding(padding: padding, child: wrap);
      }

      return wrap;
    }

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: responsiveSpacing));
      }
    }

    Widget row = Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: spacedChildren,
    );

    if (padding != null) {
      row = Padding(padding: padding, child: row);
    }

    return row;
  }

  /// Create adaptive wrap layout
  static Widget adaptiveWrap({
    required List<Widget> children,
    required BuildContext context,
    WrapAlignment alignment = WrapAlignment.start,
    WrapAlignment runAlignment = WrapAlignment.start,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    double? spacing,
    double? runSpacing,
    EdgeInsetsGeometry? padding,
  }) {
    final responsiveSpacing =
        spacing ??
        ResponsiveBreakpoints.getResponsiveValue(
          context,
          mobile: 8.0,
          tablet: 12.0,
          desktop: 16.0,
          largeDesktop: 20.0,
        );

    final responsiveRunSpacing = runSpacing ?? responsiveSpacing;

    Widget wrap = Wrap(
      alignment: alignment,
      runAlignment: runAlignment,
      crossAxisAlignment: crossAxisAlignment,
      spacing: responsiveSpacing ?? 8.0,
      runSpacing: responsiveRunSpacing ?? 8.0,
      children: children,
    );

    if (padding != null) {
      wrap = Padding(padding: padding, child: wrap);
    }

    return wrap;
  }

  /// Create adaptive stack layout
  static Widget adaptiveStack({
    required List<Widget> children,
    required BuildContext context,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    StackFit fit = StackFit.loose,
    Clip clipBehavior = Clip.hardEdge,
    EdgeInsetsGeometry? padding,
  }) {
    Widget stack = Stack(
      alignment: alignment,
      fit: fit,
      clipBehavior: clipBehavior,
      children: children,
    );

    if (padding != null) {
      stack = Padding(padding: padding, child: stack);
    }

    return stack;
  }

  /// Helper method to convert MainAxisAlignment to WrapAlignment
  static WrapAlignment _getWrapAlignment(MainAxisAlignment mainAxisAlignment) {
    switch (mainAxisAlignment) {
      case MainAxisAlignment.start:
        return WrapAlignment.start;
      case MainAxisAlignment.end:
        return WrapAlignment.end;
      case MainAxisAlignment.center:
        return WrapAlignment.center;
      case MainAxisAlignment.spaceBetween:
        return WrapAlignment.spaceBetween;
      case MainAxisAlignment.spaceAround:
        return WrapAlignment.spaceAround;
      case MainAxisAlignment.spaceEvenly:
        return WrapAlignment.spaceEvenly;
    }
  }

  /// Helper method to convert CrossAxisAlignment to WrapCrossAlignment
  static WrapCrossAlignment _getWrapCrossAlignment(
    CrossAxisAlignment crossAxisAlignment,
  ) {
    switch (crossAxisAlignment) {
      case CrossAxisAlignment.start:
        return WrapCrossAlignment.start;
      case CrossAxisAlignment.end:
        return WrapCrossAlignment.end;
      case CrossAxisAlignment.center:
        return WrapCrossAlignment.center;
      case CrossAxisAlignment.stretch:
        return WrapCrossAlignment.start; // Wrap doesn't have stretch
      case CrossAxisAlignment.baseline:
        return WrapCrossAlignment.start; // Wrap doesn't have baseline
    }
  }
}

/// Adaptive sidebar layout
class AdaptiveSidebar extends StatelessWidget {
  final Widget sidebar;
  final Widget content;
  final double sidebarWidth;
  final bool showSidebarOnMobile;
  final bool collapsibleSidebar;
  final VoidCallback? onSidebarToggle;

  const AdaptiveSidebar({
    super.key,
    required this.sidebar,
    required this.content,
    this.sidebarWidth = 280,
    this.showSidebarOnMobile = false,
    this.collapsibleSidebar = true,
    this.onSidebarToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveBreakpoints.isMobile(context)) {
      if (showSidebarOnMobile) {
        return Drawer(child: sidebar);
      } else {
        return content;
      }
    }

    return Row(
      children: [
        Container(
          width: sidebarWidth,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            border: Border(
              right: BorderSide(
                color: AppColors.darkTextTertiary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: sidebar,
        ),
        Expanded(child: content),
      ],
    );
  }
}

/// Adaptive master-detail layout
class AdaptiveMasterDetail extends StatelessWidget {
  final Widget master;
  final Widget detail;
  final double masterWidth;
  final bool showDetailOnMobile;
  final bool isDetailVisible;

  const AdaptiveMasterDetail({
    super.key,
    required this.master,
    required this.detail,
    this.masterWidth = 320,
    this.showDetailOnMobile = false,
    this.isDetailVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveBreakpoints.isMobile(context)) {
      if (showDetailOnMobile && isDetailVisible) {
        return detail;
      } else {
        return master;
      }
    }

    return Row(
      children: [
        Container(
          width: masterWidth,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            border: Border(
              right: BorderSide(
                color: AppColors.darkTextTertiary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: master,
        ),
        Expanded(
          child: isDetailVisible
              ? detail
              : Container(
                  color: AppColors.darkBackground,
                  child: const Center(
                    child: Text(
                      'Select an item to view details',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

/// Adaptive tab layout
class AdaptiveTabLayout extends StatelessWidget {
  final List<Tab> tabs;
  final List<Widget> children;
  final TabController? controller;
  final bool scrollableOnMobile;
  final EdgeInsetsGeometry? padding;

  const AdaptiveTabLayout({
    super.key,
    required this.tabs,
    required this.children,
    this.controller,
    this.scrollableOnMobile = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isScrollable =
        scrollableOnMobile && ResponsiveBreakpoints.isMobile(context);

    return Column(
      children: [
        Container(
          padding: padding,
          child: TabBar(
            controller: controller,
            tabs: tabs,
            isScrollable: isScrollable,
            tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
            labelPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveBreakpoints.getResponsiveValue(
                context,
                mobile: 16.0,
                tablet: 20.0,
                desktop: 24.0,
              ),
              vertical: ResponsiveBreakpoints.getResponsiveValue(
                context,
                mobile: 12.0,
                tablet: 16.0,
                desktop: 20.0,
              ),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(controller: controller, children: children),
        ),
      ],
    );
  }
}

/// Adaptive card grid
class AdaptiveCardGrid extends StatelessWidget {
  final List<Widget> cards;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final int? largeDesktopColumns;
  final double? childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const AdaptiveCardGrid({
    super.key,
    required this.cards,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.largeDesktopColumns,
    this.childAspectRatio,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayouts.adaptiveGrid(
      children: cards,
      context: context,
      mobileColumns: mobileColumns ?? 1,
      tabletColumns: tabletColumns ?? 2,
      desktopColumns: desktopColumns ?? 3,
      largeDesktopColumns: largeDesktopColumns ?? 4,
      childAspectRatio: childAspectRatio,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
    );
  }
}

/// Adaptive content container
class AdaptiveContentContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool centerContent;
  final Color? backgroundColor;

  const AdaptiveContentContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
    this.centerContent = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveMaxWidth =
        maxWidth ??
        ResponsiveBreakpoints.getResponsiveValue(
          context,
          mobile: double.infinity,
          tablet: 768.0,
          desktop: 1200.0,
          largeDesktop: 1400.0,
        );

    final responsivePadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: ResponsiveBreakpoints.getResponsiveValue(
            context,
            mobile: 16.0,
            tablet: 24.0,
            desktop: 32.0,
            largeDesktop: 48.0,
          ),
          vertical: ResponsiveBreakpoints.getResponsiveValue(
            context,
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
            largeDesktop: 32.0,
          ),
        );

    Widget content = Container(
      constraints: BoxConstraints(
        maxWidth: responsiveMaxWidth ?? double.infinity,
      ),
      padding: responsivePadding,
      margin: margin,
      decoration: backgroundColor != null
          ? BoxDecoration(color: backgroundColor)
          : null,
      child: child,
    );

    if (centerContent && !ResponsiveBreakpoints.isMobile(context)) {
      content = Center(child: content);
    }

    return content;
  }
}
