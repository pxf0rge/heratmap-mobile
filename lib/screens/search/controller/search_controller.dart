import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/core/data_state.dart';
import 'package:heratmap/core/text_utils.dart';
import 'package:heratmap/data/cache/favorites_store.dart';
import 'package:heratmap/data/cache/search_history.dart';
import 'package:heratmap/data/models/factory_model.dart';
import 'package:heratmap/data/repository/factory_repository.dart';

/// کنترلر تب جستجو.
///
/// استراتژی جستجو **دو لایه** است:
/// ۱. فیلتر محلی نرمال‌شده روی داده‌ی کش‌شده — بی‌درنگ و آفلاین‌پذیر، تا لیست
///    هنگام تایپ نپرد و منتظر شبکه نماند.
/// ۲. جستجوی سرور با debounce ([debounceTime]) که نتیجه‌اش با تطبیق محلی
///    اجتماع می‌شود ([FactoryRepository.searchFactories]).
///
/// شماره‌ی ترتیب درخواست (`_searchSeq`) تضمین می‌کند پاسخ کهنه‌ی یک عبارت
/// قدیمی، نتیجه‌ی عبارت تازه را بازنویسی نکند.
class SearchController extends GetxController with DataStateMixin {
  SearchController(this._repo, {SearchHistoryStore? history})
    : _history = history ?? SearchHistoryStore();

  /// تأخیر جستجوی سرور پس از آخرین ضربه‌ی کلید.
  static const Duration debounceTime = Duration(milliseconds: 350);

  final FactoryRepository _repo;
  final SearchHistoryStore _history;

  /// متن فیلد جستجو؛ منبع حقیقت برای UI (پاک‌کردن/تاریخچه).
  final textController = TextEditingController();
  final focusNode = FocusNode();

  /// عبارت جستجوی جاری (برای debounce و واکنش UI).
  final query = ''.obs;

  /// null = همه، در غیر این صورت نام فاز مثل «فاز ۱».
  final selectedPhaseName = Rxn<String>();

  final results = <FactoryModel>[].obs;

  /// جستجوهای اخیر کاربر (تازه‌ترین اول).
  final history = <String>[].obs;

  /// درخواست جستجو در جریان است (نشانگر نازک بالای لیست).
  final isSearching = false.obs;

  /// پنل «جستجوهای اخیر» باز است (فیلد فوکوس دارد و عبارت خالی است).
  final isHistoryVisible = false.obs;

  /// فقط شرکت‌های نشان‌شده نمایش داده شوند.
  final showOnlyFavorites = false.obs;

  /// آخرین جستجو نتوانست از سرور بگیرد (نتایج از حافظه‌ی دستگاه است).
  final serverSearchBlocked = false.obs;

  final _allFactories = <FactoryModel>[];

  /// شماره‌ی آخرین درخواست جستجو — برای دور ریختن پاسخ‌های کهنه.
  var _searchSeq = 0;

  /// آخرین عبارتی که واقعاً به سرور رفت.
  ///
  /// لازم است چون یک عبارت می‌تواند از دو مسیر اجرا شود: `debounce` تایپ و
  /// اجرای فوری (Enter/تاریخچه). بدون این محافظ، هر اجرای فوری یک درخواست
  /// تکراری هم بعد از ۳۵۰ms می‌فرستاد.
  String? _lastTerm;

  // ── وضعیت‌های مشتق ────────────────────────────────────────────────────────

  bool get isBrowsing => normalizeSearchText(query.value).isEmpty;

  bool get hasQuery => !isBrowsing;

  bool get hasPhaseFilter => (selectedPhaseName.value ?? '').isNotEmpty;

  bool get hasFavoritesFilter => showOnlyFavorites.value;

  /// آیا کاربر فیلتری فعال دارد؟ (مبنای پیام «چیزی پیدا نشد»)
  bool get hasActiveFilter => hasQuery || hasPhaseFilter || hasFavoritesFilter;

  /// بارگذاری اولیه (هیچ داده‌ای در حافظه نیست) → اسکلتون تمام‌صفحه.
  bool get isInitialLoading => isLoading.value && _allFactories.isEmpty;

  // ── چرخه‌ی عمر ────────────────────────────────────────────────────────────

  FavoritesStore? get _favoritesStore =>
      Get.isRegistered<FavoritesStore>() ? Get.find<FavoritesStore>() : null;

  @override
  void onInit() {
    super.onInit();
    history.value = _history.read();
    focusNode.addListener(_onFocusChanged);
    debounce(query, _searchOnServer, time: debounceTime);
    ever(selectedPhaseName, (_) => _applyLocalFilter());

    // اگر کاربر در صفحه‌ی جزئیات ستاره‌ی شرکتی را بزند، لیست همین‌جا تازه شود.
    final favorites = _favoritesStore;
    if (favorites != null) {
      ever(favorites.ids, (_) => _applyLocalFilter());
    }

    loadAll();
  }

  @override
  void onClose() {
    focusNode.removeListener(_onFocusChanged);
    focusNode.dispose();
    textController.dispose();
    super.onClose();
  }

