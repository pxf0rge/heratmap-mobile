part of 'app_theme.dart';

class InputdecorationTheme {
  static InputDecorationTheme get lightInputdecoration => InputDecorationTheme(
        filled: true,
        fillColor: NeutralColors.n100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimentions.spaces16,
          vertical: Dimentions.spaces14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimentions.radius14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimentions.radius14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimentions.radius14),
          borderSide: const BorderSide(color: PrimaryColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimentions.radius14),
          borderSide: const BorderSide(color: StatusColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimentions.radius14),
          borderSide: const BorderSide(color: StatusColors.red, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          color: NeutralColors.n400,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          color: OtherColors.textgreyLightColor,
        ),
      );

  static InputDecorationTheme get darkInputdecoration => InputDecorationTheme(
        filled: true,
        fillColor: NeutralColors.n800,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimentions.spaces16,
          vertical: Dimentions.spaces14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimentions.radius14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimentions.radius14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimentions.radius14),
          borderSide: const BorderSide(color: PrimaryColors.p400, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimentions.radius14),
          borderSide: const BorderSide(color: StatusColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimentions.radius14),
          borderSide: const BorderSide(color: StatusColors.red, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          color: NeutralColors.n500,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          color: NeutralColors.n500,
        ),
      );
}
