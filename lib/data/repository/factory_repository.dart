import 'package:flutter/foundation.dart';
import 'package:heratmap/core/app_config.dart';
import 'package:heratmap/core/text_utils.dart';
import 'package:heratmap/data/cache/local_cache.dart';
import 'package:heratmap/data/endpoints.dart';
import 'package:heratmap/data/models/factory_model.dart';
import 'package:heratmap/data/provider/app_provider.dart';
import 'package:heratmap/data/result.dart';
import 'package:heratmap/data/retry.dart';

/// دسترسی به داده‌ی شرکت‌ها با الگوی «شبکه با تلاش مجدد، بازگشت به کش محلی».
///
/// هر متد یک [DataResult] برمی‌گرداند: یا [DataSuccess] با منبع/زمان داده،
/// یا [DataFailure] با [DataError] تایپ‌دار. هیچ‌گاه استثنا پرتاب نمی‌شود،
/// پس UI می‌تواند بین «خالی»، «آفلاین» و «خطای واقعی» تفاوت بگذارد.
class FactoryRepository {
  FactoryRepository({
    LocalCache? cache,
    SingleFlight? singleFlight,
    DateTime Function()? now,
  }) : _cache = cache ?? LocalCache(),
       _singleFlight = singleFlight ?? SingleFlight(),
       _now = now ?? DateTime.now;

  static const String _allKey = 'factories_all';
  static const String _countsKey = 'factory_counts_by_phase';

  /// پس از یک خطای گذرا در جستجوی سرور، تا این مدت سرور دوباره صدا زده
  /// نمی‌شود. بدون این محدودیت، تایپ در حالت آفلاین برای هر حرف یک درخواست
  /// با سه تلاش و backoff می‌سازد و UI را قفل می‌کند.
  static const Duration searchCooldown = Duration(seconds: 30);

  final LocalCache _cache;
  final SingleFlight _singleFlight;
  final DateTime Function() _now;

  DateTime? _searchBlockedUntil;

  /// آیا جستجوی سمت سرور موقتاً کنار گذاشته شده است؟
  /// UI از این مقدار برای نمایش پیام «جستجوی آفلاین» استفاده می‌کند.
  bool get isSearchServerBlocked =>
      _searchBlockedUntil != null && _now().isBefore(_searchBlockedUntil!);

  // ── API عمومی ─────────────────────────────────────────────────────────────

  /// فهرست شرکت‌ها. اگر [phase] داده شود، فقط شرکت‌های همان فاز برمی‌گردند.
  ///
  /// همه‌ی شرکت‌ها با یک درخواست گرفته و کش می‌شوند و فیلتر فاز **محلی** انجام
  /// می‌شود؛ دلیلش دو چیز است: (۱) مقایسه‌ی نام فاز تحمل نگارشی دارد
  /// (`فاز ۱` ≡ `فاز 1`)، پس داده‌ی ناهمگون باعث فهرست خالی نمی‌شود،
  /// (۲) در حالت آفلاین هم فیلتر فاز کار می‌کند.
  Future<DataResult<List<FactoryModel>>> getFactories({
    String? phase,
    bool forceRefresh = false,
  }) {
    final phaseName = phase?.trim() ?? '';
    final hasPhase = phaseName.isNotEmpty;

    return _singleFlight.run(
      hasPhase ? 'factories:phase:$phaseName' : 'factories:all',
      () async {
        final all = await _loadAll(forceRefresh: forceRefresh);

        if (all is! DataSuccess<List<FactoryModel>>) {
          return DataFailure<List<FactoryModel>>(
            all.errorOrNull ??
                const DataError(DataErrorKind.unknown, detail: 'unknown'),
          );
        }

        final items = hasPhase
            ? all.data
                  .where((f) => phaseNamesMatch(f.phase, phaseName))
                  .toList()
            : all.data;

        return DataSuccess(items, source: all.source, fetchedAt: all.fetchedAt);
      },
    );
  }

