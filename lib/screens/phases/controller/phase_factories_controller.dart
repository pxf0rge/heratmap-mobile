import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:heratmap/core/data_state.dart';
import 'package:heratmap/data/models/factory_model.dart';
import 'package:heratmap/data/models/phase_model.dart';
import 'package:heratmap/data/repository/factory_repository.dart';

class PhaseFactoriesController extends GetxController with DataStateMixin {
  final FactoryRepository _repo;
  PhaseFactoriesController(this._repo);

  final factories = <FactoryModel>[].obs;
  late PhaseModel phase;

  @override
  void onInit() {
    super.onInit();
    phase = Get.arguments as PhaseModel;
    load();
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    dataError.value = null;

    // فیلتر فاز داخل مخزن انجام می‌شود و تفاوت نگارشی نام فاز را تحمل می‌کند
    final result = await _repo.getFactories(
      phase: phase.name,
      forceRefresh: forceRefresh,
    );
    final data = result.dataOrNull;
    if (data != null) {
      factories.value = data;
      debugPrint(
        'PhaseFactoriesController: ${data.length} factories for "${phase.name}"',
      );
    }
    applyResult(result);

    isLoading.value = false;
  }

  Future<void> retry() => load(forceRefresh: true);
}
