import 'package:flutter/material.dart';

/// Screen Type Enum
enum ScreenType { mobile, tablet, desktop }

/// Responsive Helper - Handles responsive design across all screen sizes
class ResponsiveHelper {
  ResponsiveHelper._();

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Get current screen type
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    return getScreenType(context) == ScreenType.tablet;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return getScreenType(context) == ScreenType.desktop;
  }

  /// Check if screen is small (mobile or tablet)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletBreakpoint;
  }

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get proportional width based on design size (default 375 for mobile)
  static double proportionalWidth(BuildContext context, double width, {double designWidth = 375}) {
    return (width / designWidth) * screenWidth(context);
  }

  /// Get proportional height based on design size (default 812 for mobile)
  static double proportionalHeight(BuildContext context, double height, {double designHeight = 812}) {
    return (height / designHeight) * screenHeight(context);
  }

  /// Get responsive font size
  static double responsiveFontSize(BuildContext context, double fontSize) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return fontSize;
      case ScreenType.tablet:
        return fontSize * 1.2;
      case ScreenType.desktop:
        return fontSize * 1.4;
    }
  }

  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context, {
    double mobilePadding = 16,
    double tabletPadding = 24,
    double desktopPadding = 32,
  }) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return EdgeInsets.all(mobilePadding);
      case ScreenType.tablet:
        return EdgeInsets.all(tabletPadding);
      case ScreenType.desktop:
        return EdgeInsets.all(desktopPadding);
    }
  }

  /// Get responsive horizontal padding
  static EdgeInsets responsiveHorizontalPadding(BuildContext context, {
    double mobilePadding = 16,
    double tabletPadding = 32,
    double desktopPadding = 48,
  }) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return EdgeInsets.symmetric(horizontal: mobilePadding);
      case ScreenType.tablet:
        return EdgeInsets.symmetric(horizontal: tabletPadding);
      case ScreenType.desktop:
        return EdgeInsets.symmetric(horizontal: desktopPadding);
    }
  }

  /// Get number of grid columns based on screen type
  static int getGridColumns(BuildContext context, {
    int mobileColumns = 2,
    int tabletColumns = 3,
    int desktopColumns = 4,
  }) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return mobileColumns;
      case ScreenType.tablet:
        return tabletColumns;
      case ScreenType.desktop:
        return desktopColumns;
    }
  }

  /// Get grid item aspect ratio
  static double getGridAspectRatio(BuildContext context, {
    double mobileRatio = 0.75,
    double tabletRatio = 0.8,
    double desktopRatio = 0.85,
  }) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return mobileRatio;
      case ScreenType.tablet:
        return tabletRatio;
      case ScreenType.desktop:
        return desktopRatio;
    }
  }

  /// Get max content width
  static double getMaxContentWidth(BuildContext context) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return screenWidth(context);
      case ScreenType.tablet:
        return 700;
      case ScreenType.desktop:
        return 1200;
    }
  }
}

/// Responsive Layout Builder - Builds different layouts based on screen type
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveHelper.desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= ResponsiveHelper.tabletBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Responsive Value - Returns different values based on screen type
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  T getValue(BuildContext context) {
    final screenType = ResponsiveHelper.getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// Responsive SizedBox
class ResponsiveSizedBox extends StatelessWidget {
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;
  final double? mobileHeight;
  final double? tabletHeight;
  final double? desktopHeight;
  final Widget? child;

  const ResponsiveSizedBox({
    super.key,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
    this.mobileHeight,
    this.tabletHeight,
    this.desktopHeight,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveHelper.getScreenType(context);
    
    double? width;
    double? height;
    
    switch (screenType) {
      case ScreenType.mobile:
        width = mobileWidth;
        height = mobileHeight;
        break;
      case ScreenType.tablet:
        width = tabletWidth ?? mobileWidth;
        height = tabletHeight ?? mobileHeight;
        break;
      case ScreenType.desktop:
        width = desktopWidth ?? tabletWidth ?? mobileWidth;
        height = desktopHeight ?? tabletHeight ?? mobileHeight;
        break;
    }
    
    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }
}

/// Screen size information for use in widgets
class ScreenSizeInfo {
  final ScreenType screenType;
  final double width;
  final double height;
  final double pixelRatio;
  final EdgeInsets padding;
  final EdgeInsets viewInsets;

  const ScreenSizeInfo({
    required this.screenType,
    required this.width,
    required this.height,
    required this.pixelRatio,
    required this.padding,
    required this.viewInsets,
  });

  factory ScreenSizeInfo.fromContext(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return ScreenSizeInfo(
      screenType: ResponsiveHelper.getScreenType(context),
      width: mediaQuery.size.width,
      height: mediaQuery.size.height,
      pixelRatio: mediaQuery.devicePixelRatio,
      padding: mediaQuery.padding,
      viewInsets: mediaQuery.viewInsets,
    );
  }
}

/// Screen size provider widget
class ScreenSizeProvider extends InheritedWidget {
  final ScreenSizeInfo screenSizeInfo;

  const ScreenSizeProvider({
    super.key,
    required this.screenSizeInfo,
    required super.child,
  });

  static ScreenSizeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ScreenSizeProvider>();
  }

  @override
  bool updateShouldNotify(ScreenSizeProvider oldWidget) {
    return screenSizeInfo.screenType != oldWidget.screenSizeInfo.screenType ||
        screenSizeInfo.width != oldWidget.screenSizeInfo.width ||
        screenSizeInfo.height != oldWidget.screenSizeInfo.height;
  }
}
