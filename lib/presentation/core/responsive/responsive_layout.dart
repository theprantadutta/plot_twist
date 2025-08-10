import 'package:flutter/material.dart';

/// Responsive layout system with mobile-first approach
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  final double mobileBreakpoint;
  final double tabletBreakpoint;
  final double desktopBreakpoint;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    this.mobileBreakpoint = 600,
    this.tabletBreakpoint = 1024,
    this.desktopBreakpoint = 1440,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= desktopBreakpoint && largeDesktop != null) {
          return largeDesktop!;
        } else if (width >= tabletBreakpoint && desktop != null) {
          return desktop!;
        } else if (width >= mobileBreakpoint && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Responsive breakpoints utility
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
  static const double largeDesktop = 1920;

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= desktop && width < largeDesktop;
  }

  /// Check if current screen is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktop;
  }

  /// Get current device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= largeDesktop) {
      return DeviceType.largeDesktop;
    } else if (width >= desktop) {
      return DeviceType.desktop;
    } else if (width >= tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  /// Get responsive value based on screen size
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
}

/// Device type enumeration
enum DeviceType { mobile, tablet, desktop, largeDesktop }

/// Responsive padding utility
class ResponsivePadding {
  /// Get responsive horizontal padding
  static EdgeInsetsGeometry horizontal(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: ResponsiveBreakpoints.getResponsiveValue(
        context,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
        largeDesktop: 48.0,
      ),
    );
  }

  /// Get responsive vertical padding
  static EdgeInsetsGeometry vertical(BuildContext context) {
    return EdgeInsets.symmetric(
      vertical: ResponsiveBreakpoints.getResponsiveValue(
        context,
        mobile: 16.0,
        tablet: 20.0,
        desktop: 24.0,
        largeDesktop: 32.0,
      ),
    );
  }

  /// Get responsive all-around padding
  static EdgeInsetsGeometry all(BuildContext context) {
    return EdgeInsets.all(
      ResponsiveBreakpoints.getResponsiveValue(
        context,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
        largeDesktop: 48.0,
      ),
    );
  }

  /// Get custom responsive padding
  static EdgeInsetsGeometry custom(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return EdgeInsets.all(
      ResponsiveBreakpoints.getResponsiveValue(
        context,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
        largeDesktop: largeDesktop,
      ),
    );
  }
}

/// Responsive spacing utility
class ResponsiveSpacing {
  /// Get responsive spacing value
  static double get(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return ResponsiveBreakpoints.getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }

  /// Small spacing
  static double small(BuildContext context) {
    return ResponsiveBreakpoints.getResponsiveValue(
      context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
      largeDesktop: 20.0,
    );
  }

  /// Medium spacing
  static double medium(BuildContext context) {
    return ResponsiveBreakpoints.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
      largeDesktop: 32.0,
    );
  }

  /// Large spacing
  static double large(BuildContext context) {
    return ResponsiveBreakpoints.getResponsiveValue(
      context,
      mobile: 24.0,
      tablet: 32.0,
      desktop: 40.0,
      largeDesktop: 48.0,
    );
  }

  /// Extra large spacing
  static double extraLarge(BuildContext context) {
    return ResponsiveBreakpoints.getResponsiveValue(
      context,
      mobile: 32.0,
      tablet: 40.0,
      desktop: 48.0,
      largeDesktop: 64.0,
    );
  }
}

/// Responsive grid utility
class ResponsiveGrid {
  /// Get responsive column count
  static int getColumnCount(
    BuildContext context, {
    required int mobile,
    int? tablet,
    int? desktop,
    int? largeDesktop,
  }) {
    return ResponsiveBreakpoints.getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }

  /// Get responsive aspect ratio
  static double getAspectRatio(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return ResponsiveBreakpoints.getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }

  /// Get responsive cross axis spacing
  static double getCrossAxisSpacing(BuildContext context) {
    return ResponsiveBreakpoints.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
      largeDesktop: 24.0,
    );
  }

  /// Get responsive main axis spacing
  static double getMainAxisSpacing(BuildContext context) {
    return ResponsiveBreakpoints.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
      largeDesktop: 24.0,
    );
  }
}

/// Responsive typography scaling
class ResponsiveTypography {
  /// Get responsive font size
  static double getFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return ResponsiveBreakpoints.getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }

  /// Get responsive line height
  static double getLineHeight(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return ResponsiveBreakpoints.getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }
}

/// Responsive container utility
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool centerContent;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
    this.centerContent = true,
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

    final responsivePadding = padding ?? ResponsivePadding.horizontal(context);

    Widget content = Container(
      constraints: BoxConstraints(
        maxWidth: responsiveMaxWidth ?? double.infinity,
      ),
      padding: responsivePadding,
      margin: margin,
      child: child,
    );

    if (centerContent && !ResponsiveBreakpoints.isMobile(context)) {
      content = Center(child: content);
    }

    return content;
  }
}

/// Responsive flex utility
class ResponsiveFlex extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final Axis? forceDirection;
  final double spacing;

  const ResponsiveFlex({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.forceDirection,
    this.spacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    final direction =
        forceDirection ??
        (ResponsiveBreakpoints.isMobile(context)
            ? Axis.vertical
            : Axis.horizontal);

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1 && spacing > 0) {
        spacedChildren.add(
          direction == Axis.horizontal
              ? SizedBox(width: spacing)
              : SizedBox(height: spacing),
        );
      }
    }

    return Flex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: spacedChildren,
    );
  }
}

/// Responsive wrap utility
class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;
  final WrapAlignment alignment;
  final WrapAlignment runAlignment;
  final WrapCrossAlignment crossAxisAlignment;
  final double spacing;
  final double runSpacing;

  const ResponsiveWrap({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.spacing = 0,
    this.runSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveSpacing = spacing > 0
        ? spacing
        : ResponsiveSpacing.small(context);
    final responsiveRunSpacing = runSpacing > 0
        ? runSpacing
        : ResponsiveSpacing.small(context);

    return Wrap(
      direction: direction,
      alignment: alignment,
      runAlignment: runAlignment,
      crossAxisAlignment: crossAxisAlignment,
      spacing: responsiveSpacing,
      runSpacing: responsiveRunSpacing,
      children: children,
    );
  }
}
