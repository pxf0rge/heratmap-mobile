import 'package:flutter/foundation.dart';
import 'package:heratmap/core/app_config.dart';
import 'package:heratmap/data/cache/local_cache.dart';
import 'package:heratmap/data/endpoints.dart';
import 'package:heratmap/data/models/emergency_contact_model.dart';
import 'package:heratmap/data/provider/app_provider.dart';
import 'package:heratmap/data/result.dart';
import 'package:heratmap/data/retry.dart';

class EmergencyContactRepository {
  EmergencyContactRepository({LocalCache? cache})
      : _cache = cache ?? LocalCache();

  static const String _key = 'emergency_contacts_all';

  final LocalCache _cache;

  Future<DataResult<List<EmergencyContactModel>>> getContacts(
      {bool forceRefresh = false}) async {
    return _fetch(forceRefresh: forceRefresh);
  }

  Future<DataResult<List<EmergencyContactModel>>> _fetch(
      {bool forceRefresh = false}) async {
    final fresh = _readCache();
    if (!forceRefresh &&
        fresh != null &&
        !fresh.isOlderThan(AppConfig.freshCacheAge)) {
      return DataSuccess(
        fresh.value,
        source: DataSource.cache,
        fetchedAt: fresh.storedAt,
      );
    }

    try {
      final rows = await withRetry(
        () => _fetchAll().timeout(AppConfig.requestTimeout),
        onRetry: (attempt, error) => debugPrint(
          'EmergencyContactRepository: attempt $attempt failed → $error',
        ),
      );
      final items = rows.map(EmergencyContactModel.fromMap).toList();
      _cache.writeList(_key, items, (item) => item.toMap());
      return DataSuccess(
        items,
        source: DataSource.network,
        fetchedAt: DateTime.now(),
      );
    } catch (error) {
      final failure = DataError.fromException(error);
      if (failure.isTransient && fresh != null) {
        return DataSuccess(
          fresh.value,
          source: DataSource.cache,
          fetchedAt: fresh.storedAt,
        );
      }
      return DataFailure(failure);
    }
  }

  DateTime? lastUpdatedAt() => _cache.storedAt(_key);

  void clearCache() {
    _cache.remove(_key);
  }

  CacheEntry<List<EmergencyContactModel>>? _readCache() =>
      _cache.readList(_key, EmergencyContactModel.fromMap);

  Future<List<Map<String, dynamic>>> _fetchAll() async {
    final List<Map<String, dynamic>> data = await AppProvider.db
        .from(Endpoints.emergencyContacts)
        .select()
        .order('sort_order', ascending: true);
    return data;
  }
}