  /// جستجوی متنی روی نام/دسته‌بندی/آدرس/فاز.
  ///
  /// دو مسیر با هم کار می‌کنند:
  /// ۱. **سرور** (`ilike` با الگوی `*`) — مرجع و مقیاس‌پذیر.
  /// ۲. **کلاینت** با نرمال‌سازی فارسی/پشتو — سرور «فاز ۱» و «فاز 1» را یکی
  ///    نمی‌بیند و «ی/ي» عربی را هم متمایز می‌داند؛ نتیجه‌ی سرور و محلی
  ///    **اجتماع** می‌شوند تا هیچ ردیفی از دست نرود.
  ///
  /// در حالت آفلاین (یا پس از خطای گذرا تا پایان [searchCooldown]) مسیر سرور
  /// کنار گذاشته می‌شود و روی داده‌ی محلی با همان نرمال‌سازی جستجو می‌شود.
  Future<DataResult<List<FactoryModel>>> searchFactories(
    String query, {
    bool forceRefresh = false,
  }) {
    final term = query.trim();
    if (normalizeSearchText(term).isEmpty) {
      return getFactories(forceRefresh: forceRefresh);
    }

    return _singleFlight.run('factories:search:$term', () async {
      // داده‌ی محلی (کش تازه یا شبکه) — هم مبنای نتیجه‌ی بی‌درنگ است و هم
      // مسیر جایگزین وقتی سرور در دسترس نیست.
      final all = await _loadAll(forceRefresh: forceRefresh);
      final localBase = all.dataOrNull ?? const <FactoryModel>[];
      final localMatches = filterLocally(localBase, term);

      // منبع/زمانِ نتیجه‌ی محلی، همان منبع/زمانِ داده‌ی زیربنایی است
      DataSuccess<List<FactoryModel>> localSuccess() => DataSuccess(
        rankByRelevance([...localMatches], term),
        source: all is DataSuccess<List<FactoryModel>>
            ? all.source
            : DataSource.cache,
        fetchedAt: all is DataSuccess<List<FactoryModel>>
            ? all.fetchedAt
            : null,
      );

      DataFailure<List<FactoryModel>> localFailure() => DataFailure(
        all.errorOrNull ??
            const DataError(DataErrorKind.unknown, detail: 'unknown'),
      );

      final filter = postgrestIlikeFilter(term);
      if (filter == null || isSearchServerBlocked) {
        return all is DataSuccess<List<FactoryModel>>
            ? localSuccess()
            : localFailure();
      }

      try {
        final rows = await withRetry(
          () => _fetchRemoteSearch(filter).timeout(AppConfig.requestTimeout),
          onRetry: (attempt, error) => debugPrint(
            'FactoryRepository.searchFactories: attempt $attempt failed → $error',
          ),
        );
        _searchBlockedUntil = null;
        return DataSuccess(
          rankByRelevance(
            mergeSearchResults(
              remote: rows.map(FactoryModel.fromMap).toList(),
              local: localMatches,
            ),
            term,
          ),
          source: DataSource.network,
          fetchedAt: DateTime.now(),
        );
      } catch (error) {
        final failure = DataError.fromException(error);
        if (!failure.isTransient) return DataFailure(failure);

        // خطای گذرا → تعطیلی موقت مسیر سرور و ادامه با داده‌ی محلی
        _searchBlockedUntil = _now().add(searchCooldown);
        debugPrint(
          'FactoryRepository.searchFactories: server unreachable; '
          'local search over ${localMatches.length} rows',
        );
        return localSuccess();
      }
    });
  }

  /// یک شرکت بر اساس شناسه.
  Future<DataResult<FactoryModel>> getFactory(String id) {
    return _singleFlight.run('factory:$id', () async {
      try {
        final row = await withRetry(
          () => _fetchOne(id).timeout(AppConfig.requestTimeout),
        );
        return DataSuccess(
          FactoryModel.fromMap(row),
          source: DataSource.network,
          fetchedAt: DateTime.now(),
        );
      } catch (error) {
        final failure = DataError.fromException(error);
        if (failure.isTransient) {
          final cached = _readCache();
          final match = cached?.value.where((f) => f.id == id).toList();
          if (cached != null && match != null && match.isNotEmpty) {
            return DataSuccess(
              match.first,
              source: DataSource.cache,
              fetchedAt: cached.storedAt,
            );
          }
        }
        return DataFailure(failure);
      }
    });
  }

