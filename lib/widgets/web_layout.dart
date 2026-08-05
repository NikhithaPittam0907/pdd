import 'package:flutter/material.dart';

/// A responsive wrapper widget that ensures Flutter screens render like modern desktop
/// web applications when opened in web browsers or on large monitors.
class WebLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;
  final AlignmentGeometry alignment;

  const WebLayout({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.backgroundColor,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Container(
            color: backgroundColor ?? const Color(0xFFF4F6FB),
            alignment: alignment,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}
