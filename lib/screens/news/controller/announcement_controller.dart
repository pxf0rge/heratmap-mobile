import 'package:get/get.dart';
import 'package:heratmap/core/data_state.dart';
import 'package:heratmap/data/models/announcement_model.dart';
import 'package:heratmap/data/repository/announcement_repository.dart';

class AnnouncementController extends GetxController with DataStateMixin {
  final AnnouncementRepository _repo;
  AnnouncementController(this._repo);

  final announcements = <AnnouncementModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAnnouncements();
  }

  Future<void> loadAnnouncements({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    dataError.value = null;

    final result = await _repo.getAnnouncements(forceRefresh: forceRefresh);
    final data = result.dataOrNull;
    if (data != null) announcements.value = data;
    applyResult(result);
    isLoading.value = false;
  }

  Future<void> reload() => loadAnnouncements(forceRefresh: true);

  /// فعال و قابل‌نمایش برای اپ (منقضی‌نشده اولویت دارد؛ منقضی‌ها انتهای لیست).
  List<AnnouncementModel> get visibleAnnouncements {
    final active = announcements
        .where((a) => a.isActive)
        .toList(growable: false);
    active.sort((a, b) {
      final aExpired = a.isExpired ? 1 : 0;
      final bExpired = b.isExpired ? 1 : 0;
      if (aExpired != bExpired) return aExpired - bExpired;
      final aDate = a.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return active;
  }

  bool get hasActive => announcements.any((a) => a.isActive && !a.isExpired);
}
