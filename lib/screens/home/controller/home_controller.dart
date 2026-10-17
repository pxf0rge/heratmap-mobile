import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:heratmap/core/app_config.dart';
import 'package:heratmap/core/data_state.dart';
import 'package:heratmap/core/locale_format.dart';
import 'package:heratmap/data/models/factory_model.dart';
import 'package:heratmap/data/models/phase_model.dart';
import 'package:heratmap/data/models/poi_model.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/data/repository/factory_repository.dart';
import 'package:heratmap/data/repository/poi_repository.dart';
import 'package:heratmap/data/repository/phase_repository.dart';
import 'package:latlong2/latlong.dart';

/// وضعیت دسترسی به موقعیت مکانی — UI بر اساس این مقدار تصمیم می‌گیرد.
enum LocationState {
  /// هنوز بررسی نشده
  unknown,

  /// موقعیت در دسترس است
  granted,

  /// کاربر این بار «رد» کرده؛ دفعه‌ی بعد دوباره می‌پرسیم
  denied,

  /// کاربر برای همیشه رد کرده؛ فقط از تنظیمات اپ قابل تغییر است
  permanentlyDenied,

  /// سرویس موقعیت دستگاه خاموش است
  serviceDisabled,

  /// مجوز هست ولی موقعیت فعلی به دست نیامد (داخل ساختمان، GPS ضعیف)
  unavailable,
}

class HomeController extends GetxController with DataStateMixin {
  final FactoryRepository _factoryRepo;
  final PhaseRepository _phaseRepo;
  final PoiRepository _poiRepo;
  HomeController(this._factoryRepo, this._phaseRepo, this._poiRepo);

  // ── Navigation ────────────────────────────────────────────────────────────
  final currentIndex = 0.obs;

  // ── Map ───────────────────────────────────────────────────────────────────
  /// کنترلر نقشه در اختیار کنترلر است تا دکمه‌های نوار بالا، شیت پایین و پین‌ها
  /// همه بتوانند دوربین را حرکت دهند.
  final mapController = MapController();

  /// زوم اولیه‌ی نقشه (پیش از تنظیم دوربین روی محدوده‌ی داده).
  static const double initialZoom = 16.0;

  /// مرکز پیش‌فرض وقتی داده‌ی مکانی نداریم (شهرک صنعتی هرات).
  /// منبع واحد مقدار: [AppConfig] — صفحه‌ی «تماس با ما» هم از همان می‌خواند.
  static const LatLng heratCenter = LatLng(
    AppConfig.townLatitude,
    AppConfig.townLongitude,
  );

  /// محدوده‌ی شهرک — fallback وقتی هیچ شرکت مختصات‌دار نداریم.
  static final LatLngBounds townBounds = LatLngBounds(
    const LatLng(34.188, 62.200),
    const LatLng(34.218, 62.230),
  );

  /// حداقل اندازه‌ی محدوده‌ی داده (≈۴۵۰ متر در هر جهت) تا با یک شرکت هم
  /// نقشه قابل استفاده بماند.
  static const double _minSpanDegrees = 0.004;

  final userLocation = Rxn<LatLng>();
  final locationState = LocationState.unknown.obs;

  /// شرکتی که با لمس پین انتخاب شده است (پیش‌نمایش در شیت پایین).
  final selectedFactory = Rxn<FactoryModel>();

  // ── Factories ─────────────────────────────────────────────────────────────
  final factories = <FactoryModel>[].obs;

  // ── Phases ────────────────────────────────────────────────────────────────
  final phases = <PhaseModel>[].obs;

  // ── POIs ──────────────────────────────────────────────────────────────────
  final pois = <PoiModel>[].obs;

  // ── Bottom sheet ──────────────────────────────────────────────────────────
  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  @override
  void onInit() {
    super.onInit();
    _requestLocationAndLoad();
  }

  @override
  void onClose() {
    mapController.dispose();
    super.onClose();
  }

  // ── Bounds ────────────────────────────────────────────────────────────────

