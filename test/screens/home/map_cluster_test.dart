import 'package:flutter_test/flutter_test.dart';
import 'package:heratmap/data/models/factory_model.dart';
import 'package:heratmap/screens/home/map/map_cluster.dart';
import 'package:latlong2/latlong.dart';

FactoryModel _factory({
  required String id,
  double? lat,
  double? lon,
  String name = 'شرکت',
}) => FactoryModel(
  id: id,
  name: name,
  category: 'برق و قدرت',
  phase: 'فاز 1',
  lat: lat ?? 0,
  lon: lon ?? 0,
  address: 'خیابان اول',
  phone: '',
  workStart: '',
  workEnd: '',
  lotNumber: '',
  isActive: true,
  description: '',
  image: '',
  websiteUrl: '',
);

/// تصویر ساده: ۱ درجه = ۱۰۰٬۰۰۰ پیکسل (مستقل از نقشه‌ی واقعی، برای تست).
/// با این مقیاس، ۰٫۰۰۰۱ درجه = ۱۰ پیکسل و ۰٫۰۱ درجه = ۱۰۰۰ پیکسل.
Offset _project(LatLng point) =>
    Offset(point.longitude * 100000, point.latitude * 100000);

void main() {
  test('ورودی خالی → خوشه‌ی خالی', () {
    expect(clusterFactories(factories: const [], project: _project), isEmpty);
  });

  test('شرکت‌های بدون مختصات معتبر نادیده گرفته می‌شوند', () {
    final clusters = clusterFactories(
      factories: [_factory(id: '1'), _factory(id: '2', lat: 0, lon: 0)],
      project: _project,
    );
    expect(clusters, isEmpty);
  });

  test('دو شرکت نزدیک در یک خوشه قرار می‌گیرند', () {
    final clusters = clusterFactories(
      factories: [
        _factory(id: '1', lat: 34.2000, lon: 62.2000),
        _factory(id: '2', lat: 34.2001, lon: 62.2001), // ~۳۰ پیکسل فاصله
      ],
      project: _project,
    );

    expect(clusters.length, 1);
    expect(clusters.single.count, 2);
    expect(clusters.single.isSingle, isFalse);
  });

  test('دو شرکت دور از هم دو خوشه می‌سازند', () {
    final clusters = clusterFactories(
      factories: [
        _factory(id: '1', lat: 34.1900, lon: 62.2000),
        _factory(id: '2', lat: 34.2100, lon: 62.2200),
      ],
      project: _project,
    );

    expect(clusters.length, 2);
    expect(clusters.every((c) => c.isSingle), isTrue);
  });

  test('مرکز خوشه، میانگین مختصات اعضاست', () {
    final clusters = clusterFactories(
      factories: [
        _factory(id: '1', lat: 34.2000, lon: 62.2000),
        _factory(id: '2', lat: 34.2002, lon: 62.2002),
      ],
      project: _project,
    );

    expect(clusters.single.center.latitude, closeTo(34.2001, 1e-9));
    expect(clusters.single.center.longitude, closeTo(62.2001, 1e-9));
  });

  test('هیچ شرکتی گم یا تکراری نمی‌شود', () {
    final factories = [
      for (var i = 0; i < 40; i++)
        _factory(
          id: '$i',
          lat: 34.20 + (i % 7) * 0.0006,
          lon: 62.20 + (i % 5) * 0.0007,
          name: 'شرکت $i',
        ),
    ];

    final clusters = clusterFactories(factories: factories, project: _project);

    final ids = [for (final c in clusters) for (final f in c.factories) f.id];
    expect(ids.length, factories.length);
    expect(ids.toSet().length, factories.length);
    expect(ids.toSet(), factories.map((f) => f.id).toSet());
  });

  test('با افزایش شعاع، تعداد خوشه‌ها کم می‌شود', () {
    final factories = [
      for (var i = 0; i < 12; i++)
        _factory(id: '$i', lat: 34.2000 + i * 0.0008, lon: 62.2000),
    ];

    final small = clusterFactories(
      factories: factories,
      project: _project,
      radiusPx: 20,
    );
    final large = clusterFactories(
      factories: factories,
      project: _project,
      radiusPx: 200,
    );

    expect(large.length, lessThan(small.length));
    expect(large.fold<int>(0, (sum, c) => sum + c.count), factories.length);
  });

  test('points فقط مختصات معتبر را برمی‌گرداند', () {
    final clusters = clusterFactories(
      factories: [
        _factory(id: '1', lat: 34.2000, lon: 62.2000),
        _factory(id: '2', lat: 34.2001, lon: 62.2001),
      ],
      project: _project,
    );

    expect(clusters.single.points.length, 2);
  });
}
