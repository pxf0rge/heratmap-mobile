import 'package:flutter/material.dart';

/// پالت یکپارچه اپ — تیل ملایم صنعتی، بدون بنفش و گرادیان‌های رنگارنگ.
class PrimaryColors {
  static const Color primary = Color(0xff1A6B6B);
  static const Color p50 = Color(0xffEEF7F7);
  static const Color p100 = Color(0xffD5EBEB);
  static const Color p200 = Color(0xffA8D4D4);
  static const Color p300 = Color(0xff6FB3B3);
  static const Color p400 = Color(0xff3D9191);
  static const Color p500 = Color(0xff1A6B6B);
  static const Color p600 = Color(0xff155858);
  static const Color p700 = Color(0xff114747);
  static const Color p800 = Color(0xff0D3838);
  static const Color p900 = Color(0xff0A2B2B);
  static const Color p950 = Color(0xff061A1A);
}

class SecondaryColors {
  static const Color primary = Color(0xffC4A35A);
  static const Color p50 = Color(0xffFBF7EE);
  static const Color p100 = Color(0xffF5ECD6);
  static const Color p200 = Color(0xffEAD9A8);
  static const Color p300 = Color(0xffDCC47A);
  static const Color p400 = Color(0xffD0B15F);
  static const Color p500 = Color(0xffC4A35A);
  static const Color p600 = Color(0xffA8873F);
  static const Color p700 = Color(0xff876C32);
  static const Color p800 = Color(0xff6B5528);
  static const Color p900 = Color(0xff52411F);
  static const Color p950 = Color(0xff2E2410);
}

class NeutralColors {
  static const Color primary = Color(0xff6B7280);
  static const Color n50 = Color(0xffF7F8FA);
  static const Color n100 = Color(0xffEFF1F4);
  static const Color n200 = Color(0xffE2E5EA);
  static const Color n300 = Color(0xffC9CED6);
  static const Color n400 = Color(0xff9AA1AC);
  static const Color n500 = Color(0xff6B7280);
  static const Color n600 = Color(0xff4B5563);
  static const Color n700 = Color(0xff374151);
  static const Color n800 = Color(0xff1F2937);
  static const Color n900 = Color(0xff111827);
  static const Color n950 = Color(0xff0B0F14);
}

class StatusColors {
  static const Color red = Color(0xffD64545);
  static const Color redLight = Color(0xffFDECEC);
  static const Color green = Color(0xff2F9E6A);
  static const Color greenLight = Color(0xffE6F6EE);
  static const Color yellow = Color(0xffC9972A);
  static const Color yellowLight = Color(0xffFBF3E0);
  static const Color orange = Color(0xffD97706);
  static const Color orangeLight = Color(0xffFEF3E6);
}

class OtherColors {
  static const Color scaffoldLight = Color(0xffF5F6F8);
  static const Color scaffoldLightBackground = Color(0xffF5F6F8);
  static const Color surfaceLight = Color(0xffFFFFFF);
  static const Color cardLight = Color(0xffFFFFFF);

  static const Color scaffoldDark = Color(0xff0E1216);
  static const Color scaffoldDarkBackground = Color(0xff0E1216);
  static const Color surfaceDark = Color(0xff171C22);
  static const Color cardDark = Color(0xff1C2229);

  static const Color textLightColor = Color(0xff15202B);
  static const Color textgreyLightColor = Color(0xff6B7280);

  static const Color textDarkColor = Color(0xffF3F4F6);
  static const Color textgreyColor = Color(0xff9AA1AC);
  static const Color textgrey300Color = Color(0xff6B7280);
}

/// نگه داشته شده برای سازگاری؛ در UI جدید کمتر استفاده می‌شود.
class ThirdColors {
  static const Color primary = Color(0xff1A6B6B);
  static const Color p50 = Color(0xffEEF7F7);
  static const Color p100 = Color(0xffD5EBEB);
  static const Color p200 = Color(0xffA8D4D4);
  static const Color p300 = Color(0xff6FB3B3);
  static const Color p400 = Color(0xff3D9191);
  static const Color p500 = Color(0xff1A6B6B);
  static const Color p600 = Color(0xff155858);
  static const Color p700 = Color(0xff114747);
  static const Color p800 = Color(0xff0D3838);
  static const Color p900 = Color(0xff0A2B2B);
  static const Color p950 = Color(0xff061A1A);
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xff1A6B6B), Color(0xff155858)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xff1A6B6B), Color(0xff155858)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xff0A2B2B), Color(0xff114747), Color(0xff1A6B6B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [Color(0xffD64545), Color(0xffB93A3A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xff1A6B6B), Color(0xff155858)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xffC4A35A), Color(0xffA8873F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xff1A6B6B), Color(0xff155858)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// کمک‌کننده‌های تم‌آگاه برای سطح و حاشیه در حالت روشن/تاریک.
class AppSurfaces {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color scaffold(BuildContext context) =>
      isDark(context) ? OtherColors.scaffoldDark : OtherColors.scaffoldLight;

  static Color card(BuildContext context) =>
      isDark(context) ? OtherColors.cardDark : OtherColors.cardLight;

  static Color border(BuildContext context) =>
      isDark(context) ? NeutralColors.n700 : NeutralColors.n200;

  static Color muted(BuildContext context) =>
      isDark(context) ? NeutralColors.n400 : NeutralColors.n500;

  static Color softFill(BuildContext context) =>
      isDark(context) ? NeutralColors.n800 : NeutralColors.n100;

  static Color primarySoft(BuildContext context) =>
      isDark(context)
          ? PrimaryColors.primary.withValues(alpha: 0.18)
          : PrimaryColors.p50;
}
