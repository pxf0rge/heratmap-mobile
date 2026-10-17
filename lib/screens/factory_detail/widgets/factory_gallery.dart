import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/core/locale_format.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';

/// گالری تصاویر شرکت.
///
/// - چند تصویر → کاروسل با شمارنده‌ی «۱ / ۳» و نقطه‌های نشانگر.
/// - لمس تصویر → نمایش تمام‌صفحه با بزرگ‌نمایی (pinch + دوبار لمس).
/// - بدون تصویر → جانشین با آیکن کارخانه (هیچ ناحیه‌ی خالی بی‌توضیح نمی‌ماند).
class FactoryGallery extends StatefulWidget {
  const FactoryGallery({super.key, required this.images});

  final List<String> images;

  @override
  State<FactoryGallery> createState() => _FactoryGalleryState();
}

class _FactoryGalleryState extends State<FactoryGallery> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    if (images.isEmpty) return const FactoryImagePlaceholder();

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemBuilder: (_, index) => GestureDetector(
            onTap: () => _openViewer(context, index),
            child: FactoryNetworkImage(url: images[index]),
          ),
        ),

        // نقطه‌های نشانگر پایین تصویر
        if (images.length > 1)
          Positioned(
            bottom: Dimentions.spaces12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < images.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(
                      horizontal: Dimentions.spaces4,
                    ),
                    width: _currentPage == i ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(
                        Dimentions.radiusFull,
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // شمارنده‌ی تصویر (بالا، سمت مخالف دکمه‌ی بازگشت) — زیر نوار وضعیت نه.
        // برای تک‌تصویر نمایش داده نمی‌شود («۱ / ۱» اطلاعاتی ندارد).
        if (images.length > 1)
          Positioned(
            top: 0,
            left: Dimentions.spaces12,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: Dimentions.spaces8),
                child: Semantics(
                  label: AppStrings.imageCounter.trParams({
                    'i': formatInteger(_currentPage + 1),
                    'n': formatInteger(images.length),
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimentions.spaces8,
                      vertical: Dimentions.spaces2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(
                        Dimentions.radiusFull,
                      ),
                    ),
                    child: Text(
                      '${formatInteger(_currentPage + 1)} / '
                      '${formatInteger(images.length)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _openViewer(BuildContext context, int index) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) =>
            FactoryImageViewer(images: widget.images, initialIndex: index),
      ),
    );
  }
}

/// نمایش تمام‌صفحه‌ی تصویر با بزرگ‌نمایی.
class FactoryImageViewer extends StatefulWidget {
  const FactoryImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  final List<String> images;
  final int initialIndex;

  @override
  State<FactoryImageViewer> createState() => _FactoryImageViewerState();
}

class _FactoryImageViewerState extends State<FactoryImageViewer> {
  late final PageController _pageController = PageController(
    initialPage: widget.initialIndex,
  );
  final TransformationController _transformation = TransformationController();
  late int _currentPage = widget.initialIndex;
  bool _zoomed = false;

  @override
  void dispose() {
    _pageController.dispose();
    _transformation.dispose();
    super.dispose();
  }

  /// دوبار لمس = بزرگ‌نمایی حول همان نقطه / بازگشت به حالت اول.
  void _toggleZoom(TapDownDetails details) {
    if (_zoomed) {
      _transformation.value = Matrix4.identity();
      setState(() => _zoomed = false);
      return;
    }

    const scale = 2.5;
    final position = details.localPosition;
    _transformation.value = Matrix4.identity()
      ..translateByDouble(
        -position.dx * (scale - 1),
        -position.dy * (scale - 1),
        0,
        1,
      )
      ..scaleByDouble(scale, scale, 1, 1);
    setState(() => _zoomed = true);
  }

  void _close() {
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        // لمس پس‌زمینه = بستن (فقط وقتی بزرگ‌نمایی فعال نیست)
        onTap: _zoomed ? null : _close,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              physics: _zoomed
                  ? const NeverScrollableScrollPhysics()
                  : const PageScrollPhysics(),
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                  _zoomed = false;
                  _transformation.value = Matrix4.identity();
                });
              },
              itemBuilder: (_, index) => GestureDetector(
                onDoubleTapDown: _toggleZoom,
                onDoubleTap: () {},
                child: InteractiveViewer(
                  transformationController: _transformation,
                  minScale: 1,
                  maxScale: 5,
                  child: Center(
                    child: FactoryNetworkImage(
                      url: widget.images[index],
                      fit: BoxFit.contain,
                      placeholderColor: Colors.black,
                    ),
                  ),
                ),
              ),
            ),

            // دکمه‌ی بستن — ناحیه‌ی لمس ۴۸dp
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: Semantics(
                  button: true,
                  label: AppStrings.cancel.tr,
                  child: SizedBox(
                    width: Dimentions.buttonHeight48,
                    height: Dimentions.buttonHeight48,
                    child: IconButton(
                      onPressed: _close,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (widget.images.length > 1)
              Positioned(
                bottom: Dimentions.spaces24,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '${formatInteger(_currentPage + 1)} / '
                    '${formatInteger(widget.images.length)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// تصویر شبکه با جانشین و حالت خطا.
class FactoryNetworkImage extends StatelessWidget {
  const FactoryNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.placeholderColor = PrimaryColors.p100,
  });

  final String url;
  final BoxFit fit;
  final Color placeholderColor;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => FactoryImagePlaceholder(color: placeholderColor),
      errorWidget: (_, __, ___) =>
          FactoryImagePlaceholder(color: placeholderColor),
    );
  }
}

/// جانشین تصویر — وقتی شرکتی عکس ندارد.
class FactoryImagePlaceholder extends StatelessWidget {
  const FactoryImagePlaceholder({super.key, this.color = PrimaryColors.p100});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: const Center(
        child: Icon(
          Icons.factory_rounded,
          color: PrimaryColors.p300,
          size: Dimentions.icon48,
        ),
      ),
    );
  }
}
