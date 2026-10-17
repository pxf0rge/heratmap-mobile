// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/Estedad-Black.ttf
  String get estedadBlack => 'assets/fonts/Estedad-Black.ttf';

  /// File path: assets/fonts/Estedad-Bold.ttf
  String get estedadBold => 'assets/fonts/Estedad-Bold.ttf';

  /// File path: assets/fonts/Estedad-ExtraBold.ttf
  String get estedadExtraBold => 'assets/fonts/Estedad-ExtraBold.ttf';

  /// File path: assets/fonts/Estedad-ExtraLight.ttf
  String get estedadExtraLight => 'assets/fonts/Estedad-ExtraLight.ttf';

  /// File path: assets/fonts/Estedad-Light.ttf
  String get estedadLight => 'assets/fonts/Estedad-Light.ttf';

  /// File path: assets/fonts/Estedad-Medium.ttf
  String get estedadMedium => 'assets/fonts/Estedad-Medium.ttf';

  /// File path: assets/fonts/Estedad-Regular.ttf
  String get estedadRegular => 'assets/fonts/Estedad-Regular.ttf';

  /// File path: assets/fonts/Estedad-SemiBold.ttf
  String get estedadSemiBold => 'assets/fonts/Estedad-SemiBold.ttf';

  /// File path: assets/fonts/Estedad-Thin.ttf
  String get estedadThin => 'assets/fonts/Estedad-Thin.ttf';

  /// List of all assets
  List<String> get values => [
    estedadBlack,
    estedadBold,
    estedadExtraBold,
    estedadExtraLight,
    estedadLight,
    estedadMedium,
    estedadRegular,
    estedadSemiBold,
    estedadThin,
  ];
}

class $AssetsImageGen {
  const $AssetsImageGen();

  /// File path: assets/image/logo.png
  AssetGenImage get logo => const AssetGenImage('assets/image/logo.png');

  /// List of all assets
  List<AssetGenImage> get values => [logo];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsImageGen image = $AssetsImageGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
