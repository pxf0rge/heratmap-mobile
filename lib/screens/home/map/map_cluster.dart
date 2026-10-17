import 'dart:ui' show Offset;

import 'package:heratmap/data/models/factory_model.dart';
import 'package:latlong2/latlong.dart';

/// یک خوشه‌ی پین روی نقشه: یک یا چند شرکت که در یک ناحیه‌ی کوچک جمع شده‌اند.
class MapCluster {
  const MapCluster({required this.factories, required this.center});

  final List<FactoryModel> factories;

  /// میانگین مختصات اعضا (مکان نمایش خوشه).
  final LatLng center;

  int get count => factories.length;

  bool get isSingle => factories.length == 1;

  FactoryModel get first => factories.first;

  /// مختصات معتبر اعضا — برای زوم‌کردن روی خوشه.
  List<LatLng> get points => [
    for (final factory in factories)
      if (factory.hasValidLocation) LatLng(factory.lat, factory.lon),
  ];

  @override
  String toString() => 'MapCluster($count @ ${center.latitude},${center.longitude})';
}

/// خوشه‌بندی حریصانه‌ی پین‌ها بر اساس **فاصله‌ی پیکسلی** روی صفحه.
///
/// به‌جای [MapCamera] یک تابع تصویرگیر (`project`) می‌گیرد تا خالص و تست‌پذیر بماند؛
/// ویجت نقشه این‌گونه صدا می‌زند:
/// ```dart
/// clusterFactories(
///   factories: factories,
///   project: (latLng) {
///     final p = camera.latLngToScreenPoint(latLng);
///     return Offset(p.x, p.y);
///   },
/// )
/// ```
///
/// الگوریتم: هر شرکت به اولین خوشه‌ای می‌چسبد که مرکز آن در فاصله‌ی [radiusPx]
/// قرار دارد؛ در غیر این صورت خوشه‌ی جدید می‌سازد. شرکت‌های بدون مختصات معتبر
/// نادیده گرفته می‌شوند. ترتیب ورودی حفظ می‌شود (نتیجه قطعی).
List<MapCluster> clusterFactories({
  required List<FactoryModel> factories,
  required Offset Function(LatLng point) project,
  double radiusPx = 56,
}) {
  final located = [
    for (final factory in factories)
      if (factory.hasValidLocation) factory,
  ];
  if (located.isEmpty) return const [];

  final buckets = <_Bucket>[];

  for (final factory in located) {
    final point = project(LatLng(factory.lat, factory.lon));

    _Bucket? target;
    for (final bucket in buckets) {
      if ((bucket.point - point).distance <= radiusPx) {
        target = bucket;
        break;
      }
    }

    if (target == null) {
      buckets.add(_Bucket(first: factory, point: point));
    } else {
      target.add(factory, point);
    }
  }

  return [
    for (final bucket in buckets)
      MapCluster(factories: bucket.factories, center: bucket.center),
  ];
}

/// خوشه در حال ساخت: مرکز پیکسلی متحرک + میانگین مختصات.
class _Bucket {
  _Bucket({required FactoryModel first, required this.point})
    : factories = [first],
      _latSum = first.lat,
      _lonSum = first.lon;

  final List<FactoryModel> factories;
  Offset point;

  double _latSum;
  double _lonSum;

  LatLng get center => LatLng(_latSum / factories.length, _lonSum / factories.length);

  void add(FactoryModel factory, Offset factoryPoint) {
    final previousCount = factories.length;
    factories.add(factory);
    _latSum += factory.lat;
    _lonSum += factory.lon;

    point = Offset(
      (point.dx * previousCount + factoryPoint.dx) / factories.length,
      (point.dy * previousCount + factoryPoint.dy) / factories.length,
    );
  }
}
