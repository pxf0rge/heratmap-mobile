import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/screens/settings/controller/settings_controller.dart';

/// جهت چیدمان را از زبان انتخابشده میگیرد و روی **همهی مسیرها** اعمال میکند.
///
/// چرا در `builder` اپ و نه در هر صفحه؟ چون مسیرهای pushشده (جزئیات شرکت،
/// فهرست شرکتهای یک فاز، درباره/تماس) فرزندِ Navigator هستند و داخل
/// `Directionality` صفحهی خانه قرار نمیگیرند. یک نقطهی واحد، از فراموششدن
/// یک صفحه جلوگیری میکند و آیکنهای جهتی (فلش بازگشت) هم خودکار میچرخند.
class AppDirectionality extends StatelessWidget {
  const AppDirectionality({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // SettingsController ابتدا در HomeBinding ثبت میشود، پس پیش از آن
    // مقدار پیشفرض راست‌به‌چپ را برمیگردانیم تا Obx بی‌جهت صدا زده نشود.
    if (!Get.isRegistered<SettingsController>()) {
      return Directionality(textDirection: TextDirection.rtl, child: child);
    }

    return Obx(() {
      final direction = Get.find<SettingsController>().textDirection;
      return Directionality(textDirection: direction, child: child);
    });
  }
}
