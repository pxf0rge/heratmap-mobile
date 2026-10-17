import 'package:flutter/material.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 12,
    this.radius = Dimentions.radius8,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: NeutralColors.n100,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class SkeletonPulse extends StatefulWidget {
  const SkeletonPulse({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.4,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: IgnorePointer(child: widget.child),
    );
  }
}

class FactoryListSkeleton extends StatelessWidget {
  const FactoryListSkeleton({super.key, this.items = 6, this.padding});

  final int items;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: ListView.separated(
        padding:
            padding ??
            const EdgeInsets.symmetric(
              horizontal: Dimentions.spaces16,
              vertical: Dimentions.spaces12,
            ),
        itemCount: items,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, __) => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimentions.spaces12,
            vertical: Dimentions.spaces10,
          ),
          decoration: BoxDecoration(
            color: NeutralColors.n50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              SkeletonBox(width: 42, height: 42, radius: 12),
              SizedBox(width: Dimentions.spaces12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 150, height: 14),
                    SizedBox(height: Dimentions.spaces6),
                    SkeletonBox(width: 210, height: 11),
                  ],
                ),
              ),
              SizedBox(width: Dimentions.spaces12),
              SkeletonBox(width: 48, height: 24, radius: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class PhaseGridSkeleton extends StatelessWidget {
  const PhaseGridSkeleton({super.key, this.items = 4});

  final int items;

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: GridView.builder(
        padding: const EdgeInsets.all(Dimentions.spaces16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: Dimentions.spaces12,
          mainAxisSpacing: Dimentions.spaces12,
          childAspectRatio: 0.85,
        ),
        itemCount: items,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: NeutralColors.n50,
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                child: ColoredBox(color: NeutralColors.n100),
              ),
              Padding(
                padding: const EdgeInsets.all(Dimentions.spaces12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(width: 70, height: 14),
                    SizedBox(height: Dimentions.spaces8),
                    SkeletonBox(width: 50, height: 11),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterChipsSkeleton extends StatelessWidget {
  const FilterChipsSkeleton({super.key, this.items = 4});

  final int items;

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: Row(
        children: [
          for (var i = 0; i < items; i++)
            Padding(
              padding: const EdgeInsets.only(right: Dimentions.spaces8),
              child: SkeletonBox(
                width: i == 0 ? 52 : 84,
                height: 30,
                radius: Dimentions.radiusFull,
              ),
            ),
        ],
      ),
    );
  }
}
