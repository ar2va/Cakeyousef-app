import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// App-wide messenger so services (deep links, payment results) can show
/// snack bars without a BuildContext.
final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showAppMessage(
  String message, {
  bool success = false,
  bool error = false,
  Duration duration = const Duration(seconds: 4),
}) {
  final messenger = appMessengerKey.currentState;
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        backgroundColor: success
            ? const Color(0xFF059669)
            : error
                ? const Color(0xFFDC2626)
                : AppColors.dark900,
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
}
