import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_client.dart';
import '../api/checkout_api.dart';
import '../state/auth_session.dart';
import '../widgets/auth_sheet.dart';

void _snack(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: GoogleFonts.vazirmatn(),
        textAlign: TextAlign.center,
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

bool _paying = false;

/// In-app purchase: the API creates the order with the app's token, the bank
/// page opens in the browser, and the site returns to `cakeyousef://payment`
/// (handled in DeepLinkService).
Future<void> _startPayment(
  BuildContext context, {
  required List<CheckoutItem> items,
  required bool shippingRequired,
}) async {
  if (_paying) return;

  final session = AuthSession.instance;
  if (!session.isLoggedIn) {
    _snack(context, 'برای خرید ابتدا وارد حساب شوید');
    await showAuthSheet(context);
    if (!session.isLoggedIn) return;
  }

  if (shippingRequired) {
    final details = session.checkoutDetails;
    final hasAddress = details != null &&
        details.address.trim().isNotEmpty &&
        details.legacyCityId != null;
    if (!hasAddress) {
      if (!context.mounted) return;
      _snack(
        context,
        'برای ارسال محصول، ابتدا آدرس و کد پستی را در بخش پروفایل تکمیل کنید',
      );
      return;
    }
  }

  _paying = true;
  try {
    if (context.mounted) {
      _snack(context, 'در حال اتصال به درگاه پرداخت…');
    }
    final url = await CheckoutApi().requestZarinpalPayment(
      items: items,
      shippingRequired: shippingRequired,
    );
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      _snack(context, 'امکان باز کردن درگاه پرداخت نیست');
    }
  } on ApiException catch (e) {
    if (e.statusCode == 401) {
      await session.logout();
      if (context.mounted) _snack(context, 'نشست منقضی شده؛ دوباره وارد شوید');
      return;
    }
    if (context.mounted) _snack(context, e.message);
  } catch (_) {
    if (context.mounted) _snack(context, 'ایجاد پرداخت ناموفق بود');
  } finally {
    _paying = false;
  }
}

Future<void> buyCourse(BuildContext context, {required String courseId}) {
  final legacyId = int.tryParse(courseId);
  if (legacyId == null) {
    _snack(context, 'شناسه دوره نامعتبر است');
    return Future.value();
  }
  return _startPayment(
    context,
    items: [CheckoutItem(legacyId: legacyId, kind: 'course')],
    shippingRequired: false,
  );
}

Future<void> buyProduct(
  BuildContext context, {
  required String productId,
  int quantity = 1,
}) {
  final legacyId = int.tryParse(productId);
  if (legacyId == null) {
    _snack(context, 'شناسه محصول نامعتبر است');
    return Future.value();
  }
  return _startPayment(
    context,
    items: [
      CheckoutItem(legacyId: legacyId, kind: 'product', quantity: quantity),
    ],
    shippingRequired: true,
  );
}
