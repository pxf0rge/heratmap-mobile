import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';

part 'inputdecoration_theme.dart';
part 'text_themes.dart';

const String _fontFamily = 'Estedad';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: _fontFamily,
    primaryColor: PrimaryColors.primary,
    scaffoldBackgroundColor: OtherColors.scaffoldLight,
    colorScheme: const ColorScheme.light(
      primary: PrimaryColors.primary,
      onPrimary: Colors.white,
      secondary: SecondaryColors.p500,
      onSecondary: Colors.white,
      surface: OtherColors.surfaceLight,
      onSurface: OtherColors.textLightColor,
      error: StatusColors.red,
      outline: NeutralColors.n200,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: OtherColors.surfaceLight,
      foregroundColor: OtherColors.textLightColor,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontFamily: _fontFamily,
        color: OtherColors.textLightColor,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: OtherColors.textLightColor),
    ),
    cardTheme: CardThemeData(
      color: OtherColors.cardLight,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimentions.radius16),
        side: const BorderSide(color: NeutralColors.n200, width: 1),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: OtherColors.cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimentions.radius20),
      ),
    ),
    inputDecorationTheme: InputdecorationTheme.lightInputdecoration,
    textTheme: TextThemes.lightTextTheme,
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: OtherColors.cardLight,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimentions.radius24),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: PrimaryColors.primary,
      unselectedItemColor: NeutralColors.n400,
      enableFeedback: false,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: PrimaryColors.primary,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: NeutralColors.n400,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: NeutralColors.n200,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: NeutralColors.n800,
      contentTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimentions.radius12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: PrimaryColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimentions.radius12),
        ),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PrimaryColors.primary,
        side: const BorderSide(color: PrimaryColors.p200),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimentions.radius12),
        ),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: PrimaryColors.primary,
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: NeutralColors.n100,
      selectedColor: PrimaryColors.primary,
      side: const BorderSide(color: NeutralColors.n200),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimentions.radiusFull),
      ),
      labelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: PrimaryColors.primary,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: _fontFamily,
    primaryColor: PrimaryColors.p400,
    scaffoldBackgroundColor: OtherColors.scaffoldDark,
    colorScheme: const ColorScheme.dark(
      primary: PrimaryColors.p400,
      onPrimary: Colors.white,
      secondary: SecondaryColors.p400,
      onSecondary: NeutralColors.n900,
      surface: OtherColors.surfaceDark,
      onSurface: OtherColors.textDarkColor,
      error: StatusColors.red,
      outline: NeutralColors.n700,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: OtherColors.surfaceDark,
      foregroundColor: OtherColors.textDarkColor,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontFamily: _fontFamily,
        color: OtherColors.textDarkColor,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: OtherColors.textDarkColor),
    ),
    cardTheme: CardThemeData(
      color: OtherColors.cardDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimentions.radius16),
        side: const BorderSide(color: NeutralColors.n700, width: 1),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: OtherColors.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimentions.radius20),
      ),
    ),
    inputDecorationTheme: InputdecorationTheme.darkInputdecoration,
    textTheme: TextThemes.darkTextTheme,
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: OtherColors.cardDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimentions.radius24),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: PrimaryColors.p300,
      unselectedItemColor: NeutralColors.n500,
      enableFeedback: false,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: PrimaryColors.p300,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: NeutralColors.n500,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: NeutralColors.n700,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: NeutralColors.n800,
      contentTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimentions.radius12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: PrimaryColors.p400,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimentions.radius12),
        ),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PrimaryColors.p300,
        side: const BorderSide(color: PrimaryColors.p600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimentions.radius12),
        ),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: PrimaryColors.p300,
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: NeutralColors.n800,
      selectedColor: PrimaryColors.p600,
      side: const BorderSide(color: NeutralColors.n700),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimentions.radiusFull),
      ),
      labelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: PrimaryColors.p400,
    ),
  );
}
