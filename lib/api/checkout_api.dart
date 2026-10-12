import 'api_client.dart';
import 'api_config.dart';

/// One cart line for `/checkout/zarinpal/request` (legacy catalog id).
class CheckoutItem {
  final int legacyId;
  final String kind; // 'course' | 'product'
  final int quantity;

  const CheckoutItem({
    required this.legacyId,
    required this.kind,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        'legacyId': legacyId,
        'kind': kind,
        'quantity': quantity,
      };
}

class CheckoutApi {
  CheckoutApi({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  /// Creates the order + ZarinPal payment with the app's Bearer token.
  ///
  /// Returns the bank page URL. After paying, the site's callback sends the
  /// user back to [ApiConfig.paymentRedirectUri] with `status`, `orderId`, `ref`.
  Future<String> requestZarinpalPayment({
    required List<CheckoutItem> items,
    required bool shippingRequired,
  }) async {
    final body = await _client.post(
      '/checkout/zarinpal/request',
      auth: true,
      body: {
        'items': items.map((item) => item.toJson()).toList(),
        'shippingRequired': shippingRequired,
        'returnUri': ApiConfig.paymentRedirectUri,
      },
    );
    final url = body['paymentUrl']?.toString().trim() ?? '';
    if (url.isEmpty) {
      throw const ApiException('آدرس درگاه پرداخت دریافت نشد');
    }
    return url;
  }
}
