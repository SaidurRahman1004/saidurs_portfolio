import 'package:flutter/material.dart';

import '../../config/constants.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWrapper({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppConstants.mobileBreakpoint &&
      MediaQuery.of(context).size.width < AppConstants.tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppConstants.tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth >= AppConstants.desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= AppConstants.tabletBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

//Responsive Value Helper Class for Responsive Widget
class Responsive {
  static double value({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if(ResponsiveWrapper.isDesktop(context)){
      return desktop ?? tablet ?? mobile;
    }else if(ResponsiveWrapper.isTablet(context)){
      return tablet ?? mobile;
    }else{
      return mobile;
    }
  }
}
