import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/content_api.dart';
import '../models/catalog_models.dart';

/// Products catalog from `/api/content/products`.
class ProductsRepository extends ChangeNotifier {
  ProductsRepository._();
  static final ProductsRepository instance = ProductsRepository._();

  final ContentApi _api = ContentApi();

  List<ShopProductDto> products = const [];
  List<String> categories = const ['همه'];
  String selectedCategory = 'همه';
  bool loading = false;
  String? error;
  bool _fromApi = false;

  bool get hasData => products.isNotEmpty;

  void selectCategory(String category) {
    final next = category.trim().isEmpty ? 'همه' : category.trim();
    if (selectedCategory == next) return;
    selectedCategory = next;
    notifyListeners();
  }

  static const int homePreviewCount = 8;

  List<ShopProductDto> get homePreview =>
      products.take(homePreviewCount).toList(growable: false);

  Future<void> load({bool force = false}) async {
    if (loading) return;
    if (_fromApi && hasData && !force) return;

    loading = true;
    error = null;
    notifyListeners();

    try {
      final remote = await _api.fetchProducts();
      if (remote.products.isNotEmpty) {
        products = remote.products;
        categories = remote.categories;
        if (!categories.contains(selectedCategory)) {
          selectedCategory = 'همه';
        }
        _fromApi = true;
        error = null;
      } else if (!_fromApi) {
        products = const [];
        categories = const ['همه'];
        selectedCategory = 'همه';
        error = 'محصولی یافت نشد';
      }
    } on ApiException catch (e) {
      error = e.message;
      if (!_fromApi) {
        products = const [];
        categories = const ['همه'];
        selectedCategory = 'همه';
      }
    } catch (e) {
      debugPrint('Products load failed: $e');
      error = 'بارگذاری محصولات ناموفق بود';
      if (!_fromApi) {
        products = const [];
        categories = const ['همه'];
        selectedCategory = 'همه';
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  List<ShopProductDto> filtered(String category) {
    if (category.isEmpty || category == 'همه') return products;
    return products.where((p) => p.category == category).toList();
  }

  List<ShopProductDto> relatedTo(ShopProductDto product, {int limit = 6}) {
    final same = products
        .where((p) => p.id != product.id && p.category == product.category)
        .toList();
    if (same.length >= limit) return same.take(limit).toList(growable: false);
    final rest = products
        .where((p) => p.id != product.id && p.category != product.category)
        .take(limit - same.length);
    return [...same, ...rest];
  }

  Future<ShopProductDto> fetchDetail(String id, {bool forceRemote = true}) async {
    final match = products.where((p) => p.id == id);
    final cached = match.isEmpty ? null : match.first;

    if (forceRemote || cached == null || !cached.hasRichDetail) {
      try {
        final detail = await _api.fetchProductDetail(id);
        _upsert(detail);
        return detail;
      } on ApiException {
        if (cached != null) return cached;
        rethrow;
      } catch (_) {
        if (cached != null) return cached;
        throw StateError('محصول یافت نشد');
      }
    }
    return cached;
  }

  void _upsert(ShopProductDto detail) {
    final next = List<ShopProductDto>.of(products);
    final index = next.indexWhere((p) => p.id == detail.id);
    if (index >= 0) {
      next[index] = detail;
    } else {
      next.add(detail);
    }
    products = next;
    notifyListeners();
  }
}