  // ── ورودی کاربر ──────────────────────────────────────────────────────────

  /// هر ضربه‌ی کلید: فیلتر محلی بی‌درنگ، جستجوی سرور پس از debounce.
  void onQueryInput(String value) {
    query.value = value;
    _applyLocalFilter();
    _syncHistoryVisibility();
  }

  void clearQuery() {
    textController.clear();
    query.value = '';
    _applyLocalFilter();
    _syncHistoryVisibility();
  }

  /// پاک‌کردن همه‌ی فیلترها: عبارت جستجو + فیلتر فاز + نشان‌شده‌ها.
  void clearFilters() {
    selectedPhaseName.value = null;
    showOnlyFavorites.value = false;
    clearQuery();
  }

  /// روشن/خاموش کردن فیلتر «نشان‌شده‌ها».
  void setShowOnlyFavorites(bool value) {
    showOnlyFavorites.value = value;
    _applyLocalFilter();
  }

  /// تأیید جستجو با کلید Enter: ثبت در تاریخچه + اجرای فوری سرور.
  void onQuerySubmitted(String value) {
    query.value = value;
    _applyLocalFilter();
    rememberQuery();
    focusNode.unfocus();
    _searchOnServer(value);
  }

  /// ثبت عبارت جاری در تاریخچه (تازه‌ترین اول، بدون تکرار).
  void rememberQuery() {
    final value = query.value.trim();
    if (value.isEmpty) return;
    history.value = _history.add(value);
    _syncHistoryVisibility();
  }

  /// اجرای یک جستجوی ذخیره‌شده از تاریخچه.
  void applyHistory(String value) {
    textController.text = value;
    textController.selection = TextSelection.collapsed(offset: value.length);
    query.value = value;
    _applyLocalFilter();
    focusNode.unfocus();
    _searchOnServer(value);
  }

  void removeHistoryItem(String value) {
    history.value = _history.remove(value);
    _syncHistoryVisibility();
  }

  void clearHistory() {
    history.value = _history.clear();
    _syncHistoryVisibility();
  }

  /// انتخاب فاز (null = همه).
  void setPhaseName(String? name) => selectedPhaseName.value = name;

  // ── داده ─────────────────────────────────────────────────────────────────

  Future<void> loadAll({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    dataError.value = null;

    final result = await _repo.getFactories(forceRefresh: forceRefresh);
    final data = result.dataOrNull;
    if (data != null) {
      _allFactories
        ..clear()
        ..addAll(data);
    }
    applyResult(result);
    serverSearchBlocked.value = _repo.isSearchServerBlocked;
    isLoading.value = false;

    _applyLocalFilter();
  }

  Future<void> retry() async {
    await loadAll(forceRefresh: true);
    if (hasQuery) await _searchOnServer(query.value, force: true);
  }

  // ── داخلی ────────────────────────────────────────────────────────────────

  void _applyLocalFilter() {
    var list = _applyPhaseFilter(_allFactories);
    if (hasQuery) {
      list = FactoryRepository.filterLocally(list, query.value);
    }
    results.value = FactoryRepository.rankByRelevance(
      _applyFavoritesFilter(list),
      query.value,
    );
  }

  /// جستجوی سمت سرور؛ نتیجه جای نتیجه‌ی محلی را می‌گیرد (هر دو یک اجتماع‌اند).
  Future<void> _searchOnServer(String value, {bool force = false}) async {
    final term = value.trim();
    if (normalizeSearchText(term).isEmpty) return;
    if (!force && term == _lastTerm) return;
    _lastTerm = term;

    final seq = ++_searchSeq;
    isSearching.value = true;

    final result = await _repo.searchFactories(term);

    // پاسخ کهنه — کاربر در این فاصله عبارت تازه‌ای تایپ کرده است.
    if (seq != _searchSeq) return;

    final data = result.dataOrNull;
    if (data != null) {
      results.value = _applyFavoritesFilter(_applyPhaseFilter(data));
    }

    applyResult(result);
    serverSearchBlocked.value = _repo.isSearchServerBlocked;
    isSearching.value = false;
  }

  List<FactoryModel> _applyFavoritesFilter(List<FactoryModel> items) {
    if (!showOnlyFavorites.value) return items;

    final favorites = _favoritesStore;
    if (favorites == null) return items;
    return [
      for (final factory in items)
        if (favorites.contains(factory.id)) factory,
    ];
  }

  List<FactoryModel> _applyPhaseFilter(List<FactoryModel> items) {
    final phaseName = selectedPhaseName.value;
    if (phaseName == null || phaseName.isEmpty) return items;
    return [
      for (final factory in items)
        if (phaseNamesMatch(factory.phase, phaseName)) factory,
    ];
  }

  void _onFocusChanged() {
    // ترک فیلد = پایان یک جستجو → به تاریخچه اضافه شود.
    if (!focusNode.hasFocus) rememberQuery();
    _syncHistoryVisibility();
  }

  void _syncHistoryVisibility() {
    isHistoryVisible.value =
        focusNode.hasFocus && !hasQuery && history.isNotEmpty;
  }
}
