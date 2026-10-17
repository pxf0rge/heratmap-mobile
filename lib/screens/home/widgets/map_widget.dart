import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Path;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:get/get.dart';
import 'package:heratmap/core/locale_format.dart';
import 'package:heratmap/data/models/factory_model.dart';
import 'package:heratmap/data/models/phase_model.dart';
import 'package:heratmap/data/models/poi_model.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/screens/home/controller/home_controller.dart';
import 'package:heratmap/screens/home/map/map_cluster.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:latlong2/latlong.dart';

const _storeName = 'heratMap';

// OpenStreetMap — free, no API key, reliable
const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// شعاع خوشه‌بندی به پیکسل؛ کمی بیشتر از عرض پین تا پین‌ها روی هم نیفتند.
const double _clusterRadiusPx = 62;

/// حاشیه‌ای که نوار بالا و شیت پایین روی نقشه می‌پوشانند (برای fit کردن دوربین).
const EdgeInsets _fitPadding = EdgeInsets.fromLTRB(48, 150, 48, 210);

// ── Custom pin icon ───────────────────────────────────────────────────────────

Future<ui.Image> _buildPinImage({
  IconData icon = Icons.factory_outlined,
  Color bgColor = PrimaryColors.primary,
  Color iconColor = Colors.white,
  double pinWidth = 56,
  double pinHeight = 64,
  double tailHeight = 14,
  double cornerRadius = 12,
  double iconSize = 28,
  double scale = 2.0,
}) async {
  final rectH = pinHeight - tailHeight;
  final w = pinWidth * scale;
  final h = pinHeight * scale;
  final rh = rectH * scale;
  final th = tailHeight * scale;
  final r = cornerRadius * scale;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w, h));

  final paint = Paint()
    ..color = bgColor
    ..style = PaintingStyle.fill;

  // Rounded rect body
  canvas.drawRRect(
    RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, rh), Radius.circular(r)),
    paint,
  );

  // Triangle tail — use ui.Path explicitly to avoid flutter_map's Path type
  final tail = ui.Path()
    ..moveTo(w / 2 - th * 0.8, rh)
    ..lineTo(w / 2 + th * 0.8, rh)
    ..lineTo(w / 2, h)
    ..close();
  canvas.drawPath(tail, paint);

  // Icon glyph
  final fontSize = iconSize * scale;
  final pb =
      ui.ParagraphBuilder(
          ui.ParagraphStyle(fontFamily: icon.fontFamily, fontSize: fontSize),
        )
        ..pushStyle(
          ui.TextStyle(
            color: iconColor,
            fontSize: fontSize,
            fontFamily: icon.fontFamily,
          ),
        )
        ..addText(String.fromCharCode(icon.codePoint));

  final para = pb.build()..layout(ui.ParagraphConstraints(width: w));
  canvas.drawParagraph(
    para,
    Offset((w - para.longestLine) / 2, (rh - para.height) / 2),
  );

  return recorder.endRecording().toImage(w.toInt(), h.toInt());
}

