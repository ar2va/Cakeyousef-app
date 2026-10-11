import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/content_api.dart';
import '../models/catalog_models.dart';

class SlidersRepository extends ChangeNotifier {
  SlidersRepository._();
  static final SlidersRepository instance = SlidersRepository._();

  final ContentApi _api = ContentApi();

  List<HomeSlideDto> slides = const [];
  bool loading = false;
  String? error;
  bool _fromApi = false;

  bool get hasData => slides.isNotEmpty;

  Future<void> load({bool force = false}) async {
    if (loading) return;
    if (_fromApi && hasData && !force) return;

    loading = true;
    error = null;
    notifyListeners();

    try {
      final remote = await _api.fetchSliders();
      if (remote.isNotEmpty) {
        slides = remote;
        _fromApi = true;
        error = null;
      } else if (!_fromApi) {
        slides = const [];
      }
    } on ApiException catch (e) {
      error = e.message;
    } catch (e) {
      debugPrint('Sliders load failed: $e');
      error = 'بارگذاری اسلایدر ناموفق بود';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