  /// شمارش شرکت‌های هر فاز با **یک** درخواست (به‌جای یک درخواست برای هر فاز).
  Future<DataResult<Map<String, int>>> countsByPhase() {
    return _singleFlight.run('factories:counts', () async {
      try {
        final rows = await withRetry(
          () => _fetchPhaseColumn().timeout(AppConfig.requestTimeout),
        );
        final counts = <String, int>{};
        for (final row in rows) {
          final phase = (row['phase'] as Object?)?.toString().trim() ?? '';
          counts[phase] = (counts[phase] ?? 0) + 1;
        }
        _cache.writeMap(_countsKey, counts);
        return DataSuccess(
          counts,
          source: DataSource.network,
          fetchedAt: DateTime.now(),
        );
      } catch (error) {
        final failure = DataError.fromException(error);
        if (failure.isTransient) {
          final cached = _cache.readMap(_countsKey);
          if (cached != null) {
            return DataSuccess(
              cached.value.map(
                (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
              ),
              source: DataSource.cache,
              fetchedAt: cached.storedAt,
            );
          }
        }
        return DataFailure(failure);
      }
    });
  }

  /// اجتماع نتیجه‌ی سرور و تطبیق محلی؛ تکرارها بر اساس شناسه حذف می‌شوند.
  static List<FactoryModel> mergeSearchResults({
    required List<FactoryModel> remote,
    required List<FactoryModel> local,
  }) {
    final seen = <String>{};
    final merged = <FactoryModel>[];

    for (final item in [...remote, ...local]) {
      if (item.id.isNotEmpty && !seen.add(item.id)) continue;
      merged.add(item);
    }
    return merged;
  }

  /// مرتب‌سازی بر اساس میزان ارتباط با عبارت جستجو:
  /// ۰) نام با عبارت شروع می‌شود، ۱) نام شامل عبارت است،
  /// ۲) دسته/آدرس/فاز مطابقت دارد، ۳) بقیه (مطابقت کلمه‌به‌کلمه).
  ///
  /// ترتیب اصلی حفظ می‌شود (sort پایدار) تا نتیجه بین دو بار جستجو نپرد.
  static List<FactoryModel> rankByRelevance(
    List<FactoryModel> items,
    String query,
  ) {
    final term = normalizeSearchText(query);
    if (term.isEmpty || items.length < 2) return items;

    final indexed = items.indexed.toList();
    indexed.sort((a, b) {
      final byScore = _relevanceScore(
        a.$2,
        term,
      ).compareTo(_relevanceScore(b.$2, term));
      return byScore != 0 ? byScore : a.$1.compareTo(b.$1);
    });
    return [for (final entry in indexed) entry.$2];
  }

  static int _relevanceScore(FactoryModel factory, String term) {
    final name = normalizeSearchText(factory.name);
    if (name.startsWith(term)) return 0;
    if (name.contains(term)) return 1;
    for (final field in [factory.category, factory.address, factory.phase]) {
      if (normalizeSearchText(field).contains(term)) return 2;
    }
    return 3;
  }

  /// فیلتر محلی نرمال‌شده (فارسی/پشتو) — برای حالت آفلاین و جستجوی سریع.
  static List<FactoryModel> filterLocally(
    List<FactoryModel> items,
    String query,
  ) {
    if (normalizeSearchText(query).isEmpty) return items;
    return items
        .where(
          (f) =>
              matchesQuery(f.name, query) ||
              matchesQuery(f.address, query) ||
              matchesQuery(f.category, query) ||
              matchesQuery(f.phase, query),
        )
        .toList();
  }

  /// زمان آخرین ذخیره‌ی کش (برای نمایش «آخرین به‌روزرسانی»).
  DateTime? lastUpdatedAt() => _cache.storedAt(_allKey);

  /// پاک‌کردن همه‌ی داده‌های محلی (دکمه‌ی تنظیمات — فاز ۷).
  void clearCache() {
    _cache.invalidateAll();
    _singleFlight.clear();
    _searchBlockedUntil = null;
  }

  // ── داخلی ─────────────────────────────────────────────────────────────────

  /// خواندن فهرست کامل: کش تازه → شبکه → کش کهنه.
  Future<DataResult<List<FactoryModel>>> _loadAll({bool forceRefresh = false}) {
    return _singleFlight.run('factories:all', () async {
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
            'FactoryRepository.getFactories: attempt $attempt failed → $error',
          ),
        );
        final items = rows.map(FactoryModel.fromMap).toList();
        _cache.writeList(_allKey, items, (item) => item.toMap());
        return DataSuccess(
          items,
          source: DataSource.network,
          fetchedAt: DateTime.now(),
        );
      } catch (error) {
        final failure = DataError.fromException(error);
        if (failure.isTransient && fresh != null) {
          debugPrint(
            'FactoryRepository.getFactories: local cache '
            '(${fresh.value.length} rows, ${fresh.age().inMinutes} min old)',
          );
          return DataSuccess(
            fresh.value,
            source: DataSource.cache,
            fetchedAt: fresh.storedAt,
          );
        }
        return DataFailure(failure);
      }
    });
  }

  CacheEntry<List<FactoryModel>>? _readCache() =>
      _cache.readList(_allKey, FactoryModel.fromMap);

  // ── درخواست‌های شبکه ──────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _fetchAll() async {
    final List<Map<String, dynamic>> data = await AppProvider.db
        .from(Endpoints.factories)
        .select()
        .order('name', ascending: true);
    return data;
  }

  /// [filter] خروجی [postgrestIlikeFilter] است (بدون پرانتز بیرونی؛ خودِ
  /// کلاینت آن را اضافه می‌کند).
  Future<List<Map<String, dynamic>>> _fetchRemoteSearch(String filter) async {
    final List<Map<String, dynamic>> data = await AppProvider.db
        .from(Endpoints.factories)
        .select()
        .or(filter)
        .order('name', ascending: true);
    return data;
  }

  Future<Map<String, dynamic>> _fetchOne(String id) async {
    final Map<String, dynamic> data = await AppProvider.db
        .from(Endpoints.factories)
        .select()
        .eq('id', id)
        .single();
    return data;
  }

  Future<List<Map<String, dynamic>>> _fetchPhaseColumn() async {
    final List<Map<String, dynamic>> data = await AppProvider.db
        .from(Endpoints.factories)
        .select('phase');
    return data;
  }
}
