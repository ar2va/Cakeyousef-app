import 'package:flutter/material.dart';

/// Official Google Play logo asset (prism + wordmark cropped to mark).
class GooglePlayIcon extends StatelessWidget {
  const GooglePlayIcon({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          'assets/images/stores/google_play_logo.png',
          fit: BoxFit.cover,
          alignment: Alignment.centerLeft,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

/// Cafe Bazaar brand mark (from official logo asset).
class BazaarIcon extends StatelessWidget {
  const BazaarIcon({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/stores/bazaar_icon.jpg',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
