import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:heratmap/core/factory_links.dart';
import 'package:heratmap/core/locale_format.dart';
import 'package:heratmap/core/working_hours.dart';
import 'package:heratmap/data/cache/favorites_store.dart';
import 'package:heratmap/data/models/factory_model.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/screens/home/controller/home_controller.dart';
import 'package:heratmap/screens/phases/controller/phases_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// مقصدی که کاربر برای مسیریابی انتخاب می‌کند.
enum NavigationTarget { googleMaps, inAppMap }

/// کنترلر صفحه‌ی جزئیات شرکت.
///
/// اکشن‌ها **کلید ترجمه‌ی پیام** برمی‌گردانند (نه متن نمایشی) تا کنترلر از UI
/// جدا بماند و تست‌پذیر باشد: `null` یعنی انجام شد، وگرنه کلید پیام خطا.
class FactoryDetailController extends GetxController {
  late FactoryModel factory;

  /// وضعیت باز/بسته؛ هر دقیقه یک‌بار تازه می‌شود تا نشانگر روی صفحه کهنه نشود.
  late final Rxn<OpenStatus> openStatus = Rxn<OpenStatus>();

  Timer? _statusTimer;

  @override
  void onInit() {
    super.onInit();
    factory = Get.arguments as FactoryModel;
    _updateStatus();
    _statusTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _updateStatus(),
    );
  }

  @override
  void onClose() {
    _statusTimer?.cancel();
    super.onClose();
  }

  void _updateStatus() {
    final raw = '${factory.workStart} - ${factory.workEnd}';
    openStatus.value = currentWorkingStatus(raw);
  }

  // ── اطلاعات نمایشی ────────────────────────────────────────────────────────

  /// برچسب فاز؛ اگر فهرست فازها در دسترس باشد، نگارش رسمی همان فاز.
  String get phaseLabel {
    final raw = factory.phase.trim();
    if (raw.isEmpty) return '—';

    if (Get.isRegistered<PhasesController>()) {
      final label = Get.find<PhasesController>().labelFor(raw);
      if (label.isNotEmpty) return label;
    }
    return raw;
  }

  /// ساعت کاری یکدست‌شده و محلی‌شده (`7 - 7` → `۰۷:۰۰ - ۱۹:۰۰`).
  String get workingHoursLabel {
    final raw = '${factory.workStart} - ${factory.workEnd}';
    final label = displayWorkingHours(raw);
    return label.isEmpty ? '—' : formatClockLabel(label);
  }

  /// برچسب کوتاه وضعیت: «باز است» / «بسته است» / «ساعت کاری نامشخص».
  String get statusText => switch (openStatus.value?.kind) {
    OpenStatusKind.open => AppStrings.openNow.tr,
    OpenStatusKind.closed => AppStrings.closedNow.tr,
    _ => AppStrings.workingHoursUnknown.tr,
  };

  /// توضیح وضعیت: «تا ساعت 19:00» یا «از ساعت 07:00 باز می‌شود».
  String? get statusDetail {
    final status = openStatus.value;
    final hours = status?.hours;
    if (hours == null) return null;

    return status!.kind == OpenStatusKind.open
        ? AppStrings.closesAt.trParams({
            't': formatClockLabel(hours.closeLabel),
          })
        : AppStrings.opensAt.trParams({'t': formatClockLabel(hours.openLabel)});
  }

  /// برچسب ترکیبی وضعیت برای صفحه‌خوان؛ جداکننده هم از ترجمه می‌آید
  /// تا در انگلیسی، ویرگول فارسی خوانده نشود.
  String get statusSemantics {
    final detail = statusDetail;
    if (detail == null) return statusText;
    return AppStrings.a11yStatusJoin.trParams({'s': statusText, 'd': detail});
  }

  /// آیا ساعت کاری قابل فهم بود؟ (اگر نه، نشانگر باز/بسته نمایش داده نمی‌شود)
  bool get hasKnownHours => openStatus.value?.isKnown ?? false;

  bool get hasWorkingHoursText => factory.workStart.trim().isNotEmpty || factory.workEnd.trim().isNotEmpty;

  /// آیا اصلاً تصویری برای نمایش هست؟
  bool get hasImages => factory.imageUrls.isNotEmpty;

  // ── وضعیت دکمه‌ها ─────────────────────────────────────────────────────────

  /// مسیریابی فقط با مختصات معتبر ممکن است (صفر = ثبت‌نشده).
  bool get canNavigate => factory.hasValidLocation;

  /// اگر مسیریابی ممکن نیست، علتش (کلید ترجمه).
  String? get navigationBlockedReason =>
      canNavigate ? null : AppStrings.noLocation;

  /// شماره‌ی تماس معتبر است؟ (شماره‌ی ناقص دکمه را فعال نمی‌کند)
  bool get hasValidPhone => normalizePhoneNumber(factory.phone) != null;

  bool get isFavorite => Get.isRegistered<FavoritesStore>()
      ? Get.find<FavoritesStore>().contains(factory.id)
      : false;

  bool get canBeFavorite => factory.id.isNotEmpty;

  // ── اکشن‌ها ───────────────────────────────────────────────────────────────

  /// نشان‌کردن/برداشتن نشان. کلید پیام موفقیت را برمی‌گرداند (یا `null`).
  String? toggleFavorite() {
    if (!canBeFavorite || !Get.isRegistered<FavoritesStore>()) return null;

    final added = Get.find<FavoritesStore>().toggle(factory.id);
    return added
        ? AppStrings.addedToFavorites
        : AppStrings.removedFromFavorites;
  }

  /// رونوشت شماره در کلیپ‌بورد.
  Future<String?> copyPhone() async {
    final number = normalizePhoneNumber(factory.phone);
    if (number == null) return AppStrings.invalidPhone;

    await Clipboard.setData(ClipboardData(text: number));
    return AppStrings.phoneCopied;
  }

  /// تماس تلفنی — با اعتبارسنجی شماره.
  Future<String?> callPhone() async {
    final uri = factoryTelUri(factory.phone);
    if (uri == null) return AppStrings.invalidPhone;

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return null;
    }
    return AppStrings.actionFailed;
  }

  /// مسیریابی به مقصد انتخاب‌شده.
  Future<String?> openNavigation(NavigationTarget target) async {
    if (!canNavigate) return AppStrings.noLocation;

    if (target == NavigationTarget.inAppMap) {
      _focusOnAppMap();
      return null;
    }

    // اول اپ رسمی گوگل‌مپ (فقط اندروید)، سپس نسخه‌ی وب
    final appUri = factoryNavigationAppUri(factory);
    if (appUri != null && Platform.isAndroid && await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
      return null;
    }

    final webUri = factoryDirectionsUri(factory);
    if (webUri != null && await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return null;
    }
    return AppStrings.actionFailed;
  }

  /// اشتراک‌گذاری اطلاعات شرکت به زبان فعلی اپ.
  Future<String?> shareFactory() async {
    try {
      await Share.share(buildFactoryShareText(factory), subject: factory.name);
      return null;
    } catch (_) {
      return AppStrings.actionFailed;
    }
  }

  /// باز کردن وبسایت شرکت در مرورگر.
  Future<String?> openWebsite() async {
    final url = factory.websiteUrl.trim();
    if (url.isEmpty) return AppStrings.actionFailed;

    final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
    if (uri == null) return AppStrings.actionFailed;

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return null;
    }
    return AppStrings.actionFailed;
  }

  /// بازگشت به نقشه‌ی اپ و انتخاب همین شرکت.
  void _focusOnAppMap() {
    Get.back();
    if (!Get.isRegistered<HomeController>()) return;

    final home = Get.find<HomeController>();
    home.changeTab(0);
    home.selectFactory(factory);
  }
}