// ── Widget ────────────────────────────────────────────────────────────────────

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final HomeController _ctrl = Get.find<HomeController>();

  // Build FMTCTileProvider once — avoid rebuilding on every frame
  final _tileProvider = FMTCTileProvider(
    stores: const {_storeName: BrowseStoreStrategy.readUpdateCreate},
  );

  ui.Image? _pinImage;
  ui.Image? _selectedPinImage;
  Worker? _factoriesWorker;
  bool _didInitialFit = false;

  @override
  void initState() {
    super.initState();
    _loadPinImages();
    _factoriesWorker = ever(_ctrl.factories, (_) => _fitToDataOnce());
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitToDataOnce());
  }

  @override
  void dispose() {
    _factoriesWorker?.dispose();
    _tileProvider.dispose();
    // MapController در اختیار HomeController است و آنجا dispose می‌شود
    super.dispose();
  }

  Future<void> _loadPinImages() async {
    final normal = await _buildPinImage();
    final selected = await _buildPinImage(
      bgColor: SecondaryColors.primary,
      iconColor: PrimaryColors.p900,
    );
    if (!mounted) return;
    setState(() {
      _pinImage = normal;
      _selectedPinImage = selected;
    });
  }

  /// اولین باری که داده می‌رسد، دوربین روی محدوده‌ی شرکت‌ها تنظیم می‌شود.
  void _fitToDataOnce() {
    if (_didInitialFit || !mounted) return;
    if (_ctrl.locatedFactories.isEmpty) return;

    try {
      _ctrl.mapController.fitCamera(
        CameraFit.bounds(
          bounds: _ctrl.dataBounds,
          padding: _fitPadding,
          maxZoom: 17,
        ),
      );
      _didInitialFit = true;
    } catch (_) {
      // نقشه هنوز آماده نیست؛ بار بعد (onMapReady یا رسیدن داده) تلاش می‌شود
    }
  }

  void _onMarkerTap(FactoryModel factory) {
    _ctrl.selectFactory(factory);
    if (_ctrl.sheetController.isAttached) {
      _ctrl.sheetController.animateTo(
        0.42,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// زوم روی خوشه تا پین‌های تشکیل‌دهنده‌اش جدا شوند.
  void _zoomIntoCluster(MapCluster cluster) {
    final points = cluster.points;
    if (points.isEmpty) return;

    var currentZoom = HomeController.initialZoom;
    try {
      currentZoom = _ctrl.mapController.camera.zoom;
    } catch (_) {}

    try {
      _ctrl.mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(72),
          maxZoom: 18,
          minZoom: currentZoom + 1,
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final factories = _ctrl.factories;
      final userLocation = _ctrl.userLocation.value;
      final selectedId = _ctrl.selectedFactory.value?.id;
      final phases = _ctrl.phases;
      final pois = _ctrl.pois;

      return FlutterMap(
        mapController: _ctrl.mapController,
        options: MapOptions(
          initialCenter: _ctrl.initialCenter,
          initialZoom: HomeController.initialZoom,
          minZoom: 13.5,
          maxZoom: 19,
          // محدوده از داده مشتق می‌شود (و همیشه کل شهرک را هم در بر می‌گیرد)
          cameraConstraint: CameraConstraint.containCenter(
            bounds: _ctrl.cameraBounds,
          ),
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
          onTap: (_, __) => _ctrl.clearSelection(),
          onMapReady: _fitToDataOnce,
        ),
        children: [
          // Tiles — cached by FMTC after first online load
          TileLayer(
            urlTemplate: _tileUrl,
            retinaMode: RetinaMode.isHighDensity(context),
            userAgentPackageName: 'com.example.heratmap',
            tileProvider: _tileProvider,
          ),

          // Phase boundaries (polygons + centroid labels)
          PolygonLayer(
            polygons: _buildPhasePolygons(phases),
          ),
          MarkerLayer(
            markers: _buildPhaseLabelMarkers(phases),
          ),

          // POI markers
          MarkerLayer(
            markers: _buildPoiMarkers(pois),
          ),

          // خوشه‌بندی داخل Builder انجام می‌شود چون به دوربین فعلی نیاز دارد
          Builder(
            builder: (context) {
              final camera = MapCamera.of(context);
              final clusters = clusterFactories(
                factories: factories,
                radiusPx: _clusterRadiusPx,
                project: (latLng) {
                  final screen = camera.latLngToScreenPoint(latLng);
                  return Offset(screen.x, screen.y);
                },
              );

              return MarkerLayer(
                markers: [
                  if (userLocation != null) _userMarker(userLocation),
                  for (final cluster in clusters)
                    _clusterMarker(cluster, selectedId: selectedId),
                ],
              );
            },
          ),
        ],
      );
    });
  }

  List<LatLng> _boundaryPoints(List<List<double>> boundary) {
    return [for (final c in boundary) if (c.length >= 2) LatLng(c[0], c[1])];
  }

  List<Polygon> _buildPhasePolygons(List<PhaseModel> phases) {
    final colors = [
      PrimaryColors.primary,
      SecondaryColors.primary,
      const Color(0xFFFCC419),
      const Color(0xFF7950F2),
      const Color(0xFFFA5252),
      const Color(0xFF20C997),
    ];
    final polygons = <Polygon>[];
    for (var i = 0; i < phases.length; i++) {
      final points = _boundaryPoints(phases[i].boundary);
      if (points.length < 3) continue;
      final color = colors[i % colors.length];
      polygons.add(Polygon(
        points: points,
        color: color.withValues(alpha: 0.22),
        borderColor: color,
        borderStrokeWidth: 2.5,
      ));
    }
    return polygons;
  }

  List<Marker> _buildPhaseLabelMarkers(List<PhaseModel> phases) {
    final colors = [
      PrimaryColors.primary,
      SecondaryColors.primary,
      const Color(0xFFFCC419),
      const Color(0xFF7950F2),
      const Color(0xFFFA5252),
      const Color(0xFF20C997),
    ];
    final markers = <Marker>[];
    for (var i = 0; i < phases.length; i++) {
      final phase = phases[i];
      final points = _boundaryPoints(phase.boundary);
      if (points.length < 3) continue;
      final bounds = LatLngBounds.fromPoints(points);
      final center = bounds.center;
      final color = colors[i % colors.length];
      markers.add(Marker(
        point: center,
        width: 36,
        height: 36,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '${phase.number}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ));
    }
    return markers;
  }

  List<Marker> _buildPoiMarkers(List<PoiModel> pois) {
    return pois.where((p) => p.hasValidLocation).map((poi) {
      return Marker(
        point: LatLng(poi.lat, poi.lon),
        width: 32,
        height: 32,
        child: Tooltip(
          message: poi.name,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: SecondaryColors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(
              Icons.location_on,
              color: SecondaryColors.primary,
              size: 18,
            ),
          ),
        ),
      );
    }).toList();
  }

  Marker _userMarker(LatLng location) => Marker(
    point: location,
    width: 40,
    height: 40,
    child: Container(
      decoration: BoxDecoration(
        color: PrimaryColors.p500,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: PrimaryColors.primary.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.person_pin_circle_rounded,
        color: Colors.white,
        size: 20,
      ),
    ),
  );

  Marker _clusterMarker(MapCluster cluster, {String? selectedId}) {
    if (cluster.isSingle) {
      final factory = cluster.first;
      final isSelected = selectedId != null && selectedId == factory.id;
      final image = isSelected ? _selectedPinImage : _pinImage;

      return Marker(
        point: LatLng(factory.lat, factory.lon),
        width: factory.lotNumber.isNotEmpty ? 80 : 56,
        height: factory.lotNumber.isNotEmpty ? 80 : 64,
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () => _onMarkerTap(factory),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (factory.lotNumber.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? SecondaryColors.primary : PrimaryColors.p300,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: Text(
                    factory.lotNumber,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? SecondaryColors.primary : PrimaryColors.p700,
                    ),
                  ),
                ),
              if (factory.lotNumber.isNotEmpty) const SizedBox(height: 2),
              image != null
                  ? RawImage(
                      image: image,
                      width: 56,
                      height: 64,
                      fit: BoxFit.fill,
                    )
                  : Icon(
                      Icons.location_on,
                      color: isSelected
                          ? SecondaryColors.primary
                          : PrimaryColors.primary,
                      size: 40,
                    ),
            ],
          ),
        ),
      );
    }

    final size = _clusterSize(cluster.count);

    return Marker(
      point: cluster.center,
      width: size,
      height: size,
      child: GestureDetector(
        onTap: () => _zoomIntoCluster(cluster),
        child: Semantics(
          button: true,
          label: '${cluster.count} ${AppStrings.companies.tr}',
          child: Container(
            decoration: BoxDecoration(
              color: PrimaryColors.primary.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              formatInteger(cluster.count),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: size >= 56 ? 16 : 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _clusterSize(int count) {
    if (count < 10) return 42;
    if (count < 100) return 50;
    return 58;
  }
}