  /// شرکت‌هایی که مختصات معتبر دارند.
  List<FactoryModel> get locatedFactories => [
    for (final factory in factories)
      if (factory.hasValidLocation) factory,
  ];

  /// محدوده‌ی محاسبه‌شده از روی مختصات شرکت‌ها (با ۲۵٪ حاشیه و حداقل اندازه).
  /// اگر داده‌ی مکانی نباشد، محدوده‌ی شهرک برمی‌گردد.
  LatLngBounds get dataBounds {
    final located = locatedFactories;
    if (located.isEmpty) return townBounds;

    final bounds = LatLngBounds.fromPoints([
      for (final factory in located) LatLng(factory.lat, factory.lon),
    ]);

    final latPad = math.max(
      (bounds.north - bounds.south) * 0.25,
      _minSpanDegrees,
    );
    final lonPad = math.max(
      (bounds.east - bounds.west) * 0.25,
      _minSpanDegrees,
    );

    return LatLngBounds(
      LatLng(bounds.south - latPad, bounds.west - lonPad),
      LatLng(bounds.north + latPad, bounds.east + lonPad),
    );
  }

  /// محدوده‌ی حرکت دوربین: اجتماع داده و شهرک.
  /// همیشه همه‌ی شرکت‌ها در دسترس‌اند و کاربر هم می‌تواند کل شهرک را ببیند.
  LatLngBounds get cameraBounds {
    final data = dataBounds;
    return LatLngBounds(
      LatLng(
        math.min(data.south, townBounds.south),
        math.min(data.west, townBounds.west),
      ),
      LatLng(
        math.max(data.north, townBounds.north),
        math.max(data.east, townBounds.east),
      ),
    );
  }

  /// مرکز اولیه‌ی نقشه.
  LatLng get initialCenter =>
      locatedFactories.isEmpty ? heratCenter : dataBounds.center;

  // ── Location ──────────────────────────────────────────────────────────────

  Future<void> _requestLocationAndLoad() async {
    await refreshUserLocation();
    await Future.wait([
      loadFactories(),
      _loadPhases(),
      _loadPois(),
    ]);
  }

