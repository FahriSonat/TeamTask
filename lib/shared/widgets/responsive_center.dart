// Dosya: lib/shared/widgets/responsive_center.dart
// Tablet ve geniş ekranlarda içeriği sınırlı genişlikte ortalayan sarmalayıcı.

import 'package:flutter/material.dart';

/// Tablet ve yatay ekranlarda içeriğin tüm genişliğe yayılmasını engeller;
/// telefonda (dar ekranda) çocuğu olduğu gibi gösterir.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveCenter({super.key, required this.child, this.maxWidth = 640});

  /// Ekran dar ise içerik tam genişlikte kalır, genişse en fazla maxWidth olur.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
