import 'dart:math' as math;

import 'package:flutter/material.dart';

class PageConstraint extends StatelessWidget {
  const PageConstraint({super.key, required this.child});

  static const double maxPageWidth = 600;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: math.min(MediaQuery.of(context).size.width, maxPageWidth),
        ),
        child: child,
      ),
    );
  }
}
