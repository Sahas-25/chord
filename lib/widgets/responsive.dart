import 'package:flutter/material.dart';

/// Simple breakpoints used by the whole app.
class Responsive {
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static bool isMobile(BuildContext context) => width(context) < 600;
  static bool isTablet(BuildContext context) =>
      width(context) >= 600 && width(context) < 1000;
  static bool isDesktop(BuildContext context) => width(context) >= 1000;
}

/// Centres the page and stops it from becoming too wide on big screens.
class PageContainer extends StatelessWidget {
  const PageContainer({super.key, required this.child, this.maxWidth = 1000});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
