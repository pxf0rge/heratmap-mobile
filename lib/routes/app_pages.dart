import 'package:get/get.dart';
import 'package:heratmap/routes/app_routes.dart';
import 'package:heratmap/screens/splash/splash_screen.dart';
import 'package:heratmap/screens/home/home_screen.dart';
import 'package:heratmap/screens/home/binding/home_binding.dart';
import 'package:heratmap/screens/factory_detail/factory_detail_screen.dart';
import 'package:heratmap/screens/factory_detail/binding/factory_detail_binding.dart';
import 'package:heratmap/screens/phases/phase_factories_screen.dart';
import 'package:heratmap/screens/phases/binding/phase_factories_binding.dart';
import 'package:heratmap/screens/settings/about_screen.dart';
import 'package:heratmap/screens/settings/contact_screen.dart';
import 'package:heratmap/screens/news/news_detail_screen.dart';
import 'package:heratmap/screens/news/announcement_detail_screen.dart';
import 'package:heratmap/screens/emergency/emergency_contacts_screen.dart';
import 'package:heratmap/screens/emergency/controller/emergency_controller.dart';
import 'package:heratmap/data/repository/emergency_contact_repository.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.factoryDetail,
      page: () => const FactoryDetailScreen(),
      binding: FactoryDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.phaseFactories,
      page: () => const PhaseFactoriesScreen(),
      binding: PhaseFactoriesBinding(),
    ),
    GetPage(name: AppRoutes.aboutApp, page: () => const AboutScreen()),
    GetPage(name: AppRoutes.contactUs, page: () => const ContactScreen()),
    GetPage(name: AppRoutes.newsDetail, page: () => const NewsDetailScreen()),
    GetPage(
      name: AppRoutes.announcementDetail,
      page: () => const AnnouncementDetailScreen(),
    ),
    GetPage(
      name: AppRoutes.emergencyContacts,
      page: () => const EmergencyContactsScreen(),
      binding: _EmergencyBinding(),
    ),
  ];
}

class _EmergencyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmergencyContactRepository>(
      () => EmergencyContactRepository(),
    );
    Get.lazyPut<EmergencyContactController>(
      () => EmergencyContactController(Get.find<EmergencyContactRepository>()),
    );
  }
}
