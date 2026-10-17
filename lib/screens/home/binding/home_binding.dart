import 'package:get/get.dart';
import 'package:heratmap/data/cache/favorites_store.dart';
import 'package:heratmap/data/repository/announcement_repository.dart';
import 'package:heratmap/data/repository/factory_repository.dart';
import 'package:heratmap/data/repository/phase_repository.dart';
import 'package:heratmap/data/repository/poi_repository.dart';
import 'package:heratmap/data/repository/news_repository.dart';
import 'package:heratmap/screens/home/controller/home_controller.dart';
import 'package:heratmap/screens/search/controller/search_controller.dart'
    as app;
import 'package:heratmap/screens/phases/controller/phases_controller.dart';
import 'package:heratmap/screens/settings/controller/settings_controller.dart';
import 'package:heratmap/screens/news/controller/announcement_controller.dart';
import 'package:heratmap/screens/news/controller/news_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // وضعیت مشترک اپ: شرکتهای نشانشده (صفحهی جزئیات + فیلتر جستجو)
    Get.put<FavoritesStore>(FavoritesStore(), permanent: true);

    // Repositories
    Get.lazyPut<FactoryRepository>(() => FactoryRepository());
    Get.lazyPut<PhaseRepository>(() => PhaseRepository());
    Get.lazyPut<PoiRepository>(() => PoiRepository());
    Get.lazyPut<NewsRepository>(() => NewsRepository());
    Get.lazyPut<AnnouncementRepository>(() => AnnouncementRepository());

    // Controllers
    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<FactoryRepository>(),
        Get.find<PhaseRepository>(),
        Get.find<PoiRepository>(),
      ),
    );
    Get.lazyPut<app.SearchController>(
      () => app.SearchController(Get.find<FactoryRepository>()),
    );
    Get.lazyPut<PhasesController>(
      () => PhasesController(Get.find<PhaseRepository>()),
    );
    Get.lazyPut<SettingsController>(() => SettingsController());
    Get.lazyPut<NewsController>(
      () => NewsController(Get.find<NewsRepository>()),
    );
    Get.lazyPut<AnnouncementController>(
      () => AnnouncementController(Get.find<AnnouncementRepository>()),
    );
  }
}
