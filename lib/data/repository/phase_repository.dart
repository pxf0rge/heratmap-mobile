import 'package:flutter/foundation.dart';
import 'package:heratmap/core/app_config.dart';
import 'package:heratmap/data/cache/local_cache.dart';
import 'package:heratmap/data/endpoints.dart';
import 'package:heratmap/data/models/phase_model.dart';
import 'package:heratmap/data/provider/app_provider.dart';
import 'package:heratmap/data/result.dart';
import 'package:heratmap/data/retry.dart';

/// دسترسی به داده‌ی فازها با همان الگوی [FactoryRepository]:
/// شبکه با تلاش مجدد، بازگشت به کش محلی، و نتیجه‌ی تایپ‌دار.
class PhaseRepository {
  PhaseRepository({LocalCache? cache, SingleFlight? singleFlight})
    : _cache = cache ?? LocalCache(),
      _singleFlight = singleFlight ?? SingleFlight();

  static const String _cacheName = 'phases';

  final LocalCache _cache;
  final SingleFlight _singleFlight;

  Future<DataResult<List<PhaseModel>>> getPhases({bool forceRefresh = false}) {
    return _singleFlight.run('phases:all', () async {
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
          () => _fetchPhases().timeout(AppConfig.requestTimeout),
          onRetry: (attempt, error) => debugPrint(
            'PhaseRepository.getPhases: attempt $attempt failed → $error',
          ),
        );
        final items = rows.map(PhaseModel.fromMap).toList();
        _cache.writeList(_cacheName, items, (item) => item.toMap());
        return DataSuccess(
          items,
          source: DataSource.network,
          fetchedAt: DateTime.now(),
        );
      } catch (error) {
        final failure = DataError.fromException(error);
        if (failure.isTransient) {
          final cached = _readCache();
          if (cached != null) {
            debugPrint(
              'PhaseRepository.getPhases: local cache '
              '(${cached.value.length} phases, ${cached.age().inMinutes} min old)',
            );
            return DataSuccess(
              cached.value,
              source: DataSource.cache,
              fetchedAt: cached.storedAt,
            );
          }
        }
        return DataFailure(failure);
      }
    });
  }

  Future<DataResult<PhaseModel>> getPhase(String id) {
    return _singleFlight.run('phase:$id', () async {
      try {
        final row = await withRetry(
          () => _fetchPhase(id).timeout(AppConfig.requestTimeout),
        );
        return DataSuccess(
          PhaseModel.fromMap(row),
          source: DataSource.network,
          fetchedAt: DateTime.now(),
        );
      } catch (error) {
        final failure = DataError.fromException(error);
        if (failure.isTransient) {
          final cached = _readCache();
          final match = cached?.value.where((p) => p.id == id).toList();
          if (match != null && match.isNotEmpty) {
            return DataSuccess(
              match.first,
              source: DataSource.cache,
              fetchedAt: cached!.storedAt,
            );
          }
        }
        return DataFailure(failure);
      }
    });
  }

  DateTime? lastUpdatedAt() => _cache.storedAt(_cacheName);

  void clearCache() {
    _cache.remove(_cacheName);
    _singleFlight.clear();
  }

  // ── درخواست‌های شبکه ──────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _fetchPhases() async {
    final List<Map<String, dynamic>> data = await AppProvider.db
        .from(Endpoints.phases)
        .select()
        .order('number', ascending: true);
    return data;
  }

  Future<Map<String, dynamic>> _fetchPhase(String id) async {
    final Map<String, dynamic> data = await AppProvider.db
        .from(Endpoints.phases)
        .select()
        .eq('id', id)
        .single();
    return data;
  }

  CacheEntry<List<PhaseModel>>? _readCache() =>
      _cache.readList(_cacheName, PhaseModel.fromMap);
}
