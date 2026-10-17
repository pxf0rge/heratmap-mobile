import 'package:get/get.dart';
import 'package:heratmap/data/repository/factory_repository.dart';
import 'package:heratmap/screens/phases/controller/phase_factories_controller.dart';

class PhaseFactoriesBinding extends Bindings {
  @override
  void dependencies() {
    // FactoryRepository may already be registered by HomeBinding.
    // putOrFind ensures we reuse it if it exists, create it if not.
    if (!Get.isRegistered<FactoryRepository>()) {
      Get.put<FactoryRepository>(FactoryRepository(), permanent: true);
    }
    Get.put<PhaseFactoriesController>(
      PhaseFactoriesController(Get.find<FactoryRepository>()),
    );
  }
}
