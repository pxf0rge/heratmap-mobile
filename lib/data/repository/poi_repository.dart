import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:heratmap/data/models/poi_model.dart';
import 'package:heratmap/data/result.dart';
import 'package:heratmap/data/retry.dart';

class PoiRepository extends GetxController {
  final _client = Supabase.instance.client;
  List<PoiModel> _cache = [];

  List<PoiModel> get cachedPois => _cache;
  bool get hasData => _cache.isNotEmpty;

  Future<DataResult<List<PoiModel>>> fetchPois() async {
    try {
      final data = await withRetry(
        () async {
          final response = await _client
              .from('pois')
              .select()
              .eq('is_active', true)
              .order('sort_order');
          return response;
        },
        maxAttempts: 2,
      );

      final pois = data.map((e) => PoiModel.fromMap(e)).toList();
      _cache = pois;
      return DataSuccess(pois);
    } catch (e) {
      return DataFailure(DataError.fromException(e));
    }
  }

  void clearCache() {
    _cache = [];
  }
}
