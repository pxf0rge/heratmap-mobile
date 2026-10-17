import 'package:get/get.dart';
import 'package:heratmap/core/data_state.dart';
import 'package:heratmap/core/text_utils.dart';
import 'package:heratmap/data/models/phase_model.dart';
import 'package:heratmap/data/repository/factory_repository.dart';
import 'package:heratmap/data/repository/phase_repository.dart';

class PhasesController extends GetxController with DataStateMixin {
  final PhaseRepository _phaseRepo;
  PhasesController(this._phaseRepo);

  final phases = <PhaseModel>[].obs;

  /// نام نرمال‌شده‌ی فاز → تعداد شرکت
  final factoryCounts = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadPhases();
  }

  Future<void> loadPhases({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    dataError.value = null;

    final result = await _phaseRepo.getPhases(forceRefresh: forceRefresh);
    final data = result.dataOrNull;
    if (data != null) {
      phases.value = data;
      await _loadFactoryCounts(forceRefresh: forceRefresh);
    }
    applyResult(result);

    isLoading.value = false;
  }

  Future<void> reload() => loadPhases(forceRefresh: true);

  /// شمارش شرکت‌های همه‌ی فازها با یک درخواست.
  Future<void> _loadFactoryCounts({bool forceRefresh = false}) async {
    final repo = Get.isRegistered<FactoryRepository>()
        ? Get.find<FactoryRepository>()
        : FactoryRepository();

    final result = await repo.countsByPhase();
    final counts = result.dataOrNull;
    // آفلاین بدون کش → شمارش خالی می‌ماند و UI به «مشاهده شرکت‌ها» برمی‌گردد
    if (counts == null) return;

    factoryCounts.value = {
      for (final entry in counts.entries)
        normalizeSearchText(entry.key): entry.value,
    };
  }

  /// تعداد شرکت‌های یک فاز — مستقل از نگارش نام فاز (`فاز ۱` ≡ `فاز 1`).
  int countFor(String phaseName) => factoryCounts[normalizeSearchText(phaseName)] ?? 0;

  /// مجموع شرکت‌های شمارش‌شده در همه‌ی فازها (چیپ «همه»).
  int get countedTotal {
    var total = 0;
    for (final value in factoryCounts.values) {
      total += value;
    }
    return total;
  }

  /// نام نمایشی یک فاز.
  ///
  /// داده‌ی شرکت‌ها فقط نام فاز را نگه می‌دارد (`phase` متنی است و کلید خارجی
  /// ندارد)؛ اینجا آن نام با فهرست رسمی فازها تطبیق داده می‌شود تا نگارش‌های
  /// ناهمگون (`فاز ۱` در برابر `فاز 1`) یک برچسب واحد بدهند.
  String labelFor(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';

    final key = normalizeSearchText(value);
    for (final phase in phases) {
      if (normalizeSearchText(phase.name) == key) return phase.name;
    }
    return value;
  }
}