  /// بررسی مجوز و گرفتن موقعیت فعلی؛ نتیجه در [locationState] هم ذخیره می‌شود.
  Future<LocationState> refreshUserLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      locationState.value = LocationState.serviceDisabled;
      return locationState.value;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      locationState.value = LocationState.permanentlyDenied;
      return locationState.value;
    }
    if (permission == LocationPermission.denied) {
      locationState.value = LocationState.denied;
      return locationState.value;
    }

    final fetched = await _fetchUserLocation();
    locationState.value = fetched ? LocationState.granted : LocationState.unavailable;
    return locationState.value;
  }

  Future<bool> _fetchUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      userLocation.value = LatLng(position.latitude, position.longitude);
      return true;
    } catch (_) {
      // نقشه بدون موقعیت کاربر هم کار می‌کند
      return false;
    }
  }

  /// رفتن به موقعیت کاربر. در صورت نیاز مجوز می‌گیرد و وضعیت را برمی‌گرداند.
  Future<LocationState> centerOnUser() async {
    var state = locationState.value;
    if (userLocation.value == null || state != LocationState.granted) {
      state = await refreshUserLocation();
    }

    final location = userLocation.value;
    if (location != null) {
      moveCamera(location, 16.5);
      locationState.value = LocationState.granted;
      return LocationState.granted;
    }
    return state;
  }

  // ── Camera helpers ────────────────────────────────────────────────────────

  /// زوم فعلی دوربین (اگر نقشه آماده نباشد، زوم اولیه).
  double _currentZoom() {
    try {
      return mapController.camera.zoom;
    } catch (_) {
      return initialZoom;
    }
  }

  /// حرکت امن دوربین (پیش از آماده‌شدن نقشه خطا نمی‌دهد).
  void moveCamera(LatLng center, double zoom) {
    try {
      mapController.move(center, zoom);
    } catch (_) {
      // نقشه هنوز آماده نیست
    }
  }

  /// نمایش همه‌ی شرکت‌ها روی نقشه.
  void fitAllFactories() {
    if (locatedFactories.isEmpty) {
      moveCamera(heratCenter, _currentZoom());
      return;
    }
    try {
      mapController.fitCamera(
        CameraFit.bounds(
          bounds: dataBounds,
          padding: const EdgeInsets.fromLTRB(48, 150, 48, 210),
          maxZoom: 17,
        ),
      );
    } catch (_) {
      // نقشه هنوز آماده نیست
    }
  }

  // ── Selection ─────────────────────────────────────────────────────────────

  /// انتخاب شرکت از روی پین نقشه.
  void selectFactory(FactoryModel factory) {
    selectedFactory.value = factory;
    _revealSelected();
  }

  void clearSelection() => selectedFactory.value = null;

  /// دوربین را کمی بالا می‌برد تا پین انتخاب‌شده پشت شیت پایین پنهان نشود.
  void _revealSelected() {
    final factory = selectedFactory.value;
    if (factory == null || !factory.hasValidLocation) return;

    try {
      final camera = mapController.camera;
      final visible = camera.visibleBounds;
      final latSpan = (visible.north - visible.south).abs();
      final target = LatLng(
        (factory.lat + latSpan * 0.18).clamp(-85.0, 85.0),
        factory.lon,
      );
      mapController.move(target, camera.zoom);
    } catch (_) {
      // نقشه هنوز آماده نیست
    }
  }

  // ── Distances ─────────────────────────────────────────────────────────────

  List<FactoryModel> get nearestFactories {
    final valid = [...locatedFactories];
    if (userLocation.value == null) return valid.take(5).toList();
    valid.sort((a, b) => distanceTo(a).compareTo(distanceTo(b)));
    return valid.take(5).toList();
  }

  double distanceTo(FactoryModel f) {
    if (userLocation.value == null) return 0;
    final loc = userLocation.value!;
    return Geolocator.distanceBetween(
      loc.latitude,
      loc.longitude,
      f.lat,
      f.lon,
    );
  }

  /// فاصله‌ی ترجمه‌شده با ارقام زبان اپ: «۴۵۰ متر» / `450 m`.
  String formattedDistance(FactoryModel f) {
    final d = distanceTo(f);
    if (d < 1000) {
      return AppStrings.distanceMeters.trParams({
        'n': formatInteger(d.round()),
      });
    }
    return AppStrings.distanceKilometers.trParams({
      'n': formatDecimal(d / 1000, fractionDigits: 1),
    });
  }

  /// زمان تقریبی رسیدن با سرعت پیاده (۵ کیلومتر بر ساعت).
  String? estimatedArrivalTime(FactoryModel f) {
    if (userLocation.value == null) return null;
    final d = distanceTo(f);
    if (d < 10) return null;
    final minutes = (d / (5 * 1000 / 60)).round();
    if (minutes < 1) return null;
    return AppStrings.estimatedMinutes.trParams({
      'n': formatInteger(minutes),
    });
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  /// بارگذاری شرکت‌ها. با [forceRefresh] کش نادیده گرفته می‌شود.
  Future<void> loadFactories({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    dataError.value = null;

    final result = await _factoryRepo.getFactories(forceRefresh: forceRefresh);
    final data = result.dataOrNull;
    if (data != null) factories.value = data;
    applyResult(result);

    isLoading.value = false;
  }

  /// بارگذاری فازها.
  Future<void> _loadPhases() async {
    final result = await _phaseRepo.getPhases();
    if (result.isSuccess) {
      phases.value = result.dataOrNull ?? [];
    }
  }

  /// بارگذاری نقاط مهم.
  Future<void> _loadPois() async {
    final result = await _poiRepo.fetchPois();
    if (result.isSuccess) {
      pois.value = result.dataOrNull ?? [];
    }
  }

  /// دکمه‌ی تازه‌سازی در بنر «داده‌ی محلی» — کش نادیده گرفته می‌شود.
  Future<void> reload() => loadFactories(forceRefresh: true);

  void changeTab(int index) => currentIndex.value = index;
}
