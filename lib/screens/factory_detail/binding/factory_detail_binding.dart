import 'package:get/get.dart';
import 'package:heratmap/screens/factory_detail/controller/factory_detail_controller.dart';

class FactoryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FactoryDetailController>(() => FactoryDetailController());
  }
}
